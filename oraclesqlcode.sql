-- Drop Types and Tables
DROP TYPE UserType FORCE;
DROP TABLE UserTable CASCADE CONSTRAINTS;
DROP TYPE CustomerType FORCE;
DROP TYPE DeliveryManType FORCE;
DROP TYPE CategoryType FORCE;
DROP TYPE CategoryTable FORCE;
DROP TYPE MenuItemType FORCE;
DROP TABLE MenuItemTable CASCADE CONSTRAINTS;
DROP TYPE MenuItemCollection FORCE;
DROP TYPE RestaurantType FORCE;
DROP TABLE RestaurantTable CASCADE CONSTRAINTS;
DROP TYPE OrderType FORCE;
DROP TABLE OrderTable CASCADE CONSTRAINTS;
DROP TYPE PaymentType FORCE;
DROP TABLE PaymentTable CASCADE CONSTRAINTS;

-- Drop Procedures and Triggers
DROP PROCEDURE updateStatus;
DROP PROCEDURE placeOrder;
DROP PROCEDURE removeMenuItem;
DROP TRIGGER AssignDeliveryPerson;
DROP TRIGGER calculateTotalBeforeInsert;

------- Start Create TYPES and TABLES -----------------------------
 
-- Create UserType object
CREATE OR REPLACE TYPE UserType AS OBJECT(
    userid NUMBER(4),
    firstname VARCHAR2(20),
    lastname VARCHAR2(20),
    email VARCHAR2(50),
    dateofbirth DATE,
    address VARCHAR2(100),
    phone VARCHAR2(15),
    MEMBER FUNCTION getFullName RETURN VARCHAR2
) NOT FINAL;
/

-- Create User Table
CREATE TABLE UserTable of UserType(
    userid PRIMARY KEY
);


-- Create Member Fucntion for UserType object
CREATE OR REPLACE TYPE BODY UserType AS
    MEMBER FUNCTION getFullName RETURN VARCHAR2 IS
        BEGIN
            RETURN firstname || '' || lastname;
        END;
END;
/

COMMIT;

-- Create Customer Type
CREATE OR REPLACE TYPE CustomerType UNDER UserType(
    customerid VARCHAR2(6),
    registerdate TIMESTAMP,
    status VARCHAR2(15)
);
/

-- Create DeliveryMan Type
CREATE OR REPLACE TYPE DeliveryManType UNDER UserType(
    deliverymanid VARCHAR2(6),
    vehicleinfo VARCHAR2(200),
    availability VARCHAR2(30)
);
/

COMMIT;


-- Create Category Type
CREATE TYPE CategoryType AS OBJECT(
    categoryname VARCHAR(20)
);
/

-- Create VArray
CREATE TYPE CategoryTable AS VARRAY(5) OF CategoryType;
/

COMMIT;


-- Create MenuItem Type
CREATE OR REPLACE TYPE MenuItemType AS OBJECT(
    itemid NUMBER(4),
    name VARCHAR2(40),
    description VARCHAR2(150),
    price DECIMAL(10,2),
    category CategoryType
);
/

-- Create MenuItem Table
CREATE TABLE MenuItemTable of MenuItemType(
    itemid PRIMARY KEY
);

-- Create MenuItemCollection Type for nested table
CREATE OR REPLACE TYPE MenuItemCollection AS TABLE OF MenuItemType;

-- Create RestaurantType
CREATE OR REPLACE TYPE RestaurantType AS OBJECT(
    restaurantid NUMBER(4),
    name VARCHAR2(40),
    address VARCHAR2(200),
    phone VARCHAR2(20),
    menus MenuItemCollection
);
/

-- Create Restaurant Table
CREATE TABLE RestaurantTable OF RestaurantType(
    restaurantid PRIMARY KEY
) NESTED TABLE menus STORE AS MenuItemNestedTable;

COMMIT;


-- Create Order Type 
CREATE TYPE OrderType AS OBJECT(
    orderid NUMBER(5),
    orderdate TIMESTAMP,
    orderstatus VARCHAR2(50),
    totalamount DECIMAL(10,2),
    consumer REF CustomerType,
    delivery REF DeliveryManType,
    items MenuItemCollection,
    restaurant REF RestaurantType
);
/

