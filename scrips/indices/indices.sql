PRINT '--- LIMPIEZA DE ÍNDICES EXISTENTES ---';

-- Eliminamos índices creados anteriormente si existen
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'CX_Asistencia_Fecha' AND object_id = OBJECT_ID('asistencia_diaria'))
    DROP INDEX CX_Asistencia_Fecha ON asistencia_diaria;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'NCI_Asistencia_Fecha_Cobertura' AND object_id = OBJECT_ID('asistencia_diaria'))
    DROP INDEX NCI_Asistencia_Fecha_Cobertura ON asistencia_diaria;

PRINT 'Índices previos eliminados correctamente.';
GO


PRINT '--- CONSULTA BASE SIN ÍNDICE ---';
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT id_socio, id_turno, estado
FROM asistencia_diaria
WHERE fecha BETWEEN '2025-10-01' AND '2025-11-30';

GO

PRINT '--- CREACIÓN DE ÍNDICE CLUSTERED EN FECHA ---';
GO

-- Aseguramos que la PK no sea CLUSTERED para poder usar fecha como índice agrupado
ALTER TABLE asistencia_diaria DROP CONSTRAINT PK_asistencia;
GO
ALTER TABLE asistencia_diaria
ADD CONSTRAINT PK_asistencia
PRIMARY KEY NONCLUSTERED (id_socio, id_turno, fecha);
GO

-- Creamos el índice agrupado (clustered)
CREATE CLUSTERED INDEX CX_Asistencia_Fecha
ON asistencia_diaria(fecha);
GO

PRINT '--- CONSULTA CON ÍNDICE CLUSTERED ---';
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT id_socio, id_turno, estado
FROM asistencia_diaria
WHERE fecha BETWEEN '2025-10-01' AND '2025-11-30';
GO

PRINT '--- ELIMINACIÓN DE ÍNDICE CLUSTERED PARA NUEVA PRUEBA ---';
GO

DROP INDEX CX_Asistencia_Fecha ON asistencia_diaria;
GO

PRINT '--- CREACIÓN DE ÍNDICE NO CLUSTERED DE COBERTURA ---';
GO

CREATE NONCLUSTERED INDEX NCI_Asistencia_Fecha_Cobertura
ON asistencia_diaria(fecha)
INCLUDE (id_socio, id_turno, estado);
GO

PRINT '--- CONSULTA CON ÍNDICE DE COBERTURA ---';
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT id_socio, id_turno, estado
FROM asistencia_diaria
WHERE fecha BETWEEN '2025-10-01' AND '2025-11-30';
GO


-- Limpieza previa
TRUNCATE TABLE asistencia_diaria;
GO

-- Carga masiva de 1 millón de asistencias
DECLARE @i INT = 1;
WHILE @i <= 1000000
BEGIN
    INSERT INTO asistencia_diaria (id_socio, id_turno, fecha, estado)
    VALUES (
        (ABS(CHECKSUM(NEWID())) % 100) + 1,         -- 100 socios aleatorios
        (ABS(CHECKSUM(NEWID())) % 4) + 1,           -- 4 turnos
        DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 365), GETDATE()), -- fechas aleatorias del último año
        CASE (ABS(CHECKSUM(NEWID())) % 3)
            WHEN 0 THEN 'Presente'
            WHEN 1 THEN 'Ausente'
            ELSE 'Justificado'
        END
    );
    SET @i += 1;
END;
GO

-- ⚠️ Ejecutar solo en ambiente de prueba, nunca en producción
CHECKPOINT;
DBCC DROPCLEANBUFFERS;   -- limpia el buffer cache (datos)
DBCC FREEPROCCACHE;       -- limpia el plan cache (planes de ejecución)