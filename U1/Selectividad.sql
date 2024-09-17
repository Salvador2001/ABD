create database ejemplo
go 
drop table empleados
go 
CREATE TABLE Empleados (ID INT,
Nombre VARCHAR(20),
Apellido VARCHAR(20),
Ciudad VARCHAR(20))
GO
CREATE NonCLUSTERED INDEX Index_Ciudad
ON Empleados (Ciudad);

-- Crear índice nonclustered en el campo Nombre
CREATE NONCLUSTERED INDEX Index_Empleados_Nombre
ON Empleados (Nombre);


insert into Empleados values (1,'Luis', 'Sanchez', 'Culiacan')
go 

insert into Empleados values (2,'Rosa', 'Perez', 'Culiacan')
go 10000

go 

select * from Empleados where nombre='Luis' -- es selectiva y tiene índice, index seek.
go
select * from Empleados where nombre='Rosa' -- no es selectiva, scan.
go 
select * from Empleados where Ciudad ='Culiacan' -- 10001, scan.
go 
select * from Empleados where apellido='sanchez' -- 1, no hay index, scan.
go 
select * from Empleados where apellido='perez' -- 10k, no hay index, scan.
go 
insert into Empleados values (2,'Rosa', 'acosta', 'mazatlan')
go 
select * from Empleados where Ciudad ='mazatlan' -- index seek, 1 valor.
go 
select * from Empleados where Ciudad ='mazatlan' and Nombre ='rosa' -- index seek.
go 
select * from Empleados where Ciudad ='culiacan' and Nombre ='rosa' -- scan.
go
select * from Empleados where Ciudad ='mazatlan' or Nombre ='rosa' -- scan.
go
select * from Empleados where Ciudad ='mazatlan' or Nombre ='luis' -- index seek en ambos.