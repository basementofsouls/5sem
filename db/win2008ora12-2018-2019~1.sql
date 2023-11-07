CREATE TABLE Users_ (
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_name CHAR(50) NOT NULL,
    user_email CHAR(50) UNIQUE,
    user_password CHAR(100),
    date_registration DATE
)TABLESPACE COMPANY_SAIQDATA;
---Создание таблицы Заказы
CREATE TABLE Orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    ticket_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users_(user_id),
     FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
)TABLESPACE COMPANY_SAIQDATA;
---Создание таблицы Билеты
CREATE TABLE Tickets (
    ticket_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    tour_id INT,
    buy_date DATE,
    ticket_price DECIMAL(10,2),
    seat_class CHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users_(user_id),
    FOREIGN KEY (tour_id) REFERENCES Tours(tour_id)
)TABLESPACE COMPANY_SAIQDATA;
---Создание таблицы Туры
CREATE TABLE Tours (
    tour_id INT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    route_id INT,
    tourstart_datetime TIMESTAMP NOT NULL,
    tourend_datetime TIMESTAMP NOT NULL,
    FOREIGN KEY (route_id) REFERENCES Routes(route_id)
)TABLESPACE COMPANY_SAIQDATA;
---Создание таблицы Маршруты
CREATE TABLE Routes (
    route_id INT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_id INT,
    to_id INT,
    bus_id INT,
    FOREIGN KEY (from_id) REFERENCES Points(point_id),
    FOREIGN KEY (to_id) REFERENCES Points(point_id),
    FOREIGN KEY (bus_id) REFERENCES Buses(bus_id)
)TABLESPACE COMPANY_SAIQDATA;

---Создание таблицы Точки отправления/прибытия
CREATE TABLE Points (
    point_id INT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city CHAR(50) NOT NULL,
    country CHAR(50) NOT NULL,
    point_name CHAR(50) NOT NULL
)TABLESPACE COMPANY_SAIQDATA;
---Создание таблицы Автобусы
CREATE TABLE Buses (
    bus_id INT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bus_number CHAR(50) NOT NULL,
    bus_capacity NUMBER(10) NOT NULL
)TABLESPACE COMPANY_SAIQDATA;

---Создание представлений
CREATE VIEW tour_info_view AS
SELECT s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, COUNT(t.ticket_id) AS tickets_sold, b.bus_capacity
FROM Tours s
JOIN Routes r ON s.route_id = r.route_id
JOIN Buses b ON r.bus_id = b.bus_id
LEFT JOIN Tickets t ON s.tour_id = t.tour_id
GROUP BY s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, b.bus_capacity
order by s.tour_id;


CREATE OR REPLACE VIEW ordered_tickets_view AS
SELECT *
FROM Tickets
ORDER BY buy_date;


---Создание индексов
CREATE INDEX ix_Tickets_tour_id ON Tickets(tour_id) TABLESPACE COMPANY_SAIQDATA;
CREATE INDEX ix_Orders_ticket_id ON Orders(ticket_id) TABLESPACE COMPANY_SAIQDATA;
CREATE INDEX ix_Tours_route_id ON Tours(route_id) TABLESPACE COMPANY_SAIQDATA;
CREATE INDEX ix_Tickets_user_id ON Tickets(user_id) TABLESPACE COMPANY_SAIQDATA;

---Создание триггеров
CREATE OR REPLACE TRIGGER ticket_capacity_trigger
BEFORE INSERT ON Tickets
FOR EACH ROW
DECLARE
    v_capacity NUMBER;
    v_tickets_count NUMBER;
BEGIN
    SELECT bus_capacity INTO v_capacity
    FROM Buses
    WHERE bus_id = (
        SELECT bus_id
        FROM Routes
        WHERE route_id = (
            SELECT route_id
            FROM Tours
            WHERE tour_id = :new.tour_id
        )
    );
    
    SELECT COUNT(*) INTO v_tickets_count
    FROM Tickets
    WHERE tour_id = :new.tour_id;
    
    IF v_tickets_count = v_capacity THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot add ticket, flight is full.');
    END IF;
END;


CREATE OR REPLACE TRIGGER add_order
AFTER INSERT ON Tickets
FOR EACH ROW
BEGIN
  INSERT INTO Orders (user_id, ticket_id)
  SELECT u.user_id, :new.ticket_id
  FROM Users_ u
  WHERE u.user_id = :new.user_id;
