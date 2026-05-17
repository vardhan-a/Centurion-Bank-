<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    String accountType = request.getParameter("accountType");
    String initialDepositStr = request.getParameter("initialDeposit");
    String interestRateStr = request.getParameter("interestRate");
    
    // Debug information
    System.out.println("Debug: accountType=" + accountType);
    System.out.println("Debug: initialDepositStr=" + initialDepositStr);
    System.out.println("Debug: interestRateStr=" + interestRateStr);
    
    // Only process the form if all required parameters are present and not empty
    // Check if this is actually a form submission (not just page load)
    if (accountType != null && initialDepositStr != null && !accountType.isEmpty() && !initialDepositStr.isEmpty()) {
        System.out.println("Debug: Processing form submission");
        try {
            float initialDeposit = Float.parseFloat(initialDepositStr);
            float interestRate = 0.0f;
            
            if (accountType.equals("savings") && interestRateStr != null && !interestRateStr.isEmpty()) {
                interestRate = Float.parseFloat(interestRateStr);
            }
            
            // Generate account number
            String accountNumber = "CUTMAP" + String.format("%06d", new Random().nextInt(999999));
            
            // Database connection using DatabaseUtil
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            if (accountType.equals("current")) {
                // Insert current account
                PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO CheckingAccount (CheckingAccountNumber, CustomerName, Balance, CustomerID) VALUES (?, ?, ?, ?)"
                );
                stmt.setString(1, accountNumber);
                
                // Get customer name from Account table
                PreparedStatement nameStmt = conn.prepareStatement(
                    "SELECT Name FROM Account WHERE Username = ?"
                );
                nameStmt.setString(1, username);
                ResultSet nameRs = nameStmt.executeQuery();
                String customerName = username;
                if (nameRs.next()) {
                    customerName = nameRs.getString("Name");
                }
                nameRs.close();
                nameStmt.close();
                
                stmt.setString(2, customerName);
                stmt.setFloat(3, initialDeposit);
                stmt.setString(4, username);
                
                int result = stmt.executeUpdate();
                stmt.close();
                
                if (result > 0) {
                    // Record transaction
                    String transactionNumber = "TXN" + String.format("%06d", new Random().nextInt(999999));
                    boolean transactionSuccess = DatabaseUtil.recordTransaction(
                        transactionNumber, initialDeposit, "Account Opening - Deposit", "N/A", accountNumber, username);
                    
                    if (transactionSuccess) {
                        session.setAttribute("success", "Current account opened successfully with account number: " + accountNumber);
                    } else {
                        session.setAttribute("error", "Account opened but transaction recording failed.");
                    }
                }
            } else if (accountType.equals("savings")) {
                // Insert savings account
                PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO SavingsAccount (SavingsAccountNumber, CustomerName, Balance, InterestRate, CustomerID) VALUES (?, ?, ?, ?, ?)"
                );
                stmt.setString(1, accountNumber);
                
                // Get customer name from Account table
                PreparedStatement nameStmt = conn.prepareStatement(
                    "SELECT Name FROM Account WHERE Username = ?"
                );
                nameStmt.setString(1, username);
                ResultSet nameRs = nameStmt.executeQuery();
                String customerName = username;
                if (nameRs.next()) {
                    customerName = nameRs.getString("Name");
                }
                nameRs.close();
                nameStmt.close();
                
                stmt.setString(2, customerName);
                stmt.setFloat(3, initialDeposit);
                stmt.setFloat(4, interestRate);
                stmt.setString(5, username);
                
                int result = stmt.executeUpdate();
                stmt.close();
                
                if (result > 0) {
                    // Record transaction
                    String transactionNumber = "TXN" + String.format("%06d", new Random().nextInt(999999));
                    boolean transactionSuccess = DatabaseUtil.recordTransaction(
                        transactionNumber, initialDeposit, "Account Opening - Deposit", "N/A", accountNumber, username);
                    
                    if (transactionSuccess) {
                        session.setAttribute("success", "Savings account opened successfully with account number: " + accountNumber);
                    } else {
                        session.setAttribute("error", "Account opened but transaction recording failed.");
                    }
                }
            }
            
            dbConn.closeConn();
            response.sendRedirect("dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error opening account: " + e.getMessage());
            response.sendRedirect("dashboard.jsp");
        }
        // Return here to prevent displaying the form after processing
        return;
    } else {
        System.out.println("Debug: Displaying form (no form submission)");
    }
    // If parameters are not present, continue to display the form
%>
