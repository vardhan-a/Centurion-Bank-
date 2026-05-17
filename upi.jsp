<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    // Handle form submission for UPI payment
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String upiId = request.getParameter("upiId");
        String accountNumber = request.getParameter("accountNumber");
        String amountStr = request.getParameter("amount");
        String remark = request.getParameter("remark");
        
        if (upiId != null && accountNumber != null && amountStr != null && 
            !upiId.isEmpty() && !accountNumber.isEmpty() && !amountStr.isEmpty()) {
            try {
                float amount = Float.parseFloat(amountStr);
                
                if (amount <= 0) {
                    session.setAttribute("error", "Amount must be greater than zero.");
                } else {
                    // Validate that the account belongs to the user
                    Class<?> dbConnClass = Class.forName("DBConnection");
                    Object dbConn = dbConnClass.newInstance();
                    Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
                    
                    boolean accountValid = false;
                    float currentBalance = 0.0f;
                    boolean isCheckingAccount = true;
                    
                    // Check if it's a checking account
                    PreparedStatement chkStmt = conn.prepareStatement(
                        "SELECT CheckingAccountNumber, Balance FROM CheckingAccount WHERE CheckingAccountNumber = ? AND CustomerID = ?"
                    );
                    chkStmt.setString(1, accountNumber);
                    chkStmt.setString(2, username);
                    ResultSet chkRs = chkStmt.executeQuery();
                    
                    if (chkRs.next()) {
                        accountValid = true;
                        currentBalance = chkRs.getFloat("Balance");
                    }
                    chkRs.close();
                    chkStmt.close();
                    
                    // If not a checking account, check if it's a savings account
                    if (!accountValid) {
                        PreparedStatement savStmt = conn.prepareStatement(
                            "SELECT SavingsAccountNumber, Balance FROM SavingsAccount WHERE SavingsAccountNumber = ? AND CustomerID = ?"
                        );
                        savStmt.setString(1, accountNumber);
                        savStmt.setString(2, username);
                        ResultSet savRs = savStmt.executeQuery();
                        
                        if (savRs.next()) {
                            accountValid = true;
                            currentBalance = savRs.getFloat("Balance");
                            isCheckingAccount = false;
                        }
                        savRs.close();
                        savStmt.close();
                    }
                    
                    if (accountValid) {
                        if (currentBalance >= amount) {
                            // Deduct amount from account
                            float newBalance = currentBalance - amount;
                            
                            PreparedStatement updateStmt;
                            if (isCheckingAccount) {
                                updateStmt = conn.prepareStatement(
                                    "UPDATE CheckingAccount SET Balance = ? WHERE CheckingAccountNumber = ?"
                                );
                            } else {
                                updateStmt = conn.prepareStatement(
                                    "UPDATE SavingsAccount SET Balance = ? WHERE SavingsAccountNumber = ?"
                                );
                            }
                            updateStmt.setFloat(1, newBalance);
                            updateStmt.setString(2, accountNumber);
                            updateStmt.executeUpdate();
                            updateStmt.close();
                            
                            // Record transaction
                            Class<?> dbUtilClass = Class.forName("DatabaseUtil");
                            String transactionNumber = "UPI" + System.currentTimeMillis();
                            dbUtilClass.getMethod("recordTransaction", String.class, float.class, String.class, String.class, String.class, String.class)
                                .invoke(null, transactionNumber, amount, "UPI Payment to " + upiId, accountNumber, "N/A", username);
                            
                            session.setAttribute("success", "UPI payment of Rs." + String.format("%.2f", amount) + " to " + upiId + " successful.");
                        } else {
                            session.setAttribute("error", "Insufficient funds in account " + accountNumber + ". Current balance: Rs." + String.format("%.2f", currentBalance));
                        }
                    } else {
                        session.setAttribute("error", "Invalid account number or account does not belong to you.");
                    }
                    
                    dbConnClass.getMethod("closeConn").invoke(dbConn);
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid amount entered.");
            } catch (Exception e) {
                session.setAttribute("error", "Error processing UPI payment: " + e.getMessage());
                e.printStackTrace();
            }
            
            response.sendRedirect("upi.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UPI Services - Centurion Bank</title>
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
        
        .upi-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 5px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .upi-icon {
            font-size: 4rem;
            color: var(--primary-dark);
            margin-bottom: 1rem;
        }
        
        .upi-vpa {
            background: var(--primary-light);
            padding: 1rem;
            border-radius: 8px;
            text-align: center;
            margin: 1rem 0;
            font-family: monospace;
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .upi-actions {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }
        
        .upi-action-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 1.5rem;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .upi-action-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-color: var(--primary-medium);
        }
        
        .action-icon {
            font-size: 2rem;
            color: var(--primary-dark);
            margin-bottom: 1rem;
        }
        
        .action-title {
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 0.5rem;
        }
        
        .action-desc {
            font-size: 0.9rem;
            color: var(--gray);
        }
        
        .form-section {
            background-color: var(--primary-light);
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
        }
        
        .form-section h3 {
            margin-top: 0;
            color: var(--primary-dark);
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
        
        .btn-block {
            display: block;
            width: 100%;
        }
        
        .btn-success {
            background-color: var(--success);
        }
        
        .btn-success:hover {
            background-color: #218838;
        }
        
        .transaction-history {
            margin-top: 2rem;
        }
        
        .transaction-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        
        .transaction-table th {
            background-color: var(--primary-dark);
            color: white;
            padding: 1rem;
            text-align: left;
        }
        
        .transaction-table td {
            padding: 1rem;
            border-bottom: 1px solid var(--border);
        }
        
        .transaction-table tr:nth-child(even) {
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
                <h2 class="page-title"><i class="fas fa-mobile-alt"></i> UPI Services</h2>
                
                <%
                    String successMessage = (String) session.getAttribute("success");
                    String errorMessage = (String) session.getAttribute("error");
                    if (successMessage != null) {
                %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <%
                    session.removeAttribute("success");
                    }
                    if (errorMessage != null) {
                %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
                <%
                    session.removeAttribute("error");
                    }
                %>
                
                <div class="upi-header">
                    <div class="upi-icon">
                        <i class="fas fa-qrcode"></i>
                    </div>
                    <h3>Unified Payments Interface</h3>
                    <p>Send and receive money instantly using UPI</p>
                    
                    <div class="upi-vpa">
                        <i class="fas fa-at"></i> username@centurionbank
                    </div>
                    
                    <p>Your UPI ID is linked to all your accounts</p>
                </div>
                
                <div class="upi-actions">
                    <div class="upi-action-card">
                        <div class="action-icon">
                            <i class="fas fa-arrow-down"></i>
                        </div>
                        <div class="action-title">Pay</div>
                        <div class="action-desc">Send money to contacts</div>
                    </div>
                    
                    <div class="upi-action-card">
                        <div class="action-icon">
                            <i class="fas fa-arrow-up"></i>
                        </div>
                        <div class="action-title">Request</div>
                        <div class="action-desc">Request money from contacts</div>
                    </div>
                    
                    <div class="upi-action-card">
                        <div class="action-icon">
                            <i class="fas fa-qrcode"></i>
                        </div>
                        <div class="action-title">Scan & Pay</div>
                        <div class="action-desc">Scan QR code to pay</div>
                    </div>
                    
                    <div class="upi-action-card">
                        <div class="action-icon">
                            <i class="fas fa-qrcode"></i>
                        </div>
                        <div class="action-title">Show QR</div>
                        <div class="action-desc">Show QR code to receive</div>
                    </div>
                </div>
                
                <div class="form-section">
                    <h3>Send Money via UPI</h3>
                    <form action="upi.jsp" method="post">
                        <div class="form-group">
                            <label for="upiId">Recipient's UPI ID:</label>
                            <input type="text" name="upiId" id="upiId" class="form-control" placeholder="example@upi" required>
                        </div>
                        
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
                            <label for="amount">Amount (Rs.):</label>
                            <input type="number" name="amount" id="amount" class="form-control" placeholder="0.00" min="1" step="0.01" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="remark">Remark (Optional):</label>
                            <input type="text" name="remark" id="remark" class="form-control" placeholder="Enter remark">
                        </div>
                        
                        <button type="submit" class="btn btn-success btn-block"><i class="fas fa-paper-plane"></i> Send Money</button>
                    </form>
                </div>
                
                <div class="transaction-history">
                    <h3>Recent UPI Transactions</h3>
                    <table class="transaction-table">
                        <thead>
                            <tr>
                                <th>Date & Time</th>
                                <th>To/From</th>
                                <th>Remark</th>
                                <th>Amount (Rs.)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>2023-06-15 14:30</td>
                                <td>friend@upi</td>
                                <td>Dinner</td>
                                <td class="amount-negative">500.00</td>
                                <td>Success</td>
                            </tr>
                            <tr>
                                <td>2023-06-14 10:15</td>
                                <td>store@upi</td>
                                <td>Groceries</td>
                                <td class="amount-negative">1250.75</td>
                                <td>Success</td>
                            </tr>
                            <tr>
                                <td>2023-06-12 16:45</td>
                                <td>colleague@upi</td>
                                <td>Repayment</td>
                                <td class="amount-positive">2000.00</td>
                                <td>Success</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
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
                        <li><a href="statements.jsp"><i class="fas fa-file-invoice"></i> Statements</a></li>
                        <li><a href="cards.jsp"><i class="fas fa-credit-card"></i> Cards</a></li>
                        <li><a href="upi.jsp" class="active"><i class="fas fa-mobile-alt"></i> UPI</a></li>
                        <li><a href="bills.jsp"><i class="fas fa-receipt"></i> Bill Payments</a></li>
                    </ul>
                </div>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-info-circle"></i> Quick Info</h3>
                    <p>Send and receive money instantly using UPI. Link your accounts to create a UPI ID and start transacting.</p>
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
    </script>
</body>
</html>