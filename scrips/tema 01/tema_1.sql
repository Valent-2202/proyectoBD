CREATE DATABASE proyectoBD;
GO
USE proyectoBD;
GO

CREATE TABLE estado_suscripcion
(
  id_estado_suscripcion INT IDENTITY(1,1) NOT NULL,
  descripcion VARCHAR(50) NOT NULL,
  CONSTRAINT PK_estado_suscripcion PRIMARY KEY (id_estado_suscripcion),
  CONSTRAINT UQ_estado_suscripcion UNIQUE (descripcion)
);

CREATE TABLE tipo_suscripcion
(
  id_tipo_suscripcion INT IDENTITY(1,1) NOT NULL,
  nombre_suscripcion VARCHAR(50) NOT NULL,
  precio INT NOT NULL,
  descripcion_tipo_sub VARCHAR(50) NOT NULL,
  duracion INT NOT NULL,
  CONSTRAINT PK_tipo_suscripcion PRIMARY KEY (id_tipo_suscripcion),
  CONSTRAINT CK_tipo_suscripcion_duracion CHECK (duracion > 0),
  CONSTRAINT CK_tipo_suscripcion_precio CHECK (precio > 0),
  CONSTRAINT UQ_tipo_suscripcion_nombre UNIQUE (nombre_suscripcion)
);

CREATE TABLE medio_pago
(
  id_medio_pago INT IDENTITY(1,1) NOT NULL,
  tipo_medio_pago VARCHAR(50) NOT NULL,
  CONSTRAINT PK_medio_pago PRIMARY KEY (id_medio_pago),
  CONSTRAINT UQ_medio_pago_tipo UNIQUE (tipo_medio_pago)
);

CREATE TABLE entrenador
(
  id_entrenador INT IDENTITY(1,1) NOT NULL,
  nombre_entrenador VARCHAR(50) NOT NULL,
  apellido_entrenador VARCHAR(50) NOT NULL,
  telefono_entrenador INT NOT NULL,
  correo_entrenador VARCHAR(100) NOT NULL,
  dni_entrenador INT NOT NULL,
  fecha_nacimiento INT NOT NULL,
  CONSTRAINT PK_entrenador PRIMARY KEY (id_entrenador),
  CONSTRAINT UQ_entrenador_dni UNIQUE (dni_entrenador),
  CONSTRAINT UQ_entrenador_correo UNIQUE (correo_entrenador),
  CONSTRAINT CK_entrenador_edad CHECK (edad >= 18),
  CONSTRAINT CK_entrenador_dni CHECK (dni_entrenador > 0 AND LEN(dni_entrenador) <= 8),
  CONSTRAINT CK_correo_arroba CHECK (CHARINDEX('@', correo_entrenador) > 1),
  CONSTRAINT CK_correo_dominio CHECK (CHARINDEX('.', correo_entrenador, CHARINDEX('@', correo_entrenador)+1) > 0),
  CONSTRAINT CK_correo_len CHECK (LEN(correo_entrenador) BETWEEN 5 AND 100)
);

CREATE TABLE nivel_academico
(
  id_nivel_academico INT IDENTITY(1,1) NOT NULL,
  descripcion_nivel_academico VARCHAR(50) NOT NULL,
  CONSTRAINT PK_nivel_academico PRIMARY KEY (id_nivel_academico),
  CONSTRAINT UQ_nivel_academico UNIQUE (descripcion_nivel_academico)
);

CREATE TABLE clase_estado
(
  id_clase_estado INT IDENTITY(1,1) NOT NULL,
  descripcion_clase_estado VARCHAR(50) NOT NULL,
  CONSTRAINT PK_clase_estado PRIMARY KEY (id_clase_estado),
  CONSTRAINT UQ_clase_estado UNIQUE (descripcion_clase_estado)
);

CREATE TABLE espacio_entrenamiento
(
  id_espacio_entrenamiento INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  direccion VARCHAR(50) NOT NULL,
  capacidad INT NOT NULL,
  CONSTRAINT PK_espacio_entrenamiento PRIMARY KEY (id_espacio_entrenamiento),
  CONSTRAINT CK_espacio_capacidad CHECK (capacidad > 0)
);

CREATE TABLE dia
(
  id_dia INT IDENTITY(1,1) NOT NULL,
  fecha_sesion DATE NOT NULL default getdate(),
  CONSTRAINT PK_dia PRIMARY KEY (id_dia)
);

CREATE TABLE contacto
(
  id_contacto INT IDENTITY(1,1) NOT NULL,
  tipo_contacto VARCHAR(50) NOT NULL,
  CONSTRAINT PK_contacto PRIMARY KEY (id_contacto)
);

