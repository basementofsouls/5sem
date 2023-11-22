create database Turfirma;

use database Turfirma;
-- Создание таблицы Users
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    user_email VARCHAR(50) UNIQUE,
    user_password CHAR(100),
    date_registration DATE
);

-- Создание таблицы Заказы
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    ticket_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (ticket_id) REFERENCES Tickets (ticket_id)
);

-- Создание таблицы Билеты
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

-- Создание таблицы Туры
CREATE TABLE Tours (
    tour_id INT IDENTITY(1,1) PRIMARY KEY,
    route_id INT,
    tourstart_datetime DATETIME2 NOT NULL,
    tourend_datetime DATETIME2 NOT NULL,
    FOREIGN KEY (route_id) REFERENCES Routes (route_id)
);

-- Создание таблицы Маршруты
CREATE TABLE Routes (
    route_id INT IDENTITY(1,1) PRIMARY KEY,
    from_id INT,
    to_id INT,
    bus_id INT,
    FOREIGN KEY (from_id) REFERENCES Points (point_id),
    FOREIGN KEY (to_id) REFERENCES Points (point_id),
    FOREIGN KEY (bus_id) REFERENCES Buses (bus_id)
);

-- Создание таблицы Точки отправления/прибытия
CREATE TABLE Points (
    point_id INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    point_name VARCHAR(50) NOT NULL
);

-- Создание таблицы Автобусы
CREATE TABLE Buses (
    bus_id INT IDENTITY(1,1) PRIMARY KEY,
    bus_number VARCHAR(50) NOT NULL,
    bus_capacity INT NOT NULL
);

-- Создание представления tour_info_view
CREATE VIEW tour_info_view AS
SELECT TOP 100 PERCENT
    s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, COUNT(t.ticket_id) AS tickets_sold, b.bus_capacity
FROM Tours s
INNER JOIN Routes r ON s.route_id = r.route_id
INNER JOIN Buses b ON r.bus_id = b.bus_id
LEFT JOIN Tickets t ON s.tour_id = t.tour_id
GROUP BY s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, b.bus_capacity
ORDER BY s.tour_id;


-- Создание представления ordered_tickets_view
CREATE VIEW ordered_tickets_view AS
SELECT *
FROM Tickets;

SELECT *
FROM ordered_tickets_view
ORDER BY buy_date;

-- Индекс для столбца tour_id в таблице Tickets
CREATE INDEX ix_Tickets_tour_id ON Tickets(tour_id);

-- Индекс для столбца ticket_id в таблице Orders
CREATE INDEX ix_Orders_ticket_id ON Orders(ticket_id);

-- Индекс для столбца route_id в таблице Tours
CREATE INDEX ix_Tours_route_id ON Tours(route_id);

-- Индекс для столбца user_id в таблице Tickets
CREATE INDEX ix_Tickets_user_id ON Tickets(user_id);


-- Триггер для проверки вместимости автобуса
CREATE TRIGGER ticket_capacity_trigger
ON Tickets
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @v_capacity INT;
    DECLARE @v_tickets_count INT;

    -- Получить вместимость автобуса
    SELECT @v_capacity = B.bus_capacity
    FROM Routes R
    INNER JOIN Tours T ON R.route_id = T.route_id
    INNER JOIN Buses B ON R.bus_id = B.bus_id
    WHERE T.tour_id = (SELECT tour_id FROM INSERTED);

    -- Подсчитать количество проданных билетов
    SELECT @v_tickets_count = COUNT(*)
    FROM Tickets
    WHERE tour_id = (SELECT tour_id FROM INSERTED);

    -- Проверка на вместимость
    IF @v_tickets_count >= @v_capacity
    BEGIN
        THROW 51000, 'Cannot add ticket, tour is full.', 1;
    END;
    ELSE
    BEGIN
        -- Вставка новых билетов
        INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
        SELECT I.user_id, I.tour_id, I.buy_date, I.ticket_price, I.seat_class
        FROM INSERTED I;
    END;
END;





-- Триггер для создания заказов
CREATE OR ALTER TRIGGER add_order
ON Tickets
AFTER INSERT
AS
BEGIN
  INSERT INTO Orders (user_id, ticket_id)
  SELECT u.user_id, i.ticket_id
  FROM Users u
  JOIN INSERTED i ON u.user_id = i.user_id;
END;

-- Хранимая процедура для добавления пользователя
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

