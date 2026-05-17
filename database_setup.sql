-- Database setup script for Centurion Bank
-- Create the database
CREATE DATABASE IF NOT EXISTS JavaClass;
USE JavaClass;

-- Create Account table
CREATE TABLE IF NOT EXISTS Account (
    Username VARCHAR(50) PRIMARY KEY,
    Password VARCHAR(50) NOT NULL,
    Name VARCHAR(100) NOT NULL
);

-- Create CheckingAccount table
CREATE TABLE IF NOT EXISTS CheckingAccount (
    CheckingAccountNumber VARCHAR(50) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Balance FLOAT NOT NULL,
    CustomerID VARCHAR(50) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Account(Username)
);

-- Create SavingsAccount table
CREATE TABLE IF NOT EXISTS SavingsAccount (
    SavingsAccountNumber VARCHAR(50) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Balance FLOAT NOT NULL,
    InterestRate FLOAT NOT NULL,
    CustomerID VARCHAR(50) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Account(Username)
);

-- Create Transactions table
CREATE TABLE IF NOT EXISTS Transactions (
    TransactionNumber VARCHAR(50) PRIMARY KEY,
    TransactionAmount FLOAT NOT NULL,
    TransactionType VARCHAR(50) NOT NULL,
    TransactionTime DATETIME NOT NULL,
    TransactionDate DATE NOT NULL,
    FromAccount VARCHAR(50),
    ToAccount VARCHAR(50),
    CustomerID VARCHAR(50) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Account(Username)
);

-- Insert sample data
INSERT INTO Account (Username, Password, Name) VALUES 
('john_doe', 'password123', 'John Doe'),
('jane_smith', 'password456', 'Jane Smith'),
('vardanvijayar', '12345', 'Vardan Vijayar');

INSERT INTO CheckingAccount (CheckingAccountNumber, CustomerName, Balance, CustomerID) VALUES 
('CUTMAP123456', 'John Doe', 5000.00, 'john_doe'),
('CUTMAP789012', 'Jane Smith', 3000.00, 'jane_smith'),
('CUTMAP111111', 'Vardan Vijayar', 15000.00, 'vardanvijayar');

INSERT INTO SavingsAccount (SavingsAccountNumber, CustomerName, Balance, InterestRate, CustomerID) VALUES 
('CUTMAP345678', 'John Doe', 10000.00, 2.5, 'john_doe'),
('CUTMAP901234', 'Jane Smith', 7500.00, 3.0, 'jane_smith'),
('CUTMAP222222', 'Vardan Vijayar', 25000.00, 3.5, 'vardanvijayar');

INSERT INTO Transactions (TransactionNumber, TransactionAmount, TransactionType, TransactionTime, TransactionDate, FromAccount, ToAccount, CustomerID) VALUES 
('TXN000001', 1000.00, 'Deposit', NOW(), NOW(), 'N/A', 'CUTMAP123456', 'john_doe'),
('TXN000002', 500.00, 'Withdrawal', NOW(), NOW(), 'CUTMAP123456', 'N/A', 'john_doe'),
('TXN000003', 2000.00, 'Transfer Out', NOW(), NOW(), 'CUTMAP123456', 'CUTMAP789012', 'john_doe'),
('TXN000004', 2000.00, 'Transfer In', NOW(), NOW(), 'CUTMAP123456', 'CUTMAP789012', 'jane_smith'),
('TXN000005', 5000.00, 'Deposit', NOW(), NOW(), 'N/A', 'CUTMAP111111', 'vardanvijayar'),
('TXN000006', 3000.00, 'Transfer Out', NOW(), NOW(), 'CUTMAP222222', 'CUTMAP123456', 'vardanvijayar');