CREATE TABLE estado_de_pago
(
  id_estado_pago INT IDENTITY(1,1) NOT NULL,
  descripcion_est_pago VARCHAR(50) NOT NULL,
  CONSTRAINT PK_estado_pago PRIMARY KEY (id_estado_pago),
  CONSTRAINT UQ_estado_pago UNIQUE (descripcion_est_pago)
);

CREATE TABLE socio
(
  dni INT NOT NULL,
  nombre_socio VARCHAR(50) NOT NULL,
  apellido_socio VARCHAR(50) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  id_socio INT IDENTITY(1,1) NOT NULL,
  fecha_alta DATE NOT NULL default getdate(),
  id_contacto INT NOT NULL,
  CONSTRAINT PK_socio PRIMARY KEY (id_socio),
  CONSTRAINT UQ_socio_dni UNIQUE (dni),
  CONSTRAINT FK_socio_contacto FOREIGN KEY (id_contacto) REFERENCES contacto(id_contacto),
  CONSTRAINT CK_socio_dni CHECK (dni > 0 AND LEN(dni) <= 8),
  CONSTRAINT CK_socio_fecha_alta CHECK (fecha_alta <= GETDATE())
);

CREATE TABLE suscripcion
(
  id_suscripcion INT IDENTITY(1,1) NOT NULL,
  fecha_suscripcion DATE NOT NULL default getdate(),
  id_tipo_suscripcion INT NOT NULL,
  id_socio INT NOT NULL,
  id_estado INT NOT NULL,
  CONSTRAINT PK_suscripcion PRIMARY KEY (id_suscripcion, id_tipo_suscripcion, id_socio),
  CONSTRAINT FK_suscripcion_tipo FOREIGN KEY (id_tipo_suscripcion) REFERENCES tipo_suscripcion(id_tipo_suscripcion),
  CONSTRAINT FK_suscripcion_socio FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
  CONSTRAINT FK_suscripcion_estado FOREIGN KEY (id_estado) REFERENCES estado_suscripcion(id_estado_suscripcion),
  CONSTRAINT CK_suscripcion_fecha CHECK (fecha_suscripcion <= GETDATE())
);

-- La relación entre SUSCRIPCION y PAGO se modela como 1 a N. 
-- Esto significa que una misma suscripción puede estar asociada a múltiples pagos,
-- ya sea porque el socio abona en cuotas, realiza pagos parciales, o efectúa renovaciones.
-- Por esta razón, la tabla PAGO contiene la clave foránea hacia SUSCRIPCION.
-- De esta forma se evita restringir la relación a 1 a 1, lo que no sería realista en la operatoria de un gimnasio,
-- y se garantiza que cada pago quede vinculado a la suscripción correspondiente.
CREATE TABLE pago
(
  id_pago INT IDENTITY(1,1) NOT NULL,
  monto INT NOT NULL,
  id_medio_pago INT NOT NULL,
  id_suscripcion INT NOT NULL,
  id_tipo_suscripcion INT NOT NULL,
  id_socio INT NOT NULL,
  id_estado_pago INT NOT NULL,
  CONSTRAINT PK_pago PRIMARY KEY (id_pago),
  CONSTRAINT FK_pago_medio FOREIGN KEY (id_medio_pago) REFERENCES medio_pago(id_medio_pago),
  CONSTRAINT FK_pago_suscripcion FOREIGN KEY (id_suscripcion, id_tipo_suscripcion, id_socio) REFERENCES suscripcion(id_suscripcion, id_tipo_suscripcion, id_socio),
  CONSTRAINT FK_pago_estado FOREIGN KEY (id_estado_pago) REFERENCES estado_de_pago(id_estado_pago),
  CONSTRAINT CK_pago_monto CHECK (monto > 0)
);

CREATE TABLE especialidad_entrenador
(
  id_especialidad INT IDENTITY(1,1) NOT NULL,
  descripcion_especialidad VARCHAR(50) NOT NULL,
  id_nivel_academico INT NOT NULL,
  CONSTRAINT PK_especialidad PRIMARY KEY (id_especialidad),
  CONSTRAINT UQ_especialidad UNIQUE (descripcion_especialidad),
  CONSTRAINT FK_especialidad_nivel FOREIGN KEY (id_nivel_academico) REFERENCES nivel_academico(id_nivel_academico)
);

CREATE TABLE tiene_especialidades
(
  fecha_alta_especialidad DATE NOT NULL default getdate(),
  id_entrenador INT NOT NULL,
  id_especialidad INT NOT NULL,
  CONSTRAINT PK_tiene_especialidades PRIMARY KEY (id_entrenador, id_especialidad),
  CONSTRAINT FK_te_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
  CONSTRAINT FK_te_especialidad FOREIGN KEY (id_especialidad) REFERENCES especialidad_entrenador(id_especialidad),
  CONSTRAINT CK_te_fecha CHECK (fecha_alta_especialidad <= GETDATE())
);

