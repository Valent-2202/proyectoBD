

/* =========================================================
   1) Catálogos / Maestros
   ========================================================= */

CREATE TABLE estado_suscripcion (
  id_estado_suscripcion INT IDENTITY(1,1) PRIMARY KEY,
  descripcion VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_estado_suscripcion UNIQUE (descripcion)
);

CREATE TABLE estado_de_pago (
  id_estado_pago INT IDENTITY(1,1) PRIMARY KEY,
  descripcion_est_pago VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_estado_de_pago UNIQUE (descripcion_est_pago)
);

CREATE TABLE medio_pago (
  id_medio_pago INT IDENTITY(1,1) PRIMARY KEY,
  tipo_medio_pago VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_medio_pago UNIQUE (tipo_medio_pago)
);

CREATE TABLE pais (
  id_pais INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  cant_habitantes INT NULL,
  CONSTRAINT UQ_pais_nombre UNIQUE (nombre),
  CONSTRAINT CK_pais_habitantes CHECK (cant_habitantes IS NULL OR cant_habitantes >= 0)
);

CREATE TABLE provincia (
  id_provincia INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  cantidad_habitantes INT NULL,
  codigo_postal INT NULL,
  id_pais INT NOT NULL,
  CONSTRAINT FK_provincia_pais FOREIGN KEY (id_pais) REFERENCES pais(id_pais),
  CONSTRAINT UQ_provincia_nombre_pais UNIQUE (nombre, id_pais)
);

CREATE TABLE localidad (
  id_localidad INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  cantidad_habitantes INT NULL,
  id_provincia INT NOT NULL,
  CONSTRAINT FK_localidad_provincia FOREIGN KEY (id_provincia) REFERENCES provincia(id_provincia),
  CONSTRAINT UQ_localidad_nombre_prov UNIQUE (nombre, id_provincia)
);

CREATE TABLE sede (
  id_sede INT IDENTITY(1,1) PRIMARY KEY,
  direccion VARCHAR(120) NOT NULL,
  estado BIT NOT NULL DEFAULT 1,  -- 1=activa, 0=inactiva
  id_localidad INT NOT NULL,
  CONSTRAINT FK_sede_localidad FOREIGN KEY (id_localidad) REFERENCES localidad(id_localidad),
  CONSTRAINT UQ_sede_direccion_localidad UNIQUE (direccion, id_localidad)
);

CREATE TABLE entrenador (
  id_entrenador INT IDENTITY(1,1) PRIMARY KEY,
  nombre_entrenador VARCHAR(50) NOT NULL,
  apellido_entrenador VARCHAR(50) NOT NULL,
  telefono_entrenador VARCHAR(20) NOT NULL,
  correo_entrenador VARCHAR(100) NOT NULL,
  dni_entrenador INT NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  CONSTRAINT UQ_entrenador_dni UNIQUE (dni_entrenador),
  CONSTRAINT UQ_entrenador_correo UNIQUE (correo_entrenador),
  CONSTRAINT CK_entrenador_fnac CHECK (fecha_nacimiento < GETDATE())
);

/* =========================================================
   2) Contactos y Socios
   ========================================================= */

CREATE TABLE contacto (
  id_contacto INT IDENTITY(1,1) PRIMARY KEY,
  tipo_contacto VARCHAR(30) NOT NULL,       -- 'Email', 'Teléfono', etc.
  valor_contacto VARCHAR(255) NOT NULL,
  CONSTRAINT UQ_contacto_tipo_valor UNIQUE (tipo_contacto, valor_contacto)
);

CREATE TABLE socio (
  id_socio INT IDENTITY(1,1) PRIMARY KEY,
  dni INT NOT NULL,
  nombre_socio VARCHAR(50) NOT NULL,
  apellido_socio VARCHAR(50) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  fecha_alta DATE NOT NULL,
  CONSTRAINT UQ_socio_dni UNIQUE (dni),
  CONSTRAINT CK_socio_fechas CHECK (fecha_nacimiento < fecha_alta AND fecha_alta <= GETDATE())
);

CREATE TABLE socio_contacto (
  id_socio INT NOT NULL,
  id_contacto INT NOT NULL,
  CONSTRAINT PK_socio_contacto PRIMARY KEY (id_socio, id_contacto),
  CONSTRAINT FK_socio_contacto_socio FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
  CONSTRAINT FK_socio_contacto_contacto FOREIGN KEY (id_contacto) REFERENCES contacto(id_contacto)
);

/* =========================================================
   3) Turnos y Asistencias
   ========================================================= */

