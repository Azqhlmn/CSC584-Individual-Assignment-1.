package com.ehadir.util;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class DateUtil {

    // "2026-11-20T14:00" (input datetime-local) kepada Timestamp; null kalau format salah
    public static Timestamp parseInput(String value) {
        if (value == null) {
            return null;
        }
        String v = value.trim().replace('T', ' ');
        if (v.length() == 16) {
            v = v + ":00";
        }
        try {
            return Timestamp.valueOf(v);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    // Timestamp kepada format input datetime-local
    public static String toInput(Timestamp ts) {
        if (ts == null) {
            return "";
        }
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(ts);
    }
}