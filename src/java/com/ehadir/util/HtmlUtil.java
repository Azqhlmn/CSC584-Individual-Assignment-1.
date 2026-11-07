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
    
    
    // Escape teks untuk diletak dalam string JavaScript ("...")
    public static String js(String s) {
        if (s == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '"':  sb.append("\\\""); break;
                case '\'': sb.append("\\'"); break;
                case '<':  sb.append("\\u003C"); break;
                case '>':  sb.append("\\u003E"); break;
                case '&':  sb.append("\\u0026"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }
}