CREATE TABLE turno (
  id_turno INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,              -- 'Mañana', 'Tarde', etc.
  horario_desde TIME(0) NOT NULL,
  horario_hasta TIME(0) NOT NULL,
  id_entrenador INT NOT NULL,
  id_sede INT NOT NULL,
  CONSTRAINT FK_turno_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
  CONSTRAINT FK_turno_sede FOREIGN KEY (id_sede) REFERENCES sede(id_sede),
  CONSTRAINT CK_turno_rango CHECK (horario_desde < horario_hasta),
  CONSTRAINT UQ_turno_sede_nombre UNIQUE (id_sede, nombre)
);

CREATE TABLE asistencia_diaria (
  id_socio INT NOT NULL,
  id_turno INT NOT NULL,
  fecha DATE NOT NULL,
  estado VARCHAR(50) NOT NULL,  -- 'Presente', 'Ausente', etc.
  CONSTRAINT PK_asistencia PRIMARY KEY (id_socio, id_turno, fecha),
  CONSTRAINT FK_asistencia_socio FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
  CONSTRAINT FK_asistencia_turno FOREIGN KEY (id_turno) REFERENCES turno(id_turno),
  CONSTRAINT CK_asistencia_fecha CHECK (fecha >= '2000-01-01' AND fecha <= GETDATE())
);

/* =========================================================
   4) Suscripciones y Pagos
   ========================================================= */

CREATE TABLE suscripcion (
  id_suscripcion INT IDENTITY(1,1) PRIMARY KEY,
  fecha_suscripcion DATE NOT NULL,
  id_socio INT NOT NULL,
  id_estado INT NOT NULL,
  CONSTRAINT FK_suscripcion_socio FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
  CONSTRAINT FK_suscripcion_estado FOREIGN KEY (id_estado) REFERENCES estado_suscripcion(id_estado_suscripcion),
  CONSTRAINT CK_suscripcion_fecha CHECK (fecha_suscripcion >= '2025-01-01' AND fecha_suscripcion <= GETDATE())
);

CREATE TABLE pago (
  id_pago INT IDENTITY(1,1) PRIMARY KEY,
  monto DECIMAL(12,2) NOT NULL,
  id_medio_pago INT NOT NULL,
  id_estado_pago INT NOT NULL,
  id_suscripcion INT NOT NULL,
  CONSTRAINT FK_pago_medio FOREIGN KEY (id_medio_pago) REFERENCES medio_pago(id_medio_pago),
  CONSTRAINT FK_pago_estado FOREIGN KEY (id_estado_pago) REFERENCES estado_de_pago(id_estado_pago),
  CONSTRAINT FK_pago_suscripcion FOREIGN KEY (id_suscripcion) REFERENCES suscripcion(id_suscripcion),
  CONSTRAINT CK_pago_monto CHECK (monto > 0)
);

/* =========================================================
   5) Índices útiles
   ========================================================= */
CREATE INDEX IX_provincia_pais ON provincia(id_pais);
CREATE INDEX IX_localidad_provincia ON localidad(id_provincia);
CREATE INDEX IX_sede_localidad ON sede(id_localidad);
CREATE INDEX IX_turno_sede ON turno(id_sede);
CREATE INDEX IX_turno_entrenador ON turno(id_entrenador);
CREATE INDEX IX_asistencia_turno ON asistencia_diaria(id_turno);
CREATE INDEX IX_asistencia_socio ON asistencia_diaria(id_socio);
CREATE INDEX IX_pago_suscripcion ON pago(id_suscripcion);


ALTER TABLE suscripcion
ADD duracion_meses INT NOT NULL DEFAULT 1
    CONSTRAINT CK_suscripcion_duracion CHECK (duracion_meses > 0);

ALTER TABLE suscripcion
ADD fecha_vencimiento DATE NULL;


-- ============================================
-- Arreglando pequeños errores
-- ============================================

-- ENTRENADOR
IF COL_LENGTH('entrenador', 'estado_entrenador') IS NULL
BEGIN
    ALTER TABLE entrenador
    ADD estado_entrenador VARCHAR(50) 
        CONSTRAINT DF_estado_entrenador DEFAULT 'Activo' 
        WITH VALUES;  -- 🔹 importante: rellena las filas existentes


-- SOCIO
IF COL_LENGTH('socio', 'estado_socio') IS NULL
BEGIN
    ALTER TABLE socio
    ADD estado_socio VARCHAR(50) 
        CONSTRAINT DF_estado_socio DEFAULT 'Activo' 
        WITH VALUES;
END


-- ============================================
-- 2️⃣  Agregar restricciones CHECK (solo si no existen)
-- ============================================

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints 
    WHERE name = 'CK_estado_entrenador'
)
ALTER TABLE entrenador
ADD CONSTRAINT CK_estado_entrenador 
CHECK (estado_entrenador IN ('Activo', 'Inactivo'));


IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints 
    WHERE name = 'CK_estado_socio'
)
ALTER TABLE socio
ADD CONSTRAINT CK_estado_socio 
CHECK (estado_socio IN ('Activo', 'Inactivo'));


