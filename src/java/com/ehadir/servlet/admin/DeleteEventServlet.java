package com.ehadir.servlet.admin;

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

@WebServlet("/admin/deleteEventServlet")
public class DeleteEventServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/manageEvents.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ctx = request.getContextPath();
        if (!"admin".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("eventId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/admin/manageEvents.jsp?error=notfound");
            return;
        }

        // Hanya event berstatus canceled boleh dipadam.
        // Pendaftaran event tu turut terpadam (ON DELETE CASCADE).
        int deleted;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "DELETE FROM events WHERE event_id = ? AND status = 'canceled'")) {
            ps.setInt(1, eventId);
            deleted = ps.executeUpdate();
        } catch (SQLException e) {
            getServletContext().log("Delete event database error", e);
            response.sendRedirect(ctx + "/admin/manageEvents.jsp?error=system");
            return;
        }

        if (deleted == 0) {
            response.sendRedirect(ctx + "/admin/manageEvents.jsp?error=notcanceled");
        } else {
            response.sendRedirect(ctx + "/admin/manageEvents.jsp?msg=deleted");
        }
    }
}