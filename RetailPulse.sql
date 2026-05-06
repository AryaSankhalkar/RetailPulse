--Creating Tables with Constraints
CREATE TABLE CUSTOMERS (
    CustID VARCHAR2(5) PRIMARY KEY,
    CustName VARCHAR2(20) NOT NULL,
    Email VARCHAR2(20) UNIQUE,
    City VARCHAR2(20) CHECK (City IN ('Mapusa', 'Panaji', 'Ponda', 'Vasco', 'Margao')), 
    Birthdate DATE,
    JoinDate DATE DEFAULT SYSDATE 
);

CREATE TABLE PRODUCTS (
    ProdID VARCHAR2(5) PRIMARY KEY,
    ProdName VARCHAR2(20) NOT NULL,
    Category_Code VARCHAR2(10),
    Price NUMBER CHECK (Price > 0), 
    Stock NUMBER(5) DEFAULT 0 check(Stock >=0)
);

CREATE TABLE SALES (
    SalesID VARCHAR2(5) PRIMARY KEY,
    CustID VARCHAR2(5),
    ProdID VARCHAR2(5),
    Qty NUMBER CHECK (Qty > 0),
    SaleDate DATE DEFAULT SYSDATE
); 
DROP TABLE PRODUCT_CATEGORIES;
CREATE TABLE PRODUCT_CATEGORIES (
    Category_Code VARCHAR2(10) PRIMARY KEY,
    Category_Name VARCHAR2(20),
    Staff_Instruction VARCHAR2(30)
    );
    
 alter table sales add
 CONSTRAINT fk_sales_customers FOREIGN KEY(CustID) REFERENCES CUSTOMERS(CustID);
    
 alter table sales add
 CONSTRAINT fk_sales_products FOREIGN KEY(ProdID) REFERENCES PRODUCTS(ProdID);

 alter table products add
 CONSTRAINT fk_products_category FOREIGN KEY(Category_Code) REFERENCES PRODUCT_CATEGORIES(Category_Code);

--Creating a Sequence for automatic Sales IDs
CREATE SEQUENCE sales_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

---CREATING A TRIGGER FOR STOCK
CREATE TRIGGER sy_stock
AFTER INSERT ON SALES FOR EACH ROW
BEGIN
UPDATE PRODUCTS SET Stock=Stock - :NEW.Qty
WHERE ProdID= :NEW.ProdID;
END;
/
-- Inserting into product_category table
INSERT INTO PRODUCT_CATEGORIES VALUES ('ELEC', 'Electronics', 'check warranty');
INSERT INTO PRODUCT_CATEGORIES VALUES ('FURN', 'Furniture', 'check furniture quality');
INSERT INTO PRODUCT_CATEGORIES VALUES ('OTHR', 'OTHERS', 'no specifications');

-- Inserting into Customers table
INSERT INTO CUSTOMERS VALUES (1, 'John D''Sa', 'john%retail.com', 'Panaji', '15-MAY-1995', '10-JAN-2023');
INSERT INTO CUSTOMERS VALUES (2, 'Addison Ron', 'addison@retail.com', 'Mapusa', '20-JUN-1980', SYSDATE);
INSERT INTO CUSTOMERS VALUES (3, 'Sara Smith', 'sara@retail.com', 'Vasco', '12-DEC-1990', '01-FEB-2024');
INSERT INTO CUSTOMERS VALUES (4, 'Nick Jones', 'nick@retail.com', 'Ponda', '10-MAR-1998', '01-NOV-2025');
INSERT INTO CUSTOMERS VALUES (5, 'Tom Holland', 'tomh@retail.com', 'Margao', '01-JUN-1996', SYSDATE);
INSERT INTO CUSTOMERS VALUES (6, 'Charles Dias', 'charles@retail.com', 'Panaji', '16-10-1997', SYSDATE);
INSERT INTO CUSTOMERS VALUES (7, 'Rosie Fernandes', 'rosie@retail.com', 'Panaji', '11-11-2005', '22-MAR-2023');

