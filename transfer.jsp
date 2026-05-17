<%@ page import="java.sql.*, java.util.*, java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String name = (String) session.getAttribute("name");
    
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    // Initialize account lists
    List<Map<String, String>> currentAccounts = new ArrayList<>();
    List<Map<String, String>> savingsAccounts = new ArrayList<>();
    
    try {
        // Dynamically load DBConnection class
        Class<?> dbConnClass = Class.forName("DBConnection");
        Object dbConn = dbConnClass.newInstance();
        Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
        
        // Get current accounts
        PreparedStatement currentStmt = conn.prepareStatement(
            "SELECT CheckingAccountNumber, Balance FROM CheckingAccount WHERE CustomerID = ?"
        );
        currentStmt.setString(1, username);
        ResultSet currentRs = currentStmt.executeQuery();
        
        while (currentRs.next()) {
            Map<String, String> account = new HashMap<>();
            account.put("accountNumber", currentRs.getString("CheckingAccountNumber"));
            account.put("balance", String.format("%.2f", currentRs.getFloat("Balance")));
            currentAccounts.add(account);
        }
        currentRs.close();
        currentStmt.close();
        
        // Get savings accounts
        PreparedStatement savingsStmt = conn.prepareStatement(
            "SELECT SavingsAccountNumber, Balance FROM SavingsAccount WHERE CustomerID = ?"
        );
        savingsStmt.setString(1, username);
        ResultSet savingsRs = savingsStmt.executeQuery();
        
        while (savingsRs.next()) {
            Map<String, String> account = new HashMap<>();
            account.put("accountNumber", savingsRs.getString("SavingsAccountNumber"));
            account.put("balance", String.format("%.2f", savingsRs.getFloat("Balance")));
            savingsAccounts.add(account);
        }
        savingsRs.close();
        savingsStmt.close();
        
        dbConnClass.getMethod("closeConn").invoke(dbConn);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fromAccount = request.getParameter("fromAccount");
        String toAccount = request.getParameter("toAccount");
        String amountStr = request.getParameter("amount");
        
        if (fromAccount != null && toAccount != null && amountStr != null && 
            !fromAccount.isEmpty() && !toAccount.isEmpty() && !amountStr.isEmpty()) {
            try {
                float amount = Float.parseFloat(amountStr);
                
                if (amount <= 0) {
                    session.setAttribute("error", "Amount must be greater than zero.");
                } else if (fromAccount.equals(toAccount)) {
                    session.setAttribute("error", "From and To accounts cannot be the same.");
                } else {
                    // Process transfer
                    Class<?> dbUtilClass = Class.forName("DatabaseUtil");
                    // We'll need to add a transferBetweenAccounts method to DatabaseUtil
                    // For now, we'll use a generic approach
                    Boolean success = false;
                    
                    try {
                        // Try to transfer between accounts
                        success = (Boolean) dbUtilClass.getMethod("transferBetweenAccounts", String.class, String.class, float.class, String.class)
                            .invoke(null, fromAccount, toAccount, amount, username);
                    } catch (NoSuchMethodException e) {
                        // If the method doesn't exist, we'll implement a basic transfer here
                        success = transferBetweenAccountsBasic(fromAccount, toAccount, amount, username);
                    }
                    
                    if (success) {
                        session.setAttribute("success", "Successfully transferred Rs." + String.format("%.2f", amount) + " from account " + fromAccount + " to account " + toAccount + ".");
                        response.sendRedirect("transfer.jsp");
                        return;
                    } else {
                        session.setAttribute("error", "Failed to transfer funds. Please check account details and try again.");
                    }
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid amount entered.");
            } catch (Exception e) {
                session.setAttribute("error", "An error occurred while processing your transfer: " + e.getMessage());
                e.printStackTrace();
            }
        } else {
            session.setAttribute("error", "Please fill in all fields.");
        }
    }
%>
<%!
    // Basic transfer method in case the DatabaseUtil method doesn't exist
    public boolean transferBetweenAccountsBasic(String fromAccount, String toAccount, float amount, String customerId) {
        boolean success = false;
        Connection conn = null;
        try {
            Class<?> dbConnClass = Class.forName("DBConnection");
            Object dbConn = dbConnClass.newInstance();
            conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
            
            // Start transaction
            conn.setAutoCommit(false);
            
            // Check if from account exists and belongs to user
            PreparedStatement fromCheckStmt = conn.prepareStatement(
                "SELECT Balance, CustomerID FROM CheckingAccount WHERE CheckingAccountNumber = ?");
            fromCheckStmt.setString(1, fromAccount);
            ResultSet fromRs = fromCheckStmt.executeQuery();
            
            float fromBalance = -1;
            boolean isFromChecking = true;
            String fromCustomerId = "";
            
            if (fromRs.next()) {
                fromBalance = fromRs.getFloat("Balance");
                fromCustomerId = fromRs.getString("CustomerID");
            } else {
                // Check if it's a savings account
                fromCheckStmt.close();
                fromCheckStmt = conn.prepareStatement(
                    "SELECT Balance, CustomerID FROM SavingsAccount WHERE SavingsAccountNumber = ?");
                fromCheckStmt.setString(1, fromAccount);
                fromRs = fromCheckStmt.executeQuery();
                
                if (fromRs.next()) {
                    fromBalance = fromRs.getFloat("Balance");
                    fromCustomerId = fromRs.getString("CustomerID");
                    isFromChecking = false;
                }
                fromRs.close();
            }
            
            fromCheckStmt.close();
            
            if (fromBalance < 0 || !fromCustomerId.equals(customerId)) {
                // From account not found or doesn't belong to user
                conn.rollback();
                dbConnClass.getMethod("closeConn").invoke(dbConn);
                return false;
            }
            
            if (fromBalance < amount) {
                // Insufficient funds
                conn.rollback();
                dbConnClass.getMethod("closeConn").invoke(dbConn);
                session.setAttribute("error", "Insufficient funds in source account. Current balance: Rs." + String.format("%.2f", fromBalance));
                return false;
            }
            
            // Check if to account exists (any user) and get customer ID
            PreparedStatement toCheckStmt = conn.prepareStatement(
                "SELECT CheckingAccountNumber, CustomerID FROM CheckingAccount WHERE CheckingAccountNumber = ?");
            toCheckStmt.setString(1, toAccount);
            ResultSet toRs = toCheckStmt.executeQuery();
            
            boolean isToChecking = true;
            String toCustomerId = "";
            
            if (toRs.next()) {
                toCustomerId = toRs.getString("CustomerID");
            } else {
                // Check if it's a savings account
                toCheckStmt.close();
                toCheckStmt = conn.prepareStatement(
                    "SELECT SavingsAccountNumber, CustomerID FROM SavingsAccount WHERE SavingsAccountNumber = ?");
                toCheckStmt.setString(1, toAccount);
                toRs = toCheckStmt.executeQuery();
                
                if (toRs.next()) {
                    toCustomerId = toRs.getString("CustomerID");
                    isToChecking = false;
                } else {
                    // To account not found
                    conn.rollback();
                    toCheckStmt.close();
                    dbConnClass.getMethod("closeConn").invoke(dbConn);
                    session.setAttribute("error", "Destination account not found.");
                    return false;
                }
            }
            
            toRs.close();
            toCheckStmt.close();
            
            // Perform the transfer
            // 1. Deduct from fromAccount
            float newFromBalance = fromBalance - amount;
            PreparedStatement deductStmt;
            if (isFromChecking) {
                deductStmt = conn.prepareStatement(
                    "UPDATE CheckingAccount SET Balance = ? WHERE CheckingAccountNumber = ?");
            } else {
                deductStmt = conn.prepareStatement(
                    "UPDATE SavingsAccount SET Balance = ? WHERE SavingsAccountNumber = ?");
            }
            deductStmt.setFloat(1, newFromBalance);
            deductStmt.setString(2, fromAccount);
            deductStmt.executeUpdate();
            deductStmt.close();
            
            // 2. Add to toAccount
            PreparedStatement addToStmt;
            if (isToChecking) {
                addToStmt = conn.prepareStatement(
                    "UPDATE CheckingAccount SET Balance = Balance + ? WHERE CheckingAccountNumber = ?");
            } else {
                addToStmt = conn.prepareStatement(
                    "UPDATE SavingsAccount SET Balance = Balance + ? WHERE SavingsAccountNumber = ?");
            }
            addToStmt.setFloat(1, amount);
            addToStmt.setString(2, toAccount);
            addToStmt.executeUpdate();
            addToStmt.close();
            
            // 3. Record transactions
            Class<?> dbUtilClass = Class.forName("DatabaseUtil");
            String transactionNumber1 = "TRF" + System.currentTimeMillis();
            String transactionNumber2 = "TRF" + (System.currentTimeMillis() + 1);
            
            // Record outgoing transaction for sender
            dbUtilClass.getMethod("recordTransaction", String.class, float.class, String.class, String.class, String.class, String.class)
                .invoke(null, transactionNumber1, amount, "Transfer Out", fromAccount, toAccount, customerId);
            
            // Record incoming transaction for recipient
            dbUtilClass.getMethod("recordTransaction", String.class, float.class, String.class, String.class, String.class, String.class)
                .invoke(null, transactionNumber2, amount, "Transfer In", fromAccount, toAccount, toCustomerId);
            
            // Commit transaction
            conn.commit();
            dbConnClass.getMethod("closeConn").invoke(dbConn);
            success = true;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception rollbackEx) {
                rollbackEx.printStackTrace();
            }
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        return success;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transfer - Centurion Bank</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-dark: #003366;
            --primary-medium: #0055aa;
            --primary-light: #e3f2fd;
            --secondary: #ff6600;
            --success: #28a745;
            --info: #17a2b8;
            --warning: #ffc107;
            --danger: #dc3545;
            --light: #f8f9fa;
            --dark: #343a40;
            --gray: #6c757d;
            --border: #dee2e6;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f7fa;
            color: #333;
            line-height: 1.6;
        }
        
        .header {
            background: linear-gradient(135deg, var(--primary-dark), #002244);
            color: white;
            padding: 1rem 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 1.8rem;
            font-weight: 600;
            margin: 0;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .welcome-text {
            font-size: 1.1rem;
            font-weight: 500;
        }
        
        .logout-btn {
            background-color: var(--secondary);
            color: white;
            padding: 0.5rem 1rem;
            text-decoration: none;
            border-radius: 4px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .logout-btn:hover {
            background-color: #e65c00;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 300px;
            gap: 2rem;
        }
        
        @media (max-width: 768px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .main-content {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        }
        
        .section-title {
            font-size: 1.5rem;
            color: var(--primary-dark);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--primary-light);
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: var(--dark);
        }
        
        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid var(--border);
            border-radius: 5px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary-medium);
            box-shadow: 0 0 0 3px rgba(0, 85, 170, 0.1);
        }
        
        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn-primary {
            background-color: var(--primary-medium);
            color: white;
        }
        
        .btn-primary:hover {
            background-color: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        .sidebar-section {
            margin-bottom: 2rem;
        }
        
        .sidebar-title {
            font-size: 1.2rem;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--border);
        }
        
        .nav-links {
            list-style: none;
        }
        
        .nav-links li {
            margin-bottom: 0.5rem;
        }
        
        .nav-links a {
            display: block;
            padding: 0.75rem;
            color: var(--dark);
            text-decoration: none;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        
        .nav-links a:hover, .nav-links a.active {
            background-color: var(--primary-light);
            color: var(--primary-dark);
            font-weight: 500;
        }
        
        .nav-links i {
            margin-right: 0.5rem;
            width: 20px;
            text-align: center;
        }
        
        .notification {
            padding: 1rem;
            border-radius: 5px;
            margin-bottom: 1.5rem;
            text-align: center;
            font-weight: 500;
        }
        
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1><i class="fas fa-university"></i> Centurion Bank</h1>
        <div class="user-info">
            <a href="dashboard.jsp" class="logout-btn"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="dashboard-grid">
            <div class="main-content">
                <h2 class="section-title"><i class="fas fa-exchange-alt"></i> Transfer Funds</h2>
                
                <!-- Display success or error messages -->
                <%
                    String successMessage = (String) session.getAttribute("success");
                    String errorMessage = (String) session.getAttribute("error");
                    
                    if (successMessage != null) {
                        out.println("<div class='notification success'>" + successMessage + "</div>");
                        session.removeAttribute("success");
                    }
                    
                    if (errorMessage != null) {
                        out.println("<div class='notification error'>" + errorMessage + "</div>");
                        session.removeAttribute("error");
                    }
                %>
                
                <form action="transfer.jsp" method="post">
                    <div class="form-group">
                        <label for="fromAccount">From Account:</label>
                        <select id="fromAccount" name="fromAccount" class="form-control" required>
                            <option value="">Select Account</option>
                            <%
                                // Populate current accounts
                                for (Map<String, String> account : currentAccounts) {
                                    out.println("<option value='" + account.get("accountNumber") + "'>" + account.get("accountNumber") + " (Current) - Rs." + account.get("balance") + "</option>");
                                }
                                
                                // Populate savings accounts
                                for (Map<String, String> account : savingsAccounts) {
                                    out.println("<option value='" + account.get("accountNumber") + "'>" + account.get("accountNumber") + " (Savings) - Rs." + account.get("balance") + "</option>");
                                }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="toAccount">To Account Number:</label>
                        <input type="text" id="toAccount" name="toAccount" class="form-control" placeholder="Enter recipient's account number" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="amount">Amount (Rs.):</label>
                        <input type="number" id="amount" name="amount" class="form-control" min="0.01" step="0.01" required>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">Transfer</button>
                </form>
            </div>
            
            <div class="sidebar">
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-bars"></i> Menu</h3>
                    <ul class="nav-links">
                        <li><a href="dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
                        <li><a href="openAccount.jsp"><i class="fas fa-plus-circle"></i> Open Account</a></li>
                        <li><a href="deposit.jsp"><i class="fas fa-arrow-down"></i> Deposit</a></li>
                        <li><a href="withdraw.jsp"><i class="fas fa-arrow-up"></i> Withdraw</a></li>
                        <li><a href="transfer.jsp" class="active"><i class="fas fa-exchange-alt"></i> Transfer</a></li>
                        <li><a href="transactions.jsp"><i class="fas fa-history"></i> Transactions</a></li>
                        <li><a href="statements.jsp"><i class="fas fa-file-invoice"></i> Statements</a></li>
                        <li><a href="cards.jsp"><i class="fas fa-credit-card"></i> Cards</a></li>
                        <li><a href="upi.jsp"><i class="fas fa-mobile-alt"></i> UPI</a></li>
                        <li><a href="bills.jsp"><i class="fas fa-receipt"></i> Bill Payments</a></li>
                    </ul>
                </div>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-info-circle"></i> Transfer Information</h3>
                    <p>Transfer funds between accounts. Select your account from the dropdown and enter the recipient's account number.</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>