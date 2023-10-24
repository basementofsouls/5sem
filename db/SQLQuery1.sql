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
        THROW 51000, 'Cannot add ticket, flight is full.', 1;
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
