package controller;

import dao.ProfileDAO;
import model.Profile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "ProfileController", urlPatterns = {"/ProfileController"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 1024 * 1024 * 5,
    maxRequestSize    = 1024 * 1024 * 10
)
public class ProfileController extends HttpServlet {

    private static final String EMAIL_REGEX =
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

    private static final String UPLOAD_DIR = "C:/ProfileUploads";

    private final ProfileDAO profileDAO = new ProfileDAO();

    protected void processRequest(HttpServletRequest request,
                                  HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Route 1 — view all
        String action = request.getParameter("action");
        if ("list".equals(action)) {
            request.setAttribute("profileList", profileDAO.getAllProfiles());
            request.getRequestDispatcher("view-all.jsp")
                   .forward(request, response);
            return;
        }

        // Route 2 — view single profile
        String idParam = request.getParameter("id");
        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam.trim());
                Profile saved = profileDAO.getProfileById(id);
                if (saved != null) {
                    request.setAttribute("profile", saved);
                    request.getRequestDispatcher("display.jsp")
                           .forward(request, response);
                    return;
                }
            } catch (NumberFormatException ignored) {}
        }

        // Route 3 — process form
        String fullName  = request.getParameter("fullName");
        String studentId = request.getParameter("studentId");
        String program   = request.getParameter("program");
        String email     = request.getParameter("email");
        String hobbies   = request.getParameter("hobbies");
        String website   = request.getParameter("website");
        String github    = request.getParameter("github");
        String twitter   = request.getParameter("twitter");
        String instagram = request.getParameter("instagram");
        String facebook  = request.getParameter("facebook");
        String webDesign      = request.getParameter("webDesign");
        String webMarkup      = request.getParameter("webMarkup");
        String onePage        = request.getParameter("onePage");
        String mobileTemplate = request.getParameter("mobileTemplate");
        String backendApi     = request.getParameter("backendApi");

        // bio — read separately, preserve as-is
        String bio = "";
        try {
            bio = request.getParameter("bio");
            if (bio == null) bio = "";
        } catch (Exception e) {
            bio = "";
        }

        // Validation
        boolean hasError = false;
        String  errorMsg = "";

        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()) {
            hasError = true;
            errorMsg = "Full Name and Email are required.";
        } else if (!Pattern.matches(EMAIL_REGEX, email.trim())) {
            hasError = true;
            errorMsg = "Invalid email format. Example: user@domain.com";
        }

        if (hasError) {
            response.sendRedirect("index.html?error="
                + URLEncoder.encode(errorMsg, "UTF-8"));
            return;
        }

        // Handle photo upload
        String photoPath = "";
        try {
            Part photoPart = request.getPart("photo");

            if (photoPart != null && photoPart.getSize() > 0) {

                String originalName = photoPart.getSubmittedFileName();
                String extension    = "";

                if (originalName != null && originalName.contains(".")) {
                    extension = originalName
                        .substring(originalName.lastIndexOf("."))
                        .toLowerCase();
                }

                if (extension.equals(".jpg")
                        || extension.equals(".jpeg")
                        || extension.equals(".png")
                        || extension.equals(".gif")) {

                    String fileName = "photo_"
                        + System.currentTimeMillis() + extension;

                    File dir = new File(UPLOAD_DIR);
                    if (!dir.exists()) dir.mkdirs();

                    String fullFilePath = UPLOAD_DIR
                        + File.separator + fileName;

                    try (InputStream input = photoPart.getInputStream();
                         FileOutputStream output =
                                 new FileOutputStream(fullFilePath)) {
                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        while ((bytesRead = input.read(buffer)) != -1) {
                            output.write(buffer, 0, bytesRead);
                        }
                    }

                    photoPath = fileName;
                    System.out.println("✅ Photo saved: " + fullFilePath);

                } else {
                    System.out.println("⚠️ Invalid file type: " + extension);
                }
            } else {
                System.out.println("ℹ️ No photo uploaded.");
            }

        } catch (Exception e) {
            System.out.println("⚠️ Photo upload error: " + e.getMessage());
            e.printStackTrace();
        }

        // Populate JavaBean
        Profile p = new Profile();
        p.setFullName(fullName.trim());
        p.setStudentId(fill(studentId,  "N/A"));
        p.setProgram(fill(program,      "N/A"));
        p.setEmail(email.trim());
        p.setHobbies(fill(hobbies,      "None"));
        p.setBio(bio.trim());
        p.setWebsite(fill(website,      "https://uitm.edu.my"));
        p.setGithub(fill(github,        "github.com"));
        p.setTwitter(fill(twitter,      "@twitter"));
        p.setInstagram(fill(instagram,  "instagram"));
        p.setFacebook(fill(facebook,    "facebook"));
        p.setWebDesign(toInt(webDesign,           80));
        p.setWebMarkup(toInt(webMarkup,           72));
        p.setOnePage(toInt(onePage,               89));
        p.setMobileTemplate(toInt(mobileTemplate, 55));
        p.setBackendApi(toInt(backendApi,         66));
        p.setPhotoPath(photoPath);

        // Save via DAO
        int newId = profileDAO.insertProfile(p);

        if (newId == -1) {
            response.sendRedirect("index.html?error="
                + URLEncoder.encode(
                    "Database error. Could not save profile.", "UTF-8"));
            return;
        }

        response.sendRedirect("ProfileController?id=" + newId);
    }

    private String fill(String val, String fallback) {
        return (val != null && !val.trim().isEmpty())
               ? val.trim() : fallback;
    }

    private int toInt(String val, int def) {
        if (val == null || val.trim().isEmpty()) return def;
        try {
            return Math.max(0, Math.min(100,
                   Integer.parseInt(val.trim())));
        } catch (NumberFormatException e) { return def; }
    }

    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse res)
            throws ServletException, IOException {
        processRequest(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse res)
            throws ServletException, IOException {
        processRequest(req, res);
    }
}