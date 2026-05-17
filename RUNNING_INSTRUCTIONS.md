# Running the Online Banking System

## Prerequisites
- MySQL Server
- Tomcat Server
- Java Development Kit (JDK)

## Setup Instructions

### 1. Start MySQL Server
Make sure MySQL is running on your system:
```bash
brew services start mysql
```

### 2. Database Setup
The database should already be set up with sample data. If you need to reset it:
```bash
./setup_db_auto.sh
```

### 3. Start Tomcat Server
```bash
brew services start tomcat
```

### 4. Deploy the Application
The application is automatically deployed as `centurion-bank.war` to Tomcat.

### 5. Access the Application
Open your web browser and go to:
http://localhost:8080/centurion-bank/

## Test Accounts
You can log in with any of these test accounts:

1. Username: `john_doe`, Password: `password123`
2. Username: `jane_smith`, Password: `mypassword`
3. Username: `vardanvijayar`, Password: `12345`
4. Username: `testuser`, Password: `testpass`
5. Username: `VARDHAN`, Password: `vardhan2006@`

## Troubleshooting

### If you encounter database connection errors:
1. Make sure MySQL is running
2. Verify the credentials in `DatabaseConfig.java` match your MySQL setup
3. Ensure the `JavaClass` database exists with all required tables

### If the web application doesn't load:
1. Check that Tomcat is running: `brew services list | grep tomcat`
2. Verify the WAR file was deployed correctly
3. Check Tomcat logs for errors: `/opt/homebrew/Cellar/tomcat/11.0.13/libexec/logs/`

### To recompile the application:
```bash
./compile.sh
```

Then redeploy the WAR file to Tomcat.