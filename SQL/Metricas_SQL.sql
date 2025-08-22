--Tabla de hechos
SELECT * FROM Flights

--Tablas de dimensiones
SELECT * FROM Classes
SELECT * FROM Airlines
SELECT * FROM FlightNumbers
SELECT * FROM Routes
SELECT * FROM Schedule

--Creación de vistas
CREATE VIEW Aerolineas AS
SELECT airline_name FROM Airlines

SELECT * FROM Aerolineas

ALTER VIEW Todas_las_Rutas AS
SELECT DISTINCT source_city,destination_city FROM Routes

SELECT * FROM Todas_las_Rutas

--Uso de subconsultas
SELECT flight_code FROM FlightNumbers FL WHERE 
EXISTS(SELECT * FROM Flights F WHERE FL.flight_number_id=F.flight_number_id AND class_id=2)

--Codigos de vuelo que solo tienen una clase
SELECT flight_code FROM FlightNumbers FL WHERE 
3 >(SELECT COUNT(DISTINCT class_id) FROM flights F WHERE FL.flight_number_id=F.flight_number_id )

--Codigos de vuelos que solo tienes clase bussines
SELECT flight_code
FROM FlightNumbers
WHERE flight_number_id IN (
    SELECT flight_number_id
    FROM Flights
    GROUP BY flight_number_id
    HAVING COUNT(DISTINCT class_id) =2
)

--Aerolineas que tiene un promedio en horas menor que el promedio total de vuelos
SELECT A.airline_name FROM Airlines A JOIN Flights F ON A.airline_id=F.airline_id 
GROUP BY A.airline_name
HAVING AVG (duration)<(SELECT AVG(duration) FROM Flights)

SELECT DISTINCT source_city Ciudades  FROM Routes R JOIN Flights F ON R.route_id= F.route_id WHERE days_left= 1 AND stops = 0

--Muestra cuántos vuelos distintos hay por cada tipo de clase (económica o business)
SELECT class_id ,COUNT(DISTINCT flight_number_id) CODIGOS_DE_VUELO FROM Flights
GROUP BY  class_id ORDER BY  class_id

--Precio promedio de los vuelos por Aerolinea
SELECT A.airline_name, CAST(AVG(F.price) AS INT) PRECIO_DOLARES FROM Flights F 
JOIN Airlines A ON A.airline_id= F.airline_id 
GROUP BY airline_name

--Lista de los aviones que han sido usados en más de 5 vuelos

SELECT A.airline_name ,MAX(F.price) MÁXIMO_PRECIO ,MIN(F.price) MÍNIMO_PRECIO FROM Flights F 
JOIN Airlines A ON A.airline_id= F.airline_id 
GROUP BY airline_name

--Lista de numeros de vuelo que salen temprano y muy temprano y que son de clase economica

SELECT DISTINCT F.flight_number_id FROM Flights F 
JOIN Schedule S ON S.schedule_id=F.schedule_id WHERE S.departure_time IN ('Morning','Early_Morning') AND F.class_id=1

--Usando funciones de ventana para mostrarnos un ranking de los precios accesibles
WITH Tabla_en_uso AS (
SELECT A.airline_name, CAST(AVG(F.price) AS INT) Precio_promedio FROM Flights F
JOIN Airlines A ON  A.airline_id= F.airline_id
GROUP BY A.airline_name
)

SELECT 
T.airline_name ,
T.Precio_promedio,
ROW_NUMBER() OVER(ORDER BY T.Precio_promedio) Precios_disponibles
FROM Tabla_en_uso T
ORDER BY T.Precio_promedio


SELECT 
S.departure_time,
S.departure_time,
AVG(F.duration) Duracion_promedio
FROM Flights F
JOIN Schedule S ON F.schedule_id= S.schedule_id
GROUP BY S.departure_time,S.departure_time

SELECT DISTINCT
S.departure_time,
S.arrival_time,
CAST(AVG(F.duration) OVER(PARTITION BY S.departure_time,
S.arrival_time) AS INT) Hrs
FROM Schedule S LEFT JOIN
Flights F ON S.schedule_id=F.schedule_id

SELECT @@SERVERNAME 