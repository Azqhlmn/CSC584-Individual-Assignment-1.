package dao;

import model.Profile;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProfileDAO {

    private static final String URL =
            "jdbc:derby://localhost:1527/student_db";
    private static final String USER     = "app";
    private static final String PASSWORD = "app";

    static {
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            System.out.println("✅ Derby driver loaded OK.");
        } catch (ClassNotFoundException e) {
            System.out.println("❌ Derby driver not found: " + e.getMessage());
        }
    }

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // INSERT
    public int insertProfile(Profile p) {
        String sql =
            "INSERT INTO profiles "
            + "(full_name, student_id, program, email, hobbies, bio, "
            + " website, github, twitter, instagram, facebook, "
            + " web_design, web_markup, one_page, mobile_template, "
            + " backend_api, photo_path) "
            + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1,  p.getFullName());
            ps.setString(2,  p.getStudentId());
            ps.setString(3,  p.getProgram());
            ps.setString(4,  p.getEmail());
            ps.setString(5,  p.getHobbies());
            ps.setString(6,  p.getBio());
            ps.setString(7,  p.getWebsite());
            ps.setString(8,  p.getGithub());
            ps.setString(9,  p.getTwitter());
            ps.setString(10, p.getInstagram());
            ps.setString(11, p.getFacebook());
            ps.setInt(12,    p.getWebDesign());
            ps.setInt(13,    p.getWebMarkup());
            ps.setInt(14,    p.getOnePage());
            ps.setInt(15,    p.getMobileTemplate());
            ps.setInt(16,    p.getBackendApi());
            ps.setString(17, p.getPhotoPath());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        int newId = keys.getInt(1);
                        System.out.println("✅ Profile saved. ID = " + newId);
                        return newId;
                    }
                }
            }
            return -1;

        } catch (SQLException e) {
            System.out.println("❌ insertProfile error: " + e.getMessage());
            e.printStackTrace();
            return -1;
        }
    }

    // SELECT ALL
    public List<Profile> getAllProfiles() {
        List<Profile> list = new ArrayList<>();
        String sql = "SELECT * FROM profiles ORDER BY id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapRow(rs));
            System.out.println("✅ getAllProfiles: " + list.size() + " rows.");

        } catch (SQLException e) {
            System.out.println("❌ getAllProfiles error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // SELECT BY ID
    public Profile getProfileById(int id) {
        String sql = "SELECT * FROM profiles WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("✅ getProfileById(" + id + ") found.");
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ getProfileById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // MAP ROW — CLOB fix for bio
    private Profile mapRow(ResultSet rs) throws SQLException {
        Profile p = new Profile();
        p.setId(rs.getInt("id"));
        p.setFullName(rs.getString("full_name"));
        p.setStudentId(rs.getString("student_id"));
        p.setProgram(rs.getString("program"));
        p.setEmail(rs.getString("email"));
        p.setHobbies(rs.getString("hobbies"));

        // CLOB fix — Derby stores bio as CLOB
        try {
            Clob bioClob = rs.getClob("bio");
            if (bioClob != null) {
                p.setBio(bioClob.getSubString(1, (int) bioClob.length()));
            } else {
                p.setBio("");
            }
        } catch (Exception e) {
            // fallback if getClob fails
            String bioStr = rs.getString("bio");
            p.setBio(bioStr != null ? bioStr : "");
        }

        p.setWebsite(rs.getString("website"));
        p.setGithub(rs.getString("github"));
        p.setTwitter(rs.getString("twitter"));
        p.setInstagram(rs.getString("instagram"));
        p.setFacebook(rs.getString("facebook"));
        p.setWebDesign(rs.getInt("web_design"));
        p.setWebMarkup(rs.getInt("web_markup"));
        p.setOnePage(rs.getInt("one_page"));
        p.setMobileTemplate(rs.getInt("mobile_template"));
        p.setBackendApi(rs.getInt("backend_api"));

        String photo = rs.getString("photo_path");
        p.setPhotoPath(photo != null ? photo : "");

        return p;
    }
}