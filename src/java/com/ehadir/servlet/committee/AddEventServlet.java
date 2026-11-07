package com.ehadir.servlet.committee;

import com.ehadir.bean.User;
import com.ehadir.util.DBConnection;
import com.ehadir.util.DateUtil;
import com.ehadir.util.LookupUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/committee/addEventServlet")
public class AddEventServlet extends HttpServlet {

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

    // Muat senarai kategori untuk borang
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (committee(request) == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        try (Connection con = DBConnection.getConnection()) {
            request.setAttribute("categories", LookupUtil.loadCategories(con));
        } catch (SQLException e) {
            getServletContext().log("AddEventServlet database error", e);
            response.sendRedirect(request.getContextPath() + "/committee/committeeDashboard.jsp");
            return;
        }
        request.getRequestDispatcher("/committee/addEvent.jsp").forward(request, response);
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

        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String venue = trim(request.getParameter("venue"));
        String dateText = trim(request.getParameter("eventDate"));

        if (title.isEmpty() || venue.isEmpty() || dateText.isEmpty()) {
            fail(response, ctx, "empty");
            return;
        }
        if (title.length() > 150 || venue.length() > 100 || description.length() > 500) {
            fail(response, ctx, "toolong");
            return;
        }

        int categoryId;
        try {
            categoryId = Integer.parseInt(request.getParameter("categoryId"));
        } catch (NumberFormatException e) {
            fail(response, ctx, "invalid");
            return;
        }

        int capacity;
        try {
            capacity = Integer.parseInt(request.getParameter("capacity"));
        } catch (NumberFormatException e) {
            fail(response, ctx, "capacity");
            return;
        }
        if (capacity < 1 || capacity > 1000) {
            fail(response, ctx, "capacity");
            return;
        }

        Timestamp eventDate = DateUtil.parseInput(dateText);
        if (eventDate == null) {
            fail(response, ctx, "date");
            return;
        }
        if (!eventDate.after(new Timestamp(System.currentTimeMillis()))) {
            fail(response, ctx, "pastdate");
            return;
        }

        String sql = "INSERT INTO events (club_id, category_id, created_by, title, description, "
                   + "venue, event_date, capacity, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'open')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, user.getClubId().intValue());
            ps.setInt(2, categoryId);
            ps.setInt(3, user.getUserId());
            ps.setString(4, title);
            ps.setString(5, description);
            ps.setString(6, venue);
            ps.setTimestamp(7, eventDate);
            ps.setInt(8, capacity);
            ps.executeUpdate();
        } catch (SQLException e) {
            if ("23503".equals(e.getSQLState())) {     // kategori tak wujud
                fail(response, ctx, "invalid");
            } else {
                getServletContext().log("Add event database error", e);
                fail(response, ctx, "system");
            }
            return;
        }

        response.sendRedirect(ctx + "/committee/manageEvents.jsp?msg=added");
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private void fail(HttpServletResponse response, String ctx, String code) throws IOException {
        response.sendRedirect(ctx + "/committee/addEvent.jsp?error=" + code);
    }
}