CREATE TABLE clase
(
  id_clase INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  id_clase_estado INT NOT NULL,
  CONSTRAINT PK_clase PRIMARY KEY (id_clase),
  CONSTRAINT FK_clase_estado FOREIGN KEY (id_clase_estado) REFERENCES clase_estado(id_clase_estado),
  CONSTRAINT UQ_clase_nombre UNIQUE (nombre)
);

CREATE TABLE tipo_clases_con_subs
(
  fecha_alta DATE NOT NULL default getdate(),
  fecha_baja DATE NULL default getdate(),
  id_tipo_suscripcion INT NOT NULL,
  id_clase INT NOT NULL,
  CONSTRAINT PK_tipo_clases PRIMARY KEY (id_tipo_suscripcion, id_clase),
  CONSTRAINT FK_tccs_tipo FOREIGN KEY (id_tipo_suscripcion) REFERENCES tipo_suscripcion(id_tipo_suscripcion),
  CONSTRAINT FK_tccs_clase FOREIGN KEY (id_clase) REFERENCES clase(id_clase),
  CONSTRAINT CK_tccs_fechas CHECK (fecha_baja >= fecha_alta)
);

CREATE TABLE sesion
(
  id_sesion INT IDENTITY(1,1) NOT NULL,
  hora_hasta DATETIME NOT NULL,
  hora_inicio DATETIME NOT NULL,
  capacidad_max INT NOT NULL,
  id_clase INT NOT NULL,
  id_dia INT NOT NULL,
  id_espacio_entrenamiento INT NOT NULL,
  CONSTRAINT PK_sesion PRIMARY KEY (id_sesion),
  CONSTRAINT FK_sesion_clase FOREIGN KEY (id_clase) REFERENCES clase(id_clase),
  CONSTRAINT FK_sesion_dia FOREIGN KEY (id_dia) REFERENCES dia(id_dia),
  CONSTRAINT FK_sesion_espacio FOREIGN KEY (id_espacio_entrenamiento) REFERENCES espacio_entrenamiento(id_espacio_entrenamiento),
  CONSTRAINT CK_sesion_horario CHECK (hora_hasta > hora_inicio),
  CONSTRAINT CK_sesion_capacidad CHECK (capacidad_max > 0)
);

CREATE TABLE sesion_entrenador
(
  rol VARCHAR(20) NOT NULL,
  id_entrenador INT NOT NULL,
  id_sesion INT NOT NULL,
  CONSTRAINT PK_sesion_entrenador PRIMARY KEY (id_entrenador, id_sesion),
  CONSTRAINT FK_se_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
  CONSTRAINT FK_se_sesion FOREIGN KEY (id_sesion) REFERENCES sesion(id_sesion),
  CONSTRAINT CK_se_rol CHECK (rol IN ('LIDER','ASISTENTE'))
);

-- La tabla ASISTENCIA_DIARIA registra la participación de los socios en cada sesión.
-- El campo ESTADO refleja el ciclo completo de la asistencia, con los siguientes valores:
--   * RESERVADA → el socio apartó un lugar en la sesión (control de cupos).
--   * ASISTIO   → el socio asistió efectivamente a la clase.
--   * AUSENTE   → el socio tenía reserva pero no se presentó.
--   * CANCELADA → la reserva fue anulada por el socio o por el gimnasio.
-- De esta forma, el sistema permite administrar la capacidad de las clases, 
-- controlar la asistencia real y obtener estadísticas precisas de ocupación y ausentismo.

-- CONSTRAINT CK_asistencia_fecha CHECK (fecha <= GETDATE()): un socio no puede registrar asistencia en el futuro
CREATE TABLE asistencia_diaria
(
  id_asistencia INT IDENTITY(1,1) NOT NULL,
  fecha DATE NULL default getdate(),
  estado VARCHAR(50) NOT NULL,
  id_sesion INT NOT NULL,
  id_socio INT NOT NULL,
  CONSTRAINT PK_asistencia PRIMARY KEY (id_asistencia, id_sesion, id_socio),
  CONSTRAINT FK_asistencia_sesion FOREIGN KEY (id_sesion) REFERENCES sesion(id_sesion),
  CONSTRAINT FK_asistencia_socio FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
  CONSTRAINT CK_asistencia_estado CHECK (estado IN ('RESERVADA','ASISTIO','AUSENTE','CANCELADA')),
  CONSTRAINT CK_asistencia_fecha CHECK (fecha <= GETDATE())
);
