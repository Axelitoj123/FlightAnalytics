--CREACION DE TABLAS (MODELO ESTRELLA):

-- Tabla 1: Airlines 
CREATE TABLE Airlines (
    airline_id VARCHAR(10) PRIMARY KEY,     
    airline_name VARCHAR(50)
);

-- Tabla 2: FlightNumbers 
CREATE TABLE FlightNumbers (
    flight_number_id INT IDENTITY(1,1) PRIMARY KEY,
    flight_code VARCHAR(20)
);

-- Tabla 3: Routes 
CREATE TABLE Routes (
    route_id VARCHAR(10) PRIMARY KEY,        
    source_city VARCHAR(40),
    destination_city VARCHAR(40),
    stops VARCHAR(10)
);

-- Tabla 4: Schedule 
CREATE TABLE Schedule (
    schedule_id VARCHAR(10) PRIMARY KEY,      
    departure_time VARCHAR(20),
    arrival_time VARCHAR(20)
);

-- Tabla 5: Classes 
CREATE TABLE Classes (
    class_id INT IDENTITY(1,1) PRIMARY KEY,
    class_name VARCHAR(20)
);

-- Tabla 6: Flights 
CREATE TABLE Flights (
    flight_number_id INT,         -- FK de FlightNumbers
    airline_id VARCHAR(10),       -- FK de Airlines
    route_id VARCHAR(10),         -- FK de Routes
    schedule_id VARCHAR(10),      -- FK de Schedule
    class_id INT,                 -- FK de Classes
    duration FLOAT,
    days_left INT,
    price FLOAT
);

--Inserción de datos a las tablas

-- Insertar en Airlines 
INSERT INTO Airlines (airline_id, airline_name)
SELECT 
    CONCAT('AIR', RIGHT('000' + CAST(ROW_NUMBER() OVER (ORDER BY airline) AS VARCHAR), 3)),
    airline
FROM (
    SELECT DISTINCT airline
    FROM airflights
) AS sub;

-- Insertar en FlightNumbers 
INSERT INTO FlightNumbers (flight_code)
SELECT DISTINCT flight
FROM airflights;

-- Insertar en Routes 
INSERT INTO Routes (route_id, source_city, destination_city, stops)
SELECT 
    CONCAT('ROU', RIGHT('000' + CAST(ROW_NUMBER() OVER (ORDER BY source_city, destination_city, stops) AS VARCHAR), 3)),
    source_city,
    destination_city,
    stops
FROM (
    SELECT DISTINCT source_city, destination_city, stops
    FROM airflights
) AS sub;

-- Insertar en Schedule 
INSERT INTO Schedule (schedule_id, departure_time, arrival_time)
SELECT 
    CONCAT('SCH', RIGHT('000' + CAST(ROW_NUMBER() OVER (ORDER BY departure_time, arrival_time) AS VARCHAR), 3)),
    departure_time,
    arrival_time
FROM (
    SELECT DISTINCT departure_time, arrival_time
    FROM airflights
) AS sub;

-- Insertar en Classes 
INSERT INTO Classes (class_name)
SELECT DISTINCT class
FROM airflights;

--Mostrando las tablas(dimensiones) llenas

SELECT * FROM Classes
SELECT * FROM Airlines
SELECT * FROM FlightNumbers
SELECT * FROM Routes
SELECT * FROM Schedule

--Inserción para la tabla de hechos

INSERT INTO Flights (
    flight_number_id,
    airline_id,
    route_id,
    schedule_id,
    class_id,
    duration,
    days_left,
    price
)
SELECT
    fn.flight_number_id,
    a.airline_id,
    r.route_id,
    s.schedule_id,
    c.class_id,
    af.duration,
    af.days_left,
    af.price
FROM airflights af
JOIN FlightNumbers fn ON af.flight = fn.flight_code
JOIN Airlines a ON af.airline = a.airline_name
JOIN Routes r ON 
    af.source_city = r.source_city AND 
    af.destination_city = r.destination_city AND 
    af.stops = r.stops
JOIN Schedule s ON 
    af.departure_time = s.departure_time AND 
    af.arrival_time = s.arrival_time
JOIN Classes c ON af.class = c.class_name;

--Mostrando tabla de hechos lleno
SELECT * FROM Flights
