package com.ehadir.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL = "jdbc:derby://localhost:1527/EHadirDB";
    private static final String USER = "ehadir";
    private static final String PASSWORD = "ehadir";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Derby driver not found", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}