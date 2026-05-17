#!/bin/bash

# Compile script for Centurion Bank application

echo "Compiling Centurion Bank application..."

# Check if mysql-connector-java JAR exists
if [ ! -f "mysql-connector-java-8.0.30.jar" ]; then
    echo "MySQL Connector JAR not found."
    echo "Please download mysql-connector-java-8.0.30.jar and place it in this directory."
    echo "You can download it from: https://dev.mysql.com/downloads/connector/j/"
    exit 1
fi

# Compile Java files
echo "Compiling Java files..."
javac -cp ".:mysql-connector-java-8.0.30.jar" *.java

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    echo ""
    echo "To run the application:"
    echo "1. Make sure MySQL server is running"
    echo "2. Execute the database_setup.sql script"
    echo "3. Deploy the application to Tomcat"
    echo "4. Access the application at http://localhost:8080/Online-Banking-System-using-Java-master/"
else
    echo "Compilation failed. Please check the error messages above."
fi