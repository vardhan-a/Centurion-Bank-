import java.sql.*;

public class test_db_connection {
    public static void main(String[] args) {
        try {
            // Load MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Database connection parameters
            String URL = "jdbc:mysql://localhost:3306/JavaClass?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
            String USERNAME = "root";
            String PASSWORD = "Vardhan2006@";
            
            // Connect to MySQL database
            Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("Database connection successful!");
            
            // Test a simple query
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM Account");
            
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Number of accounts in the database: " + count);
            }
            
            // Close connections
            rs.close();
            stmt.close();
            connection.close();
            
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found: " + e.getMessage());
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}