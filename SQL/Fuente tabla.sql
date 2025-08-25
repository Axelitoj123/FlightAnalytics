CREATE DATABASE proyecto_airflights
USE proyecto_airflights

CREATE TABLE airflights(
indice INT ,
airline VARCHAR(40) ,
flight VARCHAR(40),
source_city VARCHAR(40),
departure_time VARCHAR(40),
stops VARCHAR(40),
arrival_time VARCHAR(40),
destination_city VARCHAR(40),
class VARCHAR(40),
duration FLOAT,
days_left INT,
price FLOAT)

BULK INSERT 
			airflights
FROM 
		'E:\PROYECTOS_AXEL_ANALYST\airlines_flights_data.csv'
WITH (
		FIELDTERMINATOR =',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
		)

--ACTUALIZAR LOS PRECIOS PARA QUE SE MANEJE EN DOLARES YA QUE SE MANEJABA EN RUPIAS(INDIA)
BEGIN TRAN
UPDATE airflights SET price= price*0.012
ROLLBACK

UPDATE airflights
SET price = ROUND(price, 1)

--ACTUALIZAR LOS STOPS EN NUMEROS ENTEROS
UPDATE airflights SET stops= 0
WHERE stops= 'zero'

UPDATE airflights SET stops= 1
WHERE stops= 'one'

UPDATE airflights SET stops= 2
WHERE stops= 'two_or_more'

ALTER TABLE airflights
ALTER COLUMN stops INT

--Conociendo la tabla original
--Información de la tabla
sp_help airflights

--Tabla original
SELECT DISTINCT flight,class FROM airflights ORDER BY flight,class
SELECT DISTINCT flight,class FROM airflights WHERE flight= 'SG-946'
--Cantidad de filas
SELECT COUNT(*) FROM airflights

--Todas las aerolineas
SELECT DISTINCT (airline) AEROLINEAS FROM airflights

SELECT DISTINCT stops FROM airflights

SELECT * FROM airflights WHERE stops ='two_or_more'

--Distintos rutas que tiene la aerolinea
SELECT DISTINCT source_city,destination_city,stops FROM airflights

--Todas las programaciones en los vuelos
SELECT DISTINCT departure_time,arrival_time FROM airflights

SELECT DISTINCT flight FROM airflights WHERE flight= 'two_or_more'

SELECT * FROM airflights 
WHERE source_city= 'Bangalore' 
AND destination_city='Kolkata'

SELECT * FROM airflights WHERE flight='AI-439'

SELECT flight,COUNT(*) VECES FROM airflights 
GROUP BY flight


----CONSIDERACIONES
--El precio que manejaba la tabla original era en rupias(INDIA), por ello lo pase en la moneda Dolares para que sea mas entendible y práctico..
--Se procedera armar un modelo BI(estrella) ya que es mas eficiente.
--Existe repeticion en la tabla original para el campo de airline,flight y class asi que empezare por ahi armando sus tablas(Dimensiones).
--Decidí que las tablas de fligths y class colocare como llave IDENTITY y las demas agregare un codigo formado por el nombre de la tabla y orden.
--Existe algunos codigo de vuelo que cuentan con una sola clase

