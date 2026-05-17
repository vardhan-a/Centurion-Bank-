/******************************************************************************
*	Program Author: Dr. Yongming Tang for CSCI 6810 Java and the Internet	  *
*	Date: September, 2012													  *
*******************************************************************************/

import java.util.*;
import java.sql.*;

public class DBConnection {

    private Connection connection;
    private String URL;
    private String username;
    private String password;

    public DBConnection() {
        // MySQL connection string from configuration file
        URL = DatabaseConfig.URL;
        username = DatabaseConfig.USERNAME;
        password = DatabaseConfig.PASSWORD;
        connection = null;
    }

    public Connection openConn() {
        try {
            // Load MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Connect to MySQL database
            connection = DriverManager.getConnection(URL, username, password);
        }
        catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found: " + e.getMessage());
            e.printStackTrace();
            connection = null;
        }
        catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
            connection = null;
        }
        catch (Exception e) {
            System.err.println("Unexpected error during database connection: " + e.getMessage());
            e.printStackTrace();
            connection = null;
        }
        return connection;
    }

    public void closeConn() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        }
        catch(SQLException e) {
           System.err.println ("Can't close the database connection: " + e.getMessage());
           e.printStackTrace();
        }
        catch(Exception e) {
           System.err.println ("Unexpected error while closing database connection: " + e.getMessage());
           e.printStackTrace();
        }
    }

     public Vector<String> getNextRow(ResultSet rs,ResultSetMetaData rsmd) throws SQLException
	 {
	     Vector<String> currentRow = new Vector<String>();

	     for(int i=1;i<=rsmd.getColumnCount();i++)
	         switch(rsmd.getColumnType(i))
	         {
	              case Types.VARCHAR:
	              case Types.LONGVARCHAR:
	                   currentRow.addElement(rs.getString(i));
	                   break;
	              case Types.INTEGER:
	                   currentRow.addElement(String.valueOf(rs.getLong(i)));
	                   break;
	              case Types.DOUBLE:
	              	   currentRow.addElement(String.valueOf(rs.getDouble(i)));
	                   break;
	              case Types.FLOAT:
	              	   currentRow.addElement(String.valueOf(rs.getFloat(i)));
	                   break;
	              default:
	                   System.out.println("Type was: "+ rsmd.getColumnTypeName(i));
	          }

	          return currentRow;
    }
}