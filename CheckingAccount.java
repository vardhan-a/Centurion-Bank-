/******************************************************************************
*	Program Author: Dr. Yongming Tang for CSCI 6810 Java and the Internet	  *
*	Date: October, 2013													      *
*******************************************************************************/

import java.sql.*;

public class CheckingAccount
{   //Instance Variables
	private String CheckingAccountNumber, CustomerName, CustomerID;
	private float Balance = -1, Amount = -1;

		public CheckingAccount(String CA_Num, String Cust_Name, String Cust_ID, String Amt) { //Constructor One with three parameters
		CheckingAccountNumber = CA_Num;
		CustomerName = Cust_Name;
		CustomerID = Cust_ID;
		//Balance = Float.parseFloat(Bal);
		Amount = Float.parseFloat(Amt);
	}



	public CheckingAccount(String CA_Num) { //Constructor Two with one parameter
		CheckingAccountNumber = CA_Num;
	}
	public CheckingAccount() { //Constructor with no parameters for fetching the account no.
		}


    public boolean openAcct() {
	     boolean done = false;
				try {
				    if (!done) {
				        DBConnection ToDB = new DBConnection(); //Have a connection to the DB
				        Connection DBConn = ToDB.openConn();
				        PreparedStatement pstmt = DBConn.prepareStatement("SELECT CheckingAccountNumber FROM CheckingAccount WHERE CheckingAccountNumber = ?"); //Using prepared statement
				        pstmt.setString(1, CheckingAccountNumber);
				        ResultSet Rslt = pstmt.executeQuery(); //Inquire if the username exsits.
				        done = !Rslt.next();
				        if (done) {
						    pstmt = DBConn.prepareStatement("INSERT INTO CheckingAccount(CheckingAccountNumber, CustomerName, Balance, CustomerID) VALUES (?, ?, ?, ?)"); //Using prepared statement
						    pstmt.setString(1, CheckingAccountNumber);
						    pstmt.setString(2, CustomerName);
						    pstmt.setFloat(3, Amount);
						    pstmt.setString(4, CustomerID);
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
	public String getAccno(String C_ID) {  //Method to return a Current Account No.
			try {
			        DBConnection ToDB = new DBConnection(); //Have a connection to the DB
			        Connection DBConn = ToDB.openConn();
			        PreparedStatement pstmt = DBConn.prepareStatement("SELECT CheckingAccountNumber FROM CheckingAccount WHERE CustomerID = ?");
			        pstmt.setString(1, C_ID);
			        ResultSet Rslt = pstmt.executeQuery();

			        while (Rslt.next()) {
					CheckingAccountNumber = Rslt.getString("CheckingAccountNumber");

				    }
				    pstmt.close();
				    ToDB.closeConn();
			}
		    catch(java.sql.SQLException e)
		    {
					 System.out.println("SQLException: " + e);
					 while (e != null)
					 {   System.out.println("SQLState: " + e.getSQLState());
						 System.out.println("Message: " + e.getMessage());
						 System.out.println("Vendor: " + e.getErrorCode());
						 e = e.getNextException();
						 System.out.println("");
					 }
		    }
		    return CheckingAccountNumber;
	}
    public float getBalance() {  //Method to return a Current Account balance
		try {
		        DBConnection ToDB = new DBConnection(); //Have a connection to the DB
		        Connection DBConn = ToDB.openConn();
		        PreparedStatement pstmt = DBConn.prepareStatement("SELECT Balance FROM CheckingAccount WHERE CheckingAccountNumber = ?"); //SQL query command for Balance
		        pstmt.setString(1, CheckingAccountNumber);
		        ResultSet Rslt = pstmt.executeQuery();

		        while (Rslt.next()) {
					Balance = Rslt.getFloat(1);
			    }
			    pstmt.close();
			    ToDB.closeConn();
		}
	    catch(java.sql.SQLException e)
	    {
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
	    {
				 System.out.println("Exception: " + e);
				 e.printStackTrace ();
	    }
	    return Balance;
	}

    public float getBalance(String ChkAcctNumber) {  //Method to return a Current Account balance
		try {
		        DBConnection ToDB = new DBConnection(); //Have a connection to the DB
		        Connection DBConn = ToDB.openConn();
		        PreparedStatement pstmt = DBConn.prepareStatement("SELECT Balance FROM CheckingAccount WHERE CheckingAccountNumber = ?"); //SQL query command for Balance
		        pstmt.setString(1, ChkAcctNumber);
		        ResultSet Rslt = pstmt.executeQuery();

		        while (Rslt.next()) {
					Balance = Rslt.getFloat(1);
			    }
			    pstmt.close();
			    ToDB.closeConn();
		}
	    catch(java.sql.SQLException e)
	    {
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
	    {
				 System.out.println("Exception: " + e);
				 e.printStackTrace ();
	    }
	    return Balance;
	}

	public boolean deposit(String C_ID){

			boolean done= !CheckingAccountNumber.equals("") && !CustomerID.equals("");

			try{
				if(done){
					DBConnection DBconn = new DBConnection();
					Connection conn = DBconn.openConn();
					PreparedStatement pstmt = conn.prepareStatement("SELECT Balance FROM CheckingAccount WHERE CheckingAccountNumber = ? AND CustomerID = ?");
					pstmt.setString(1, CheckingAccountNumber);
					pstmt.setString(2, C_ID);
					ResultSet reslt = pstmt.executeQuery();

					while (reslt.next()) {
						 Balance = reslt.getFloat(1);
						}
					Balance = Balance + Amount;
					pstmt = conn.prepareStatement("UPDATE CheckingAccount SET Balance = ? WHERE CheckingAccountNumber = ?");
					pstmt.setFloat(1, Balance);
					pstmt.setString(2, CheckingAccountNumber);
					pstmt.executeUpdate();
					pstmt.close();
					DBconn.closeConn();
					}
				}

			catch (SQLException e){
				System.out.println("SQLException" + e);
				done= false;
				System.out.println("SQLExceptionState" + e.getSQLState());
				System.out.println("message" + e.getMessage());
				System.out.println("vendor" + e.getErrorCode());
				e.getNextException();
				System.out.println("");
			}

			catch (java.lang.Exception e){

				System.out.println("Exception" + e);
				e.printStackTrace();
			}

			return done;
	}
	public boolean Withdraw(String C_ID){

			boolean done = !CheckingAccountNumber.equals("") && !CustomerID.equals("");

			try{
				if(done){
					DBConnection DBconn = new DBConnection();
					Connection Conn = DBconn.openConn();
					PreparedStatement pstmt = Conn.prepareStatement("SELECT Balance FROM CheckingAccount WHERE CheckingAccountNumber = ? AND CustomerID = ?");
					pstmt.setString(1, CheckingAccountNumber);
					pstmt.setString(2, C_ID);
					ResultSet rslt = pstmt.executeQuery();
					while (rslt.next()) {
						 Balance = rslt.getFloat(1);
					}
					if (Balance>=Amount) {
						Balance = Balance - Amount;
						pstmt = Conn.prepareStatement("UPDATE CheckingAccount SET Balance = ? WHERE CheckingAccountNumber = ?");
						pstmt.setFloat(1, Balance);
						pstmt.setString(2, CheckingAccountNumber);
						pstmt.executeUpdate();
						pstmt.close();
						DBconn.closeConn();

					}
				}
			}
			catch (java.sql.SQLException e){

				System.out.println("SQLException" + e);
				while (e != null){
					System.out.println("SqlExceptionState" + e.getSQLState());
					System.out.println("Message"+ e.getMessage());
					System.out.println("Vendor"+ e.getErrorCode());

					e = e.getNextException();
					System.out.println("");

				}
			}
			catch (java.lang.Exception e){

				System.out.println("Exception" + e);

				e.printStackTrace();

			}
	       return done;
	   }
}