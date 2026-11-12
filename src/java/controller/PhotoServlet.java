package controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/uploads/*")
public class PhotoServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "C:/ProfileUploads";

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = pathInfo.substring(1);
        File file = new File(UPLOAD_DIR + File.separator + fileName);

        if (!file.exists() || !file.isFile()) {
            System.out.println("❌ Photo not found: "
                + file.getAbsolutePath());
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String lower = fileName.toLowerCase();
        if (lower.endsWith(".png")) {
            response.setContentType("image/png");
        } else if (lower.endsWith(".gif")) {
            response.setContentType("image/gif");
        } else {
            response.setContentType("image/jpeg");
        }

        response.setContentLength((int) file.length());

        try (FileInputStream in  = new FileInputStream(file);
             OutputStream    out = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int    bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }

        System.out.println("✅ Served photo: " + fileName);
    }
}