END;


CREATE OR REPLACE PROCEDURE add_user(
  user_name IN CHAR,
  user_email IN CHAR,
  user_password IN CHAR,
  date_registration IN DATE
) AS
BEGIN
  INSERT INTO Users_ (user_name, user_email, user_password, date_registration)
  VALUES (user_name, user_email, user_password, date_registration);
END;

CREATE OR REPLACE PROCEDURE delete_user(p_user_id IN NUMBER)
AS
BEGIN
    -- удаление заказов пользователя
    DELETE FROM orders WHERE user_id = p_user_id;
    
    -- удаление билетов пользователя
    DELETE FROM tickets WHERE user_id = p_user_id;
    
    -- удаление пользователя
    DELETE FROM users_ WHERE user_id = p_user_id;
    
    COMMIT;
END;
/

----Создание функций
CREATE OR REPLACE FUNCTION count_sold_tickets(start_date IN DATE, end_date IN DATE)
RETURN INTEGER
AS
  sold_tickets INTEGER;
BEGIN
  SELECT COUNT(*) INTO sold_tickets FROM Tickets WHERE buy_date >= start_date AND buy_date <= end_date;
  RETURN sold_tickets;
END;

--------------ЛР3----------
ALTER TABLE Points
ADD hierarchy_path VARCHAR2(4000);


UPDATE Points p
SET p.hierarchy_path = (
    SELECT SYS_CONNECT_BY_PATH(city || '/' || country || '/' || point_name, '/')
    FROM Points
    WHERE point_id = CONNECT_BY_ROOT point_id
    START WITH point_id = p.point_id
    CONNECT BY PRIOR point_id = point_id
);


-----Получение всех подчиненных узлов в иерархии
CREATE OR REPLACE FUNCTION GetSubordinates(p_node_id NUMBER) RETURN SYS_REFCURSOR IS
  l_cursor SYS_REFCURSOR;
BEGIN
  OPEN l_cursor FOR
  SELECT point_id, city, country, point_name, hierarchy_path
  FROM Points
  WHERE hierarchy_path LIKE (SELECT hierarchy_path || '%' FROM Points WHERE point_id = p_node_id);

  RETURN l_cursor;
END GetSubordinates;
/


---------Получение иерархической структуры в виде дерева
CREATE OR REPLACE FUNCTION GetHierarchyTree RETURN SYS_REFCURSOR IS
  l_cursor SYS_REFCURSOR;
BEGIN
  OPEN l_cursor FOR
  SELECT point_id, city, country, point_name, hierarchy_path
  FROM Points
  START WITH SUBSTR(hierarchy_path, 1, INSTR(hierarchy_path, '/', 1, 1) - 1) IS NULL
  CONNECT BY PRIOR point_id = point_id
  ORDER SIBLINGS BY point_name;

  RETURN l_cursor;
END GetHierarchyTree;
/



-----Добавление нового узла
CREATE OR REPLACE PROCEDURE AddNode(p_city VARCHAR2, p_country VARCHAR2, p_point_name VARCHAR2, p_parent_id NUMBER) IS
  l_parent_path VARCHAR2(4000);
BEGIN
  -- Получите иерархический путь родительского узла
  SELECT hierarchy_path
  INTO l_parent_path
  FROM Points
  WHERE point_id = p_parent_id;

  -- новый узел с корректным иерархическим путем
  INSERT INTO Points (city, country, point_name, hierarchy_path)
  VALUES (p_city, p_country, p_point_name, l_parent_path || '/' || p_point_name);

  COMMIT;
END AddNode;
/



----Перемещение узла в другое место иерархии
CREATE OR REPLACE PROCEDURE MoveNode(p_node_id NUMBER, p_new_parent_id NUMBER) IS
  l_new_parent_path VARCHAR2(4000);
BEGIN
  --иерархический путь нового родительского узла
  SELECT hierarchy_path
  INTO l_new_parent_path
  FROM Points
  WHERE point_id = p_new_parent_id;

  -- обновление иерархического пути перемещаемого узла
  UPDATE Points
  SET hierarchy_path = l_new_parent_path || '/' || point_name
  WHERE point_id = p_node_id;

  COMMIT;
END MoveNode;
/


