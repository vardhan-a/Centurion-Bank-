#!/bin/bash

# Database setup script for Centurion Bank

echo "Setting up Centurion Bank database..."

# Check if MySQL is installed
if ! command -v mysql &> /dev/null
then
    echo "MySQL is not installed. Please install MySQL server and try again."
    exit 1
fi

# Check if database setup file exists
if [ ! -f "database_setup.sql" ]; then
    echo "database_setup.sql file not found!"
    exit 1
fi

echo "This script will:"
echo "1. Create the 'JavaClass' database"
echo "2. Create all required tables"
echo "3. Insert sample data"
echo ""
echo "WARNING: This will overwrite any existing data in the JavaClass database!"
echo ""
read -p "Do you want to continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Database setup cancelled."
    exit 0
fi

# Run the database setup script
echo "Running database setup..."
mysql -u root -p < database_setup.sql

if [ $? -eq 0 ]; then
    echo "Database setup completed successfully!"
    echo ""
    echo "You can now compile and run the application."
    echo "Use './compile.sh' to compile the Java files."
else
    echo "Database setup failed. Please check the error messages above."
fi