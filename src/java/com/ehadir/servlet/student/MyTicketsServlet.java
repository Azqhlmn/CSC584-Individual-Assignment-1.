package com.ehadir.servlet.student;

import com.ehadir.bean.Registration;
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

@WebServlet("/student/myTicketsServlet")
public class MyTicketsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object u = request.getSession().getAttribute("user");
        if (!(u instanceof User) || !"student".equals(((User) u).getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        User user = (User) u;

        String sql = "SELECT r.reg_id, r.event_id, r.ticket_code, r.reg_date, r.attendance_status, "
                   + "e.title, e.venue, e.event_date, c.club_name "
                   + "FROM registrations r "
                   + "JOIN events e ON e.event_id = r.event_id "
                   + "JOIN clubs c ON c.club_id = e.club_id "
                   + "WHERE r.user_id = ? "
                   + "ORDER BY e.event_date DESC";

        Timestamp now = new Timestamp(System.currentTimeMillis());
        List<Registration> tickets = new ArrayList<Registration>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, user.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration r = new Registration();
                    r.setRegId(rs.getInt("reg_id"));
                    r.setEventId(rs.getInt("event_id"));
                    r.setTicketCode(rs.getString("ticket_code"));
                    r.setRegDate(rs.getTimestamp("reg_date"));
                    r.setAttendanceStatus(rs.getString("attendance_status"));
                    r.setEventTitle(rs.getString("title"));
                    r.setVenue(rs.getString("venue"));
                    r.setEventDate(rs.getTimestamp("event_date"));
                    r.setClubName(rs.getString("club_name"));
                    // Boleh batal kalau belum hadir dan event belum bermula
                    r.setCanCancel("pending".equals(r.getAttendanceStatus())
                            && r.getEventDate().after(now));
                    tickets.add(r);
                }
            }
        } catch (SQLException ex) {
            getServletContext().log("MyTicketsServlet database error", ex);
            response.sendRedirect(request.getContextPath() + "/student/studentDashboard.jsp");
            return;
        }

        request.setAttribute("tickets", tickets);
        request.getRequestDispatcher("/student/myTickets.jsp").forward(request, response);
    }
}