USE proyectoBD;
GO

/* =========================================================
   CARGAMOS
   ========================================================= */

-- ESTADOS
INSERT INTO estado_suscripcion (descripcion) 
VALUES ('Activa'), ('Vencida'), ('Pausada');

INSERT INTO estado_de_pago (descripcion_est_pago) 
VALUES ('Pagado'), ('Pendiente');

INSERT INTO medio_pago (tipo_medio_pago) 
VALUES ('Efectivo'), ('Débito');
GO


/* =========================================================
   GEOGRAFIA
   ========================================================= */

-- 🔸 Si la columna codigo_postal no existe, la agregamos
IF COL_LENGTH('localidad', 'codigo_postal') IS NULL
BEGIN
    ALTER TABLE localidad ADD codigo_postal INT NULL;
END
GO

-- País
INSERT INTO pais (nombre, cant_habitantes)
VALUES ('Argentina', 56000000);   -- id_pais = 1
GO

-- Provincias
INSERT INTO provincia (nombre, cantidad_habitantes, id_pais) 
VALUES 
('Corrientes', 1500000, 1),    -- id_provincia = 1
('Chaco',      1000000, 1);    -- id_provincia = 2
GO

-- Localidades
INSERT INTO localidad (nombre, cantidad_habitantes, codigo_postal, id_provincia) 
VALUES 
('Corrientes Capital', 1000000, 3400, 1),   -- id_localidad = 1
('Resistencia',        500000, 3500, 2);    -- id_localidad = 2
GO

-- Sedes
INSERT INTO sede (direccion, estado, id_localidad)
VALUES 
('Av. Principal 100', 1, 1),  -- id_sede = 1
('Calle Central 200', 1, 2),  -- id_sede = 2
('9 de Julio 1449', 1, 1);    -- id_sede = 3
GO


/* =========================================================
   ENTRENADORES
   ========================================================= */

INSERT INTO entrenador 
(nombre_entrenador, apellido_entrenador, telefono_entrenador, correo_entrenador, dni_entrenador, fecha_nacimiento)
VALUES
('Carla', 'Pérez', '3794123456', 'carla.perez@gym.com', 20123456, '1990-04-12'),
('Diego', 'Suárez', '3624556677', 'diego.suarez@gym.com', 22111222, '1988-09-03'),
('María', 'López', '3764123987', 'maria.lopez@gym.com', 23999888, '1992-11-25');
GO


/* =========================================================
   CONTACTOS Y SOCIOS
   ========================================================= */

-- Contactos generales
INSERT INTO contacto (tipo_contacto, valor_contacto) 
VALUES
('Email', 'ana@gmail.com'),
('Teléfono', '+54 3794 112233'),
('Email', 'bruno@mail.com'),
('Teléfono', '+54 362 445566'),
('Email', 'camila@mail.com');
GO

-- Socios
INSERT INTO socio (dni, nombre_socio, apellido_socio, fecha_nacimiento, fecha_alta)
VALUES
(30111222, 'Ana', 'Martínez', '2000-07-15', '2025-01-10'),
(32123456, 'Bruno', 'Fernández', '1998-03-08', '2025-02-20'),
(33123456, 'Camila', 'Rojas', '1995-12-01', '2025-04-15');
GO

-- Relación socio-contacto
INSERT INTO socio_contacto (id_socio, id_contacto)
VALUES
(1, 1), (1, 2),
(2, 3), (2, 4),
(3, 5);
GO


/* =========================================================
   TURNOS
   ========================================================= */

INSERT INTO turno (nombre, horario_desde, horario_hasta, id_entrenador, id_sede)
VALUES
('Mañana', '08:00', '12:00', 1, 1),   -- id_turno = 1
('Tarde',  '16:00', '20:00', 2, 1),   -- id_turno = 2
('Mañana', '08:00', '12:00', 3, 2),   -- id_turno = 3
('Noche',  '20:00', '22:00', 2, 2);   -- id_turno = 4
GO


/* =========================================================
   ASISTENCIAS DIARIAS
   ========================================================= */

INSERT INTO asistencia_diaria (id_socio, id_turno, fecha, estado)
VALUES
(1, 1, '2025-10-30', 'Presente'),
(1, 1, '2025-11-03', 'Ausente'),
(2, 2, '2025-11-01', 'Presente'),
(2, 2, '2025-11-04', 'Presente'),
(3, 3, '2025-10-31', 'Justificado');
GO


/* =========================================================
   SUSCRIPCIONES Y PAGOS
   ========================================================= */

INSERT INTO suscripcion (fecha_suscripcion, id_socio, id_estado)
VALUES
('2025-10-01', 1, 1),
('2025-09-15', 2, 2),
('2025-08-20', 3, 1);
GO

INSERT INTO pago (monto, id_medio_pago, id_estado_pago, id_suscripcion)
VALUES
(18000.00, 1, 1, 1),
(20000.00, 2, 1, 2),
(15000.00, 1, 1, 3);
GO


/* =========================================================
   REGISTROS DE PRUEBA Y CONSULTAS
   ========================================================= */

-- Entrenador adicional
INSERT INTO entrenador 
(nombre_entrenador, apellido_entrenador, telefono_entrenador, correo_entrenador, dni_entrenador, fecha_nacimiento, estado_entrenador)
VALUES
('Facundo', 'Perez', '3794-123548', 'Facu_Perez3502@gym.com', 38564215, '1990-01-01', 'Activo');
GO

-- Consultas de verificación
SELECT * FROM pais;
SELECT * FROM provincia;
SELECT * FROM localidad;
SELECT * FROM sede;
SELECT * FROM socio;
SELECT * FROM asistencia_diaria;
GO