-- Хранимая процедура для удаления пользователя
CREATE PROCEDURE delete_user
@p_user_id INT
AS
BEGIN
    -- Удаление заказов пользователя
    DELETE FROM Orders WHERE user_id = @p_user_id;
    
    -- Удаление билетов пользователя
    DELETE FROM Tickets WHERE user_id = @p_user_id;
    
    -- Удаление пользователя
    DELETE FROM Users WHERE user_id = @p_user_id;
    
    COMMIT;
END;

-- Создание функции для подсчета проданных билетов
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


-----------------------------------------ЛР 3-----------------------------------
---Добавление столбца иерархии
ALTER TABLE Points
ADD point_hierarchy hierarchyid;


---Создание процедуры для отображения подчиненных узлов с указанием уровня иерархии
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


---Создание процедуры для добавления подчиненного узла
CREATE PROCEDURE AddChildNode
    @ParentNodePath hierarchyid, 
    @NewNodeName NVARCHAR(100)
AS
BEGIN
  DECLARE @LastChild hierarchyid;

  DECLARE @NewPointId INT;
  SET @NewPointId = CAST(CAST(CONVERT(uniqueidentifier, NEWID()) AS VARBINARY) AS INT);

    -- Get the last child node under the parent
    SELECT TOP 1 @LastChild = point_hierarchy
    FROM Points
    WHERE point_hierarchy.GetAncestor(1) = @ParentNodePath
    ORDER BY point_hierarchy DESC;

    DECLARE @NewNodePath hierarchyid;
    -- Use the last child as the first parameter to GetDescendant
    SET @NewNodePath = @ParentNodePath.GetDescendant(@LastChild, NULL);

    INSERT INTO Points(point_id, point_name, point_hierarchy)
    VALUES (@NewPointId, @NewNodeName, @NewNodePath);
END;
DECLARE @NodePath hierarchyid;
SET @NodePath = hierarchyid::Parse('/');

EXEC DisplayChildPoints @NodePath;

---Создание процедуры для перемещения подчиненной ветки
CREATE PROCEDURE MoveSubtree @sourceNode hierarchyid, @destinationNode hierarchyid
AS
BEGIN
    DECLARE @distance hierarchyid;
    SET @distance = @destinationNode.GetDescendant(NULL, NULL);

    UPDATE Points
    SET point_hierarchy = point_hierarchy.GetReparentedValue(@distance, @sourceNode)
    WHERE point_hierarchy.IsDescendantOf(@sourceNode) = 1;
END;



-- корневой узел
INSERT INTO Points (city, country, point_name, point_hierarchy)
VALUES ('City A', 'Country A', 'Root', hierarchyid::GetRoot());
INSERT INTO Points (city, country, point_name, point_hierarchy)
VALUES ('City B', 'Country B', 'Root', hierarchyid::GetRoot());

Select * from Points;
-- Вызов процедуры AddSubordinate для добавления подчиненных узлов
DECLARE @root hierarchyid;
SELECT @root = point_hierarchy FROM Points WHERE point_id = 1033; -- Здесь 1 - идентификатор корневого узла

EXEC AddSubordinate @root, 'City B', 'Country A', 'Child 1';
EXEC AddSubordinate @root, 'City E', 'Country B', 'Child 2';


-- Получить иерархические пути к существующим узлам (Child 1 и Child 2)
DECLARE @child1 hierarchyid, @child2 hierarchyid;

SELECT @child1 = point_hierarchy FROM Points WHERE point_id = 2; -- Идентификатор Child 1
SELECT @child2 = point_hierarchy FROM Points WHERE point_id = 3; -- Идентификатор Child 2

-- Добавить подчиненные узлы для Child 1
EXEC AddSubordinate @child1, 'City C', 'Country A', 'Grandchild 1';
EXEC AddSubordinate @child1, 'City D', 'Country A', 'Grandchild 2';

-- Добавить подчиненные узлы для Child 2
EXEC AddSubordinate @child2, 'City F', 'Country B', 'Grandchild 3';

CREATE OR ALTER PROCEDURE DisplayChildPoints
    @NodePath hierarchyid
AS
BEGIN
    -- Вывод подчиненных узлов для переданного в параметре узла
    SELECT
        point_id,
        point_name,
        -- Используем метод ToString() с указанием уровня для корректного отображения пути
        point_hierarchy.ToString() AS NodePath,
        point_hierarchy.GetLevel() AS NodeLevel
    FROM
        Points
    WHERE
        point_hierarchy.IsDescendantOf(@NodePath) = 1
    ORDER BY point_hierarchy;
