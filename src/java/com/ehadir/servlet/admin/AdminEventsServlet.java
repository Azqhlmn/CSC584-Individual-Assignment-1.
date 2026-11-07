package com.ehadir.servlet.admin;

import com.ehadir.bean.Event;
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

@WebServlet("/admin/adminEventsServlet")
public class AdminEventsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!"admin".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String sql = "SELECT e.event_id, e.title, e.venue, e.event_date, e.capacity, e.status, "
                   + "c.club_name, "
                   + "(SELECT COUNT(*) FROM registrations r WHERE r.event_id = e.event_id) AS registered "
                   + "FROM events e JOIN clubs c ON c.club_id = e.club_id "
                   + "ORDER BY e.event_date DESC";

        List<Event> events = new ArrayList<Event>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Event e = new Event();
                e.setEventId(rs.getInt("event_id"));
                e.setTitle(rs.getString("title"));
                e.setVenue(rs.getString("venue"));
                e.setEventDate(rs.getTimestamp("event_date"));
                e.setCapacity(rs.getInt("capacity"));
                e.setStatus(rs.getString("status"));
                e.setClubName(rs.getString("club_name"));
                e.setRegistered(rs.getInt("registered"));
                events.add(e);
            }
        } catch (SQLException ex) {
            getServletContext().log("AdminEventsServlet database error", ex);
            response.sendRedirect(request.getContextPath() + "/admin/adminDashboard.jsp");
            return;
        }

        request.setAttribute("events", events);
        request.getRequestDispatcher("/admin/manageEvents.jsp").forward(request, response);
    }
}