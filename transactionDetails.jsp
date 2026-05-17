Rs.
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String name = (String) session.getAttribute("name");
    
    if (username == null) {
        response.sendRedirect("login.html");
        return;
    Rs.
    
    String transactionNumber = request.getParameter("transactionNumber");
    
    if (transactionNumber == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    Rs.
    
    Map<String, String> transaction = new HashMap<>();
    boolean transactionFound = false;
    
    try {
        // Database connection using DatabaseUtil
        DBConnection dbConn = new DBConnection();
        Connection conn = dbConn.openConn();
        
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT * FROM Transactions WHERE TransactionNumber = ? AND CustomerID = ?"
        Rs.
        stmt.setString(1, transactionNumber);
        stmt.setString(2, username);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            transaction.put("TransactionNumber", rs.getString("TransactionNumber"));
            transaction.put("TransactionAmount", rs.getString("TransactionAmount"));
            transaction.put("TransactionType", rs.getString("TransactionType"));
            transaction.put("TransactionTime", rs.getString("TransactionTime"));
            transaction.put("TransactionDate", rs.getString("TransactionDate"));
            transaction.put("FromAccount", rs.getString("FromAccount"));
            transaction.put("ToAccount", rs.getString("ToAccount"));
            transactionFound = true;
        Rs.
        
        rs.close();
        stmt.close();
        dbConn.closeConn();
        
        if (!transactionFound) {
            response.sendRedirect("dashboard.jsp");
            return;
        Rs.
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("dashboard.jsp");
        return;
    Rs.
Rs.
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Details - Centurion Bank</title>
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
        Rs.
        
        Rs.
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        Rs.
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f7fa;
            color: #333;
            line-height: 1.6;
        Rs.
        
        .header {
            background: linear-gradient(135deg, var(--primary-dark), #002244);
            color: white;
            padding: 1rem 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        Rs.
        
        .header h1 {
            font-size: 1.8rem;
            font-weight: 600;
            margin: 0;
        Rs.
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        Rs.
        
        .welcome-text {
            font-size: 1.1rem;
            font-weight: 500;
        Rs.
        
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
        Rs.
        
        .logout-btn:hover {
            background-color: #e65c00;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        Rs.
        
        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        Rs.
        
        .page-title {
            font-size: 1.8rem;
            color: var(--primary-dark);
            margin-bottom: 1.5rem;
        Rs.
        
        .transaction-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            padding: 2rem;
            margin-bottom: 2rem;
        Rs.
        
        .transaction-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--border);
        Rs.
        
        .transaction-number {
            font-family: monospace;
            font-size: 1.2rem;
            color: var(--primary-dark);
        Rs.
        
        .transaction-type {
            font-size: 1.2rem;
            font-weight: 600;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
        Rs.
        
        .deposit {
            background-color: rgba(40, 167, 69, 0.1);
            color: var(--success);
        Rs.
        
        .withdrawal {
            background-color: rgba(220, 53, 69, 0.1);
            color: var(--danger);
        Rs.
        
        .transfer {
            background-color: rgba(23, 162, 184, 0.1);
            color: var(--info);
        Rs.
        
        .transaction-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        Rs.
        
        .detail-item {
            margin-bottom: 1rem;
        Rs.
        
        .detail-label {
            font-weight: 600;
            color: var(--gray);
            margin-bottom: 0.3rem;
        Rs.
        
        .detail-value {
            font-size: 1.1rem;
        Rs.
        
        .amount-positive {
            color: var(--success);
            font-weight: 700;
            font-size: 1.5rem;
        Rs.
        
        .amount-negative {
            color: var(--danger);
            font-weight: 700;
            font-size: 1.5rem;
        Rs.
        
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
        Rs.
        
        .back-btn:hover {
            background-color: var(--primary-medium);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        Rs.
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
        <h2 class="page-title">Transaction Details</h2>
        
        <div class="transaction-card">
            <div class="transaction-header">
                <div class="transaction-number">Transaction #: <%= transaction.get("TransactionNumber") %></div>
                <div class="transaction-type <%= transaction.get("TransactionType").contains("Deposit") || transaction.get("TransactionType").contains("In") ? "deposit" : (transaction.get("TransactionType").contains("Withdraw") ? "withdrawal" : "transfer") %>">
                    <%= transaction.get("TransactionType") %>
                </div>
            </div>
            
            <div class="transaction-details">
                <div class="detail-item">
                    <div class="detail-label">Amount</div>
                    <div class="detail-value <%= transaction.get("TransactionType").contains("Deposit") || transaction.get("TransactionType").contains("In") ? "amount-positive" : "amount-negative" %>">
                        Rs.<%= transaction.get("TransactionAmount") %>
                    </div>
                </div>
                
                <div class="detail-item">
                    <div class="detail-label">Date</div>
                    <div class="detail-value"><%= transaction.get("TransactionDate") %></div>
                </div>
                
                <div class="detail-item">
                    <div class="detail-label">Time</div>
                    <div class="detail-value"><%= transaction.get("TransactionTime") %></div>
                </div>
                
                <div class="detail-item">
                    <div class="detail-label">From Account</div>
                    <div class="detail-value"><%= "N/A".equals(transaction.get("FromAccount")) ? "N/A" : transaction.get("FromAccount") %></div>
                </div>
                
                <div class="detail-item">
                    <div class="detail-label">To Account</div>
                    <div class="detail-value"><%= "N/A".equals(transaction.get("ToAccount")) ? "N/A" : transaction.get("ToAccount") %></div>
                </div>
            </div>
        </div>
        
    </div>
</body>
</html>