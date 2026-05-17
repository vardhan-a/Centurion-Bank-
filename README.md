# Centurion Bank - Online Banking System

This is a complete web-based banking system developed using Java, JSP, and MySQL. The system provides a comprehensive suite of banking functionalities with a modern, responsive user interface.

## Recent Updates

- Fixed rupee symbol display issues throughout the application (replaced ₹ with "Rs.")
- Made account tiles in dashboard non-clickable as requested
- Fixed critical CSS syntax errors that were causing parsing issues
- Enhanced database with new user accounts and sample transactions
- Resolved file corruption issues in transfer functionality
- Improved overall code quality and stability

## Key Features

### User Management
- Secure user registration and authentication
- Session management with automatic timeout
- Password encryption and security measures

### Account Services
- Dashboard with account overview and balances
- Open new checking and savings accounts
- View detailed account information
- Account activity monitoring

### Financial Transactions
- Deposit funds into accounts
- Withdraw funds from accounts
- Transfer funds between own accounts
- View comprehensive transaction history
- Detailed transaction records with timestamps

### Payment Services
- Bill payment functionality
- UPI payment integration
- Multiple payment options

### User Interface
- Responsive design that works on desktop and mobile devices
- Modern, intuitive user interface
- Real-time balance updates
- Clear transaction categorization

## Technical Architecture

### Frontend Technologies
- **HTML5** - Markup language for structuring content
- **CSS3** - Styling and layout with responsive design
- **JavaScript** - Client-side interactivity and validation
- **Bootstrap** - Responsive framework components
- **Font Awesome** - Iconography and visual elements

### Backend Technologies
- **Java** - Core programming language
- **JSP (JavaServer Pages)** - Server-side scripting for dynamic content
- **Servlets** - HTTP request handling
- **JDBC** - Database connectivity and operations

### Database
- **MySQL** - Relational database management system
- **ACID Transactions** - Ensuring data integrity
- **Normalized Schema** - Efficient data organization

### Server Environment
- **Apache Tomcat** - Web application server
- **JDK 8+** - Java development kit

## Prerequisites

- Java Development Kit (JDK) 8 or higher
- Apache Tomcat 9 or higher
- MySQL Server 5.7 or higher
- MySQL Connector/J (JDBC Driver)
- Minimum 4GB RAM recommended
- 100MB free disk space

## Setup Instructions

### 1. Database Setup

1. Start your MySQL server
2. Create a new database (default name: JavaClass):
   ```sql
   CREATE DATABASE JavaClass;
   ```
3. Execute the `database_setup.sql` script to create tables and initial structure:
   ```sql
   mysql -u root -p < database_setup.sql
   ```
4. Optionally run `setup_users_and_data.sql` to populate with test users and sample data:
   ```sql
   mysql -u root -p < setup_users_and_data.sql
   ```

### 2. Configure Database Connection

Update the database connection details in [DBConnection.java](DBConnection.java) if needed:
- Database URL: `jdbc:mysql://localhost:3306/JavaClass?useSSL=false&serverTimezone=UTC`
- Username: Update if not using root
- Password: Update if password protected

For JSP files, ensure the connection parameters match those in DBConnection.java.

### 3. Application Deployment

#### Option A: Manual Compilation and Deployment
1. Navigate to the project directory
2. Compile all Java files:
   ```bash
   javac -cp ".:mysql-connector-java-8.0.30.jar" *.java
   ```
3. Copy all files to Tomcat's webapps directory in a folder named `centurion-bank`
4. Start/restart Tomcat server

#### Option B: WAR Deployment
1. Package the application as a WAR file
2. Deploy through Tomcat Manager or copy to webapps directory
3. Start/restart Tomcat server

### 4. Access the Application

Open your browser and navigate to:
```
http://localhost:8080/centurion-bank/
```

Default landing page: [index.html](index.html)

## File Structure Overview

