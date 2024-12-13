--1. Database Creation:

CREATE DATABASE RestaurantManagementSystem;
USE RestaurantManagementSystem;


--2. Table Creation:
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50) NOT NULL,
    CustomerPhone VARCHAR(15) NOT NULL,
    CustomerEmail VARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(50) NOT NULL,
    EmployeePhone VARCHAR(15) NOT NULL,
    EmployeeEmail VARCHAR(50) NOT NULL,
    EmployeeRole VARCHAR(20) NOT NULL
);

CREATE TABLE Menu (
    MenuItemID INT PRIMARY KEY,
    MenuItemName VARCHAR(50) NOT NULL,
    MenuItemDescription VARCHAR(100) NOT NULL,
    MenuItemPrice DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    OrderDate DATE NOT NULL,
    OrderTime TIME NOT NULL,
    TableNumber INT NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);



CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES Menu(MenuItemID)
);

CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ReservationDate DATE NOT NULL,
    ReservationTime TIME NOT NULL,
    TableNumber INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (MenuItemID) REFERENCES Menu(MenuItemID)
);


--3. Data Insertion:

INSERT INTO Menu VALUES (1, 'Steak', 'Grilled ribeye steak', 25.99);
INSERT INTO Menu VALUES (2, 'Pasta', 'Spaghetti with meatballs', 12.99);
INSERT INTO Menu VALUES (3, 'Salmon', 'Pan-seared salmon with vegetables', 18.99);
INSERT INTO Menu VALUES (4, 'Burger', 'Classic cheeseburger with fries', 8.99);
INSERT INTO Menu VALUES (5, 'Pizza', 'Margherita pizza with tomato sauce and mozzarella cheese', 14.99);

INSERT INTO Customers VALUES (1, 'John Smith', '555-1234', 'john.smith@example.com');
INSERT INTO Customers VALUES (2, 'Jane Doe', '555-5678', 'jane.doe@example.com');
INSERT INTO Customers VALUES (3, 'Bob Johnson', '555-9012', 'bob.johnson@example.com');

INSERT INTO Employees VALUES (1, 'Mike Brown', '555-1111', 'mike.brown@example.com', 'Manager');
INSERT INTO Employees VALUES (2, 'Sarah Lee', '555-2222', 'sarah.lee@example.com', 'Server');
INSERT INTO Employees VALUES (3, 'Tom Smith', '555-3333', 'tom.smith@example.com', 'Chef');

INSERT INTO Orders VALUES (1, 1, 2, '2021-10-20', '18:30:00', 5, 42.97);
INSERT INTO Orders VALUES (2, 2, 3, '2021-10-21', '19:00:00', 3, 31.98);
INSERT INTO Orders VALUES (3, 3, 2, '2021-10-22', '20:00:00', 2, 23.97);

INSERT INTO OrderItems VALUES (1, 1, 1, 2, 51.98);
INSERT INTO OrderItems VALUES (2, 1, 4, 1, 8.99);
INSERT INTO OrderItems VALUES (3, 2, 2, 1, 12.99);
INSERT INTO OrderItems VALUES (4, 2, 5, 1, 14.99);
INSERT INTO OrderItems VALUES (5, 3, 3, 1, 18.99);

INSERT INTO Reservations VALUES (1, 1, '2021-10-25', '18:00:00', 4);
INSERT INTO Reservations VALUES (2, 2, '2021-10-26', '19:30:00', 6);
INSERT INTO Reservations VALUES (3, 3, '2021-10-27', '20:00:00', 2);

INSERT INTO Inventory VALUES (1, 1, 20);
INSERT INTO Inventory VALUES (2, 2, 15);
INSERT INTO Inventory VALUES (3, 3, 10);
INSERT INTO Inventory VALUES (4, 4, 25);
INSERT INTO Inventory VALUES (5, 5, 12);


--4. Data Retrieval:

-- Simple select statement
SELECT * FROM Menu WHERE MenuItemPrice > 15;

-- Join statement
SELECT Orders.OrderID, Customers.CustomerName, Employees.EmployeeName
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
INNER JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
WHERE Orders.OrderDate = '2021-10-21';

-- Subquery
SELECT CustomerName, CustomerPhone, CustomerEmail
FROM Customers
WHERE CustomerID IN (SELECT CustomerID FROM Reservations WHERE TableNumber = 4);

-- Aggregate function
SELECT AVG(MenuItemPrice) AS AveragePrice FROM Menu;

-- Complex join
SELECT Orders.OrderID, OrderItems.Quantity, Menu.MenuItemName, Menu.MenuItemPrice, OrderItems.Subtotal
FROM Orders
INNER JOIN OrderItems ON Orders.OrderID = OrderItems.OrderID
INNER JOIN Menu ON OrderItems.MenuItemID = Menu.MenuItemID
WHERE Orders.TableNumber = 5;


--5. Transactions:

-- Reduce stock quantity and credit the seller for a sale of one product
BEGIN TRANSACTION;

UPDATE Inventory SET Quantity = Quantity - 1 WHERE MenuItemID = 1;
UPDATE Employees SET EmployeeSales = EmployeeSales + 25.99 WHERE EmployeeID = 2;

COMMIT TRANSACTION;

-- Debit the buyer and credit the taxer for a sale of one product
BEGIN TRANSACTION;

UPDATE Customers SET CustomerBalance = CustomerBalance - 25.99 WHERE CustomerID = 1;
UPDATE Employees SET EmployeeSalesTax = EmployeeSalesTax + 1.30 WHERE EmployeeID = 2;

COMMIT TRANSACTION;


--6. Views and Procedures:

-- View to show all menu items with their current stock quantity
CREATE VIEW CurrentInventory AS
SELECT Menu.MenuItemName, Inventory.Quantity
FROM Menu
INNER JOIN Inventory ON Menu.MenuItemID = Inventory.MenuItemID;

-- Parameterized procedure to add a new customer to the database
CREATE PROCEDURE AddCustomer
@CustomerName VARCHAR(50),
@CustomerPhone VARCHAR(15),
@CustomerEmail VARCHAR(50)
AS
BEGIN
    INSERT INTO Customers (CustomerName, CustomerPhone, CustomerEmail)
    VALUES (@CustomerName, @CustomerPhone, @CustomerEmail);
END;

-- Trigger to generate audit information whenever a new order is placed
CREATE TRIGGER OrderAudit
ON Orders
AFTER INSERT
AS
BEGIN
    DECLARE @OrderID INT;
    SET @OrderID = (SELECT OrderID FROM inserted);

    INSERT INTO OrderAudit (OrderID, EmployeeID, OrderDate)
    VALUES (@OrderID, (SELECT EmployeeID FROM inserted), GETDATE());
END;


---7. Security Access Control:

-- Grant read permission to all users on the Menu table
GRANT SELECT ON Menu TO PUBLIC;

-- Grant write permission to the Manager role on the Orders table
GRANT INSERT, UPDATE, DELETE ON Orders TO Manager;

-- Grant create permission to the Chef role on the Inventory table
GRANT CREATE TABLE ON Inventory TO Chef;
