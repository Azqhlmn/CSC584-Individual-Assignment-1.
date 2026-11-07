package com.ehadir.servlet.committee;

import com.ehadir.bean.Event;
import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;
import com.ehadir.util.DateUtil;
import com.ehadir.util.LookupUtil;

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

@WebServlet("/committee/updateEventServlet")
public class UpdateEventServlet extends HttpServlet {

    private User committee(HttpServletRequest request) {
        Object u = request.getSession().getAttribute("user");
        if (u instanceof User) {
            User user = (User) u;
            if ("committee".equals(user.getRole()) && user.getClubId() != null) {
                return user;
            }
        }
        return null;
    }

    // Muat event yang nak diedit (hanya event kelab sendiri)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = committee(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        String ctx = request.getContextPath();

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("eventId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/committee/manageEvents.jsp?error=notfound");
            return;
        }

        String sql = "SELECT e.event_id, e.category_id, e.title, e.description, e.venue, e.event_date, "
                   + "e.capacity, e.status, "
                   + "(SELECT COUNT(*) FROM registrations r WHERE r.event_id = e.event_id) AS registered "
                   + "FROM events e WHERE e.event_id = ? AND e.club_id = ?";

        Event ev = null;
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, eventId);
                ps.setInt(2, user.getClubId().intValue());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ev = new Event();
                        ev.setEventId(rs.getInt("event_id"));
                        ev.setCategoryId(rs.getInt("category_id"));
                        ev.setTitle(rs.getString("title"));
                        ev.setDescription(rs.getString("description"));
                        ev.setVenue(rs.getString("venue"));
                        ev.setEventDate(rs.getTimestamp("event_date"));
                        ev.setCapacity(rs.getInt("capacity"));
                        ev.setStatus(rs.getString("status"));
                        ev.setRegistered(rs.getInt("registered"));
                    }
                }
            }
            if (ev == null) {
                response.sendRedirect(ctx + "/committee/manageEvents.jsp?error=notfound");
                return;
            }
            request.setAttribute("categories", LookupUtil.loadCategories(con));
        } catch (SQLException e) {
            getServletContext().log("UpdateEventServlet database error", e);
            response.sendRedirect(ctx + "/committee/manageEvents.jsp?error=system");
            return;
        }

        request.setAttribute("event", ev);
        request.getRequestDispatcher("/committee/updateEvent.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = committee(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("eventId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/committee/manageEvents.jsp?error=notfound");
            return;
        }

        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String venue = trim(request.getParameter("venue"));
        String dateText = trim(request.getParameter("eventDate"));
        boolean canceled = "canceled".equals(request.getParameter("status"));

        if (title.isEmpty() || venue.isEmpty() || dateText.isEmpty()) {
            fail(response, ctx, eventId, "empty");
            return;
        }
        if (title.length() > 150 || venue.length() > 100 || description.length() > 500) {
            fail(response, ctx, eventId, "toolong");
            return;
        }

        int categoryId;
        try {
            categoryId = Integer.parseInt(request.getParameter("categoryId"));
        } catch (NumberFormatException e) {
            fail(response, ctx, eventId, "invalid");
            return;
        }

        int capacity;
        try {
            capacity = Integer.parseInt(request.getParameter("capacity"));
        } catch (NumberFormatException e) {
            fail(response, ctx, eventId, "capacity");
            return;
        }
        if (capacity < 1 || capacity > 1000) {
            fail(response, ctx, eventId, "capacity");
            return;
        }

        Timestamp eventDate = DateUtil.parseInput(dateText);
        if (eventDate == null) {
            fail(response, ctx, eventId, "date");
            return;
        }

        String result;
        try {
            result = update(user.getClubId().intValue(), eventId, categoryId, title, description,
                            venue, eventDate, capacity, canceled);
        } catch (SQLException e) {
            if ("23503".equals(e.getSQLState())) {
                result = "invalid";
            } else {
                getServletContext().log("Update event database error", e);
                result = "system";
            }
        }

        if (result.equals("updated")) {
            response.sendRedirect(ctx + "/committee/manageEvents.jsp?msg=updated");
        } else if (result.equals("notfound")) {
            response.sendRedirect(ctx + "/committee/manageEvents.jsp?error=notfound");
        } else {
            fail(response, ctx, eventId, result);
        }
    }

    private String update(int clubId, int eventId, int categoryId, String title, String description,
                          String venue, Timestamp eventDate, int capacity, boolean canceled)
            throws SQLException {
        Connection con = DBConnection.getConnection();
        try {
            con.setAutoCommit(false);

            // Kunci baris event dan pastikan ia milik kelab ini
            try (PreparedStatement lock = con.prepareStatement(
                    "UPDATE events SET status = status WHERE event_id = ? AND club_id = ?")) {
                lock.setInt(1, eventId);
                lock.setInt(2, clubId);
                if (lock.executeUpdate() == 0) {
                    con.rollback();
                    return "notfound";
                }
            }

            int registered;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM registrations WHERE event_id = ?")) {
                ps.setInt(1, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    registered = rs.getInt(1);
                }
            }

            // Kapasiti tak boleh kurang daripada bilangan yang dah daftar
            if (capacity < registered) {
                con.rollback();
                return "capacity";
            }

            // Status: canceled ikut pilihan; selain itu auto open / full
            String status;
            if (canceled) {
                status = "canceled";
            } else if (registered >= capacity) {
                status = "full";
            } else {
                status = "open";
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE events SET category_id = ?, title = ?, description = ?, venue = ?, "
                  + "event_date = ?, capacity = ?, status = ? WHERE event_id = ? AND club_id = ?")) {
                ps.setInt(1, categoryId);
                ps.setString(2, title);
                ps.setString(3, description);
                ps.setString(4, venue);
                ps.setTimestamp(5, eventDate);
                ps.setInt(6, capacity);
                ps.setString(7, status);
                ps.setInt(8, eventId);
                ps.setInt(9, clubId);
                ps.executeUpdate();
            }

            con.commit();
            return "updated";
        } catch (SQLException e) {
            con.rollback();
            throw e;
        } finally {
            con.close();
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private void fail(HttpServletResponse response, String ctx, int eventId, String code)
            throws IOException {
        response.sendRedirect(ctx + "/committee/updateEvent.jsp?eventId=" + eventId + "&error=" + code);
    }
}