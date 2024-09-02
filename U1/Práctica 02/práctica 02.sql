
create table Usuario(
	id_usuario int not null primary key,
	nombre nvarchar(30),
	apellido_paterno nvarchar(30),
	apellido_materno nvarchar(30),
	fecha_registro date,
	correo varchar(30),
	telefono int
)
go
 
create table Profesor(
	num_empleado int not null primary key references usuario (id_usuario),
	especialidad varchar(50),
	sueldo int
)
go

create table Administrativo(
	num_empleado int not null primary key references usuario (id_usuario),
	departamento varchar(50),
	sueldo int
)
go

create table Alumno
(
	matricula int not null primary key references usuario (id_usuario),
	semestre tinyint,
	carrera varchar(50)
)
go

create table Autor( 
	id_autor int not null primary key,
	nombre varchar(30)
)
go

create table Libro(
	isbn char(13) not null primary key, 
	titulo varchar(50),
	año smallint,
	ejemplares tinyint,
	ejemplares_prestados tinyint,
	editorial varchar(50)
)
go 

create table autor_libros( 
	id_autor int not null references Autor (id_autor),
	isbn char(13) not null references libro (isbn)
)
go

create table Prestamos(
	id_prestamo int not null primary key,
	estado char(10),
	fecha date,
	fecha_devolucion date
)
go

create table Multas(
	id_prestamo int not null references Prestamos(id_prestamo),
	fecha_pago date,
	monto int
)
go