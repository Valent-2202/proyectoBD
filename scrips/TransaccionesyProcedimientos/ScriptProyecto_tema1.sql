
/* Creacion De usuario */
USE proyectoBD;
GO

CREATE PROCEDURE sp_Socio_Alta
    @dni            INT,
    @nombre_socio   VARCHAR(50),
    @apellido_socio VARCHAR(50),
    @fecha_nacimiento DATE,
    @fecha_alta       DATE = NULL
AS
BEGIN

    IF @fecha_alta IS NULL
        SET @fecha_alta = CAST(GETDATE() AS DATE);

    INSERT INTO socio (
        dni,
        nombre_socio,
        apellido_socio,
        fecha_nacimiento,
        fecha_alta
    )
    VALUES (
        @dni,
        @nombre_socio,
        @apellido_socio,
        @fecha_nacimiento,
        @fecha_alta
    );

    SELECT SCOPE_IDENTITY() AS id_socio;
END;

EXEC sp_Socio_Alta
    @dni = 45487548,
    @nombre_socio = 'Juli',
    @apellido_socio = 'Gauna',
    @fecha_nacimiento = '2002-07-26';

--------------------------------------------------------------------------------------------------------------------------------------


/*Creacion de Procedimiento para Suscripcion y que se inserte un pago */
create or alter procedure sp_insertar_suscripcion_y_pago
  @id_socio         int,
  @fecha_suscripcion date,
  @monto            decimal(12,2),
  @id_medio_pago    int,
  @id_estado_pago   int = 1,
  @duracion_meses   int = 1
as
begin
  set nocount on;

  declare @id_suscripcion    int,
          @id_pago           int,
          @id_estado_activa  int = 1,
          @fecha_venc        date;

  begin try
    begin tran;

    set @fecha_venc = dateadd(month, @duracion_meses, @fecha_suscripcion);

    insert into suscripcion (fecha_suscripcion, id_socio, id_estado, duracion_meses, fecha_vencimiento)
    values (@fecha_suscripcion, @id_socio, @id_estado_activa, @duracion_meses, @fecha_venc);

    set @id_suscripcion = scope_identity();

    insert into pago (monto, id_medio_pago, id_estado_pago, id_suscripcion)
    values (@monto, @id_medio_pago, @id_estado_pago, @id_suscripcion);

    set @id_pago = scope_identity();

    commit tran;

    select 
      @id_suscripcion as id_suscripcion_creada,
      @id_pago        as id_pago_creado;
  end try
  begin catch
    if @@trancount > 0 rollback tran;
    throw;
  end catch
end;

select * from estado_suscripcion

/*Ejecucion: */

exec sp_insertar_suscripcion_y_pago
  @id_socio = 4,
  @fecha_suscripcion = '2020-10-14',
  @monto = 20000,
  @id_medio_pago = 1,
  @id_estado_pago = 2,
  @duracion_meses = 1;



select * from suscripcion s where s.id_socio=4
select * from pago 





