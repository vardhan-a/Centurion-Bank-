/******************************************************************************
*	Program Author: Kavita Mishra for CSCI 6810 Java and the Internet	  *
*	Date: September, 2018													  *
*******************************************************************************/

import java.sql.*;

public class Account
{
	private String Username, Password, Password1, Name;

	public Account(String UN, String PassW, String PassW1, String NM) {
		Username = UN;
		Password = PassW;
		Password1 = PassW1;
		Name = NM;
	}

	public Account(String UN, String PassW) {
		Username = UN;
		Password = PassW;
	}

    public boolean signUp() {
		boolean done = !Username.equals("") && !Password.equals("") && !Password1.equals("") && Password.equals(Password1);
		try {
		    if (done) {
		        DBConnection ToDB = new DBConnection(); //Have a connection to the DB
		        Connection DBConn = ToDB.openConn();
		        PreparedStatement pstmt = DBConn.prepareStatement("SELECT Username FROM Account WHERE Username = ?"); //Using prepared statement
		        pstmt.setString(1, Username);
		        ResultSet Rslt = pstmt.executeQuery(); //Inquire if the username exsits.
		        done = done && !Rslt.next();
		        if (done) {
				    pstmt = DBConn.prepareStatement("INSERT INTO Account(Username, Password, Name) VALUES (?, ?, ?)"); //Using prepared statement
				    pstmt.setString(1, Username);
				    pstmt.setString(2, Password);
				    pstmt.setString(3, Name);
				    pstmt.executeUpdate();
			    }
			    pstmt.close();
			    ToDB.closeConn();
			}
		}
	    catch(java.sql.SQLException e)
	    {         done = false;
				 System.out.println("SQLException: " + e);
				 while (e != null)
				 {   System.out.println("SQLState: " + e.getSQLState());
					 System.out.println("Message: " + e.getMessage());
					 System.out.println("Vendor: " + e.getErrorCode());
					 e = e.getNextException();
					 System.out.println("");
				 }
	    }
	    catch (java.lang.Exception e)
	    {         done = false;
				 System.out.println("Exception: " + e);
				 e.printStackTrace ();
	    }
	    return done;
	}
	
	public String signIn() {
		boolean done = !Username.equals("") && !Password.equals("");
		try {
		    if (done) {
		        DBConnection ToDB = new DBConnection(); //Have a connection to the DB
		        Connection DBConn = ToDB.openConn();
		        PreparedStatement pstmt = DBConn.prepareStatement("SELECT Name FROM Account WHERE Username = ? AND Password = ?"); //Using prepared statement
		        pstmt.setString(1, Username);
		        pstmt.setString(2, Password);
		        ResultSet Rslt = pstmt.executeQuery(); //Inquire if the username and password exists.
		        done = done && Rslt.next();
		        if (done) {
				     Name=Rslt.getString(1);
			    }
			    pstmt.close();
			    ToDB.closeConn();
			}
	    }
	    catch(java.sql.SQLException e) {
	         done = false;
			 System.out.println("SQLException: " + e);
			 while (e != null) {
			     System.out.println("SQLState: " + e.getSQLState());
				 System.out.println("Message: " + e.getMessage());
				 System.out.println("Vendor: " + e.getErrorCode());
				 e = e.getNextException();
				 System.out.println("");
			 }
	    }
	    catch (java.lang.Exception e) {
	         done = false;
			 System.out.println("Exception: " + e);
			 e.printStackTrace ();
	    }
	    return Name;
	}

	public boolean changePassword(String NewPassword) {
		boolean done = false;
		try {
		        DBConnection ToDB = new DBConnection(); //Have a connection to the DB
		        Connection DBConn = ToDB.openConn();
		        PreparedStatement pstmt = DBConn.prepareStatement("SELECT * FROM Account WHERE Username = ? AND Password = ?"); //Using prepared statement
		        pstmt.setString(1, Username);
		        pstmt.setString(2, Password);
		        ResultSet Rslt = pstmt.executeQuery(); //Inquire if the username exists.
		        if (Rslt.next()) {
				    pstmt = DBConn.prepareStatement("UPDATE Account SET Password = ? WHERE Username = ?"); //Using prepared statement
				    pstmt.setString(1, NewPassword);
				    pstmt.setString(2, Username);
				    pstmt.executeUpdate();
			        pstmt.close();
			        ToDB.closeConn();
                    done=true;
				}
		}
	    catch(java.sql.SQLException e) {
	         done = false;
			 System.out.println("SQLException: " + e);
			 while (e != null) {
			     System.out.println("SQLState: " + e.getSQLState());
				 System.out.println("Message: " + e.getMessage());
				 System.out.println("Vendor: " + e.getErrorCode());
				 e = e.getNextException();
				 System.out.println("");
			 }
	    }
	    catch (java.lang.Exception e) {
	         done = false;
			 System.out.println("Exception: " + e);
			 e.printStackTrace ();
	    }
	    return done;
	}
}