END;






ALTER TABLE Points 
add LEVELL as point_hierarchy.GetLevel() persisted;


DECLARE @NodePath hierarchyid;
SET @NodePath = hierarchyid::Parse('/');
EXEC DisplayChildPoints @NodePath;

Select * from Points;





------------------ЛР №3--------------

-- Добавление данных в таблицу Users
INSERT INTO Users (user_name, user_email, user_password, date_registration)
VALUES
('Alice', 'alice@example.com', 'password123', '2023-01-15'),
('Bob', 'bob@example.com', 'pass456', '2023-02-20'),
('Charlie', 'charlie@example.com', 'qwerty', '2023-03-10'),
('David', 'david@example.com', 'davidpass', '2023-04-25'),
('Eve', 'eve@example.com', 'evepass', '2023-05-08'),
('Frank', 'frank@example.com', 'frank123', '2023-06-30'),
('Grace', 'grace@example.com', 'gracepass', '2023-07-17'),
('Henry', 'henry@example.com', 'henrypass', '2023-08-22'),
('Isabel', 'isabel@example.com', 'isapass', '2023-09-05'),
('Jack', 'jack@example.com', 'jackpass', '2023-10-18');

-- Добавление данных в таблицу Orders


-- Добавление данных в таблицу Tickets
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(1, 4, '2023-01-16', 100.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(2, 5, '2023-02-21', 150.50, 'Business');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(3, 6, '2023-03-11', 200.25, 'First Class');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(4, 7, '2023-04-26', 180.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(5, 8, '2023-05-09', 120.75, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(6, 9, '2023-07-01', 210.50, 'First Class');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(7, 13, '2023-07-18', 95.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(8, 13, '2023-08-23', 175.25, 'Business');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(9, 13, '2023-09-06', 130.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(10, 4, '2023-10-19', 220.00, 'First Class');
Select * from Users;
-- Добавление данных в таблицу Tours
INSERT INTO Tours (route_id, tourstart_datetime, tourend_datetime)
VALUES
(13, '2023-01-17 08:00:00', '2023-01-17 16:00:00'),
(14, '2023-02-22 09:00:00', '2023-02-22 17:00:00'),
(15, '2023-03-12 10:00:00', '2023-03-12 18:00:00'),
(16, '2023-04-27 11:00:00', '2023-04-27 19:00:00'),
(17, '2023-05-10 12:00:00', '2023-05-10 20:00:00'),
(21, '2023-06-01 13:00:00', '2023-06-01 21:00:00'),
(22, '2023-07-19 14:00:00', '2023-07-19 22:00:00'),
(23, '2023-08-24 15:00:00', '2023-08-24 23:00:00'),
(24, '2023-09-07 16:00:00', '2023-09-07 00:00:00'),
(25, '2023-10-20 17:00:00', '2023-10-20 01:00:00');
Select * from Tours;
-- Добавление данных в таблицу Routes
INSERT INTO Routes (from_id, to_id, bus_id)
VALUES
(1, 2, 1),
(2, 3, 2),
(3, 4, 3),
(4, 5, 4),
(5, 6, 5);
INSERT INTO Routes (from_id, to_id, bus_id)
VALUES
(6, 1022, 6),
(1022, 1023, 7),
(1023, 1024, 8),
(1025, 1026, 9),
(1027, 1028, 10);
Select * from Routes;
-- Добавление данных в таблицу Points
DECLARE @child1 hierarchyid, @child2 hierarchyid;

SELECT @child1 = point_hierarchy FROM Points WHERE point_id = 2; -- Идентификатор Child 1
SELECT @child2 = point_hierarchy FROM Points WHERE point_id = 3; -- Идентификатор Child 2
EXEC AddSubordinate @child1, 'City C', 'Country A', 'Grandchild 1';
EXEC AddSubordinate @child1, 'City D', 'Country A', 'Grandchild 2';
EXEC AddSubordinate @child1, 'City E', 'Country A', 'Grandchild 3';
EXEC AddSubordinate @child1, 'City G', 'Country A', 'Grandchild 4';
EXEC AddSubordinate @child1, 'City H', 'Country A', 'Grandchild 5';

-- Добавление подчиненных узлов для Child 2
EXEC AddSubordinate @child2, 'City F', 'Country B', 'Grandchild 6';
EXEC AddSubordinate @child2, 'City I', 'Country B', 'Grandchild 7';
EXEC AddSubordinate @child2, 'City J', 'Country B', 'Grandchild 8';
EXEC AddSubordinate @child2, 'City K', 'Country B', 'Grandchild 9';
EXEC AddSubordinate @child2, 'City L', 'Country B', 'Grandchild 10';


-- Добавление данных в таблицу Buses
INSERT INTO Buses (bus_number, bus_capacity)
VALUES
('Bus 001', 50),
('Bus 002', 40),
('Bus 003', 60),
('Bus 004', 55),
('Bus 005', 45),
('Bus 006', 65),
('Bus 007', 70),
('Bus 008', 30),
('Bus 009', 75),
('Bus 010', 35);




-----------зад2
CREATE VIEW SalesSummary AS
SELECT 
    CAST(DATEPART(YEAR, tourstart_datetime) AS VARCHAR) + '-' + RIGHT('00' + CAST(DATEPART(MONTH, tourstart_datetime) AS VARCHAR), 2) AS period,
    SUM(ticket_price) AS total_sales
FROM Tours t
JOIN Tickets ti ON t.tour_id = ti.tour_id
GROUP BY DATEPART(YEAR, tourstart_datetime), DATEPART(MONTH, tourstart_datetime)

UNION ALL

SELECT 
    CAST(DATEPART(YEAR, tourstart_datetime) AS VARCHAR) + ' Q' + CAST(DATEPART(QUARTER, tourstart_datetime) AS VARCHAR) AS period,
    SUM(ticket_price) AS total_sales
FROM Tours t
JOIN Tickets ti ON t.tour_id = ti.tour_id
GROUP BY DATEPART(YEAR, tourstart_datetime), DATEPART(QUARTER, tourstart_datetime)

UNION ALL

SELECT 
    CAST(DATEPART(YEAR, tourstart_datetime) AS VARCHAR) + ' H' + CAST(((DATEPART(MONTH, tourstart_datetime) + 5) / 6) AS VARCHAR) AS period,
    SUM(ticket_price) AS total_sales
FROM Tours t
JOIN Tickets ti ON t.tour_id = ti.tour_id
GROUP BY DATEPART(YEAR, tourstart_datetime), ((DATEPART(MONTH, tourstart_datetime) + 5) / 6)

UNION ALL

SELECT 
    CAST(DATEPART(YEAR, tourstart_datetime) AS VARCHAR) AS period,
    SUM(ticket_price) AS total_sales
FROM Tours t
JOIN Tickets ti ON t.tour_id = ti.tour_id
GROUP BY DATEPART(YEAR, tourstart_datetime)

Select * from SalesSummary;

--------зад3
CREATE VIEW ServiceComparison AS
WITH ServiceVolume AS (
    SELECT 
        CAST(DATEPART(YEAR, tourstart_datetime) AS VARCHAR) + '-' + RIGHT('00' + CAST(DATEPART(MONTH, tourstart_datetime) AS VARCHAR), 2) AS period,
        SUM(ticket_price) AS total_sales
    FROM Tours t
    JOIN Tickets ti ON t.tour_id = ti.tour_id
    GROUP BY DATEPART(YEAR, tourstart_datetime), DATEPART(MONTH, tourstart_datetime)
),
TotalServiceVolume AS (
    SELECT SUM(total_sales) AS total
    FROM ServiceVolume
),
MaxServiceVolume AS (
    SELECT MAX(total_sales) AS max
    FROM ServiceVolume
)
SELECT 
    sv.period,
    sv.total_sales,
    (sv.total_sales / ts.total) * 100 AS percent_total,
    (sv.total_sales / ms.max) * 100 AS percent_max
FROM ServiceVolume sv
CROSS JOIN TotalServiceVolume ts
CROSS JOIN MaxServiceVolume ms


Select * from ServiceComparison;

---------4
WITH PaginatedData AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY point_hierarchy) AS RowNum
    FROM Points
)

SELECT *
FROM PaginatedData
WHERE RowNum BETWEEN 1 AND 7; -- Здесь выбираются результаты для первой страницы

-----5
WITH DeduplicatedData AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY point_id, point_hierarchy ORDER BY point_id) AS RowNum
    FROM Points
)

DELETE FROM DeduplicatedData
WHERE RowNum > 1; -- Оставляем только уникальные записи




