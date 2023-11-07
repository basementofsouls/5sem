create database Turfirma;

use database Turfirma;
-- �������� ������� Users
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    user_email VARCHAR(50) UNIQUE,
    user_password CHAR(100),
    date_registration DATE
);

-- �������� ������� ������
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    ticket_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (ticket_id) REFERENCES Tickets (ticket_id)
);

-- �������� ������� ������
CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    tour_id INT,
    buy_date DATE,
    ticket_price DECIMAL(10, 2),
    seat_class VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (tour_id) REFERENCES Tours (tour_id)
);

-- �������� ������� ����
CREATE TABLE Tours (
    tour_id INT IDENTITY(1,1) PRIMARY KEY,
    route_id INT,
    tourstart_datetime DATETIME2 NOT NULL,
    tourend_datetime DATETIME2 NOT NULL,
    FOREIGN KEY (route_id) REFERENCES Routes (route_id)
);

-- �������� ������� ��������
CREATE TABLE Routes (
    route_id INT IDENTITY(1,1) PRIMARY KEY,
    from_id INT,
    to_id INT,
    bus_id INT,
    FOREIGN KEY (from_id) REFERENCES Points (point_id),
    FOREIGN KEY (to_id) REFERENCES Points (point_id),
    FOREIGN KEY (bus_id) REFERENCES Buses (bus_id)
);

-- �������� ������� ����� �����������/��������
CREATE TABLE Points (
    point_id INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    point_name VARCHAR(50) NOT NULL
);

-- �������� ������� ��������
CREATE TABLE Buses (
    bus_id INT IDENTITY(1,1) PRIMARY KEY,
    bus_number VARCHAR(50) NOT NULL,
    bus_capacity INT NOT NULL
);

-- �������� ������������� tour_info_view
CREATE VIEW tour_info_view AS
SELECT TOP 100 PERCENT
    s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, COUNT(t.ticket_id) AS tickets_sold, b.bus_capacity
FROM Tours s
INNER JOIN Routes r ON s.route_id = r.route_id
INNER JOIN Buses b ON r.bus_id = b.bus_id
LEFT JOIN Tickets t ON s.tour_id = t.tour_id
GROUP BY s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, b.bus_capacity
ORDER BY s.tour_id;


-- �������� ������������� ordered_tickets_view
CREATE VIEW ordered_tickets_view AS
SELECT *
FROM Tickets;

SELECT *
FROM ordered_tickets_view
ORDER BY buy_date;

-- ������ ��� ������� tour_id � ������� Tickets
CREATE INDEX ix_Tickets_tour_id ON Tickets(tour_id);

-- ������ ��� ������� ticket_id � ������� Orders
CREATE INDEX ix_Orders_ticket_id ON Orders(ticket_id);

-- ������ ��� ������� route_id � ������� Tours
CREATE INDEX ix_Tours_route_id ON Tours(route_id);

-- ������ ��� ������� user_id � ������� Tickets
CREATE INDEX ix_Tickets_user_id ON Tickets(user_id);


-- ������� ��� �������� ����������� ��������
CREATE TRIGGER ticket_capacity_trigger
ON Tickets
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @v_capacity INT;
    DECLARE @v_tickets_count INT;

    -- �������� ����������� ��������
    SELECT @v_capacity = B.bus_capacity
    FROM Routes R
    INNER JOIN Tours T ON R.route_id = T.route_id
    INNER JOIN Buses B ON R.bus_id = B.bus_id
    WHERE T.tour_id = (SELECT tour_id FROM INSERTED);

    -- ���������� ���������� ��������� �������
    SELECT @v_tickets_count = COUNT(*)
    FROM Tickets
    WHERE tour_id = (SELECT tour_id FROM INSERTED);

    -- �������� �� �����������
    IF @v_tickets_count >= @v_capacity
    BEGIN
        THROW 51000, 'Cannot add ticket, flight is full.', 1;
    END;
    ELSE
    BEGIN
        -- ������� ����� �������
        INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
        SELECT I.user_id, I.tour_id, I.buy_date, I.ticket_price, I.seat_class
        FROM INSERTED I;
    END;
END;





-- ������� ��� �������� �������
CREATE TRIGGER add_order
ON Tickets
AFTER INSERT
AS
BEGIN
  INSERT INTO Orders (user_id, ticket_id)
  SELECT u.user_id, i.ticket_id
  FROM Users_ u
  JOIN INSERTED i ON u.user_id = i.user_id;
