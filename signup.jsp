<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    String name = request.getParameter("name");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    
    if (name != null && username != null && password != null && confirmPassword != null) {
        // Simplified signup - store user immediately without validation
        try {
            // Dynamically load DBConnection class
            Class<?> dbConnClass = Class.forName("DBConnection");
            Object dbConn = dbConnClass.newInstance();
            Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
            
            // Insert new user directly without checking if username exists
            PreparedStatement insertStmt = conn.prepareStatement(
                "INSERT INTO Account (Username, Password, Name) VALUES (?, ?, ?)"
            );
            insertStmt.setString(1, username);
            insertStmt.setString(2, password);
            insertStmt.setString(3, name);
            
            int result = insertStmt.executeUpdate();
            
            if (result > 0) {
                // Signup successful
                session.setAttribute("username", username);
                session.setAttribute("name", name);
                response.sendRedirect("dashboard.jsp");
            } else {
                // Signup failed
                response.sendRedirect("signup.html?error=Failed to create account");
            }
            
            insertStmt.close();
            dbConnClass.getMethod("closeConn").invoke(dbConn);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("signup.html?error=Database error: " + e.getMessage());
        }
    } else {
        response.sendRedirect("signup.html");
    }
%>