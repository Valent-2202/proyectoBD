--use proyectobd; 

/* 
carga de 1.000.000 de socios
*/

declare @i int = 1;
declare @edad int;
declare @fecha_nac date;
declare @fecha_alta date;

while @i <= 1000000
begin
    -- edad entre 18 y 68 años
    set @edad = 18 + abs(checksum(newid())) % 51;

    -- fecha de nacimiento
    set @fecha_nac = dateadd(year, -@edad, cast(getdate() as date));

    -- fecha de alta: 18 años después del nacimiento
    set @fecha_alta = dateadd(year, -(@edad - 18), cast(getdate() as date));

    insert into socio (dni, nombre_socio, apellido_socio, fecha_nacimiento, fecha_alta)
    values (
        7000000 + @i,-- recordar que el dni es único
        'nombre_'   + cast(@i as varchar(10)),
        'apellido_' + cast(@i as varchar(10)),
        @fecha_nac,
        @fecha_alta
    );

    set @i += 1;
end;
go

--verificamos cantidad de socios
select count(*) as cantidad_socios
from socio;
go

--verificamos la tabla de socios y sus registros
select * from socio


/*
carga de un millon de asistencias diarias
*/

set nocount on;
go

declare @j int = 1;

while @j <= 1000000
begin
    insert into asistencia_diaria (id_socio, id_turno, fecha, estado)
    values (
        @j,-- id_socio 
        3,-- id_turno existente en la tabla turno
        '2000-01-01',--fecha válida según el check
        case abs(checksum(newid())) % 3
            when 0 then 'presente'
            when 1 then 'ausente'
            else 'justificado'
        end
    );

    set @j += 1;
end;
go

--verificamos los turnos
select * from turno

--verificamos cantidad de asistencias
select count(*)
from asistencia_diaria;
go


/* 
   clonar tabla original para pruebas de índices
*/

--limpiamos si es necesario
truncate table asistencia_con_indice;

--clonamos
select *
into asistencia_con_indice
from asistencia_diaria
print '--- carga completa ---';
go;


--contamos
select count(*) from asistencia_con_indice

--verificamos los registros
select * from asistencia_diaria;


--contamos
select count(*) from asistencia_con_indice;

/*
   CONSULTA SIN INDICE
*/

--borra pk cluster y hacerla noncluster

alter table asistencia_diaria
drop constraint pk_asistencia;
go

alter table asistencia_diaria
add constraint pk_asistencia
primary key nonclustered (id_socio, id_turno, fecha);
go


--consulta
print '--- consulta sin índices (tabla asistencia_sin_indice) ---';

set statistics io on;
set statistics time on;

select id_socio, id_turno, estado
from asistencia_diaria
where fecha between '2000-01-01' and '2025-11-30';
go


/*
  PRUEBAS CON INDICE AGRUPADO
*/


--creación de índice agrupado (clustered index)


print '--- creando índice clustered en asistencia_con_indice(fecha) ---';

create clustered index cx_asistencia_fecha
on asistencia_con_indice (fecha);
go


--prueba 2: consulta con índice clustered


print '--- consulta con índice clustered (seek) ---';

set statistics io on;
set statistics time on;

select id_socio, id_turno, estado
from asistencia_con_indice
where fecha between '2000-01-01' and '2025-11-30';
go

--eliminar indice clustered
print '--- eliminando índice clustered para nueva prueba ---';
drop index cx_asistencia_fecha on asistencia_con_indice;
go


/*
  PRUEBAS CON INDICE NO AGRUPADO DE COBERTURA (nonclustered + include)
*/

--creamos el índice de cobertura (nonclustered + include)

print '--- creando índice de cobertura nci_asistencia_fecha_cobertura ---';

create nonclustered index nci_asistencia_fecha_cobertura
on asistencia_con_indice (fecha)
include (id_socio, id_turno, estado);
go

 
--prueba 3: consulta con índice de cobertura

print '--- consulta con índice de cobertura (optimal seek + no lookup) ---';

set statistics io on;
set statistics time on;

select id_socio, id_turno, estado
from asistencia_con_indice
where fecha between '2000-01-01' and '2025-11-30';
go

--eliminar el no agrupado
print '--- eliminando índice no clustered ---';
drop index nci_asistencia_fecha_cobertura on asistencia_con_indice;
go

/*
   limpieza de caché (buffer y plan cache)
*/

print '--- limpiando cache para próximas pruebas ---';

checkpoint;
dbcc dropcleanbuffers;   -- limpia cache de datos
dbcc freeproccache;      -- limpia cache de planes
go


