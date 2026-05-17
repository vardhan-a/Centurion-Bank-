# Centurion Bank - Complete Web Application

Congratulations! You now have a complete web-based banking system with both frontend and backend functionality.

## What We've Built

We've created a full-featured online banking system with:

1. **Frontend Interface**:
   - Modern HTML/CSS/JavaScript user interface
   - Responsive design that works on desktop and mobile
   - Tab-based navigation for all banking functions

2. **Backend Functionality**:
   - User authentication (login/signup)
   - Account management (checking and savings accounts)
   - Financial operations (deposit, withdraw, transfer)
   - Transaction history
   - Database integration with MySQL

## Key Features Implemented

- ✅ User registration and login system
- ✅ Account overview dashboard
- ✅ Open new checking and savings accounts
- ✅ Deposit funds into accounts
- ✅ Withdraw funds from accounts
- ✅ Transfer funds between accounts
- ✅ View transaction history with date filtering
- ✅ Proper session management
- ✅ Database integration with MySQL
- ✅ Error handling and user feedback

## File Structure

The application consists of:

- **HTML Files**: Static pages (index.html, login.html, signup.html)
- **JSP Files**: Dynamic pages that handle backend logic
- **Java Classes**: Business logic and database connectivity
- **SQL Script**: Database setup and initialization
- **Shell Script**: Compilation helper

## How to Run the Application

### Prerequisites

1. **Java JDK 8 or higher**
2. **Apache Tomcat 9 or higher**
3. **MySQL Server**
4. **MySQL Connector/J (JDBC Driver)**

### Setup Steps

1. **Download MySQL Connector**:
   - Download `mysql-connector-java-8.0.30.jar` from the MySQL website
   - Place it in the project directory

2. **Set up the Database**:
   - Start your MySQL server
   - Create the database and tables by running:
     ```sql
     mysql -u root -p < database_setup.sql
     ```

3. **Compile the Application**:
   ```bash
   ./compile.sh
   ```

4. **Deploy to Tomcat**:
   - Copy all files to Tomcat's webapps directory
   - Or package as a WAR file

5. **Start Tomcat** and access the application at:
   ```
   http://localhost:8080/Online-Banking-System-using-Java-master/
   ```

## Default Test Accounts

You can use these accounts to test the application:

- **User 1**: 
  - Username: `john_doe`
  - Password: `password123`

- **User 2**:
  - Username: `jane_smith`
  - Password: `password456`

## Security Notes

This is a demonstration application. For production use, you would need to implement:

- Password hashing
- Input validation and sanitization
- CSRF protection
- SQL injection prevention
- HTTPS encryption
- Proper session management

## Technologies Used

- **Frontend**: HTML5, CSS3, JavaScript
- **Backend**: Java, JSP, Servlets
- **Database**: MySQL
- **Connectivity**: JDBC
- **Server**: Apache Tomcat

Enjoy your new online banking system!