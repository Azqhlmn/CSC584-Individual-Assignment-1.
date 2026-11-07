package com.ehadir.servlet.admin;

import com.ehadir.util.DBConnection;
import com.ehadir.util.DbUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin/adminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!"admin".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<String> clubLabels = new ArrayList<String>();
        List<Integer> clubRegs = new ArrayList<Integer>();
        int open = 0;
        int full = 0;
        int canceled = 0;
        int totalEvents;
        int regTotal;
        int students;

        String clubSql = "SELECT c.club_name, COUNT(r.reg_id) AS total "
                       + "FROM clubs c "
                       + "LEFT JOIN events e ON e.club_id = c.club_id "
                       + "LEFT JOIN registrations r ON r.event_id = e.event_id "
                       + "GROUP BY c.club_id, c.club_name ORDER BY c.club_name";

        try (Connection con = DBConnection.getConnection()) {
            totalEvents = DbUtil.count(con, "SELECT COUNT(*) FROM events");
            regTotal = DbUtil.count(con, "SELECT COUNT(*) FROM registrations");
            students = DbUtil.count(con, "SELECT COUNT(*) FROM users WHERE user_role = 'student'");

            try (PreparedStatement ps = con.prepareStatement(clubSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    clubLabels.add(rs.getString("club_name"));
                    clubRegs.add(Integer.valueOf(rs.getInt("total")));
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT status, COUNT(*) FROM events GROUP BY status");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String st = rs.getString(1);
                    int n = rs.getInt(2);
                    if ("open".equals(st)) {
                        open = n;
                    } else if ("full".equals(st)) {
                        full = n;
                    } else if ("canceled".equals(st)) {
                        canceled = n;
                    }
                }
            }
        } catch (SQLException e) {
            getServletContext().log("AdminDashboardServlet database error", e);
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=system");
            return;
        }

        request.setAttribute("totalEvents", Integer.valueOf(totalEvents));
        request.setAttribute("canceledEvents", Integer.valueOf(canceled));
        request.setAttribute("regTotal", Integer.valueOf(regTotal));
        request.setAttribute("students", Integer.valueOf(students));
        request.setAttribute("clubLabels", clubLabels);
        request.setAttribute("clubRegs", clubRegs);
        request.setAttribute("evOpen", Integer.valueOf(open));
        request.setAttribute("evFull", Integer.valueOf(full));
        request.setAttribute("evCanceled", Integer.valueOf(canceled));

        request.getRequestDispatcher("/admin/adminDashboard.jsp").forward(request, response);
    }
}