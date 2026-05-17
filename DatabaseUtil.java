/******************************************************************************
*	Database Utility Class for Centurion Bank								  *
*	This class provides common database operations							  *
*******************************************************************************/

import java.sql.*;

public class DatabaseUtil {
    
    /**
     * Get account balance from either checking or savings account
     * @param accountNumber The account number
     * @param isCheckingAccount true if checking account, false if savings account
     * @return The account balance, or -1 if account not found
     */
    public static float getAccountBalance(String accountNumber, boolean isCheckingAccount) {
        float balance = -1;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            String tableName = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_TABLE : DatabaseConfig.SAVINGS_ACCOUNT_TABLE;
            String accountColumn = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_NUMBER : DatabaseConfig.SAVINGS_ACCOUNT_NUMBER;
            String balanceColumn = isCheckingAccount ? DatabaseConfig.CHECKING_BALANCE : DatabaseConfig.SAVINGS_BALANCE;
            
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT " + balanceColumn + " FROM " + tableName + " WHERE " + accountColumn + " = ?");
            pstmt.setString(1, accountNumber);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                balance = rs.getFloat(balanceColumn);
            }
            
            rs.close();
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error getting account balance: " + e.getMessage());
            e.printStackTrace();
        }
        
        return balance;
    }
    
    /**
     * Update account balance in either checking or savings account
     * @param accountNumber The account number
     * @param newBalance The new balance
     * @param isCheckingAccount true if checking account, false if savings account
     * @return true if update successful, false otherwise
     */
    public static boolean updateAccountBalance(String accountNumber, float newBalance, boolean isCheckingAccount) {
        boolean success = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            String tableName = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_TABLE : DatabaseConfig.SAVINGS_ACCOUNT_TABLE;
            String accountColumn = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_NUMBER : DatabaseConfig.SAVINGS_ACCOUNT_NUMBER;
            String balanceColumn = isCheckingAccount ? DatabaseConfig.CHECKING_BALANCE : DatabaseConfig.SAVINGS_BALANCE;
            
            PreparedStatement pstmt = conn.prepareStatement(
                "UPDATE " + tableName + " SET " + balanceColumn + " = ? WHERE " + accountColumn + " = ?");
            pstmt.setFloat(1, newBalance);
            pstmt.setString(2, accountNumber);
            int rowsAffected = pstmt.executeUpdate();
            
            success = (rowsAffected > 0);
            
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error updating account balance: " + e.getMessage());
            e.printStackTrace();
        }
        
        return success;
    }
    
    /**
     * Record a transaction in the transactions table
     * @param transactionNumber The transaction number
     * @param amount The transaction amount
     * @param transactionType The transaction type
     * @param fromAccount The from account number
     * @param toAccount The to account number
     * @param customerId The customer ID
     * @return true if recording successful, false otherwise
     */
    public static boolean recordTransaction(String transactionNumber, float amount, String transactionType, 
                                          String fromAccount, String toAccount, String customerId) {
        boolean success = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            PreparedStatement pstmt = conn.prepareStatement(
                "INSERT INTO " + DatabaseConfig.TRANSACTIONS_TABLE + 
                " (" + DatabaseConfig.TRANSACTION_NUMBER + ", " + DatabaseConfig.TRANSACTION_AMOUNT + 
                ", " + DatabaseConfig.TRANSACTION_TYPE + ", " + DatabaseConfig.TRANSACTION_TIME + 
                ", " + DatabaseConfig.TRANSACTION_DATE + ", " + DatabaseConfig.TRANSACTION_FROM_ACCOUNT + 
                ", " + DatabaseConfig.TRANSACTION_TO_ACCOUNT + ", " + DatabaseConfig.TRANSACTION_CUSTOMER_ID + 
                ") VALUES (?, ?, ?, NOW(), NOW(), ?, ?, ?)");
            pstmt.setString(1, transactionNumber);
            pstmt.setFloat(2, amount);
            pstmt.setString(3, transactionType);
            pstmt.setString(4, fromAccount);
            pstmt.setString(5, toAccount);
            pstmt.setString(6, customerId);
            int rowsAffected = pstmt.executeUpdate();
            
            success = (rowsAffected > 0);
            
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error recording transaction: " + e.getMessage());
            e.printStackTrace();
        }
        
        return success;
    }
    
    /**
     * Check if an account exists and belongs to the specified user
     * @param accountNumber The account number
     * @param customerId The customer ID
     * @param isCheckingAccount true if checking account, false if savings account
     * @return true if account exists and belongs to user, false otherwise
     */
    public static boolean validateUserAccount(String accountNumber, String customerId, boolean isCheckingAccount) {
        boolean valid = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            String tableName = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_TABLE : DatabaseConfig.SAVINGS_ACCOUNT_TABLE;
            String accountColumn = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_NUMBER : DatabaseConfig.SAVINGS_ACCOUNT_NUMBER;
            String customerColumn = isCheckingAccount ? DatabaseConfig.CHECKING_CUSTOMER_ID : DatabaseConfig.SAVINGS_CUSTOMER_ID;
            
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT " + accountColumn + " FROM " + tableName + " WHERE " + accountColumn + " = ? AND " + customerColumn + " = ?");
            pstmt.setString(1, accountNumber);
            pstmt.setString(2, customerId);
            ResultSet rs = pstmt.executeQuery();
            
            valid = rs.next();
            
            rs.close();
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error validating user account: " + e.getMessage());
            e.printStackTrace();
        }
        
        return valid;
    }
    
    /**
     * Check if an account exists (regardless of owner)
     * @param accountNumber The account number
     * @param isCheckingAccount true if checking account, false if savings account
     * @return true if account exists, false otherwise
     */
    public static boolean accountExists(String accountNumber, boolean isCheckingAccount) {
        boolean exists = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            String tableName = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_TABLE : DatabaseConfig.SAVINGS_ACCOUNT_TABLE;
            String accountColumn = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_NUMBER : DatabaseConfig.SAVINGS_ACCOUNT_NUMBER;
            
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT " + accountColumn + " FROM " + tableName + " WHERE " + accountColumn + " = ?");
            pstmt.setString(1, accountNumber);
            ResultSet rs = pstmt.executeQuery();
            
            exists = rs.next();
            
            rs.close();
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error checking if account exists: " + e.getMessage());
            e.printStackTrace();
        }
        
        return exists;
    }
    
    /**
     * Get customer ID for an account
     * @param accountNumber The account number
     * @param isCheckingAccount true if checking account, false if savings account
     * @return The customer ID, or null if account not found
     */
    public static String getCustomerIdForAccount(String accountNumber, boolean isCheckingAccount) {
        String customerId = null;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            String tableName = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_TABLE : DatabaseConfig.SAVINGS_ACCOUNT_TABLE;
            String accountColumn = isCheckingAccount ? DatabaseConfig.CHECKING_ACCOUNT_NUMBER : DatabaseConfig.SAVINGS_ACCOUNT_NUMBER;
            String customerColumn = isCheckingAccount ? DatabaseConfig.CHECKING_CUSTOMER_ID : DatabaseConfig.SAVINGS_CUSTOMER_ID;
            
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT " + customerColumn + " FROM " + tableName + " WHERE " + accountColumn + " = ?");
            pstmt.setString(1, accountNumber);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                customerId = rs.getString(customerColumn);
            }
            
            rs.close();
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error getting customer ID for account: " + e.getMessage());
            e.printStackTrace();
        }
        
        return customerId;
    }
    
    /**
     * Create a new checking account
     * @param accountNumber The account number
     * @param customerName The customer name
     * @param initialBalance The initial balance
     * @param customerId The customer ID
     * @return true if creation successful, false otherwise
     */
    public static boolean createCheckingAccount(String accountNumber, String customerName, float initialBalance, String customerId) {
        boolean success = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            PreparedStatement pstmt = conn.prepareStatement(
                "INSERT INTO " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                " (" + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + ", " + DatabaseConfig.CHECKING_CUSTOMER_NAME + 
                ", " + DatabaseConfig.CHECKING_BALANCE + ", " + DatabaseConfig.CHECKING_CUSTOMER_ID + ") VALUES (?, ?, ?, ?)");
            pstmt.setString(1, accountNumber);
            pstmt.setString(2, customerName);
            pstmt.setFloat(3, initialBalance);
            pstmt.setString(4, customerId);
            int rowsAffected = pstmt.executeUpdate();
            
            success = (rowsAffected > 0);
            
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error creating checking account: " + e.getMessage());
            e.printStackTrace();
        }
        
        return success;
    }
    
    /**
     * Deposit funds to an account
     * @param accountNumber The account number
     * @param amount The amount to deposit
     * @param customerId The customer ID
     * @return true if deposit successful, false otherwise
     */
    public static boolean depositToAccount(String accountNumber, float amount, String customerId) {
        boolean success = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            // First check if it's a checking account
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT Balance FROM " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                " WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ? AND " + DatabaseConfig.CHECKING_CUSTOMER_ID + " = ?");
            checkStmt.setString(1, accountNumber);
            checkStmt.setString(2, customerId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                // It's a checking account
                float currentBalance = rs.getFloat("Balance");
                float newBalance = currentBalance + amount;
                
                PreparedStatement updateStmt = conn.prepareStatement(
                    "UPDATE " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                    " SET " + DatabaseConfig.CHECKING_BALANCE + " = ? WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ?");
                updateStmt.setFloat(1, newBalance);
                updateStmt.setString(2, accountNumber);
                int rowsAffected = updateStmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    // Record transaction
                    String transactionNumber = "DEP" + System.currentTimeMillis();
                    recordTransaction(transactionNumber, amount, "Deposit", "N/A", accountNumber, customerId);
                    success = true;
                }
                
                updateStmt.close();
            } else {
                // Check if it's a savings account
                checkStmt.close();
                checkStmt = conn.prepareStatement(
                    "SELECT Balance FROM " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                    " WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ? AND " + DatabaseConfig.SAVINGS_CUSTOMER_ID + " = ?");
                checkStmt.setString(1, accountNumber);
                checkStmt.setString(2, customerId);
                rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    // It's a savings account
                    float currentBalance = rs.getFloat("Balance");
                    float newBalance = currentBalance + amount;
                    
                    PreparedStatement updateStmt = conn.prepareStatement(
                        "UPDATE " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                        " SET " + DatabaseConfig.SAVINGS_BALANCE + " = ? WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ?");
                    updateStmt.setFloat(1, newBalance);
                    updateStmt.setString(2, accountNumber);
                    int rowsAffected = updateStmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        // Record transaction
                        String transactionNumber = "DEP" + System.currentTimeMillis();
                        recordTransaction(transactionNumber, amount, "Deposit", "N/A", accountNumber, customerId);
                        success = true;
                    }
                    
                    updateStmt.close();
                }
                rs.close();
            }
            
            checkStmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error depositing to account: " + e.getMessage());
            e.printStackTrace();
        }
        
        return success;
    }
    
    /**
     * Withdraw funds from an account
     * @param accountNumber The account number
     * @param amount The amount to withdraw
     * @param customerId The customer ID
     * @return true if withdrawal successful, false otherwise
     */
    public static boolean withdrawFromAccount(String accountNumber, float amount, String customerId) {
        boolean success = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            // First check if it's a checking account
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT Balance FROM " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                " WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ? AND " + DatabaseConfig.CHECKING_CUSTOMER_ID + " = ?");
            checkStmt.setString(1, accountNumber);
            checkStmt.setString(2, customerId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                // It's a checking account
                float currentBalance = rs.getFloat("Balance");
                if (currentBalance >= amount) {
                    float newBalance = currentBalance - amount;
                    
                    PreparedStatement updateStmt = conn.prepareStatement(
                        "UPDATE " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                        " SET " + DatabaseConfig.CHECKING_BALANCE + " = ? WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ?");
                    updateStmt.setFloat(1, newBalance);
                    updateStmt.setString(2, accountNumber);
                    int rowsAffected = updateStmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        // Record transaction
                        String transactionNumber = "WTH" + System.currentTimeMillis();
                        recordTransaction(transactionNumber, amount, "Withdrawal", accountNumber, "N/A", customerId);
                        success = true;
                    }
                    
                    updateStmt.close();
                }
            } else {
                // Check if it's a savings account
                checkStmt.close();
                checkStmt = conn.prepareStatement(
                    "SELECT Balance FROM " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                    " WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ? AND " + DatabaseConfig.SAVINGS_CUSTOMER_ID + " = ?");
                checkStmt.setString(1, accountNumber);
                checkStmt.setString(2, customerId);
                rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    // It's a savings account
                    float currentBalance = rs.getFloat("Balance");
                    if (currentBalance >= amount) {
                        float newBalance = currentBalance - amount;
                        
                        PreparedStatement updateStmt = conn.prepareStatement(
                            "UPDATE " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                            " SET " + DatabaseConfig.SAVINGS_BALANCE + " = ? WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ?");
                        updateStmt.setFloat(1, newBalance);
                        updateStmt.setString(2, accountNumber);
                        int rowsAffected = updateStmt.executeUpdate();
                        
                        if (rowsAffected > 0) {
                            // Record transaction
                            String transactionNumber = "WTH" + System.currentTimeMillis();
                            recordTransaction(transactionNumber, amount, "Withdrawal", accountNumber, "N/A", customerId);
                            success = true;
                        }
                        
                        updateStmt.close();
                    }
                }
                rs.close();
            }
            
            checkStmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error withdrawing from account: " + e.getMessage());
            e.printStackTrace();
        }
        
        return success;
    }
    
    /**
     * Transfer funds between accounts
     * @param fromAccount The account to transfer from
     * @param toAccount The account to transfer to
     * @param amount The amount to transfer
     * @param customerId The customer ID of the sender
     * @return true if transfer successful, false otherwise
     */
    public static boolean transferBetweenAccounts(String fromAccount, String toAccount, float amount, String customerId) {
        boolean success = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            // Start transaction
            conn.setAutoCommit(false);
            
            try {
                // Check if from account exists and belongs to user
                PreparedStatement fromCheckStmt = conn.prepareStatement(
                    "SELECT Balance FROM " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                    " WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ? AND " + DatabaseConfig.CHECKING_CUSTOMER_ID + " = ?");
                fromCheckStmt.setString(1, fromAccount);
                fromCheckStmt.setString(2, customerId);
                ResultSet fromRs = fromCheckStmt.executeQuery();
                
                float fromBalance = -1;
                boolean isFromChecking = true;
                
                if (fromRs.next()) {
                    fromBalance = fromRs.getFloat("Balance");
                } else {
                    // Check if it's a savings account
                    fromCheckStmt.close();
                    fromCheckStmt = conn.prepareStatement(
                        "SELECT Balance FROM " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                        " WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ? AND " + DatabaseConfig.SAVINGS_CUSTOMER_ID + " = ?");
                    fromCheckStmt.setString(1, fromAccount);
                    fromCheckStmt.setString(2, customerId);
                    fromRs = fromCheckStmt.executeQuery();
                    
                    if (fromRs.next()) {
                        fromBalance = fromRs.getFloat("Balance");
                        isFromChecking = false;
                    }
                    fromRs.close();
                }
                
                fromCheckStmt.close();
                
                if (fromBalance < 0) {
                    // From account not found or doesn't belong to user
                    throw new SQLException("From account not found or doesn't belong to user");
                }
                
                if (fromBalance < amount) {
                    // Insufficient funds
                    throw new SQLException("Insufficient funds");
                }
                
                // Check if to account exists (any user)
                PreparedStatement toCheckStmt = conn.prepareStatement(
                    "SELECT " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " FROM " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                    " WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ?");
                toCheckStmt.setString(1, toAccount);
                ResultSet toRs = toCheckStmt.executeQuery();
                
                boolean isToChecking = true;
                
                if (!toRs.next()) {
                    // Check if it's a savings account
                    toCheckStmt.close();
                    toCheckStmt = conn.prepareStatement(
                        "SELECT " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " FROM " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                        " WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ?");
                    toCheckStmt.setString(1, toAccount);
                    toRs = toCheckStmt.executeQuery();
                    
                    if (!toRs.next()) {
                        // To account not found
                        toCheckStmt.close();
                        throw new SQLException("To account not found");
                    }
                    isToChecking = false;
                }
                
                toRs.close();
                toCheckStmt.close();
                
                // Perform the transfer
                // 1. Deduct from fromAccount
                float newFromBalance = fromBalance - amount;
                PreparedStatement deductStmt;
                if (isFromChecking) {
                    deductStmt = conn.prepareStatement(
                        "UPDATE " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                        " SET " + DatabaseConfig.CHECKING_BALANCE + " = ? WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ?");
                } else {
                    deductStmt = conn.prepareStatement(
                        "UPDATE " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                        " SET " + DatabaseConfig.SAVINGS_BALANCE + " = ? WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ?");
                }
                deductStmt.setFloat(1, newFromBalance);
                deductStmt.setString(2, fromAccount);
                deductStmt.executeUpdate();
                deductStmt.close();
                
                // 2. Add to toAccount
                PreparedStatement addToStmt;
                if (isToChecking) {
                    addToStmt = conn.prepareStatement(
                        "UPDATE " + DatabaseConfig.CHECKING_ACCOUNT_TABLE + 
                        " SET " + DatabaseConfig.CHECKING_BALANCE + " = " + DatabaseConfig.CHECKING_BALANCE + " + ? WHERE " + DatabaseConfig.CHECKING_ACCOUNT_NUMBER + " = ?");
                } else {
                    addToStmt = conn.prepareStatement(
                        "UPDATE " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                        " SET " + DatabaseConfig.SAVINGS_BALANCE + " = " + DatabaseConfig.SAVINGS_BALANCE + " + ? WHERE " + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + " = ?");
                }
                addToStmt.setFloat(1, amount);
                addToStmt.setString(2, toAccount);
                addToStmt.executeUpdate();
                addToStmt.close();
                
                // 3. Record transaction
                String transactionNumber = "TRF" + System.currentTimeMillis();
                recordTransaction(transactionNumber, amount, "Transfer Out", fromAccount, toAccount, customerId);
                
                // Commit transaction
                conn.commit();
                success = true;
            } catch (SQLException e) {
                // Rollback transaction on error
                conn.rollback();
                throw e;
            } finally {
                // Reset auto-commit
                conn.setAutoCommit(true);
                dbConn.closeConn();
            }
        } catch (SQLException e) {
            System.err.println("Error transferring between accounts: " + e.getMessage());
            e.printStackTrace();
        }
        
        return success;
    }
    
    /**
     * Create a new savings account
     * @param accountNumber The account number
     * @param customerName The customer name
     * @param initialBalance The initial balance
     * @param interestRate The interest rate
     * @param customerId The customer ID
     * @return true if creation successful, false otherwise
     */
    public static boolean createSavingsAccount(String accountNumber, String customerName, float initialBalance, float interestRate, String customerId) {
        boolean success = false;
        try {
            DBConnection dbConn = new DBConnection();
            Connection conn = dbConn.openConn();
            
            PreparedStatement pstmt = conn.prepareStatement(
                "INSERT INTO " + DatabaseConfig.SAVINGS_ACCOUNT_TABLE + 
                " (" + DatabaseConfig.SAVINGS_ACCOUNT_NUMBER + ", " + DatabaseConfig.SAVINGS_CUSTOMER_NAME + 
                ", " + DatabaseConfig.SAVINGS_BALANCE + ", " + DatabaseConfig.SAVINGS_INTEREST_RATE + 
                ", " + DatabaseConfig.SAVINGS_CUSTOMER_ID + ") VALUES (?, ?, ?, ?, ?)");
            pstmt.setString(1, accountNumber);
            pstmt.setString(2, customerName);
            pstmt.setFloat(3, initialBalance);
            pstmt.setFloat(4, interestRate);
            pstmt.setString(5, customerId);
            int rowsAffected = pstmt.executeUpdate();
            
            success = (rowsAffected > 0);
            
            pstmt.close();
            dbConn.closeConn();
        } catch (SQLException e) {
            System.err.println("Error creating savings account: " + e.getMessage());
            e.printStackTrace();
        }
        
        return success;
    }
}