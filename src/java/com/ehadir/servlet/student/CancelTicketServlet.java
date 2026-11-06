package com.ehadir.servlet.student;

import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/student/cancelTicketServlet")
public class CancelTicketServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/student/myTicketsServlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object u = request.getSession().getAttribute("user");
        if (!(u instanceof User) || !"student".equals(((User) u).getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        User user = (User) u;
        String ctx = request.getContextPath();

        int regId;
        try {
            regId = Integer.parseInt(request.getParameter("regId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/student/myTicketsServlet?error=invalid");
            return;
        }

        String result;
        try {
            result = cancel(user.getUserId(), regId);
        } catch (SQLException e) {
            getServletContext().log("Cancel ticket database error", e);
            result = "system";
        }

        if (result.equals("canceled")) {
            response.sendRedirect(ctx + "/student/myTicketsServlet?msg=canceled");
        } else {
            response.sendRedirect(ctx + "/student/myTicketsServlet?error=" + result);
        }
    }

    private String cancel(int userId, int regId) throws SQLException {
        Connection con = DBConnection.getConnection();
        try {
            con.setAutoCommit(false);

            int eventId;
            String attendance;
            Timestamp eventDate;
            // Hanya tiket milik student ini
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT r.event_id, r.attendance_status, e.event_date "
                  + "FROM registrations r JOIN events e ON e.event_id = r.event_id "
                  + "WHERE r.reg_id = ? AND r.user_id = ?")) {
                ps.setInt(1, regId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return "notfound";
                    }
                    eventId = rs.getInt("event_id");
                    attendance = rs.getString("attendance_status");
                    eventDate = rs.getTimestamp("event_date");
                }
            }

            if (!"pending".equals(attendance)) {
                con.rollback();
                return "notpending";
            }
            if (eventDate.before(new Timestamp(System.currentTimeMillis()))) {
                con.rollback();
                return "ended";
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM registrations WHERE reg_id = ? AND user_id = ?")) {
                ps.setInt(1, regId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            // Kalau event penuh dan kini ada tempat kosong, buka semula
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE events SET status = 'open' WHERE event_id = ? AND status = 'full' "
                  + "AND capacity > (SELECT COUNT(*) FROM registrations WHERE event_id = ?)")) {
                ps.setInt(1, eventId);
                ps.setInt(2, eventId);
                ps.executeUpdate();
            }

            con.commit();
            return "canceled";
        } catch (SQLException e) {
            con.rollback();
            throw e;
        } finally {
            con.close();
        }
    }
}