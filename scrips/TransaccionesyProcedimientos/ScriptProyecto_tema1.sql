USE proyectoBD;
GO

/* ======================================================
   1  FUNCIONES Y PROCEDIMIENTOS 
   ====================================================== */

-- LIMPIEZA PREVIA
IF OBJECT_ID('fn_CalcularEdad', 'FN') IS NOT NULL DROP FUNCTION fn_CalcularEdad;
IF OBJECT_ID('fn_TotalPagosSocio', 'FN') IS NOT NULL DROP FUNCTION fn_TotalPagosSocio;
IF OBJECT_ID('fn_TieneSuscripcionActiva', 'FN') IS NOT NULL DROP FUNCTION fn_TieneSuscripcionActiva;

IF OBJECT_ID('sp_socio_insertar', 'P') IS NOT NULL DROP PROCEDURE sp_socio_insertar;
IF OBJECT_ID('sp_socio_actualizar', 'P') IS NOT NULL DROP PROCEDURE sp_socio_actualizar;
IF OBJECT_ID('sp_socio_borrar', 'P') IS NOT NULL DROP PROCEDURE sp_socio_borrar;
IF OBJECT_ID('sp_pago_insertar_tx', 'P') IS NOT NULL DROP PROCEDURE sp_pago_insertar_tx;
IF OBJECT_ID('sp_registrar_socio_suscripcion_pago', 'P') IS NOT NULL DROP PROCEDURE sp_registrar_socio_suscripcion_pago;
IF OBJECT_ID('sp_demo_error_tx', 'P') IS NOT NULL DROP PROCEDURE sp_demo_error_tx;
GO

-- FUNCIONES --------------------------------------------
CREATE FUNCTION fn_CalcularEdad (@fecha_nac DATE)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    SET @edad = DATEDIFF(YEAR, @fecha_nac, GETDATE())
              - CASE WHEN FORMAT(GETDATE(), 'MMdd') < FORMAT(@fecha_nac, 'MMdd') THEN 1 ELSE 0 END;
    RETURN @edad;
END;
GO

CREATE FUNCTION fn_TotalPagosSocio (@id_socio INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @total DECIMAL(18,2);
    SELECT @total = ISNULL(SUM(monto),0)
    FROM pago
    WHERE id_socio = @id_socio;
    RETURN @total;
END;
GO

CREATE FUNCTION fn_TieneSuscripcionActiva (@id_socio INT)
RETURNS BIT
AS
BEGIN
    DECLARE @r BIT = 0;
    IF EXISTS (
        SELECT 1
        FROM suscripcion s
        JOIN estado_suscripcion es ON es.id_estado_suscripcion = s.id_estado
        WHERE s.id_socio = @id_socio AND es.descripcion = N'ACTIVA'
    )
        SET @r = 1;
    RETURN @r;
END;
GO

-- PROCEDIMIENTOS ---------------------------------------
CREATE PROCEDURE sp_socio_insertar
    @dni INT,
    @nombre_socio VARCHAR(80),
    @apellido_socio VARCHAR(80),
    @fecha_nac DATE,
    @id_contacto INT,
    @id_socio_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO socio (dni, nombre_socio, apellido_socio, fecha_nacimiento, id_contacto)
    VALUES (@dni, @nombre_socio, @apellido_socio, @fecha_nac, @id_contacto);
    SET @id_socio_out = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE sp_socio_actualizar
    @id_socio INT,
    @dni INT,
    @nombre_socio VARCHAR(80),
    @apellido_socio VARCHAR(80),
    @fecha_nac DATE,
    @id_contacto INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE socio
    SET dni=@dni, nombre_socio=@nombre_socio, apellido_socio=@apellido_socio,
        fecha_nacimiento=@fecha_nac, id_contacto=@id_contacto
    WHERE id_socio=@id_socio;
END;
GO

CREATE PROCEDURE sp_socio_borrar
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM socio WHERE id_socio=@id_socio;
END;
GO

CREATE PROCEDURE sp_pago_insertar_tx
    @monto DECIMAL(18,2),
    @id_medio_pago INT,
    @id_suscripcion INT,
    @id_tipo_suscripcion INT,
    @id_socio INT,
    @id_estado_pago INT,
    @id_pago_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @interna BIT = CASE WHEN @@TRANCOUNT=0 THEN 1 ELSE 0 END;
    IF @interna=1 BEGIN TRAN ELSE SAVE TRAN SP_PAGO_CHILD;

    BEGIN TRY
        INSERT INTO pago (monto,id_medio_pago,id_suscripcion,id_tipo_suscripcion,id_socio,id_estado_pago)
        VALUES (@monto,@id_medio_pago,@id_suscripcion,@id_tipo_suscripcion,@id_socio,@id_estado_pago);
        SET @id_pago_out=SCOPE_IDENTITY();

        IF @interna=1 COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @interna=1 AND @@TRANCOUNT>0 ROLLBACK TRAN;
        ELSE IF @@TRANCOUNT>0 ROLLBACK TRAN SP_PAGO_CHILD;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE sp_registrar_socio_suscripcion_pago
    @dni INT,
    @nombre_socio VARCHAR(80),
    @apellido_socio VARCHAR(80),
    @fecha_nac DATE,
    @id_contacto INT,
    @id_tipo_suscripcion INT,
    @monto DECIMAL(18,2),
    @id_socio_out INT OUTPUT,
    @id_suscripcion_out INT OUTPUT,
    @id_pago_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @id_socio INT, @id_suscripcion INT;

        EXEC sp_socio_insertar
             @dni=@dni,@nombre_socio=@nombre_socio,@apellido_socio=@apellido_socio,
             @fecha_nac=@fecha_nac,@id_contacto=@id_contacto,@id_socio_out=@id_socio OUTPUT;

        INSERT INTO suscripcion (id_tipo_suscripcion,id_socio,id_estado)
        VALUES(@id_tipo_suscripcion,@id_socio,1);
        SET @id_suscripcion=SCOPE_IDENTITY();

        EXEC sp_pago_insertar_tx
             @monto=@monto,@id_medio_pago=1,@id_suscripcion=@id_suscripcion,
             @id_tipo_suscripcion=@id_tipo_suscripcion,@id_socio=@id_socio,
             @id_estado_pago=2,@id_pago_out=@id_pago_out OUTPUT;

        COMMIT TRAN;
        SET @id_socio_out=@id_socio;
        SET @id_suscripcion_out=@id_suscripcion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE sp_demo_error_tx
    @dni INT,
    @nombre_socio VARCHAR(80),
    @apellido_socio VARCHAR(80),
    @fecha_nac DATE,
    @id_contacto INT,
    @id_tipo_suscripcion INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        DECLARE @id_socio INT, @id_suscripcion INT;

        EXEC sp_socio_insertar
             @dni=@dni,@nombre_socio=@nombre_socio,@apellido_socio=@apellido_socio,
             @fecha_nac=@fecha_nac,@id_contacto=@id_contacto,@id_socio_out=@id_socio OUTPUT;

        INSERT INTO suscripcion (id_tipo_suscripcion,id_socio,id_estado)
        VALUES(@id_tipo_suscripcion,@id_socio,1);
        SET @id_suscripcion=SCOPE_IDENTITY();

        DECLARE @x INT = 1/0; -- fuerza error

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
GO
