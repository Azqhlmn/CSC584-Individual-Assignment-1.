package com.ehadir.servlet.committee;

import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/committee/committeeDashboardServlet")
public class CommitteeDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object u = request.getSession().getAttribute("user");
        if (!(u instanceof User) || !"committee".equals(((User) u).getRole())
                || ((User) u).getClubId() == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int clubId = ((User) u).getClubId().intValue();
        Timestamp now = new Timestamp(System.currentTimeMillis());

        int myEvents = 0;
        int regTotal = 0;
        int seatsLeft = 0;
        List<String> labels = new ArrayList<String>();
        List<Integer> registeredList = new ArrayList<Integer>();
        List<Integer> capacityList = new ArrayList<Integer>();
        int attended = 0;
        int absent = 0;
        int pending = 0;

        String eventSql = "SELECT e.title, e.capacity, e.status, e.event_date, "
                        + "(SELECT COUNT(*) FROM registrations r WHERE r.event_id = e.event_id) AS registered "
                        + "FROM events e WHERE e.club_id = ? ORDER BY e.event_date";
        String attSql = "SELECT r.attendance_status, COUNT(*) FROM registrations r "
                      + "JOIN events e ON e.event_id = r.event_id "
                      + "WHERE e.club_id = ? GROUP BY r.attendance_status";

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(eventSql)) {
                ps.setInt(1, clubId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int capacity = rs.getInt("capacity");
                        int registered = rs.getInt("registered");
                        String status = rs.getString("status");
                        myEvents++;
                        regTotal += registered;
                        if (!"canceled".equals(status)) {
                            labels.add(rs.getString("title"));
                            registeredList.add(Integer.valueOf(registered));
                            capacityList.add(Integer.valueOf(capacity));
                        }
                        // Tempat kosong: event open yang belum bermula
                        if ("open".equals(status) && rs.getTimestamp("event_date").after(now)) {
                            seatsLeft += Math.max(0, capacity - registered);
                        }
                    }
                }
            }
            try (PreparedStatement ps = con.prepareStatement(attSql)) {
                ps.setInt(1, clubId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String st = rs.getString(1);
                        int n = rs.getInt(2);
                        if ("attended".equals(st)) {
                            attended = n;
                        } else if ("absent".equals(st)) {
                            absent = n;
                        } else {
                            pending = n;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            getServletContext().log("CommitteeDashboardServlet database error", e);
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=system");
            return;
        }

        // Kadar kehadiran: daripada pelajar yang dah ditanda (attended + absent)
        int marked = attended + absent;
        String rate = marked == 0 ? "N/A" : (attended * 100 / marked) + "%";

        request.setAttribute("myEvents", Integer.valueOf(myEvents));
        request.setAttribute("regTotal", Integer.valueOf(regTotal));
        request.setAttribute("attendanceRate", rate);
        request.setAttribute("seatsLeft", Integer.valueOf(seatsLeft));
        request.setAttribute("chartLabels", labels);
        request.setAttribute("chartRegistered", registeredList);
        request.setAttribute("chartCapacity", capacityList);
        request.setAttribute("attAttended", Integer.valueOf(attended));
        request.setAttribute("attAbsent", Integer.valueOf(absent));
        request.setAttribute("attPending", Integer.valueOf(pending));

        request.getRequestDispatcher("/committee/committeeDashboard.jsp").forward(request, response);
    }
}