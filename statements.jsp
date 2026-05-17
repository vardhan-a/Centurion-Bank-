<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Statements - Centurion Bank</title>
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
            padding: 2rem;
        }
        
        .sidebar {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            padding: 1.5rem;
            height: fit-content;
        }
        
        .page-title {
            font-size: 1.8rem;
            color: var(--primary-dark);
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
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
            background-color: var(--primary-dark);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn:hover {
            background-color: var(--primary-medium);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        .btn-secondary {
            background-color: var(--gray);
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .statement-options {
            background-color: var(--primary-light);
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
        }
        
        .statement-options h3 {
            margin-top: 0;
            color: var(--primary-dark);
        }
        
        .radio-group {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .radio-option {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .statement-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1.5rem;
        }
        
        .statement-table th {
            background-color: var(--primary-dark);
            color: white;
            padding: 1rem;
            text-align: left;
        }
        
        .statement-table td {
            padding: 1rem;
            border-bottom: 1px solid var(--border);
        }
        
        .statement-table tr:nth-child(even) {
            background-color: var(--primary-light);
        }
        
        .amount-positive {
            color: var(--success);
            font-weight: 600;
        }
        
        .amount-negative {
            color: var(--danger);
            font-weight: 600;
        }
        
        .no-statements {
            text-align: center;
            padding: 2rem;
            color: var(--gray);
            font-style: italic;
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
            <span class="welcome-text">Welcome, <%= username %></span>
            <a href="logout.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="dashboard-grid">
            <div class="main-content">
                <h2 class="page-title"><i class="fas fa-file-invoice"></i> Account Statements</h2>
                
                <div class="statement-options">
                    <h3>Generate Statement</h3>
                    <form action="statements.jsp" method="post">
                        <div class="form-group">
                            <label for="accountNumber">Select Account:</label>
                            <select name="accountNumber" id="accountNumber" class="form-control" required>
                                <option value="">Select an account</option>
                                <%
                                    try {
                                        // Dynamically load DBConnection class
                                        Class<?> dbConnClass = Class.forName("DBConnection");
                                        Object dbConn = dbConnClass.newInstance();
                                        Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
                                        
                                        // Get current accounts
                                        PreparedStatement chkStmt = conn.prepareStatement(
                                            "SELECT CheckingAccountNumber FROM CheckingAccount WHERE CustomerID = ?"
                                        );
                                        chkStmt.setString(1, username);
                                        ResultSet chkRs = chkStmt.executeQuery();
                                        
                                        while (chkRs.next()) {
                                            out.println("<option value='" + chkRs.getString("CheckingAccountNumber") + "'>" + chkRs.getString("CheckingAccountNumber") + " (Current Account)</option>");
                                        }
                                        
                                        chkRs.close();
                                        chkStmt.close();
                                        
                                        // Get savings accounts
                                        PreparedStatement savStmt = conn.prepareStatement(
                                            "SELECT SavingsAccountNumber FROM SavingsAccount WHERE CustomerID = ?"
                                        );
                                        savStmt.setString(1, username);
                                        ResultSet savRs = savStmt.executeQuery();
                                        
                                        while (savRs.next()) {
                                            out.println("<option value='" + savRs.getString("SavingsAccountNumber") + "'>" + savRs.getString("SavingsAccountNumber") + " (Savings Account)</option>");
                                        }
                                        
                                        savRs.close();
                                        savStmt.close();
                                        dbConnClass.getMethod("closeConn").invoke(dbConn);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Statement Period:</label>
                            <div class="radio-group">
                                <div class="radio-option">
                                    <input type="radio" id="lastMonth" name="period" value="lastMonth" checked>
                                    <label for="lastMonth">Last Month</label>
                                </div>
                                <div class="radio-option">
                                    <input type="radio" id="last3Months" name="period" value="last3Months">
                                    <label for="last3Months">Last 3 Months</label>
                                </div>
                                <div class="radio-option">
                                    <input type="radio" id="custom" name="period" value="custom">
                                    <label for="custom">Custom Date Range</label>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group" id="dateRange" style="display: none;">
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                <div>
                                    <label for="startDate">Start Date:</label>
                                    <input type="date" name="startDate" id="startDate" class="form-control">
                                </div>
                                <div>
                                    <label for="endDate">End Date:</label>
                                    <input type="date" name="endDate" id="endDate" class="form-control">
                                </div>
                            </div>
                        </div>
                        
                        <button type="submit" class="btn"><i class="fas fa-download"></i> Generate Statement</button>
                        <button type="button" class="btn btn-secondary" onclick="window.print()"><i class="fas fa-print"></i> Print Statement</button>
                    </form>
                </div>
                
                <%
                    String accountNumber = request.getParameter("accountNumber");
                    if (accountNumber != null && !accountNumber.isEmpty()) {
                        try {
                            // Dynamically load DBConnection class
                            Class<?> dbConnClass = Class.forName("DBConnection");
                            Object dbConn = dbConnClass.newInstance();
                            Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
                            
                            // Get account type
                            String accountType = "";
                            PreparedStatement chkStmt = conn.prepareStatement(
                                "SELECT 'Current' as type FROM CheckingAccount WHERE CheckingAccountNumber = ? AND CustomerID = ?"
                            );
                            chkStmt.setString(1, accountNumber);
                            chkStmt.setString(2, username);
                            ResultSet chkRs = chkStmt.executeQuery();
                            
                            if (chkRs.next()) {
                                accountType = chkRs.getString("type");
                            } else {
                                PreparedStatement savStmt = conn.prepareStatement(
                                    "SELECT 'Savings' as type FROM SavingsAccount WHERE SavingsAccountNumber = ? AND CustomerID = ?"
                                );
                                savStmt.setString(1, accountNumber);
                                savStmt.setString(2, username);
                                ResultSet savRs = savStmt.executeQuery();
                                
                                if (savRs.next()) {
                                    accountType = savRs.getString("type");
                                }
                                
                                savRs.close();
                                savStmt.close();
                            }
                            
                            chkRs.close();
                            chkStmt.close();
                            
                            // Get transactions for the account
                            PreparedStatement transStmt = conn.prepareStatement(
                                "SELECT * FROM Transactions WHERE (FromAccount = ? OR ToAccount = ?) AND CustomerID = ? ORDER BY TransactionDate DESC, TransactionTime DESC"
                            );
                            transStmt.setString(1, accountNumber);
                            transStmt.setString(2, accountNumber);
                            transStmt.setString(3, username);
                            ResultSet transRs = transStmt.executeQuery();
                            
                            if (transRs.next()) {
                                out.println("<h3>Statement for " + accountType + " Account: " + accountNumber + "</h3>");
                                out.println("<table class='statement-table'>");
                                out.println("<thead>");
                                out.println("<tr>");
                                out.println("<th>Date</th>");
                                out.println("<th>Description</th>");
                                out.println("<th>Reference</th>");
                                out.println("<th>Debit (Rs.)</th>");
                                out.println("<th>Credit (Rs.)</th>");
                                out.println("<th>Balance (Rs.)</th>");
                                out.println("</tr>");
                                out.println("</thead>");
                                out.println("<tbody>");
                                
                                do {
                                    String transactionType = transRs.getString("TransactionType");
                                    float amount = transRs.getFloat("TransactionAmount");
                                    String transactionNumber = transRs.getString("TransactionNumber");
                                    String date = transRs.getString("TransactionDate");
                                    
                                    out.println("<tr>");
                                    out.println("<td>" + date + "</td>");
                                    out.println("<td>" + transactionType + "</td>");
                                    out.println("<td>" + transactionNumber + "</td>");
                                    
                                    if (transactionType.contains("Deposit") || transactionType.contains("In")) {
                                        out.println("<td></td>");
                                        out.println("<td class='amount-positive'>Rs." + String.format("%.2f", amount) + "</td>");
                                    } else {
                                        out.println("<td class='amount-negative'>Rs." + String.format("%.2f", amount) + "</td>");
                                        out.println("<td></td>");
                                    }
                                    
                                    // For simplicity, we're not calculating running balance here
                                    out.println("<td>--</td>");
                                    out.println("</tr>");
                                } while (transRs.next());
                                
                                out.println("</tbody>");
                                out.println("</table>");
                            } else {
                                out.println("<div class='no-statements'>No transactions found for this account.</div>");
                            }
                            
                            transRs.close();
                            transStmt.close();
                            dbConnClass.getMethod("closeConn").invoke(dbConn);
                        } catch (Exception e) {
                            out.println("<div class='no-statements'>Error generating statement: " + e.getMessage() + "</div>");
                            e.printStackTrace();
                        }
                    }
                %>
            </div>
            
            <div class="sidebar">
                <button class="menu-toggle" id="menuToggle">
                    <span class="bar"></span>
                    <span class="bar"></span>
                    <span class="bar"></span>
                </button>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-bars"></i> Menu</h3>
                    <ul class="nav-links" id="navLinks">
                        <li><a href="dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
                        <li><a href="openAccount.jsp"><i class="fas fa-plus-circle"></i> Open Account</a></li>
                        <li><a href="deposit.jsp"><i class="fas fa-arrow-down"></i> Deposit</a></li>
                        <li><a href="withdraw.jsp"><i class="fas fa-arrow-up"></i> Withdraw</a></li>
                        <li><a href="transfer.jsp"><i class="fas fa-exchange-alt"></i> Transfer</a></li>
                        <li><a href="transactions.jsp"><i class="fas fa-history"></i> Transactions</a></li>
                        <li><a href="statements.jsp" class="active"><i class="fas fa-file-invoice"></i> Statements</a></li>
                        <li><a href="cards.jsp"><i class="fas fa-credit-card"></i> Cards</a></li>
                        <li><a href="upi.jsp"><i class="fas fa-mobile-alt"></i> UPI</a></li>
                        <li><a href="bills.jsp"><i class="fas fa-receipt"></i> Bill Payments</a></li>
                    </ul>
                </div>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-info-circle"></i> Quick Info</h3>
                    <p>View and download account statements for any period. You can print or save your statements for your records.</p>
                </div>
            </div>
        </div>
    </div>
    
    <script>
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
        
        // Show/hide date range based on selection
        document.querySelectorAll('input[name="period"]').forEach(function(radio) {
            radio.addEventListener('change', function() {
                var dateRange = document.getElementById('dateRange');
                if (this.value === 'custom') {
                    dateRange.style.display = 'block';
                } else {
                    dateRange.style.display = 'none';
                }
            });
        });
        
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
    </script>
</body>
</html>