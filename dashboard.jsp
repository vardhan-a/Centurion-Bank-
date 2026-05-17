<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String name = (String) session.getAttribute("name");
    
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    // Initialize account lists to avoid duplicate database queries
    List<Map<String, String>> currentAccounts = new ArrayList<>();
    List<Map<String, String>> savingsAccounts = new ArrayList<>();
    float totalBalance = 0.0f;
    
    try {
        // Dynamically load DBConnection and DatabaseConfig classes
        Class<?> dbConnClass = Class.forName("DBConnection");
        Class<?> dbConfigClass = Class.forName("DatabaseConfig");
        Object dbConn = dbConnClass.newInstance();
        Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
        
        // Get DatabaseConfig field values using reflection
        String checkingAccountNumber = (String) dbConfigClass.getField("CHECKING_ACCOUNT_NUMBER").get(null);
        String checkingBalance = (String) dbConfigClass.getField("CHECKING_BALANCE").get(null);
        String checkingAccountTable = (String) dbConfigClass.getField("CHECKING_ACCOUNT_TABLE").get(null);
        String checkingCustomerId = (String) dbConfigClass.getField("CHECKING_CUSTOMER_ID").get(null);
        
        PreparedStatement currStmt = conn.prepareStatement(
            "SELECT " + checkingAccountNumber + ", " + checkingBalance + 
            " FROM " + checkingAccountTable + 
            " WHERE " + checkingCustomerId + " = ?"
        );
        currStmt.setString(1, username);
        ResultSet currRs = currStmt.executeQuery();
        
        while (currRs.next()) {
            Map<String, String> account = new HashMap<>();
            account.put("accountNumber", currRs.getString(checkingAccountNumber));
            float balance = currRs.getFloat(checkingBalance);
            account.put("balance", String.valueOf(balance));
            currentAccounts.add(account);
            totalBalance += balance;
        }
        
        currRs.close();
        currStmt.close();
        
        // Get DatabaseConfig field values for savings accounts
        String savingsAccountNumber = (String) dbConfigClass.getField("SAVINGS_ACCOUNT_NUMBER").get(null);
        String savingsBalance = (String) dbConfigClass.getField("SAVINGS_BALANCE").get(null);
        String savingsAccountTable = (String) dbConfigClass.getField("SAVINGS_ACCOUNT_TABLE").get(null);
        String savingsCustomerId = (String) dbConfigClass.getField("SAVINGS_CUSTOMER_ID").get(null);
        
        // Get savings accounts
        PreparedStatement savStmt = conn.prepareStatement(
            "SELECT " + savingsAccountNumber + ", " + savingsBalance + 
            " FROM " + savingsAccountTable + 
            " WHERE " + savingsCustomerId + " = ?"
        );
        savStmt.setString(1, username);
        ResultSet savRs = savStmt.executeQuery();
        
        while (savRs.next()) {
            Map<String, String> account = new HashMap<>();
            account.put("accountNumber", savRs.getString(savingsAccountNumber));
            float balance = savRs.getFloat(savingsBalance);
            account.put("balance", String.valueOf(balance));
            savingsAccounts.add(account);
            totalBalance += balance;
        }
        
        savRs.close();
        savStmt.close();
        dbConnClass.getMethod("closeConn").invoke(dbConn);
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Centurion Bank</title>
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
        
        /* Changed grid layout to put sidebar on the right */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 300px;
            gap: 1.5rem;
        }
        
        @media (max-width: 768px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .main-content {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        
        .sidebar {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            padding: 1.5rem;
            height: fit-content;
            position: relative;
        }
        
        /* Hamburger menu styles */
        .menu-toggle {
            display: none;
            background: var(--primary-dark);
            color: white;
            border: none;
            padding: 0.5rem;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 1rem;
        }
        
        .menu-toggle .bar {
            display: block;
            width: 25px;
            height: 3px;
            background-color: white;
            margin: 4px auto;
            transition: 0.3s;
        }
        
        .balance-card {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary-medium));
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .balance-title {
            font-size: 1.2rem;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        .balance-amount {
            font-size: 2.5rem;
            font-weight: 700;
            margin: 0.5rem 0;
        }
        
        .balance-currency {
            font-size: 1.5rem;
            vertical-align: super;
        }
        
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        
        @media (max-width: 768px) {
            .quick-actions {
                grid-template-columns: 1fr;
            }
        }
        
        .action-btn {
            padding: 1rem;
            border: none;
            border-radius: 8px;
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-decoration: none;
        }
        
        .action-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
        }
        
        .btn-deposit {
            background: linear-gradient(135deg, #007bff, #0056b3);
        }
        
        .btn-withdraw {
            background: linear-gradient(135deg, var(--warning), #e0a800);
            color: #212529;
        }
        
        .btn-transfer {
            background: linear-gradient(135deg, var(--info), #138496);
        }
        
        .btn-open-account {
            background: linear-gradient(135deg, var(--success), #1e7e34);
        }
        
        .section-title {
            font-size: 1.4rem;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--primary-light);
        }
        
        .accounts-section {
            margin-bottom: 2rem;
        }
        
        .accounts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1rem;
        }
        
        .account-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 1.5rem;
            transition: all 0.3s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            cursor: pointer;
        }
        
        .account-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-color: var(--primary-medium);
        }
        
        .account-type {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--primary-dark);
            margin-bottom: 0.5rem;
        }
        
        .account-number {
            font-family: monospace;
            color: var(--gray);
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
        
        .account-balance {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--success);
        }
        
        .transactions-section {
            margin-top: 2rem;
        }
        
        .transactions-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .transactions-table th {
            background: var(--primary-dark);
            color: white;
            text-align: left;
            padding: 1rem;
            font-weight: 600;
        }
        
        .transactions-table td {
            padding: 1rem;
            border-bottom: 1px solid var(--border);
            cursor: pointer;
        }
        
        .transactions-table tr:last-child td {
            border-bottom: none;
        }
        
        .transactions-table tr:hover {
            background-color: var(--primary-light);
        }
        
        .transaction-amount {
            font-weight: 600;
        }
        
        .amount-positive {
            color: var(--success);
        }
        
        .amount-negative {
            color: var(--danger);
        }
        
        .no-data {
            text-align: center;
            padding: 2rem;
            color: var(--gray);
            font-style: italic;
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
        
        /* Responsive menu styles */
        @media (max-width: 768px) {
            .menu-toggle {
                display: block;
            }
            
            .nav-links {
                display: none;
            }
            
            .nav-links.active {
                display: block;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1><i class="fas fa-university"></i> Centurion Bank</h1>
        <div class="user-info">
            <span class="welcome-text">Welcome, <%= name != null ? name : username %></span>
            <a href="logout.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </div>
    
    <div class="container">
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
        
        <div class="dashboard-grid">
            <div class="main-content">
                <div class="balance-card">
                    <div class="balance-title">Total Account Balance</div>
                    <div class="balance-amount"><span class="balance-currency">Rs.</span><%= String.format("%.2f", totalBalance) %></div>
                    <div>Available across all accounts</div>
                </div>
                
                <div class="quick-actions">
                    <a href="deposit.jsp" class="action-btn btn-deposit">
                        <i class="fas fa-arrow-down"></i>
                        <span>Deposit</span>
                    </a>
                    <a href="withdraw.jsp" class="action-btn btn-withdraw">
                        <i class="fas fa-arrow-up"></i>
                        <span>Withdraw</span>
                    </a>
                    <a href="transfer.jsp" class="action-btn btn-transfer">
                        <i class="fas fa-exchange-alt"></i>
                        <span>Transfer</span>
                    </a>
                    <a href="openAccount.jsp" class="action-btn btn-open-account">
                        <i class="fas fa-plus-circle"></i>
                        <span>Open Account</span>
                    </a>
                </div>
                
                <div class="accounts-section">
                    <h2 class="section-title"><i class="fas fa-wallet"></i> My Accounts</h2>
                    <%
                        if (currentAccounts.isEmpty() && savingsAccounts.isEmpty()) {
                            out.println("<div class='no-data'>You don't have any accounts yet. Please open an account.</div>");
                        } else {
                    %>
                    <div class="accounts-grid">
                        <%
                            // Display current accounts
                            for (Map<String, String> account : currentAccounts) {
                                out.println("<div class='account-card'>");
                                out.println("<div class='account-type'><i class='fas fa-money-check'></i> Current Account</div>");
                                out.println("<div class='account-number'>" + account.get("accountNumber") + "</div>");
                                out.println("<div class='account-balance'>Rs." + account.get("balance") + "</div>");
                                out.println("</div>");
                            }
                            
                            // Display savings accounts
                            for (Map<String, String> account : savingsAccounts) {
                                out.println("<div class='account-card'>");
                                out.println("<div class='account-type'><i class='fas fa-piggy-bank'></i> Savings Account</div>");
                                out.println("<div class='account-number'>" + account.get("accountNumber") + "</div>");
                                out.println("<div class='account-balance'>Rs." + account.get("balance") + "</div>");
                                out.println("</div>");
                            }
                        %>
                    </div>
                    <%
                        }
                    %>
                </div>
                
                <div class="transactions-section">
                    <h2 class="section-title"><i class="fas fa-history"></i> Recent Transactions</h2>
                    <%
                        try {
                            // Dynamically load DBConnection and DatabaseConfig classes
                            Class<?> dbConnClass = Class.forName("DBConnection");
                            Class<?> dbConfigClass = Class.forName("DatabaseConfig");
                            Object dbConn = dbConnClass.newInstance();
                            Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
                            
                            // Get DatabaseConfig field values using reflection
                            String transactionsTable = (String) dbConfigClass.getField("TRANSACTIONS_TABLE").get(null);
                            String transactionCustomerId = (String) dbConfigClass.getField("TRANSACTION_CUSTOMER_ID").get(null);
                            String transactionDate = (String) dbConfigClass.getField("TRANSACTION_DATE").get(null);
                            String transactionTime = (String) dbConfigClass.getField("TRANSACTION_TIME").get(null);
                            String transactionType = (String) dbConfigClass.getField("TRANSACTION_TYPE").get(null);
                            String transactionAmount = (String) dbConfigClass.getField("TRANSACTION_AMOUNT").get(null);
                            String transactionNumber = (String) dbConfigClass.getField("TRANSACTION_NUMBER").get(null);
                            
                            // Display recent transactions (last 5)
                            PreparedStatement transStmt = conn.prepareStatement(
                                "SELECT * FROM " + transactionsTable + 
                                " WHERE " + transactionCustomerId + " = ? " +
                                "ORDER BY " + transactionDate + " DESC, " + transactionTime + " DESC LIMIT 5"
                            );
                            transStmt.setString(1, username);
                            ResultSet transRs = transStmt.executeQuery();
                            
                            if (transRs.next()) {
                                out.println("<table class='transactions-table'>");
                                out.println("<thead>");
                                out.println("<tr>");
                                out.println("<th>Transaction Number</th>");
                                out.println("<th>Type</th>");
                                out.println("<th>Amount</th>");
                                out.println("<th>Date</th>");
                                out.println("</tr>");
                                out.println("</thead>");
                                out.println("<tbody>");
                                do {
                                    String transType = transRs.getString(transactionType);
                                    float amount = transRs.getFloat(transactionAmount);
                                    String amountClass = (transType.contains("Deposit") || transType.contains("In")) ? "amount-positive" : "amount-negative";
                                    String transNumber = transRs.getString(transactionNumber);
                                    
                                    out.println("<a href='transactionDetails.jsp?transactionNumber=" + transNumber + "' style='text-decoration: none; color: inherit;'>");
                                    out.println("<tr>");
                                    out.println("<td>" + transNumber + "</td>");
                                    out.println("<td>" + transType + "</td>");
                                    out.println("<td class='transaction-amount " + amountClass + "'>Rs." + amount + "</td>");
                                    out.println("<td>" + transRs.getDate(transactionDate) + "</td>");
                                    out.println("</tr>");
                                    out.println("</a>");
                                } while (transRs.next());
                                out.println("</tbody>");
                                out.println("</table>");
                            } else {
                                out.println("<div class='no-data'>No recent transactions found.</div>");
                            }
                            
                            transRs.close();
                            transStmt.close();
                            dbConnClass.getMethod("closeConn").invoke(dbConn);
                        } catch (Exception e) {
                            out.println("<div class='notification error'>Error loading recent transactions: " + e.getMessage() + "</div>");
                            e.printStackTrace();
                        }
                    %>
                </div>
                
                <!-- All forms have been moved to dedicated pages -->
            </div>
            
            <!-- Moved sidebar to the right -->
            <div class="sidebar">
                <button class="menu-toggle" id="menuToggle">
                    <span class="bar"></span>
                    <span class="bar"></span>
                    <span class="bar"></span>
                </button>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-bars"></i> Menu</h3>
                    <ul class="nav-links" id="navLinks">
                        <li><a href="dashboard.jsp" class="active"><i class="fas fa-home"></i> Dashboard</a></li>
                        <li><a href="openAccount.jsp"><i class="fas fa-plus-circle"></i> Open Account</a></li>
                        <li><a href="deposit.jsp"><i class="fas fa-arrow-down"></i> Deposit</a></li>
                        <li><a href="withdraw.jsp"><i class="fas fa-arrow-up"></i> Withdraw</a></li>
                        <li><a href="transfer.jsp"><i class="fas fa-exchange-alt"></i> Transfer</a></li>
                        <li><a href="transactions.jsp"><i class="fas fa-history"></i> Transactions</a></li>
                        <li><a href="statements.jsp"><i class="fas fa-file-invoice"></i> Statements</a></li>
                        <li><a href="cards.jsp"><i class="fas fa-credit-card"></i> Cards</a></li>
                        <li><a href="upi.jsp"><i class="fas fa-mobile-alt"></i> UPI</a></li>
                        <li><a href="bills.jsp"><i class="fas fa-receipt"></i> Bill Payments</a></li>
                    </ul>
                </div>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-info-circle"></i> Quick Info</h3>
                    <p>Manage your accounts and transactions with ease. All your financial activities are securely recorded and displayed here.</p>
                </div>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-shield-alt"></i> Security</h3>
                    <p>Your session is secure. Remember to logout when finished using public computers.</p>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Set today's date as default for transaction search
        window.onload = function() {
            var today = new Date();
            var oneMonthAgo = new Date();
            oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);
            
            var todayStr = today.toISOString().split('T')[0];
            var oneMonthAgoStr = oneMonthAgo.toISOString().split('T')[0];
            
            if (document.getElementById('endDate')) {
                document.getElementById('endDate').value = todayStr;
            }
            if (document.getElementById('startDate')) {
                document.getElementById('startDate').value = oneMonthAgoStr;
            }
        };
        
        // Toggle menu on mobile
        document.addEventListener('DOMContentLoaded', function() {
            var menuToggle = document.getElementById('menuToggle');
            var navLinks = document.getElementById('navLinks');
            
            if (menuToggle && navLinks) {
                menuToggle.addEventListener('click', function() {
                    navLinks.classList.toggle('active');
                });
            }
        });
    </script>
</body>
</html>