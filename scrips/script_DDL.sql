create table estado_suscripcion (
  id_estado_suscripcion int identity(1,1) not null,
  descripcion           varchar(50) not null,
  constraint pk_estado_suscripcion primary key (id_estado_suscripcion),
  constraint uq_estado_suscripcion unique (descripcion)
);

create table estado_de_pago (
  id_estado_pago      int identity(1,1) not null,
  descripcion_est_pago varchar(50) not null,
  constraint pk_estado_de_pago primary key (id_estado_pago),
  constraint uq_estado_de_pago unique (descripcion_est_pago)
);

create table medio_pago (
  id_medio_pago int identity(1,1) not null,
  tipo_medio_pago varchar(50) not null,
  constraint pk_medio_pago primary key (id_medio_pago),
  constraint uq_medio_pago unique (tipo_medio_pago)
);

create table pais (
  id_pais         int identity(1,1) not null,
  nombre          varchar(50) not null,
  cant_habitantes int not null,
  constraint pk_pais primary key (id_pais),
  constraint uq_pais_nombre unique (nombre),
  constraint ck_pais_habitantes check (cant_habitantes > 0)
);

create table provincia (
  id_provincia        int identity(1,1) not null,
  nombre              varchar(50) not null,
  cantidad_habitantes int null,
  id_pais             int not null,
  constraint pk_provincia primary key (id_provincia),
  constraint fk_provincia_pais foreign key (id_pais) references pais(id_pais),
  constraint uq_provincia_nombre_pais unique (nombre, id_pais)
);

create table localidad (
  id_localidad        int identity(1,1) not null,
  nombre              varchar(50) not null,
  cantidad_habitantes int null,
  codigo_postal       int null,    
  id_provincia        int not null,
  constraint pk_localidad primary key (id_localidad),
  constraint fk_localidad_provincia foreign key (id_provincia) references provincia(id_provincia),
  constraint uq_localidad_nombre_prov unique (nombre, id_provincia)
);

create table sede (
  id_sede      int identity(1,1) not null,
  direccion    varchar(120) not null,
  estado       bit not null default 1, 
  id_localidad int not null,
  constraint pk_sede primary key (id_sede),
  constraint fk_sede_localidad foreign key (id_localidad) references localidad(id_localidad),
  constraint uq_sede_direccion_localidad unique (direccion, id_localidad)
);

create table entrenador (
  id_entrenador        int identity(1,1) not null,
  nombre_entrenador    varchar(50) not null,
  apellido_entrenador  varchar(50) not null,
  telefono_entrenador  varchar(20) not null,
  correo_entrenador    varchar(100) not null,
  dni_entrenador       int not null,
  fecha_nacimiento     date not null,
  estado_entrenador    varchar(50) not null
    constraint df_estado_entrenador default 'Activo',
  constraint pk_entrenador primary key (id_entrenador),
  constraint uq_entrenador_dni unique (dni_entrenador),
  constraint uq_entrenador_correo unique (correo_entrenador),
  constraint ck_entrenador_fnac check (fecha_nacimiento < getdate()),
  constraint ck_estado_entrenador check (estado_entrenador in ('Activo','Inactivo'))
);

create table contacto (
  id_contacto   int identity(1,1) not null,
  tipo_contacto varchar(30) not null,
  valor_contacto varchar(255) not null,
  constraint pk_contacto primary key (id_contacto),
  constraint uq_contacto_tipo_valor unique (tipo_contacto, valor_contacto)
);

create table socio (
  id_socio         int identity(1,1) not null,
  dni              int not null,
  nombre_socio     varchar(50) not null,
  apellido_socio   varchar(50) not null,
  fecha_nacimiento date not null,
  fecha_alta       date not null,
  estado_socio     varchar(50) not null
    constraint df_estado_socio default 'Activo',
  constraint pk_socio primary key (id_socio),
  constraint uq_socio_dni unique (dni),
  constraint ck_socio_fechas check (fecha_nacimiento < fecha_alta and fecha_alta <= getdate()),
  constraint ck_estado_socio check (estado_socio in ('Activo','Inactivo'))
);

create table socio_contacto (
  id_socio    int not null,
  id_contacto int not null,
  constraint pk_socio_contacto primary key (id_socio, id_contacto),
  constraint fk_socio_contacto_socio foreign key (id_socio) references socio(id_socio),
  constraint fk_socio_contacto_contacto foreign key (id_contacto) references contacto(id_contacto)
);

create table turno (
  id_turno       int identity(1,1) not null,
  nombre         varchar(50) not null,       
  horario_desde  time(0) not null,
  horario_hasta  time(0) not null,
  id_entrenador  int not null,
  id_sede        int not null,
  constraint pk_turno primary key (id_turno),
  constraint fk_turno_entrenador foreign key (id_entrenador) references entrenador(id_entrenador),
  constraint fk_turno_sede foreign key (id_sede) references sede(id_sede),
  constraint ck_turno_rango check (horario_desde < horario_hasta),
  constraint uq_turno_sede_nombre unique (id_sede, nombre)
);

create table asistencia_diaria (
  id_socio int not null,
  id_turno int not null,
  fecha    date not null,
  estado   varchar(50) not null,  
  constraint pk_asistencia primary key (id_socio, id_turno, fecha),
  constraint fk_asistencia_socio foreign key (id_socio) references socio(id_socio),
  constraint fk_asistencia_turno foreign key (id_turno) references turno(id_turno),
  constraint ck_asistencia_fecha check (fecha >= '2000-01-01' and fecha <= getdate())
);

create table suscripcion (
  id_suscripcion    int identity(1,1) not null,
  fecha_suscripcion date not null,
  id_socio          int not null,
  id_estado         int not null,
  duracion_meses    int not null
    constraint ck_suscripcion_duracion check (duracion_meses > 0),
  fecha_vencimiento date null,
  constraint pk_suscripcion primary key (id_suscripcion),
  constraint fk_suscripcion_socio foreign key (id_socio) references socio(id_socio),
  constraint fk_suscripcion_estado foreign key (id_estado) references estado_suscripcion(id_estado_suscripcion),
  constraint ck_suscripcion_fecha check (fecha_suscripcion >= '2000-01-01' and fecha_suscripcion <= getdate()),
  constraint uq_suscripcion_socio_fecha unique (id_socio, fecha_suscripcion)
);

create table pago (
  id_pago        int identity(1,1) not null,
  monto          decimal(12,2) not null,
  id_medio_pago  int not null,
  id_estado_pago int not null,
  id_suscripcion int not null,
  constraint pk_pago primary key (id_pago),
  constraint fk_pago_medio foreign key (id_medio_pago) references medio_pago(id_medio_pago),
  constraint fk_pago_estado foreign key (id_estado_pago) references estado_de_pago(id_estado_pago),
  constraint fk_pago_suscripcion foreign key (id_suscripcion) references suscripcion(id_suscripcion),
  constraint ck_pago_monto check (monto > 0)
);