-- Inserting into Products tables
INSERT INTO PRODUCTS VALUES (101, 'Laptop','ELEC', 80000, 10);
INSERT INTO PRODUCTS VALUES (102, 'Smartphone','ELEC', 30000, 25);
INSERT INTO PRODUCTS VALUES (103, 'Office Chair','FURN', 5000, 5);
INSERT INTO PRODUCTS VALUES (104, 'Carpet','OTHR', 2000, 6);
INSERT INTO PRODUCTS VALUES (105, 'Couch','FURN', 7000, 5);
INSERT INTO PRODUCTS VALUES (106, 'Lamp','OTHR', 800, 20);
INSERT INTO PRODUCTS VALUES (107, 'Wooden Table','FURN', 5500, 8);
INSERT INTO PRODUCTS VALUES (108, 'Headset','ELEC', 9000, 1);

-- Inserting Sales using the Sequence
INSERT INTO SALES VALUES (sales_seq.NEXTVAL, 1, 101, 1, SYSDATE);
INSERT INTO SALES VALUES (sales_seq.NEXTVAL, 2, 102, 2, '20-DEC-2024');
INSERT INTO SALES VALUES (sales_seq.NEXTVAL, 3, 103, 4,SYSDATE );
INSERT INTO SALES VALUES (sales_seq.NEXTVAL, 5, 106, 2, '25-MAY-2025');
INSERT INTO SALES VALUES (sales_seq.NEXTVAL, 2, 104, 1, SYSDATE);

COMMIT;

--customers sales data
SELECT 
    s.SalesID, 
    UPPER(c.CustName) AS Customer,
    p.ProdName, 
    (s.Qty * p.Price) AS Total_Amount,
    DECODE(p.Category_Code,'ELEC', 'Electronics', 'FURN', 'Furniture', 'OTHR', 'Other') AS Category 
FROM SALES s NATURAL JOIN CUSTOMERS c NATURAL JOIN PRODUCTS p;

--QUERIES--

--customers having % in email id 
SELECT CustName,Email 
FROM CUSTOMERS 
WHERE Email LIKE '%\%%' ESCAPE '\'; 

----count of each product left in stock
SELECT p.ProdID, p.ProdName, pc.Category_Name, p.stock FROM PRODUCTS p natural join PRODUCT_CATEGORIES pc;

--customers whose age is >= 21 
SELECT CustID, CustName, Birthdate, JoinDate
FROM CUSTOMERS
WHERE MONTHS_BETWEEN(JoinDate, Birthdate) / 12 >= 21; 

--customers who did not buy anything
SELECT CustID, CustName, City, Email
FROM CUSTOMERS
WHERE CustID NOT IN(SELECT CustID FROM SALES); 

--total money spent by each customer
SELECT c.CustName, Sum(s.qty * p.Price) AS Total_Spent
from CUSTOMERS c natural join SALES s natural join PRODUCTS p
GROUP BY c.CustName 
ORDER BY Total_Spent DESC;

--which city is buying the most products?
SELECT c.City, COUNT(s.SalesID) AS Order_Count
FROM CUSTOMERS c NATURAL JOIN SALES S
 GROUP BY c.City order by order_count; 

--Which customers from Panaji have made a purchase?
SELECT distinct c.CustName
FROM CUSTOMERS c
JOIN SALES s ON c.CustID = s.CustID
WHERE c.City = 'Panaji';

--Which products have never been sold? (Should we stop stocking them?)
SELECT ProdName, Price 
FROM PRODUCTS 
WHERE ProdID NOT IN (SELECT DISTINCT ProdID FROM SALES);

--Who are our top customers by total spending so we can give them a loyalty card?
SELECT c.CustName, SUM(s.Qty * p.Price) AS Total_Spent
FROM CUSTOMERS c
JOIN SALES s ON c.CustID = s.CustID
JOIN PRODUCTS p ON s.ProdID = p.ProdID
GROUP BY c.CustName
ORDER BY Total_Spent DESC;

--Which month of the year brings in the most orders?
SELECT TO_CHAR(SaleDate, 'Month') AS Season_Month, 
       COUNT(SalesID) AS Total_Orders,
       SUM(Qty) AS Items_Sold
FROM SALES
GROUP BY TO_CHAR(SaleDate, 'Month');
