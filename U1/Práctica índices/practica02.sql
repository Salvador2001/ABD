--. Fragmentación interna:
--La fragmentación interna ocurre cuando hay espacio no utilizado dentro de 
--las páginas de datos del índice. Este espacio vacío puede ser consecuencia 
--de operaciones como inserciones, eliminaciones o actualizaciones que provocan que SQL Server divida 
--las páginas de datos para dar cabida a los cambios (también conocido como page splits).

--Fragmentación externa
--La fragmentación externa ocurre cuando las páginas de un índice 
--no están almacenadas secuencialmente en el disco o en la memoria. Esto sucede cuando las páginas del índice, 
--en lugar de estar contiguas, están dispersas en diferentes partes del disco o la memoria.

CREATE TABLE Pedidos
(
    PedidoID INT IDENTITY(1,1) , -- Este será el índice clustered por defecto
    ClienteID INT,
    FechaPedido DATETIME,
    Total DECIMAL(10,2),
    Estado NVARCHAR(50)
);
go
CREATE CLUSTERED INDEX PK_Pedidos_pedidoid
ON Pedidos (pedidoid);
go 
-- Crear un índice non-clustered en Estado y FechaPedido
CREATE NONCLUSTERED INDEX IX_Pedidos_Estado_Fecha
ON Pedidos (Estado, FechaPedido);

--2.
-- Insertar datos masivos para generar fragmentación
--Vamos a insertar datos aleatorios para simular un sistema de pedidos,
-- donde el estado y la fecha varían, y también generamos intencionalmente cambios que puedan llevar a fragmentación.
DECLARE @i INT = 1
WHILE @i <= 200000
BEGIN
    INSERT INTO Pedidos (ClienteID, FechaPedido, Total, Estado)
    VALUES (FLOOR(RAND() * 1000), DATEADD(DAY, -FLOOR(RAND() * 100), GETDATE()),
            ROUND(RAND() * 1000, 2), CASE WHEN @i % 5 = 0 THEN 'Pendiente' ELSE 'Completado' END);
    SET @i = @i + 1;
END
--3. Actualizar los datos para causar fragmentación interna
--Realizaremos varias actualizaciones que causarán page splits, 
--lo que llevará a una fragmentación interna considerable en el índice non-clustered.
-- Actualizamos el estado de los pedidos para provocar page splits
UPDATE Pedidos
SET Estado = 'En Proceso'
WHERE PedidoID % 3 = 0;
--4. Revisar la fragmentación de ambos índices
--Aquí los alumnos podrán comprobar cómo estas operaciones afectaron tanto al índice clustered como al non-clustered.
-- Ver fragmentación en el índice clustered (PedidoID)
SELECT
    index_id,
    avg_fragmentation_in_percent,
    page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('Pedidos'), 1, NULL, 'DETAILED');
go
-- Ver fragmentación en el índice non-clustered (Estado, FechaPedido)
SELECT
    index_id,
    avg_fragmentation_in_percent,
    page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('Pedidos'), 2, NULL, 'DETAILED');

--5. Si el índice non-clustered está muy fragmentado (>30%), deben reconstruirlo.
--Si el índice clustered tiene una fragmentación moderada (10-30%), deben reorganizarlo.

-- Reorganizar el índice clustered si la fragmentación es moderada
ALTER INDEX PK_Pedidos_Estado_Fecha ON Pedidos REORGANIZE;

-- Reconstruir el índice non-clustered si la fragmentación es alta
ALTER INDEX IX_Pedidos_Estado_Fecha ON Pedidos REBUILD;

--6. Modificar la tabla para generar más fragmentación
--Ahora, pide a los alumnos que inserten y eliminen datos para seguir viendo cómo estas operaciones 
--afectan la fragmentación, pero esta vez con un enfoque de fragmentación externa:
-- Eliminar pedidos para provocar más fragmentación
DELETE FROM Pedidos
WHERE PedidoID % 10 = 0;
go
-- Insertar más pedidos después de las eliminaciones
DECLARE @j INT = 1
WHILE @j <= 50000
BEGIN
    INSERT INTO Pedidos (ClienteID, FechaPedido, Total, Estado)
    VALUES (FLOOR(RAND() * 1000), DATEADD(DAY, -FLOOR(RAND() * 100), GETDATE()),
            ROUND(RAND() * 1000, 2), 'Pendiente');
    SET @j = @j + 1;
END

--7. Verificar la fragmentación después de las eliminaciones e inserciones
--Por último, revisan nuevamente la fragmentación y analizan el impacto de estas operaciones en los índices.
-- Verificar la fragmentación después de las eliminaciones e inserciones
SELECT
    index_id,
    avg_fragmentation_in_percent,
    page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('Pedidos'), NULL, NULL, 'DETAILED');
