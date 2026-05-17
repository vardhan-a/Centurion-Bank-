<%@ page import="java.sql.*, java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String name = (String) session.getAttribute("name");
    
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    String accountNumber = request.getParameter("accountNumber");
    String accountType = request.getParameter("accountType");
    
    if (accountNumber == null || accountType == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    float balance = 0.0f;
    boolean accountFound = false;
    
    try {
        // Dynamically load DBConnection class
        Class<?> dbConnClass = Class.forName("DBConnection");
        Object dbConn = dbConnClass.newInstance();
        Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
        
        if ("current".equals(accountType)) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT Balance FROM CheckingAccount WHERE CheckingAccountNumber = ? AND CustomerID = ?"
            );
            stmt.setString(1, accountNumber);
            stmt.setString(2, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                balance = rs.getFloat("Balance");
                accountFound = true;
            }
            rs.close();
            stmt.close();
        } else if ("savings".equals(accountType)) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT Balance FROM SavingsAccount WHERE SavingsAccountNumber = ? AND CustomerID = ?"
            );
            stmt.setString(1, accountNumber);
            stmt.setString(2, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                balance = rs.getFloat("Balance");
                accountFound = true;
            }
            rs.close();
            stmt.close();
        }
        
        dbConnClass.getMethod("closeConn").invoke(dbConn);
        
        if (!accountFound) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Details - Centurion Bank</title>
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
        
        .page-title {
            font-size: 1.8rem;
            color: var(--primary-dark);
            margin-bottom: 1.5rem;
        }
        
        .account-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            padding: 2rem;
            margin-bottom: 2rem;
            text-align: center;
        }
        
        .account-type {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary-dark);
            margin-bottom: 1rem;
        }
        
        .account-number {
            font-family: monospace;
            color: var(--gray);
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
        }
        
        .account-balance {
            font-size: 3rem;
            font-weight: 700;
            color: var(--success);
            margin: 1rem 0;
        }
        
        .balance-label {
            font-size: 1.2rem;
            color: var(--gray);
        }
        
        .actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
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
        
        .back-btn {
            display: inline-block;
            padding: 0.75rem 1.5rem;
            background-color: var(--primary-dark);
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 1rem;
            font-weight: 500;
            transition: all 0.3s ease;
            margin-top: 1rem;
        }
        
        .back-btn:hover {
            background-color: var(--primary-medium);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
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
        <h2 class="page-title">Account Details</h2>
        
        <div class="account-card">
            <div class="account-type">
                <i class="fas fa-<%= "current".equals(accountType) ? "money-check" : "piggy-bank" %>"></i>
                <%= "current".equals(accountType) ? "Current Account" : "Savings Account" %>
            </div>
            <div class="account-number"><%= accountNumber %></div>
            <div class="balance-label">Current Balance</div>
            <div class="account-balance">Rs.<%= String.format("%.2f", balance) %></div>
        </div>
        
        <div class="actions">
            <a href="deposit.jsp?accountNumber=<%= accountNumber %>" class="action-btn btn-deposit">
                <i class="fas fa-arrow-down"></i>
                <span>Deposit</span>
            </a>
            <a href="withdraw.jsp?accountNumber=<%= accountNumber %>" class="action-btn btn-withdraw">
                <i class="fas fa-arrow-up"></i>
                <span>Withdraw</span>
            </a>
            <a href="transfer.jsp?fromAccount=<%= accountNumber %>" class="action-btn btn-transfer">
                <i class="fas fa-exchange-alt"></i>
                <span>Transfer</span>
            </a>
        </div>
        
    </div>
</body>
</html>