-- Create OrderTable
CREATE TABLE OrderTable OF OrderType(
    orderid PRIMARY KEY
)NESTED TABLE items STORE AS OrderItemsNestedTable;

-- Create Payment Type
CREATE TYPE PaymentType AS OBJECT(
    paymentid NUMBER(5),
    paymentdate TIMESTAMP,
    amount DECIMAL(10,2),
    order_ref REF OrderType
);
/

-- Create Payment Table
CREATE TABLE PaymentTable of PaymentType(
    paymentid PRIMARY KEY
);

COMMIT;
------- End Create TYPES and TABLES -----------------------------


------- Start Create Procedures and Triggers -----------------------------

-- Procedure to remove a menu item from restaurant
CREATE OR REPLACE PROCEDURE removeMenuItem(
    p_restaurantid IN NUMBER, 
    p_itemid IN NUMBER        
) AS
BEGIN
    -- Delete the item from the nested table `MenuItemCollection`
    DELETE FROM TABLE (
        SELECT menus 
        FROM RestaurantTable
        WHERE restaurantid = p_restaurantid
    )
    WHERE itemid = p_itemid; 

    COMMIT;
END;
/

-- Procedure to update order status
CREATE OR REPLACE PROCEDURE updateStatus(
    p_orderid IN NUMBER,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE OrderTable
    SET orderstatus = p_status
    WHERE orderid = p_orderid;
    COMMIT;
END;
/

-- Procedure to place an order
CREATE OR REPLACE PROCEDURE placeOrder(
    p_orderid      IN NUMBER,
    p_orderdate    IN TIMESTAMP,
    p_consumerid   IN VARCHAR2,
    p_items        IN MenuItemCollection, 
    p_restaurantid IN NUMBER,
    p_totalamount  IN DECIMAL
) IS
    p_consumer_ref   REF CustomerType;
    p_restaurant_ref REF RestaurantType;
BEGIN
    -- Retrieve reference for consumer (cast UserTable to CustomerType)
    BEGIN
        SELECT TREAT(REF(u) AS REF CustomerType)
        INTO p_consumer_ref
        FROM UserTable u
        WHERE TREAT(VALUE(u) AS CustomerType).customerid = p_consumerid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20014, 'Consumer with ID ' || p_consumerid || ' not found.');
    END;

    -- Retrieve reference for restaurant
    BEGIN
        SELECT REF(r)
        INTO p_restaurant_ref
        FROM RestaurantTable r
        WHERE r.restaurantid = p_restaurantid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20015, 'Restaurant with ID ' || p_restaurantid || ' not found.');
    END;

    -- Insert the order with multiple items
    INSERT INTO OrderTable VALUES (
        OrderType(
            p_orderid,
            p_orderdate,
            'Pending', 
            p_totalamount,
            p_consumer_ref,
            NULL, 
            p_items, 
            p_restaurant_ref
        )
    );

    DBMS_OUTPUT.PUT_LINE('Order with multiple items placed successfully.');
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20013, 'Error placing order with multiple items: ' || SQLERRM);
END;
/


SET SERVEROUTPUT ON;

-- Trigger to assign a delivery person automatically
CREATE OR REPLACE TRIGGER AssignDeliveryPerson
BEFORE INSERT ON OrderTable
FOR EACH ROW
DECLARE
    v_delivery REF DeliveryManType;
    v_delivery_id VARCHAR2(6); -- Matches the datatype of `deliverymanid`
