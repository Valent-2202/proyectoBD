-- ========================
-- CATALOGOS BÁSICOS
-- ========================
INSERT INTO estado_suscripcion (descripcion) VALUES
('ACTIVA'), ('VENCIDA'), ('CANCELADA');

INSERT INTO tipo_suscripcion (nombre_suscripcion, precio, descripcion_tipo_sub, duracion) VALUES
('Mensual', 15000, 'Acceso libre durante 30 días', 30),
('Trimestral', 40000, 'Acceso libre durante 90 días', 90),
('Anual', 150000, 'Acceso libre durante 365 días', 365);

INSERT INTO medio_pago (tipo_medio_pago) VALUES
('Efectivo'), ('Tarjeta Crédito'), ('Débito'), ('Transferencia');

INSERT INTO nivel_academico (descripcion_nivel_academico) VALUES
('Terciario'), ('Universitario'), ('Posgrado');

INSERT INTO clase_estado (descripcion_clase_estado) VALUES
('Habilitada'), ('Suspendida'), ('Finalizada');

INSERT INTO espacio_entrenamiento (nombre, direccion, capacidad) VALUES
('Salón Principal','Av. Central 123', 50),
('Sala Funcional','Belgrano 456', 30),
('Piscina Cubierta','Rivadavia 789', 20);

INSERT INTO contacto (tipo_contacto) VALUES
('Teléfono'), ('Email'), ('WhatsApp');

INSERT INTO estado_de_pago (descripcion_est_pago) VALUES
('Pendiente'), ('Pagado'), ('Vencido');

INSERT INTO dia (fecha_sesion) VALUES
('2025-10-01'), ('2025-10-02'), ('2025-10-03');

-- ========================
-- ENTRENADORES
-- ========================
INSERT INTO entrenador (nombre_entrenador, apellido_entrenador, telefono_entrenador, correo_entrenador, dni_entrenador, edad) VALUES
('Carlos','Gomez',379445566,'cgomez@mail.com',20111222,35),
('Ana','Martinez',379445577,'amartinez@mail.com',30111233,29),
('Lucia','Perez',379445588,'lperez@mail.com',40111244,40);

INSERT INTO especialidad_entrenador (descripcion_especialidad, id_nivel_academico) VALUES
('Musculación', 1),
('CrossFit', 2),
('Natación', 2),
('Pilates', 3);

INSERT INTO tiene_especialidades (id_entrenador, id_especialidad) VALUES
(1,1), (1,2), 
(2,2), (2,4),
(3,3);

-- ========================
-- SOCIOS
-- ========================
INSERT INTO socio (dni, nombre_socio, apellido_socio, fecha_nacimiento, id_contacto) VALUES
(12345678,'Juan','Lopez','1990-05-10',1),
(87654321,'Maria','Gonzalez','1985-08-15',2),
(23456789,'Pedro','Ramirez','2000-12-01',3);

-- ========================
-- SUSCRIPCIONES
-- ========================
INSERT INTO suscripcion (id_tipo_suscripcion, id_socio, id_estado) VALUES
(1,1,1), -- Mensual, Juan, Activa
(2,2,1), -- Trimestral, Maria, Activa
(3,3,2); -- Anual, Pedro, Vencida

-- ========================
-- PAGOS
-- ========================
INSERT INTO pago (monto, id_medio_pago, id_suscripcion, id_tipo_suscripcion, id_socio, id_estado_pago) VALUES
(15000,1,1,1,1,2), -- Juan, pago efectivo, pagado
(40000,2,2,2,2,1), -- Maria, tarjeta crédito, pendiente
(150000,3,3,3,3,3); -- Pedro, transferencia, vencido

-- ========================
-- CLASES
-- ========================
INSERT INTO clase (nombre, id_clase_estado) VALUES
('Spinning',1),
('CrossFit Avanzado',1),
('Natación Adultos',1);

INSERT INTO tipo_clases_con_subs (id_tipo_suscripcion, id_clase) VALUES
(1,1),
(2,2),
(3,3);

-- ========================
-- SESIONES
-- ========================
INSERT INTO sesion (hora_inicio, hora_hasta, capacidad_max, id_clase, id_dia, id_espacio_entrenamiento) VALUES
('2025-10-01 09:00','2025-10-01 10:00',20,1,1,1),
('2025-10-02 18:00','2025-10-02 19:30',30,2,2,2),
('2025-10-03 08:00','2025-10-03 09:00',15,3,3,3);

INSERT INTO sesion_entrenador (id_entrenador, id_sesion, rol) VALUES
(1,1,'LIDER'),
(2,2,'LIDER'),
(3,3,'LIDER');

-- ========================
-- ASISTENCIA
-- ========================
INSERT INTO asistencia_diaria (id_sesion, id_socio, estado) VALUES
(1,1,'ASISTIO'),
(2,2,'RESERVADA'),
(3,3,'AUSENTE');
