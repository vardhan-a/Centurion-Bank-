-- Script to clear existing data and set up new users with accounts and transactions

-- Clear existing data
DELETE FROM Transactions;
DELETE FROM SavingsAccount;
DELETE FROM CheckingAccount;
DELETE FROM Account;

-- Insert new users
INSERT INTO Account (Username, Password, Name) VALUES 
('vardhan', '2006@', 'Vardhan'),
('new', '1234', 'New User');

-- Insert checking accounts for both users
INSERT INTO CheckingAccount (CheckingAccountNumber, CustomerName, Balance, CustomerID) VALUES 
('CUTMAP100001', 'Vardhan', 15000.00, 'vardhan'),
('CUTMAP200001', 'New User', 12000.00, 'new');

-- Insert savings accounts for both users
INSERT INTO SavingsAccount (SavingsAccountNumber, CustomerName, Balance, InterestRate, CustomerID) VALUES 
('CUTMAP100002', 'Vardhan', 25000.00, 3.5, 'vardhan'),
('CUTMAP200002', 'New User', 18000.00, 3.0, 'new');

-- Insert sample transactions for vardhan
INSERT INTO Transactions (TransactionNumber, TransactionAmount, TransactionType, TransactionTime, TransactionDate, FromAccount, ToAccount, CustomerID) VALUES 
('TXN100001', 5000.00, 'Deposit', '2025-12-01 10:30:00', '2025-12-01', 'N/A', 'CUTMAP100001', 'vardhan'),
('TXN100002', 2000.00, 'Withdrawal', '2025-12-02 14:15:00', '2025-12-02', 'CUTMAP100001', 'N/A', 'vardhan'),
('TXN100003', 3000.00, 'Transfer Out', '2025-12-03 09:45:00', '2025-12-03', 'CUTMAP100001', 'CUTMAP200001', 'vardhan'),
('TXN100004', 1500.00, 'Transfer In', '2025-12-03 09:45:00', '2025-12-03', 'CUTMAP100002', 'CUTMAP200002', 'vardhan'),
('TXN100005', 1000.00, 'Online Payment', '2025-12-04 16:20:00', '2025-12-04', 'CUTMAP100001', 'N/A', 'vardhan');

-- Insert sample transactions for new user
INSERT INTO Transactions (TransactionNumber, TransactionAmount, TransactionType, TransactionTime, TransactionDate, FromAccount, ToAccount, CustomerID) VALUES 
('TXN200001', 3000.00, 'Deposit', '2025-12-01 11:00:00', '2025-12-01', 'N/A', 'CUTMAP200001', 'new'),
('TXN200002', 1500.00, 'Withdrawal', '2025-12-02 13:30:00', '2025-12-02', 'CUTMAP200001', 'N/A', 'new'),
('TXN200003', 3000.00, 'Transfer In', '2025-12-03 09:45:00', '2025-12-03', 'CUTMAP100001', 'CUTMAP200001', 'new'),
('TXN200004', 1500.00, 'Transfer Out', '2025-12-03 09:45:00', '2025-12-03', 'CUTMAP200002', 'CUTMAP100002', 'new'),
('TXN200005', 2000.00, 'Bill Payment', '2025-12-04 15:45:00', '2025-12-04', 'CUTMAP200001', 'N/A', 'new');