END;

-- �������� ��������� ��� ���������� ������������
CREATE PROCEDURE add_user
@user_name VARCHAR(50),
@user_email VARCHAR(50),
@user_password CHAR(100),
@date_registration DATE
AS
BEGIN
  INSERT INTO Users (user_name, user_email, user_password, date_registration)
  VALUES (@user_name, @user_email, @user_password, @date_registration);
END;

-- �������� ��������� ��� �������� ������������
CREATE PROCEDURE delete_user
@p_user_id INT
AS
BEGIN
    -- �������� ������� ������������
    DELETE FROM Orders WHERE user_id = @p_user_id;
    
    -- �������� ������� ������������
    DELETE FROM Tickets WHERE user_id = @p_user_id;
    
    -- �������� ������������
    DELETE FROM Users WHERE user_id = @p_user_id;
    
    COMMIT;
END;

-- �������� ������� ��� �������� ��������� �������
CREATE FUNCTION count_sold_tickets
(@start_date DATE, @end_date DATE)
RETURNS INT
AS
BEGIN
  DECLARE @sold_tickets INT;

  SELECT @sold_tickets = COUNT(*)
  FROM Tickets
  WHERE buy_date >= @start_date AND buy_date <= @end_date;

  RETURN @sold_tickets;
END;


-----------------------------------------�� 3-----------------------------------
---���������� ������� ��������
ALTER TABLE Points
ADD point_hierarchy hierarchyid;


---�������� ��������� ��� ����������� ����������� ����� � ��������� ������ ��������
CREATE PROCEDURE GetSubordinatesWithLevel @node hierarchyid
AS
BEGIN
    SELECT
        point_id,
        city,
        country,
        point_name,
        point_hierarchy.ToString() AS HierarchyPath
    FROM
        Points
    WHERE
        point_hierarchy.IsDescendantOf(@node) = 1
    ORDER BY
        point_hierarchy;
END;


---�������� ��������� ��� ���������� ������������ ����
CREATE PROCEDURE AddSubordinate @parentNode hierarchyid, @city VARCHAR(50), @country VARCHAR(50), @point_name VARCHAR(50)
AS
BEGIN
    DECLARE @childNode hierarchyid;
    SELECT @childNode = @parentNode.GetDescendant(NULL, NULL);

    INSERT INTO Points (city, country, point_name, point_hierarchy)
    VALUES (@city, @country, @point_name, @childNode);
END;


---�������� ��������� ��� ����������� ����������� �����
CREATE PROCEDURE MoveSubtree @sourceNode hierarchyid, @destinationNode hierarchyid
AS
BEGIN
    DECLARE @distance hierarchyid;
    SET @distance = @destinationNode.GetDescendant(NULL, NULL);

    UPDATE Points
    SET point_hierarchy = point_hierarchy.GetReparentedValue(@distance, @sourceNode)
    WHERE point_hierarchy.IsDescendantOf(@sourceNode) = 1;
END;



-- �������� ����
INSERT INTO Points (city, country, point_name, point_hierarchy)
VALUES ('City A', 'Country A', 'Root', hierarchyid::GetRoot());


-- ����� ��������� AddSubordinate ��� ���������� ����������� �����
DECLARE @root hierarchyid;
SELECT @root = point_hierarchy FROM Points WHERE point_id = 1; -- ����� 1 - ������������� ��������� ����

EXEC AddSubordinate @root, 'City B', 'Country A', 'Child 1';
EXEC AddSubordinate @root, 'City E', 'Country B', 'Child 2';


-- �������� ������������� ���� � ������������ ����� (Child 1 � Child 2)
DECLARE @child1 hierarchyid, @child2 hierarchyid;

SELECT @child1 = point_hierarchy FROM Points WHERE point_id = 2; -- ������������� Child 1
SELECT @child2 = point_hierarchy FROM Points WHERE point_id = 3; -- ������������� Child 2

-- �������� ����������� ���� ��� Child 1
EXEC AddSubordinate @child1, 'City C', 'Country A', 'Grandchild 1';
EXEC AddSubordinate @child1, 'City D', 'Country A', 'Grandchild 2';

-- �������� ����������� ���� ��� Child 2
EXEC AddSubordinate @child2, 'City F', 'Country B', 'Grandchild 3';


Select * from Points;