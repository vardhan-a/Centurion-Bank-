public class DatabaseConfig {
    // Database connection parameters
    public static final String URL = "jdbc:mysql://localhost:3306/JavaClass?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    public static final String USERNAME = "root";
    public static final String PASSWORD = "Vardhan2006@"; // In production, this should be encrypted or stored in environment variables
    
    // Database table names
    public static final String ACCOUNT_TABLE = "Account";
    public static final String CHECKING_ACCOUNT_TABLE = "CheckingAccount";
    public static final String SAVINGS_ACCOUNT_TABLE = "SavingsAccount";
    public static final String TRANSACTIONS_TABLE = "Transactions";
    
    // Column names for Account table
    public static final String ACCOUNT_USERNAME = "Username";
    public static final String ACCOUNT_PASSWORD = "Password";
    public static final String ACCOUNT_NAME = "Name";
    
    // Column names for CheckingAccount table
    public static final String CHECKING_ACCOUNT_NUMBER = "CheckingAccountNumber";
    public static final String CHECKING_CUSTOMER_NAME = "CustomerName";
    public static final String CHECKING_BALANCE = "Balance";
    public static final String CHECKING_CUSTOMER_ID = "CustomerID";
    
    // Column names for SavingsAccount table
    public static final String SAVINGS_ACCOUNT_NUMBER = "SavingsAccountNumber";
    public static final String SAVINGS_CUSTOMER_NAME = "CustomerName";
    public static final String SAVINGS_BALANCE = "Balance";
    public static final String SAVINGS_INTEREST_RATE = "InterestRate";
    public static final String SAVINGS_CUSTOMER_ID = "CustomerID";
    
    // Column names for Transactions table
    public static final String TRANSACTION_NUMBER = "TransactionNumber";
    public static final String TRANSACTION_AMOUNT = "TransactionAmount";
    public static final String TRANSACTION_TYPE = "TransactionType";
    public static final String TRANSACTION_TIME = "TransactionTime";
    public static final String TRANSACTION_DATE = "TransactionDate";
    public static final String TRANSACTION_FROM_ACCOUNT = "FromAccount";
    public static final String TRANSACTION_TO_ACCOUNT = "ToAccount";
    public static final String TRANSACTION_CUSTOMER_ID = "CustomerID";
}