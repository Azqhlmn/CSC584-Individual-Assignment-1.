package com.ehadir.servlet.committee;

import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/committee/updateAttendanceServlet")
public class UpdateAttendanceServlet extends HttpServlet {

    // Pastikan event milik kelab committee ini
    private static final String OWN_EVENT =
        " AND event_id = ? AND event_id IN (SELECT event_id FROM events WHERE club_id = ?)";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/committee/attendance.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object u = request.getSession().getAttribute("user");
        if (!(u instanceof User) || !"committee".equals(((User) u).getRole())
                || ((User) u).getClubId() == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        User user = (User) u;
        String ctx = request.getContextPath();

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("eventId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/committee/attendance.jsp?error=invalid");
            return;
        }

        String ticketCode = request.getParameter("ticketCode");
        ticketCode = ticketCode == null ? "" : ticketCode.trim().toUpperCase();

        String sql;
        String status;
        String key;
        String successMsg;
        if (!ticketCode.isEmpty()) {
            // Check-in guna kod tiket
            sql = "UPDATE registrations SET attendance_status = ? WHERE ticket_code = ?" + OWN_EVENT;
            status = "attended";
            key = ticketCode;
            successMsg = "checkedin";
        } else {
            status = request.getParameter("status");
            if (!"attended".equals(status) && !"absent".equals(status) && !"pending".equals(status)) {
                response.sendRedirect(ctx + "/committee/attendance.jsp?eventId=" + eventId + "&error=invalid");
                return;
            }
            sql = "UPDATE registrations SET attendance_status = ? WHERE reg_id = ?" + OWN_EVENT;
            key = request.getParameter("regId");
            successMsg = "updated";
        }

        int updated;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            if (!ticketCode.isEmpty()) {
                ps.setString(2, key);
            } else {
                try {
                    ps.setInt(2, Integer.parseInt(key));
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/committee/attendance.jsp?eventId=" + eventId + "&error=invalid");
                    return;
                }
            }
            ps.setInt(3, eventId);
            ps.setInt(4, user.getClubId().intValue());
            updated = ps.executeUpdate();
        } catch (SQLException e) {
            getServletContext().log("Update attendance database error", e);
            response.sendRedirect(ctx + "/committee/attendance.jsp?eventId=" + eventId + "&error=system");
            return;
        }

        if (updated == 0) {
            response.sendRedirect(ctx + "/committee/attendance.jsp?eventId=" + eventId + "&error=notfound");
        } else {
            response.sendRedirect(ctx + "/committee/attendance.jsp?eventId=" + eventId + "&msg=" + successMsg);
        }
    }
}