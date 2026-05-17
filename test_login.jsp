<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    try {
        // Try to instantiate the Account class
        Class.forName("Account");
        out.println("Account class found successfully!");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>