-------------------------------------------------------------------------------------------------------------------------------------------------
/* Consulta para mostrar */
CREATE FUNCTION fn_total_pagado_por_socio (@id_socio INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
  DECLARE @total DECIMAL(12,2);

  SELECT @total = ISNULL(SUM(p.monto), 0)
  FROM pago p
  JOIN suscripcion s ON s.id_suscripcion = p.id_suscripcion
  WHERE s.id_socio = @id_socio;

  RETURN @total;
END;

/*Ejecucion de Funcion / obligatorio usar dbo con funciones T-SQL todos los objetos pertenecen a un schema */

SELECT dbo.fn_total_pagado_por_socio(1) AS Total_Pagado;

select * from socio

select p.monto, s.id_suscripcion, s.id_socio from suscripcion as s
join pago as p on s.id_suscripcion = p.id_suscripcion
where s.id_socio =2;

------------------------------------------------------------------------------------------------------------------------------------------------
/*Esta función devuelve 1 (ocupado) o 0 (disponible) y verificar si el horario está libre en una sede */

CREATE FUNCTION dbo.fn_turno_ocupado
(
  @id_sede INT,
  @horario_desde TIME,
  @horario_hasta TIME
)
RETURNS BIT
AS
BEGIN
  DECLARE @ocupado BIT = 0;

  IF EXISTS (
    SELECT 1
    FROM turno
    WHERE id_sede = @id_sede
      AND (
           (@horario_desde BETWEEN horario_desde AND horario_hasta)
        OR (@horario_hasta BETWEEN horario_desde AND horario_hasta)
        OR (horario_desde BETWEEN @horario_desde AND @horario_hasta)
      )
  )
    SET @ocupado = 1;

  RETURN @ocupado;
END;

exec dbo.fn_turno_ocupado
    @id_Sede = 3,
    @horario_desde = '12:00',
    @horario_hasta = '16:00'

/*Procedimiento para ingresar un entrenador  */----------------------------------------------------------------------------------------



create or alter procedure dbo.sp_registrar_entrenador_y_turno
  @nombre          varchar(50),
  @apellido        varchar(50),
  @telefono        varchar(20),
  @correo          varchar(100),
  @dni             int,
  @fecha_nacimiento date,
  @id_sede         int,
  @nombre_turno    varchar(50),
  @horario_desde   time,
  @horario_hasta   time
as
begin
    declare @id_entrenador int,
            @id_turno      int;
    begin try
        begin tran;
        -- validaciones básicas
        if @horario_desde >= @horario_hasta
            throw 60001, 'el horario de inicio debe ser menor que el de fin.', 1;
        if exists (select 1 from entrenador where dni_entrenador = @dni)
            throw 60003, 'ya existe un entrenador con ese dni.', 1;
        if dbo.fn_turno_ocupado(@id_sede, @horario_desde, @horario_hasta) = 1
            throw 60002, 'ya existe un turno que se superpone en esa sede.', 1;
        -- insertar entrenador
        insert into entrenador (
            nombre_entrenador,
            apellido_entrenador,
            telefono_entrenador,
            correo_entrenador,
            dni_entrenador,
            fecha_nacimiento
        )
        values (
            @nombre,
            @apellido,
            @telefono,
            @correo,
            @dni,
            @fecha_nacimiento
        );
        set @id_entrenador = scope_identity();
        -- insertar turno
        insert into turno (
            nombre,
            horario_desde,
            horario_hasta,
            id_entrenador,
            id_sede
        )
        values (
            @nombre_turno,
            @horario_desde,
            @horario_hasta,
            @id_entrenador,
            @id_sede
        );
        set @id_turno = scope_identity();
        commit tran;
   
        select 
            @id_entrenador as id_entrenador_creado,
            @id_turno      as id_turno_creado;
    end try
    begin catch
        if @@trancount > 0 rollback tran;
        throw;
    end catch
end;



/*Ejemplo de Ejecucion Procedimiento  */
EXEC dbo.sp_registrar_entrenador_y_turno
  @nombre          = 'Leonar',
  @apellido        = 'fumaski',
  @telefono        = '3794-556677',
  @correo          = 'leoeltrabajador@gym.com',
  @dni             = 482545873,
  @fecha_nacimiento = '1992-08-17',
  @id_sede         = 3,
  @nombre_turno    = 'Siesta',
  @horario_desde   = '12:00',
  @horario_hasta   = '16:00';

  select * from entrenador
  select * from turno
-------------------------------------------------------------------------------------------------------------------------------------------------


/* Baja logica de Entrenador */

CREATE OR ALTER PROCEDURE sp_baja_logica_entrenador
  @id_entrenador INT,
  @id_entrenador_reemplazo INT
AS
BEGIN
  BEGIN TRY
    BEGIN TRAN;

    -- Verificar que el entrenador exista
    IF NOT EXISTS (SELECT 1 FROM entrenador WHERE id_entrenador = @id_entrenador)
      THROW 70001, 'No existe un entrenador con ese ID.', 1;

    -- Verificar si ya está inactivo
    IF EXISTS (
      SELECT 1 FROM entrenador 
      WHERE id_entrenador = @id_entrenador AND estado_entrenador = 'Inactivo'
    )
      THROW 70002, 'El entrenador ya está inactivo.', 1;

    -- Verificar que el entrenador reemplazo exista y esté activo
    IF NOT EXISTS (
      SELECT 1 FROM entrenador 
      WHERE id_entrenador = @id_entrenador_reemplazo AND estado_entrenador = 'Activo'
    )
      THROW 70003, 'El entrenador de reemplazo no existe o está inactivo.', 1;

    -- 1️ Marcar como inactivo
    UPDATE entrenador
    SET estado_entrenador = 'Inactivo'
    WHERE id_entrenador = @id_entrenador;

    -- 2️ Reasignar todos los turnos
    UPDATE turno
    SET id_entrenador = @id_entrenador_reemplazo
    WHERE id_entrenador = @id_entrenador;

    COMMIT TRAN;

    PRINT ' Entrenador dado de baja y turnos reasignados al reemplazo.';
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'Error:';
    PRINT ERROR_MESSAGE();
  END CATCH
END;

/*Ejemplo: */
EXEC sp_baja_logica_entrenador 
  @id_entrenador = 3, 
  @id_entrenador_reemplazo = 5;

select * from entrenador
select * from turno
-----------------------------------------------------------------------------------------------------------------------------------------
/*Baja Logica de Socio */

CREATE OR ALTER PROCEDURE sp_baja_logica_socio
  @id_socio INT
AS
BEGIN
  BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
      THROW 71001, 'No existe un socio con ese ID.', 1;

    IF EXISTS (
      SELECT 1 FROM socio 
      WHERE id_socio = @id_socio AND estado_socio = 'Inactivo'
    )
      THROW 71002, 'El socio ya está inactivo.', 1;

    UPDATE socio
    SET estado_socio = 'Inactivo'
    WHERE id_socio = @id_socio;

    PRINT ' Socio dado de baja lógicamente.';
  END TRY
  BEGIN CATCH
    PRINT ' Error:';
    PRINT ERROR_MESSAGE();
  END CATCH
END;
/*Ejemplo: */

EXEC sp_baja_logica_socio @id_socio = 5;

select * from socio s where s.id_socio = 5 

/*Reactivar Entrenador */---------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_reactivar_entrenador
  @id_entrenador INT
AS
BEGIN
  BEGIN TRY
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM entrenador WHERE id_entrenador = @id_entrenador)
      THROW 72001, 'No existe un entrenador con ese ID.', 1;

    -- Verificar si ya está activo
    IF EXISTS (
      SELECT 1 FROM entrenador 
      WHERE id_entrenador = @id_entrenador AND estado_entrenador = 'Activo'
    )
      THROW 72002, 'El entrenador ya está activo.', 1;

    -- Reactivar
    UPDATE entrenador
    SET estado_entrenador = 'Activo'
    WHERE id_entrenador = @id_entrenador;

    PRINT ' Entrenador reactivado correctamente.';
  END TRY
  BEGIN CATCH
    PRINT ' Error:';
    PRINT ERROR_MESSAGE();
  END CATCH
END;
/*Ejemplo: */
EXEC sp_reactivar_entrenador @id_entrenador = 3;

/* Reactivar Socio */
CREATE OR ALTER PROCEDURE sp_reactivar_socio
  @id_socio INT
AS
BEGIN
  BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
      THROW 73001, 'No existe un socio con ese ID.', 1;

    IF EXISTS (
      SELECT 1 FROM socio 
      WHERE id_socio = @id_socio AND estado_socio = 'Activo'
    )
      THROW 73002, 'El socio ya está activo.', 1;

    UPDATE socio
    SET estado_socio = 'Activo'
    WHERE id_socio = @id_socio;

    PRINT 'Socio reactivado correctamente.';
  END TRY
  BEGIN CATCH
    PRINT ' Error:';
    PRINT ERROR_MESSAGE();
  END CATCH
END;

/*Ejemplo: */
EXEC sp_reactivar_socio @id_socio = 5;

select * from socio s where s.id_socio = 5 

select * from asistencia_diaria