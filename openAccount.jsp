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
    
    String accountType = request.getParameter("accountType");
    String initialDepositStr = request.getParameter("initialDeposit");
    String interestRateStr = request.getParameter("interestRate");
    
    // Only process the form if all required parameters are present and not empty
    if (accountType != null && initialDepositStr != null && !accountType.isEmpty() && !initialDepositStr.isEmpty()) {
        try {
            float initialDeposit = Float.parseFloat(initialDepositStr);
            float interestRate = 0.0f;
            
            if (accountType.equals("savings") && interestRateStr != null && !interestRateStr.isEmpty()) {
                interestRate = Float.parseFloat(interestRateStr);
            }
            
            // Generate account number
            String accountNumber = "CUTMAP" + String.format("%06d", new Random().nextInt(999999));
            
            // Dynamically load DatabaseUtil class and create the account in the database
            boolean accountCreated = false;
            Class<?> dbUtilClass = Class.forName("DatabaseUtil");
            if (accountType.equals("current")) {
                accountCreated = (Boolean) dbUtilClass.getMethod("createCheckingAccount", String.class, String.class, float.class, String.class)
                    .invoke(null, accountNumber, name, initialDeposit, username);
                if (accountCreated) {
                    session.setAttribute("success", "Current account opened successfully with account number: " + accountNumber);
                }
            } else if (accountType.equals("savings")) {
                accountCreated = (Boolean) dbUtilClass.getMethod("createSavingsAccount", String.class, String.class, float.class, float.class, String.class)
                    .invoke(null, accountNumber, name, initialDeposit, interestRate, username);
                if (accountCreated) {
                    session.setAttribute("success", "Savings account opened successfully with account number: " + accountNumber);
                }
            }
            
            if (!accountCreated) {
                session.setAttribute("error", "Failed to create " + accountType + " account. Please try again.");
            }
            
            response.sendRedirect("dashboard.jsp");
            return;
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error opening account: " + e.getMessage());
            response.sendRedirect("dashboard.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Open Account - Centurion Bank</title>
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
            position: relative;
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
            <span class="welcome-text">Welcome, <%= name != null ? name : username %></span>
            <a href="logout.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="dashboard-grid">
            <div class="main-content">
                <h2 class="section-title"><i class="fas fa-plus-circle"></i> Open New Account</h2>
                
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
                
                <form action="openAccount.jsp" method="post">
                    <div class="form-group">
                        <label for="accountType"><i class="fas fa-user"></i> Account Type:</label>
                        <select id="accountType" name="accountType" class="form-control" required>
                            <option value="">Select Account Type</option>
                            <option value="current">Current Account</option>
                            <option value="savings">Savings Account</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="initialDeposit"><i class="fas fa-rupee-sign"></i> Initial Deposit Amount (Rs.):</label>
                        <input type="number" id="initialDeposit" name="initialDeposit" class="form-control" min="0" step="0.01" required>
                    </div>
                    
                    <div class="form-group" id="interestRateField" style="display: none;">
                        <label for="interestRate"><i class="fas fa-percent"></i> Interest Rate (%):</label>
                        <input type="number" id="interestRate" name="interestRate" class="form-control" min="0" step="0.01">
                    </div>
                    
                    <button type="submit" class="btn btn-primary">Open Account</button>
                </form>
                
                <div style="margin-top: 1.5rem;">
                    <a href="dashboard.jsp" class="btn btn-primary"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                </div>
            </div>
            
            <div class="sidebar">
                <div class="sidebar-section">
                    <h3 class="sidebar-title"><i class="fas fa-bars"></i> Menu</h3>
                    <ul class="nav-links">
                        <li><a href="dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
                        <li><a href="openAccount.jsp" class="active"><i class="fas fa-plus-circle"></i> Open Account</a></li>
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
                    <h3 class="sidebar-title"><i class="fas fa-info-circle"></i> Account Information</h3>
                    <p>Open a new account with Centurion Bank. Choose between Current and Savings accounts based on your needs.</p>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        document.getElementById('accountType').addEventListener('change', function() {
            var interestRateField = document.getElementById('interestRateField');
            if (this.value === 'savings') {
                interestRateField.style.display = 'block';
            } else {
                interestRateField.style.display = 'none';
            }
        });
    </script>
</body>
</html>