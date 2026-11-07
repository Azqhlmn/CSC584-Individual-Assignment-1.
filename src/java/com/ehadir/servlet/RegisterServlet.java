package com.ehadir.servlet;

import com.ehadir.util.DBConnection;
import com.ehadir.util.PasswordUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/registerServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String studentId = trim(request.getParameter("studentId"));
        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email")).toLowerCase();
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        // Server-side validation
        if (studentId.isEmpty() || name.isEmpty() || email.isEmpty()
                || password == null || password.isEmpty()) {
            fail(request, response, "empty");
            return;
        }
        if (!studentId.matches("\\d{10}")) {
            fail(request, response, "studentid");
            return;
        }
        if (!email.matches("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$")) {
            fail(request, response, "email");
            return;
        }
        if (password.length() < 8) {
            fail(request, response, "password");
            return;
        }
        if (!password.equals(confirm)) {
            fail(request, response, "mismatch");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            // Semak duplicate
            if (exists(con, "SELECT 1 FROM users WHERE email = ?", email)
                    || exists(con, "SELECT 1 FROM users WHERE student_id = ?", studentId)) {
                fail(request, response, "duplicate");
                return;
            }

            // Simpan akaun baru (role = student)
            String sql = "INSERT INTO users (name, email, password, user_role, student_id) "
                       + "VALUES (?, ?, ?, 'student', ?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, PasswordUtil.hash(password));
                ps.setString(4, studentId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {      // unique constraint
                fail(request, response, "duplicate");
            } else {
                getServletContext().log("Register database error", e);
                fail(request, response, "system");
            }
            return;
        }

        response.sendRedirect(request.getContextPath() + "/login.jsp?registered=1");
    }

    private boolean exists(Connection con, String sql, String value) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private void fail(HttpServletRequest request, HttpServletResponse response, String code)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp?error=" + code);
    }
}