```
/centurion-bank/
├── *.jsp                 # Dynamic web pages
├── *.java                # Java backend classes
├── *.class               # Compiled Java classes
├── *.sql                 # Database scripts
├── *.jar                 # External libraries
├── *.html                # Static web pages
├── *.sh                  # Shell scripts
└── README.md             # This documentation
```

### Key JSP Files
- [index.html](index.html) - Entry point redirecting to login
- [login.html](login.html) - User authentication interface
- [signup.html](signup.html) - New user registration
- [dashboard.jsp](dashboard.jsp) - Main user dashboard
- [accountDetails.jsp](accountDetails.jsp) - Detailed account information
- [deposit.jsp](deposit.jsp) - Funds deposit functionality
- [withdraw.jsp](withdraw.jsp) - Funds withdrawal functionality
- [transfer.jsp](transfer.jsp) - Inter-account transfers
- [statements.jsp](statements.jsp) - Transaction history
- [bills.jsp](bills.jsp) - Bill payment processing
- [upi.jsp](upi.jsp) - UPI payment integration

### Key Java Classes
- [DBConnection.java](DBConnection.java) - Database connectivity manager
- [BankAccount.java](BankAccount.java) - Base account operations
- [CheckingAccount.java](CheckingAccount.java) - Checking account implementation
- [SavingAccount.java](SavingAccount.java) - Savings account implementation
- [DatabaseUtil.java](DatabaseUtil.java) - Database utility methods

### Database Scripts
- [database_setup.sql](database_setup.sql) - Initial database schema
- [setup_users_and_data.sql](setup_users_and_data.sql) - Test data and users

## Default Test Users

### User 1:
- Username: `vardhan`
- Password: `2006@`
- Sample accounts with transactions for testing

### User 2:
- Username: `new`
- Password: `1234`
- Sample accounts with transactions for testing

Each user has:
- One checking account
- One savings account
- Sample transaction history
- Pre-populated account balances

## Account Number Format

All account numbers follow the format: `CUTMAP` followed by 6 digits (e.g., CUTMAP123456)

## Security Features

- Password encryption using secure hashing
- Session management with timeout
- SQL injection prevention through parameterized queries
- Input validation and sanitization
- Secure database connections

## Troubleshooting

1. **Database Connection Issues**
   - Verify MySQL is running
   - Check connection parameters in [DBConnection.java](DBConnection.java)
   - Ensure MySQL Connector/J JAR is in classpath
   - Confirm database name and credentials

2. **Classpath Issues**
   - Ensure MySQL Connector/J JAR is in WEB-INF/lib or Tomcat lib directory
   - Verify all required JAR files are present
   - Check Tomcat logs for class loading errors

3. **Tomcat Deployment Issues**
   - Check Tomcat logs in `$TOMCAT_HOME/logs/`
   - Verify application directory structure
   - Ensure proper file permissions
   - Restart Tomcat after making changes

4. **CSS Parsing Errors**
   - Ensure all CSS blocks have proper opening `{` and closing `}` braces
   - Check for malformed CSS selectors
   - Validate CSS syntax in style tags

5. **Login Problems**
   - Verify database contains user records
   - Check username/password case sensitivity
   - Confirm database connection is working

## Performance Considerations

- Optimized database queries for faster response times
- Efficient session management
- Minimal resource usage
- Responsive design for various devices

## Future Enhancements

- Multi-currency support
- Advanced analytics and reporting
- Mobile app integration
- Enhanced security features
- API for third-party integrations

## Technologies Used

### Core Technologies
- **Java** - Object-oriented programming language
- **JSP** - JavaServer Pages for dynamic web content
- **MySQL** - Relational database management system
- **JDBC** - Java Database Connectivity API
- **HTML5/CSS3** - Modern web standards
- **JavaScript** - Client-side scripting

### Frameworks and Libraries
- **Bootstrap** - Frontend framework for responsive design
- **Font Awesome** - Icon library
- **Apache Tomcat** - Web application server
