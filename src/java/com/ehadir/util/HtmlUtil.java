package com.ehadir.util;

public class HtmlUtil {

    // Escape teks sebelum dipaparkan dalam HTML
    public static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;");
    }
}