BEGIN
    -- Select an available delivery person from UserTable
    SELECT TREAT(REF(u) AS REF DeliveryManType), TREAT(VALUE(u) AS DeliveryManType).deliverymanid
    INTO v_delivery, v_delivery_id
    FROM UserTable u
    WHERE TREAT(VALUE(u) AS DeliveryManType).availability = 'Available'
    AND ROWNUM = 1;

    -- Assign the delivery person to the order
    :NEW.delivery := v_delivery;

    -- Update the delivery person's availability
    UPDATE UserTable u
    SET VALUE(u) = DeliveryManType(
        u.userid,
        u.firstname,
        u.lastname,
        u.email,
        u.dateofbirth,
        u.address,
        u.phone,
        TREAT(VALUE(u) AS DeliveryManType).deliverymanid,
        TREAT(VALUE(u) AS DeliveryManType).vehicleinfo,
        'Unavailable' -- Set availability to 'Unavailable'
    )
    WHERE TREAT(VALUE(u) AS DeliveryManType).deliverymanid = v_delivery_id;

    -- Set the initial order status
    :NEW.orderstatus := 'Assigned to Delivery Person: ' || v_delivery_id;

    -- Output success message
    DBMS_OUTPUT.PUT_LINE('Delivery person assigned successfully: ' || v_delivery_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Handle no available delivery person scenario
            :NEW.orderstatus := 'Pending - No Delivery Assigned';
            DBMS_OUTPUT.PUT_LINE('No available delivery person to assign.');
END;
/


-- Trigger to calculate total amount before inserting an order
CREATE OR REPLACE TRIGGER calculateTotalBeforeInsert
BEFORE INSERT ON OrderTable
FOR EACH ROW
DECLARE
    v_total DECIMAL(10, 2) := 0;
BEGIN
    -- Calculate the total amount by iterating through the MenuItemCollection
    FOR r_item IN (SELECT i.price FROM TABLE(:NEW.items) i) LOOP
        v_total := v_total + r_item.price;
    END LOOP;

    -- Assign the calculated total to the new row
    :NEW.totalamount := v_total;
END;
/

COMMIT;

------- End Create Procedures and Triggers -----------------------------


------- Start Data Insersection Section-----------------------------

-- Data Insert Into UserTable
INSERT INTO UserTable VALUES (customertype(100, 'John', 'Smith', 'john@outlet.com', TO_DATE('1999-05-20', 'YYYY-MM-DD'), '123 Maple Street, Springfield, IL 62701, USA', '094876657575', 'CU001', 
TO_DATE('2025-01-20 14:35:48', 'YYYY-MM-DD HH24:MI:SS'),'Active'));
INSERT INTO UserTable VALUES (customertype(101, 'Robert', 'Brown', 'robert.brown@example.net', TO_DATE('1992-03-07', 'YYYY-MM-DD'), '789 Pine Avenue, Chicago, IL 60601, USA', '093476554321', 'CU002', 
TO_DATE('2025-01-20 14:35:48', 'YYYY-MM-DD HH24:MI:SS'),'Active'));
INSERT INTO UserTable VALUES (customertype(102, 'Michael', 'Taylor', 'michael.taylor@domain.org', TO_DATE('1978-12-05', 'YYYY-MM-DD'), '987 Birch Road, Miami, FL 33101, USA', '098456765432', 'CU003', 
TO_DATE('2025-01-20 14:35:48', 'YYYY-MM-DD HH24:MI:SS'),'Inactive'));
INSERT INTO UserTable VALUES (customertype(103, 'Walker', 'Don', 'walkerdon@gmail.com', TO_DATE('1999-05-25', 'YYYY-MM-DD'), '126 Maple Street, Springfield, IL 62701, USA', '094878957575', 'CU004', 
TO_DATE('2025-01-20 14:35:48', 'YYYY-MM-DD HH24:MI:SS'),'Active'));

INSERT INTO UserTable VALUES (DeliveryManType(104, 'Sophia', 'Brown', 'sophiabrown@yahoo.com', TO_DATE('1998-11-20', 'YYYY-MM-DD'), '45 Pine Street, Chicago, IL 60601, USA', '094567890123', 'DM001',
'Mountain Bike, Red Color','Available'));
INSERT INTO UserTable VALUES (DeliveryManType(105, 'Ava', 'Williams', 'avawilliams@outlook.com', TO_DATE('1990-07-30', 'YYYY-MM-DD'), '67 Cedar Lane, Miami, FL 33101, USA', '098765432123', 'DM002',
'E-Bike, Green Color','Available'));
INSERT INTO UserTable VALUES (DeliveryManType(106, 'Willan', 'Mike', 'willanmike@gmail.com', TO_DATE('1999-05-25', 'YYYY-MM-DD'), '126 Maple Street, Springfield, IL 62701, USA', '094878957575', 
'DM003','Mountain Bike, Yellow Color','Available'));
INSERT INTO UserTable VALUES (DeliveryManType(107, 'James', 'Clark', 'james.clark@example.com', TO_DATE('1988-03-15', 'YYYY-MM-DD'), '789 Pine Avenue, San Francisco, CA 94101, USA', '094876543210', 
'DM004','Normal Bike, Gray Color','Available'));

COMMIT;

-- Create a variable of Status_Table type and Data Insert into MenuTable and Restaurant Table
DECLARE
    category_table CategoryTable;
BEGIN
    category_table := CategoryTable();

    category_table.EXTEND;
    category_table(1) := CategoryType('Fast food');

    category_table.EXTEND;
    category_table(2) := CategoryType('Drinks');

    category_table.EXTEND;
    category_table(3) := CategoryType('Desserts');

    category_table.EXTEND;
    category_table(4) := CategoryType('Salads');
    
    category_table.EXTEND;
    category_table(4) := CategoryType('Beverages');
    
    INSERT INTO MenuItemTable VALUES (MenuItemType(1, 'Burger', 'Delicious beef burger', 5.99, category_table(1)));
    INSERT INTO MenuItemTable VALUES (MenuItemType(2, 'Pizza One', 'Cheesy margherita pizza', 8.99, category_table(1)));
    INSERT INTO MenuItemTable VALUES (MenuItemType(3, 'Coke', 'Refreshing cola drink', 1.99, category_table(2)));
    INSERT INTO MenuItemTable VALUES (MenuItemType(4, 'Espresso', '2 shots of espresso', 4.33, category_table(2)));
    INSERT INTO MenuItemTable VALUES (MenuItemType(5, 'Cafe Latte', 'shot of espresso + 8-10 oz. of steamed milk + 1 cm of foam', 5.99, category_table(2)));
    INSERT INTO MenuItemTable VALUES (MenuItemType(6, 'Iced Coffee', 'drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + 
    flavoring syrup to taste', 6.55, category_table(2)));
    INSERT INTO MenuItemTable VALUES (MenuItemType(7, 'Pizza Two', 'Seedfood margherita pizza', 8.99, category_table(1)));
    
    INSERT INTO RestaurantTable VALUES (
        RestaurantType(1, 'Pizza Place', '789 Pine Road', '555-1234', 
        MenuItemCollection(
            MenuItemType(2, 'Pizza One', 'Cheesy margherita pizza', 8.99, category_table(1)),
            MenuItemType(7, 'Pizza Two', 'Seedfood margherita pizza', 8.99, category_table(1))
        ))
    );

    INSERT INTO RestaurantTable VALUES (
        RestaurantType(2, 'Burger Joint', '123 Main Street', '555-5678', MenuItemCollection(MenuItemType(1, 'Burger', 
        'Delicious beef burger', 5.99, category_table(1))))
    );
    
    INSERT INTO RestaurantTable VALUES (
        RestaurantType(3, 'Coffee Bean', '223 Main Road', '555-6345', 
        MenuItemCollection(
            MenuItemType(4, 'Espresso', '2 shots of espresso', 4.33, category_table(2)),
            MenuItemType(3, 'Coke', 'Refreshing cola drink', 1.99, category_table(2)),
            MenuItemType(5, 'Cafe Latte', 'shot of espresso + 8-10 oz. of steamed milk + 1 cm of foam', 5.99, category_table(2)),
            MenuItemType(6, 'Iced Coffee', 'drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + flavoring syrup to taste', 
            6.55, category_table(2))
        ))
    );
    
    INSERT INTO RestaurantTable VALUES (
        RestaurantType(4, 'Coffee Diary', '223 Main Road', '555-6345', 
        MenuItemCollection(
            MenuItemType(4, 'Espresso', '2 shots of espresso', 4.33, category_table(2)),
            MenuItemType(5, 'Cafe Latte', 'shot of espresso + 8-10 oz. of steamed milk + 1 cm of foam', 5.99, category_table(2)),
            MenuItemType(6, 'Iced Coffee', 'drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + flavoring syrup to taste', 6.55, category_table(2)),
            MenuItemType(1, 'Burger', 'Delicious beef burger', 5.99, category_table(1))
        ))
    );
    
    
END;
/

COMMIT;

SELECT * FROM menuitemtable;

-- Insert data into order table
DECLARE
    items1 MenuItemCollection := MenuItemCollection(); -- Initialize the collection
    items2 MenuItemCollection := MenuItemCollection(); -- Initialize the collection
BEGIN
    -- Add items to the collection
    items1.EXTEND;
    items1(1) := MenuItemType(4, 'Espresso', '2 shots of espresso', 4.33, CategoryType('Drinks'));

    items1.EXTEND;
    items1(2) := MenuItemType(3, 'Coke', 'Refreshing cola drink', 1.99, CategoryType('Drinks'));
    
    items2.EXTEND;
    items2(1) := MenuItemType(1, 'Burger', 'Delicious beef burger', 5.99, CategoryType('Fast Food'));
    
    items2.EXTEND;
    items2(2) := MenuItemType(6, 'Iced Coffee', 'drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + flavoring syrup to taste', 6.55, CategoryType('Drinks'));

    -- Call the procedure
    placeOrder(
        p_orderid      => 1,
        p_orderdate    => SYSTIMESTAMP,
        p_consumerid   => 'CU001',
        p_items        => items2,
        p_restaurantid => 4,
        p_totalamount  => 0.0
    );
    
    placeOrder(
        p_orderid      => 2,
        p_orderdate    => SYSTIMESTAMP,
        p_consumerid   => 'CU002',
        p_items        => items1,
        p_restaurantid => 3,
        p_totalamount  => 0.0
    );
END;
/

COMMIT;

-- Check data insert into Order Table
SELECT * FROM OrderTable;

SELECT 
    o.orderid,
    o.orderdate,
    o.orderstatus,
    o.totalamount,
    DEREF(o.consumer).firstname AS consumer_firstname,
    DEREF(o.consumer).lastname AS consumer_lastname,
    DEREF(o.delivery).deliverymanid AS deliveryman_id,
    DEREF(o.restaurant).restaurantid AS restaurant_id,
    DEREF(o.restaurant).name AS restaurant_name,
    i.itemid,
    i.name AS item_name,
    i.description AS item_description,
    i.price AS item_price,
    i.category.categoryname AS item_category
FROM 
    OrderTable o,
    TABLE(o.items) i;

SELECT 
    u.userid,
    u.firstname,
    u.lastname,
    u.email,
    u.dateofbirth,
    u.address,
    u.phone,
    CASE
        WHEN TREAT(VALUE(u) AS CustomerType) IS NOT NULL THEN 'CustomerType'
        WHEN TREAT(VALUE(u) AS DeliveryManType) IS NOT NULL THEN 'DeliveryManType'
        ELSE 'UnknownType'
    END AS user_type,
    -- Specific attributes for CustomerType
    TREAT(VALUE(u) AS CustomerType).customerid AS customerid,
    TREAT(VALUE(u) AS CustomerType).registerdate AS registerdate,
    TREAT(VALUE(u) AS CustomerType).status AS customer_status,
    -- Specific attributes for DeliveryManType
    TREAT(VALUE(u) AS DeliveryManType).deliverymanid AS deliverymanid,
    TREAT(VALUE(u) AS DeliveryManType).vehicleinfo AS vehicleinfo,
    TREAT(VALUE(u) AS DeliveryManType).availability AS availability
FROM UserTable u;


-- Insert data into paymenttable
DECLARE
    order_ref_obj REF OrderType; -- Declare a reference for the OrderType
    order_total DECIMAL(10,2); -- Variable to store the order total
    tax_rate CONSTANT DECIMAL(10,2) := 0.10; -- Tax rate (10%)
BEGIN
    -- Loop through all orders in OrderTable
    FOR order_rec IN (SELECT orderid, totalamount FROM OrderTable) LOOP
        -- Calculate the total payment amount including tax
        order_total := order_rec.totalamount + (order_rec.totalamount * tax_rate);

        -- Get a reference to the current order
        SELECT REF(o)
        INTO order_ref_obj
        FROM OrderTable o
        WHERE o.orderid = order_rec.orderid;

        -- Insert a payment into PaymentTable
        INSERT INTO PaymentTable VALUES (
            PaymentType(
                order_rec.orderid, -- Generate a payment ID (e.g., order ID + offset)
                SYSTIMESTAMP, -- Payment date
                order_total, -- Payment amount (total + tax)
                order_ref_obj -- Reference to the order
            )
        );
    END LOOP;

    -- Commit the transaction
    COMMIT;
END;
/

-- Check data insert into Payment Table 
SELECT 
    p.paymentid,
    p.paymentdate,
    p.amount,
    DEREF(p.order_ref).orderid AS order_id
FROM 
    PaymentTable p;
    
------- End Data Insersection Section-----------------------------


------- Start Using Prodecures Section-----------------------------

-- Use updatestatus procedure
BEGIN 
    updatestatus(1,'Completed');
END;
/

SELECT * FROM OrderTable;



-- Use removeMenuItem procedure
BEGIN
    removeMenuItem(1, 2); -- Removes item with ID 2 from the restaurant with ID 1
END;
/

SELECT r.restaurantid, r.name AS restaurant_name, mi.*
FROM RestaurantTable r,
     TABLE(r.menus) mi;

------- End Using Prodecures Section-----------------------------


------- Start Query Section ------------

--Query 1 --
    
CREATE OR REPLACE PROCEDURE GetCompletedOrders AS
BEGIN
    FOR order_rec IN (
        SELECT 
            o.orderid,
            o.orderdate,
            o.totalamount,
            o.orderstatus,
            DEREF(o.consumer).firstname || ' ' || DEREF(o.consumer).lastname AS customer_name,
            DEREF(o.restaurant).name AS restaurant_name,
            p.paymentid,
            p.paymentdate,
            p.amount AS payment_amount
        FROM 
            OrderTable o
            INNER JOIN PaymentTable p ON REF(o) = p.order_ref 
            LEFT JOIN UserTable u ON o.consumer = REF(u)
        WHERE 
            o.orderstatus = 'Completed'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Order ID: ' || order_rec.orderid || 
            ', Customer: ' || order_rec.customer_name ||
            ', Restaurant: ' || order_rec.restaurant_name ||
            ', Total Amount: ' || order_rec.totalamount
        );
    END LOOP;
END;
/

-- Execute the procedure
BEGIN 
    GetCompletedOrders;
END;
/





-- Query 2 ---   
SELECT 
    m.itemid, 
    m.name
FROM 
    MenuItemTable m
INTERSECT
SELECT 
    r_item.itemid, 
    r_item.name
FROM 
    RestaurantTable r, 
    TABLE(r.menus) r_item;
    
    
    
--  Query 3 ---
SELECT 
    r.name AS RestaurantName,
    LISTAGG(m.name, ', ') WITHIN GROUP (ORDER BY m.name) AS MenuItems, 
    COUNT(m.itemid) AS MenuItemCount, 
    r.address AS RestaurantAddress,  
    r.phone AS ContactNumber,        
    LISTAGG(DISTINCT m.category.categoryname, ', ') WITHIN GROUP (ORDER BY m.category.categoryname) AS Categories 
FROM 
    RestaurantTable r
CROSS JOIN 
    TABLE(r.menus) m 
CROSS JOIN 
    TABLE(CategoryTable( 
        CategoryType('Fast food'),
        CategoryType('Drinks')
    )) c 
WHERE 
    m.price > 5.00 
    AND m.category.categoryname = c.categoryname 
GROUP BY 
    r.name, r.address, r.phone 
ORDER BY 
    COUNT(m.itemid) DESC; 


--Query 4 ---
SELECT 
    o.orderid,
    o.orderdate,
    o.orderdate + INTERVAL '1' HOUR AS expected_delivery_time,
    CASE 
        WHEN SYSTIMESTAMP >= o.orderdate + INTERVAL '1' HOUR THEN 'Delivered'
        ELSE 'In Progress'
    END AS delivery_status,
    SYSTIMESTAMP - o.orderdate AS time_elapsed
FROM 
    OrderTable o;
    
    
-- Query 5 --
SELECT 
    r.name AS restaurant_name,
    SUM(o.totalamount) AS total_sales,
    AVG(o.totalamount) AS average_sales,
    ROUND(SUM(o.totalamount) / SUM(SUM(o.totalamount)) OVER () * 100, 2) AS sales_contribution
FROM 
    OrderTable o
    RIGHT JOIN RestaurantTable r ON o.restaurant = REF(r)
GROUP BY ROLLUP(r.name)
HAVING r.name IS NOT NULL
ORDER BY total_sales DESC;  
    
------- End Query Section ------------







