<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    // Handle form submission for new card request
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String accountNumber = request.getParameter("accountNumber");
        String cardType = request.getParameter("cardType");
        
        if (accountNumber != null && cardType != null && !accountNumber.isEmpty() && !cardType.isEmpty()) {
            try {
                // Validate that the account belongs to the user
                Class<?> dbConnClass = Class.forName("DBConnection");
                Object dbConn = dbConnClass.newInstance();
                Connection conn = (Connection) dbConnClass.getMethod("openConn").invoke(dbConn);
                
                boolean accountValid = false;
                
                // Check if it's a checking account
                PreparedStatement chkStmt = conn.prepareStatement(
                    "SELECT CheckingAccountNumber FROM CheckingAccount WHERE CheckingAccountNumber = ? AND CustomerID = ?"
                );
                chkStmt.setString(1, accountNumber);
                chkStmt.setString(2, username);
                ResultSet chkRs = chkStmt.executeQuery();
                
                if (chkRs.next()) {
                    accountValid = true;
                }
                chkRs.close();
                chkStmt.close();
                
                // If not a checking account, check if it's a savings account
                if (!accountValid) {
                    PreparedStatement savStmt = conn.prepareStatement(
                        "SELECT SavingsAccountNumber FROM SavingsAccount WHERE SavingsAccountNumber = ? AND CustomerID = ?"
                    );
                    savStmt.setString(1, accountNumber);
                    savStmt.setString(2, username);
                    ResultSet savRs = savStmt.executeQuery();
                    
                    if (savRs.next()) {
                        accountValid = true;
                    }
                    savRs.close();
                    savStmt.close();
                }
                
                dbConnClass.getMethod("closeConn").invoke(dbConn);
                
                if (accountValid) {
                    // In a real application, this would generate a card request
                    // For now, we'll just show a success message
                    session.setAttribute("success", "Card request for " + cardType + " card submitted successfully for account " + accountNumber + ".");
                } else {
                    session.setAttribute("error", "Invalid account number or account does not belong to you.");
                }
            } catch (Exception e) {
                session.setAttribute("error", "Error processing card request: " + e.getMessage());
                e.printStackTrace();
            }
            
            response.sendRedirect("cards.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Card Services - Centurion Bank</title>
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
        
        .card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
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
        
        .card {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary-medium));
            color: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            position: relative;
            overflow: hidden;
        }
        
        .card::before {
            content: "";
            position: absolute;
            top: -50px;
            right: -50px;
            width: 100px;
            height: 100px;
            background: rgba(255,255,255,0.1);
            border-radius: 50%;
        }
        
        .card-type {
            font-size: 1.2rem;
            margin-bottom: 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .card-number {
            font-family: 'Courier New', monospace;
            font-size: 1.3rem;
            letter-spacing: 2px;
            margin-bottom: 1.5rem;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        
        .card-details {
            display: flex;
            justify-content: space-between;
        }
        
        .card-detail {
            font-size: 0.9rem;
            opacity: 0.8;
        }
        
        .card-detail-value {
            font-size: 1rem;
            font-weight: 600;
            margin-top: 0.2rem;
        }
        
        .card-actions {
            margin-top: 1.5rem;
            display: flex;
            gap: 0.5rem;
        }
        
        .card-btn {
            flex: 1;
            padding: 0.5rem;
            background: rgba(255,255,255,0.2);
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 0.8rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .card-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .services-section {
            background-color: var(--primary-light);
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
        }
        
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        
        .service-card {
            background: white;
            border-radius: 8px;
            padding: 1rem;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .service-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .service-icon {
            font-size: 2rem;
            color: var(--primary-dark);
            margin-bottom: 0.5rem;
        }
        
        .service-title {
            font-weight: 500;
            color: var(--dark);
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
                <h2 class="page-title"><i class="fas fa-credit-card"></i> Card Services</h2>
                
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
                
                <div class="card-grid">
                    <div class="card">
                        <div class="card-type">
                            <span>Credit Card</span>
                            <i class="fab fa-cc-visa"></i>
                        </div>
                        <div class="card-number">**** **** **** 1234</div>
                        <div class="card-details">
                            <div class="card-detail">
                                <div>Card Holder</div>
                                <div class="card-detail-value">USER NAME</div>
                            </div>
                            <div class="card-detail">
                                <div>Expiry</div>
                                <div class="card-detail-value">12/25</div>
                            </div>
                        </div>
                        <div class="card-actions">
                            <button class="card-btn">Block</button>
                            <button class="card-btn">Report</button>
                        </div>
                    </div>
                    
                    <div class="card">
                        <div class="card-type">
                            <span>Debit Card</span>
                            <i class="fab fa-cc-mastercard"></i>
                        </div>
                        <div class="card-number">**** **** **** 5678</div>
                        <div class="card-details">
                            <div class="card-detail">
                                <div>Card Holder</div>
                                <div class="card-detail-value">USER NAME</div>
                            </div>
                            <div class="card-detail">
                                <div>Expiry</div>
                                <div class="card-detail-value">06/26</div>
                            </div>
                        </div>
                        <div class="card-actions">
                            <button class="card-btn">Block</button>
                            <button class="card-btn">Report</button>
                        </div>
                    </div>
                </div>
                
                <div class="services-section">
                    <h3>Card Services</h3>
                    <div class="services-grid">
                        <div class="service-card">
                            <div class="service-icon">
                                <i class="fas fa-plus-circle"></i>
                            </div>
                            <div class="service-title">Apply for New Card</div>
                        </div>
                        
                        <div class="service-card">
                            <div class="service-icon">
                                <i class="fas fa-sync-alt"></i>
                            </div>
                            <div class="service-title">Replace Card</div>
                        </div>
                        
                        <div class="service-card">
                            <div class="service-icon">
                                <i class="fas fa-lock"></i>
                            </div>
                            <div class="service-title">Block Card</div>
                        </div>
                        
                        <div class="service-card">
                            <div class="service-icon">
                                <i class="fas fa-key"></i>
                            </div>
                            <div class="service-title">Change PIN</div>
                        </div>
                        
                        <div class="service-card">
                            <div class="service-icon">
                                <i class="fas fa-file-invoice"></i>
                            </div>
                            <div class="service-title">Card Statement</div>
                        </div>
                        
                        <div class="service-card">
                            <div class="service-icon">
                                <i class="fas fa-rupee-sign"></i>
                            </div>
                            <div class="service-title">Set Limits</div>
                        </div>
                    </div>
                </div>
                
                <h3>Request New Card</h3>
                <form action="cards.jsp" method="post">
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
                        <label for="cardType">Card Type:</label>
                        <select name="cardType" id="cardType" class="form-control" required>
                            <option value="">Select card type</option>
                            <option value="debit">Debit Card</option>
                            <option value="credit">Credit Card</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn btn-block"><i class="fas fa-paper-plane"></i> Submit Request</button>
                </form>
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
                        <li><a href="cards.jsp" class="active"><i class="fas fa-credit-card"></i> Cards</a></li>
                        <li><a href="upi.jsp"><i class="fas fa-mobile-alt"></i> UPI</a></li>
                        <li><a href="bills.jsp"><i class="fas fa-receipt"></i> Bill Payments</a></li>
                    </ul>
                </div>
                
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-info-circle"></i> Quick Info</h3>
                    <p>Manage your debit and credit cards. Request new cards, block lost cards, and access card services.</p>
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