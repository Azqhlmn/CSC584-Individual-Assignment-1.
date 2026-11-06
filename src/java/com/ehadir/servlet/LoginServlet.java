package com.ehadir.servlet;

import com.ehadir.bean.User;
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
import javax.servlet.http.HttpSession;

@WebServlet("/loginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String userType = request.getParameter("userType");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (isEmpty(userType) || isEmpty(email) || isEmpty(password)) {
            fail(request, response, "empty");
            return;
        }
        email = email.trim().toLowerCase();

        User user;
        try {
            user = findUser(email, PasswordUtil.hash(password));
        } catch (SQLException e) {
            getServletContext().log("Login database error", e);
            fail(request, response, "system");
            return;
        }

        if (user == null) {
            fail(request, response, "invalid");
            return;
        }
        if (!user.getRole().equals(userType)) {
            fail(request, response, "wrongrole");
            return;
        }

        // Session management: mulakan session baru
        HttpSession old = request.getSession(false);
        if (old != null) {
            old.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("email", user.getEmail());
        session.setAttribute("role", user.getRole());
        session.setAttribute("name", user.getName());
        session.setMaxInactiveInterval(30 * 60);   // 30 minit

        String page;
        if (user.getRole().equals("admin")) {
            page = "/admin/adminDashboard.jsp";
        } else if (user.getRole().equals("committee")) {
            page = "/committee/committeeDashboard.jsp";
        } else {
            page = "/student/studentDashboard.jsp";
        }
        response.sendRedirect(request.getContextPath() + page);
    }

    // Cari user dalam database; null kalau email/password tak padan
    private User findUser(String email, String hashedPassword) throws SQLException {
        String sql = "SELECT user_id, club_id, name, email, user_role, student_id "
                   + "FROM users WHERE email = ? AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, hashedPassword);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                int club = rs.getInt("club_id");
                u.setClubId(rs.wasNull() ? null : Integer.valueOf(club));
                u.setName(rs.getString("name"));
                u.setEmail(rs.getString("email"));
                u.setRole(rs.getString("user_role"));
                u.setStudentId(rs.getString("student_id"));
                return u;
            }
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void fail(HttpServletRequest request, HttpServletResponse response, String code)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=" + code);
    }
}