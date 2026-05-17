<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    if (username != null && password != null) {
        try {
            // Dynamically load the Account class
            Class<?> accountClass = Class.forName("Account");
            Object accountObj = accountClass.getConstructor(String.class, String.class).newInstance(username, password);
            String name = (String) accountClass.getMethod("signIn").invoke(accountObj);
            
            if (name != null && !name.equals("")) {
                // Login successful
                session.setAttribute("username", username);
                session.setAttribute("name", name);
                response.sendRedirect("dashboard.jsp");
            } else {
                // Login failed
                response.sendRedirect("login.html?error=invalid");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.html?error=database");
        }
    } else {
        response.sendRedirect("login.html");
    }
%>