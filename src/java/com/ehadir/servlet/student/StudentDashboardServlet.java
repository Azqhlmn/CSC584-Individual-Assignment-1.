package com.ehadir.servlet.student;

import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;
import com.ehadir.util.DbUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/student/studentDashboardServlet")
public class StudentDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object u = request.getSession().getAttribute("user");
        if (!(u instanceof User) || !"student".equals(((User) u).getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        Integer userId = Integer.valueOf(((User) u).getUserId());

        try (Connection con = DBConnection.getConnection()) {
            int tickets = DbUtil.count(con,
                    "SELECT COUNT(*) FROM registrations WHERE user_id = ?", userId);
            int upcoming = DbUtil.count(con,
                    "SELECT COUNT(*) FROM events WHERE status <> 'canceled' AND event_date > ?",
                    new Timestamp(System.currentTimeMillis()));
            int attended = DbUtil.count(con,
                    "SELECT COUNT(*) FROM registrations WHERE user_id = ? AND attendance_status = 'attended'",
                    userId);

            request.setAttribute("tickets", Integer.valueOf(tickets));
            request.setAttribute("upcoming", Integer.valueOf(upcoming));
            request.setAttribute("attended", Integer.valueOf(attended));
        } catch (SQLException e) {
            getServletContext().log("StudentDashboardServlet database error", e);
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=system");
            return;
        }

        request.getRequestDispatcher("/student/studentDashboard.jsp").forward(request, response);
    }
}