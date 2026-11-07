package com.ehadir.servlet.committee;

import com.ehadir.bean.Event;
import com.ehadir.bean.Registration;
import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;

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

@WebServlet("/committee/attendanceServlet")
public class AttendanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object u = request.getSession().getAttribute("user");
        if (!(u instanceof User) || !"committee".equals(((User) u).getRole())
                || ((User) u).getClubId() == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        User user = (User) u;

        int eventId = 0;
        String param = request.getParameter("eventId");
        if (param != null) {
            try {
                eventId = Integer.parseInt(param);
            } catch (NumberFormatException e) {
                eventId = 0;
            }
        }

        List<Event> clubEvents = new ArrayList<Event>();
        List<Registration> registrations = new ArrayList<Registration>();
        Event selected = null;

        try (Connection con = DBConnection.getConnection()) {
            // Senarai event kelab ini (untuk dropdown)
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT event_id, title, event_date FROM events WHERE club_id = ? "
                  + "ORDER BY event_date DESC")) {
                ps.setInt(1, user.getClubId().intValue());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Event e = new Event();
                        e.setEventId(rs.getInt("event_id"));
                        e.setTitle(rs.getString("title"));
                        e.setEventDate(rs.getTimestamp("event_date"));
                        clubEvents.add(e);
                        if (e.getEventId() == eventId) {
                            selected = e;
                        }
                    }
                }
            }

            // Senarai pendaftar bagi event yang dipilih
            if (selected != null) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT r.reg_id, r.ticket_code, r.attendance_status, u.name, u.student_id "
                      + "FROM registrations r JOIN users u ON u.user_id = r.user_id "
                      + "WHERE r.event_id = ? ORDER BY r.reg_id")) {
                    ps.setInt(1, eventId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Registration r = new Registration();
                            r.setRegId(rs.getInt("reg_id"));
                            r.setTicketCode(rs.getString("ticket_code"));
                            r.setAttendanceStatus(rs.getString("attendance_status"));
                            r.setStudentName(rs.getString("name"));
                            r.setStudentId(rs.getString("student_id"));
                            registrations.add(r);
                        }
                    }
                }
            }
        } catch (SQLException ex) {
            getServletContext().log("AttendanceServlet database error", ex);
            response.sendRedirect(request.getContextPath() + "/committee/committeeDashboard.jsp");
            return;
        }

        request.setAttribute("clubEvents", clubEvents);
        request.setAttribute("selectedEvent", selected);
        request.setAttribute("registrations", registrations);
        request.getRequestDispatcher("/committee/attendance.jsp").forward(request, response);
    }
}