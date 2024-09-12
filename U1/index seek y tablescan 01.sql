-- Crear la tabla
CREATE TABLE Empleados (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50),
    Apellido NVARCHAR(50),
    Ciudad NVARCHAR(50),
    FechaContratacion DATE,
    Salario DECIMAL(10, 2)
);

-- Insertar datos aleatorios
INSERT INTO Empleados (Nombre, Apellido, Ciudad, FechaContratacion, Salario)
SELECT 
    LEFT(CONVERT(NVARCHAR(50), NEWID()), 10) AS Nombre,
    CASE 
        WHEN (RAND() * 100) < 10 THEN 'Smith' -- 10% de las veces 'Smith'
        ELSE LEFT(CONVERT(NVARCHAR(50), NEWID()), 10)
    END AS Apellido,
    CASE 
        WHEN (RAND() * 100) < 5 THEN 'Las Vegas' -- 5% de las veces 'Las Vegas'
        ELSE 'Houston'
    END AS Ciudad,
    DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), GETDATE()) AS FechaContratacion,
    RAND() * 50000 + 30000 AS Salario
FROM sys.objects AS s1
CROSS JOIN sys.objects AS s2
WHERE s1.object_id <= 1000 AND s2.object_id <= 10;

CREATE NONCLUSTERED INDEX idx_Ciudad ON Empleados(Ciudad);
CREATE NONCLUSTERED INDEX idx_Apellido ON Empleados(Apellido);
CREATE NONCLUSTERED INDEX idx_Nombre ON Empleados(Nombre);

SELECT *
FROM Empleados
WHERE Ciudad = 'Las Vegas';

SELECT *
FROM Empleados
WHERE Ciudad = 'Houston'; -- no es selectiva, por lo tanto
                        -- el índice es ignorado

SELECT *
FROM Empleados
WHERE Apellido = 'Smith';

SELECT *
FROM Empleados
WHERE Apellido = 'Doe';

SELECT *
FROM Empleados
WHERE Nombre = 'JohnDoe'; -- Asumimos que 'JohnDoe' es un nombre poco común

SELECT *
FROM Empleados
WHERE Nombre = 'Michael';

INSERT INTO Empleados (Nombre, Apellido, Ciudad, FechaContratacion, Salario)
VALUES
    ('JohnDoe', 'Smith', 'Las Vegas', '2023-01-10', 60000),
    ('Michael', 'Doe', 'Las Vegas', '2023-02-15', 65000),
    ('JohnDoe', 'Brown', 'Las Vegas', '2023-03-20', 70000),
    ('Alice', 'Smith', 'Las Vegas', '2023-04-25', 72000),
    ('Bob', 'Jones', 'Houston', '2023-05-30', 50000)

INSERT INTO Empleados (Nombre, Apellido, Ciudad, FechaContratacion, Salario)
VALUES    ('juan', 'perez', 'culiacan', '2023-01-10', 60000)
go 10000

SELECT *
FROM Empleados
WHERE Apellido = 'perez'