package com.ehadir.util;

import com.ehadir.bean.Category;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LookupUtil {

    public static List<Category> loadCategories(Connection con) throws SQLException {
        List<Category> list = new ArrayList<Category>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT category_id, category_name FROM categories ORDER BY category_name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryName(rs.getString("category_name"));
                list.add(c);
            }
        }
        return list;
    }
}