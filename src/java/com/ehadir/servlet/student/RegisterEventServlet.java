package com.ehadir.servlet.student;

import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/student/registerEventServlet")
public class RegisterEventServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/student/eventList.jsp");
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

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("eventId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/student/eventList.jsp?error=invalid");
            return;
        }

        String result;
        try {
            result = register(user.getUserId(), eventId);
        } catch (SQLException e) {
            getServletContext().log("Register event database error", e);
            result = "system";
        }

        if (result.equals("registered")) {
            response.sendRedirect(ctx + "/student/myTicketsServlet?msg=registered");
        } else {
            response.sendRedirect(ctx + "/student/eventList.jsp?error=" + result);
        }
    }

    // Pulangkan "registered" kalau berjaya, atau kod ralat
    private String register(int userId, int eventId) throws SQLException {
        Connection con = DBConnection.getConnection();
        try {
            con.setAutoCommit(false);

            // Kunci baris event supaya dua student tak boleh ambil tempat terakhir serentak
            try (PreparedStatement lock = con.prepareStatement(
                    "UPDATE events SET status = status WHERE event_id = ?")) {
                lock.setInt(1, eventId);
                if (lock.executeUpdate() == 0) {
                    con.rollback();
                    return "notfound";
                }
            }

            String status;
            int capacity;
            Timestamp eventDate;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT status, capacity, event_date FROM events WHERE event_id = ?")) {
                ps.setInt(1, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    status = rs.getString("status");
                    capacity = rs.getInt("capacity");
                    eventDate = rs.getTimestamp("event_date");
                }
            }

            if ("canceled".equals(status)) {
                con.rollback();
                return "canceled";
            }
            if (eventDate.before(new Timestamp(System.currentTimeMillis()))) {
                con.rollback();
                return "ended";
            }
            if ("full".equals(status)) {
                con.rollback();
                return "full";
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT 1 FROM registrations WHERE event_id = ? AND user_id = ?")) {
                ps.setInt(1, eventId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        con.rollback();
                        return "already";
                    }
                }
            }

            int count;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM registrations WHERE event_id = ?")) {
                ps.setInt(1, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    count = rs.getInt(1);
                }
            }
            if (count >= capacity) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE events SET status = 'full' WHERE event_id = ?")) {
                    ps.setInt(1, eventId);
                    ps.executeUpdate();
                }
                con.commit();
                return "full";
            }

            // Simpan dengan kod sementara, kemudian tukar kepada EH-tahun-nombor
            int regId;
            String tempCode = UUID.randomUUID().toString().substring(0, 18);
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO registrations (event_id, user_id, ticket_code) VALUES (?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, eventId);
                ps.setInt(2, userId);
                ps.setString(3, tempCode);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    regId = keys.getInt(1);
                }
            }
            String ticketCode = String.format("EH-%d-%05d",
                    Calendar.getInstance().get(Calendar.YEAR), regId);
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE registrations SET ticket_code = ? WHERE reg_id = ?")) {
                ps.setString(1, ticketCode);
                ps.setInt(2, regId);
                ps.executeUpdate();
            }

            // Tempat terakhir diambil: tandakan penuh
            if (count + 1 >= capacity) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE events SET status = 'full' WHERE event_id = ?")) {
                    ps.setInt(1, eventId);
                    ps.executeUpdate();
                }
            }

            con.commit();
            return "registered";
        } catch (SQLException e) {
            con.rollback();
            throw e;
        } finally {
            con.close();
        }
    }
}