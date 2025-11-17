<h1 align="center">    Universidad Nacional Del Nordeste</h1>                     
 
<h1 align="center">Proyecto de Base de Datos 1: SISGYM</h1>           

<h1 align="center">Bases de Datos I (FaCENA-UNNE)</h1>


### Profesores: 

•	Lic. Villegas Dario O.

•	Lic. Vallejos Walter O. 

•	Exp. Cuzziol Juan J.

•	Lic. Badaracco Numa

---

### Integrantes: Grupo n° 6
•	Canteros Leonardo Oscar

•	Barbero Asselborn Valentina

•	Gauna Julieta Itati

•	Ferretto Joaquin Daniel

---

Año: 2025
 
---



# 📑 Índice

- [CAPÍTULO I — INTRODUCCIÓN](#capítulo-i--introducción)
  - [1. Caso de Estudio](#1-caso-de-estudio)
  - [2. Planteamiento del Problema](#2-planteamiento-del-problema)
  - [3. Objetivo General](#3-objetivo-general)
  - [4. Objetivos Específicos](#4-objetivos-específicos)
- [CAPÍTULO II — MARCO CONCEPTUAL](#capítulo-ii--marco-conceptual)
  - [TEMA 1 – Procedimientos y Funciones](#tema-1--procedimientos-y-funciones-en-sql-server)
  - [TEMA 2 – Optimización mediante Índices](#tema-2--optimización-de-consultas-mediante-índices-en-sql-server)
  - [TEMA 3 – Transacciones, COMMIT y ROLLBACK](#tema-3--manejo-de-transacciones-commit-y-rollback)
- [CAPÍTULO III — METODOLOGÍA DE DESARROLLO](#capítulo-iii--metodología-de-desarrollo)
  - [1. Identificación de Entidades](#1-identificación-y-relevamiento-de-entidades-del-dominio)
  - [2. Modelo ER](#2-diseño-conceptual-modelo-entidadrelación-er)
  - [3. Normalización](#3-normalización-y-diseño-lógico)
  - [4. Modelo Físico](#4-construcción-del-modelo-físico-en-sql-server)
  - [5. Procedimientos, Funciones e Índices](#5-implementación-de-procedimientos-almacenados-funciones-e-índices)
  - [6. Transacciones y Errores](#6-manejo-de-transacciones-y-control-de-errores)
  - [7. Pruebas y Verificación](#7-pruebas-del-sistema-y-verificación)
- [CAPÍTULO IV — DESARROLLO DE LOS TEMAS](#capítulo-iv--desarrollo-del-tema--resultados)
  - [1. Funciones y Procedimientos](#1-implementación-de-funciones-y-procedimientos-almacenados)
  - [2. Manejo Transaccional](#2-manejo-transaccional-en-sql-server)
  - [3. Optimización mediante Índices](#3-optimización-mediante-índices)
  - [4. Replicación Transaccional](#4-implementación-de-replicación-transaccional)
  - [5. Resultados Globales](#5-resultados-globales)
- [CAPÍTULO V — CONCLUSIONES](#capítulo-v--conclusiones)
- [BIBLIOGRAFÍA](#bibliografía)
- [Repositorio](#repositorio-del-proyecto)


---




## CAPÍTULO I — INTRODUCCIÓN  

### 1. Caso de Estudio

**SISGYM** es un sistema de gestión diseñado para administrar las operaciones centrales de un gimnasio con múltiples sedes. El proyecto integra en una única plataforma la información relacionada con:

- Socios  
- Entrenadores  
- Turnos  
- Asistencias  
- Suscripciones  
- Pagos  

Además, incorpora una estructura geográfica completa que abarca:

- País  
- Provincia  
- Localidad  

El sistema se basa en un **modelo de datos relacional** implementado en **SQL Server**, lo que asegura:

- Integridad  
- Consistencia  
- Trazabilidad  

La arquitectura se diseñó para resolver problemas habituales en la administración de gimnasios, tales como:

- Registros desactualizados o duplicados de socios y contactos  
- Falta de organización entre sedes y localidades  
- Asignaciones no trazables de entrenadores a turnos  
- Ausencia de un historial confiable de asistencias diarias  
- Manejo informal del estado y vencimiento de suscripciones  
- Pagos sin vinculación formal a una suscripción  
- Poca visibilidad para consultas, reportes y auditorías internas  

SISGYM centraliza toda esta operatoria mediante:

- Un diseño normalizado  
- Reglas de negocio encapsuladas en la base de datos  
- Mecanismos de control transaccional  

---

### 2. Planteamiento del Problema

Antes de SISGYM, la gestión del gimnasio dependía de **procesos manuales** y **registros dispersos**, lo que generaba:

- Inconsistencias y errores en la información de socios  
- Contactos almacenados sin un esquema uniforme  
- Turnos creados sin control de entrenadores o sedes  
- Dificultades para validar asistencia diaria  
- Imposibilidad de relacionar correctamente suscripciones y pagos  
- Ausencia de control sobre estados (“Activa”, “Vencida”, “Pausada”) y vencimientos  
- Poca integridad referencial, dificultando mantener datos confiables  

El gimnasio necesitaba un **sistema centralizado** que asegurara:

- Integridad  
- Trazabilidad  
- Un modelo escalable  

---

### 3. Objetivo General

Construir un **sistema de gestión integral** basado en un **modelo relacional robusto**, que permita administrar socios, entrenadores, turnos, asistencias, suscripciones y pagos, garantizando:

- Integridad referencial  
- Consistencia transaccional  
- Normalización adecuada  
- Soporte eficaz para consultas y operaciones reales del gimnasio  

---

### 4. Objetivos Específicos

- Modelar las entidades principales:  
  `socio`, `contacto`, `entrenador`, `sede`, `turno`, `asistencia_diaria`, `suscripcion`, `pago`.  
- Definir y estructurar catálogos y estados:  
  `estado_suscripcion`, `estado_de_pago`, `medio_pago`.  
- Representar la jerarquía geográfica completa:  
  **país → provincia → localidad → sede**.  
- Implementar relaciones clave como:
  - socio ↔ contacto (N–N)  
  - sede ↔ turno ↔ entrenador  
  - socio ↔ suscripción ↔ pago  
  - socio ↔ asistencia ↔ turno  
- Aplicar restricciones: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK` e índices estratégicos.  
- Registrar asistencias utilizando clave primaria compuesta:  
  `(id_socio, id_turno, fecha)`.  
- Controlar la validez de datos mediante reglas como:
  - Fechas válidas  
  - Montos positivos  
  - Rangos horarios correctos  
- Incorporar lógica de negocio mediante **funciones** y **procedimientos almacenados**.  
- Garantizar atomicidad, consistencia y recuperación ante errores mediante el uso de transacciones:
  - `COMMIT` / `ROLLBACK`  
  - `TRY…CATCH`  
  - `SAVEPOINT`  

---

## CAPÍTULO II – MARCO CONCEPTUAL  

### TEMA 1 – Procedimientos y Funciones en SQL Server

En el contexto del desarrollo de bases de datos transaccionales, como el sistema SISGYM, los **procedimientos almacenados** y las **funciones definidas por el usuario** son mecanismos fundamentales para estructurar y centralizar la lógica del negocio dentro del servidor SQL.

Beneficios principales:

- **Organización interna del sistema**  
- **Reutilización de código**  
- **Ejecución precisa y coherente de operaciones críticas**  

Los **procedimientos almacenados** permiten:

- Encapsular operaciones complejas (inserciones, actualizaciones, validaciones, cálculos, flujos transaccionales)  
- Reducir duplicación de código  
- Mejorar el rendimiento  
- Facilitar el mantenimiento  
- Incorporar control de errores y manejo de transacciones (por ejemplo, registrar un pago, crear una suscripción, vincular datos entre tablas dependientes)  

Las **funciones definidas por el usuario (UDF)**:

- Encapsulan cálculos y operaciones lógicas reutilizables  
- Pueden integrarse en `SELECT`, `WHERE`, `JOIN`, etc.  
- Mejoran legibilidad y estandarización de consultas  
- Mantienen la integridad del sistema  

Ejemplos en SISGYM:

- Cálculo de edades  
- Evaluación del estado de suscripciones  
- Cálculos derivados a partir de otros datos  

En conjunto:

- Fortalecen la consistencia del sistema  
- Mejoran el desempeño  
- Reducen errores en capas superiores (aplicaciones, APIs, etc.)  
- Centralizan la lógica de negocio en la base de datos  

Todo esto favorece buenas prácticas de ingeniería de software:

- Modularidad  
- Reutilización  
- Claridad semántica  
- Control adecuado de la información  

---

### TEMA 2 – Optimización de Consultas mediante Índices en SQL Server

En bases de datos transaccionales con alto volumen de operaciones, como SISGYM, la **eficiencia de las consultas** es clave. A medida que las tablas crecen, las búsquedas secuenciales completas (Table Scan) se vuelven costosas.

Los **índices** son estructuras de datos auxiliares que permiten:

- Acceder más rápido a la información  
- Evitar recorridos completos innecesarios  
- Funcionar de forma análoga al índice de un libro  

SQL Server implementa índices con estructuras **B-Tree**, optimizadas para:

- Búsquedas  
- Ordenamientos  
- Operaciones de rango  

Tipos principales:

- **Índice clustered**:
  - Define el **orden físico** de las filas en disco  
  - Eficiente para consultas por rangos amplios  
  - Permite lecturas secuenciales con pocos saltos de página  
- **Índice nonclustered**:
  - Mantiene una estructura lógica separada  
  - Referencia ubicaciones reales de los datos  
  - No reorganiza físicamente la tabla  
  - Muy útil para consultas selectivas  
  - Puede convertirse en índice de cobertura usando `INCLUDE`  

Impacto en SISGYM:

- Búsquedas por fecha en registros de asistencia  
- Consultas por socio  
- Análisis de pagos y suscripciones  

La diferencia entre:

- Consulta sin índices (`Table Scan`)  
- Consulta con índices (`Index Seek`)  

Puede significar reducciones superiores al **90%** en:

- Lecturas lógicas  
- Tiempos de respuesta  
- Carga sobre el servidor  

Conclusión:

- La indexación es un pilar esencial para el rendimiento en SQL Server  
- Acelera el acceso a la información  
- Reduce carga del motor y mejora escalabilidad  
- Permite que SISGYM mantenga una performance estable incluso con el crecimiento constante de datos  

---

### TEMA 3 – Manejo de Transacciones, COMMIT y ROLLBACK

En sistemas que requieren **integridad y consistencia**, como SISGYM, el manejo correcto de **transacciones** es esencial.

Una **transacción** es una unidad lógica de trabajo que agrupa operaciones para que se comporten como un bloque indivisible. Su principal objetivo es evitar que la base de datos quede en un estado intermedio o incorrecto.

Propiedades **ACID**:

- **Atomicidad**: todas las operaciones se completan o ninguna  
- **Consistencia**: la base pasa de un estado válido a otro válido  
- **Aislamiento**: evita interferencias entre operaciones concurrentes  
- **Durabilidad**: los cambios confirmados persisten ante fallos  

En SQL Server, las transacciones se manejan con:

- `BEGIN TRAN`  
- `COMMIT`  
- `ROLLBACK`  

Esto permite proteger procesos sensibles como:

- Alta de socio  
- Creación de suscripción  
- Registro de pago  

El uso de bloques `TRY…CATCH`:

- Permite capturar errores en tiempo de ejecución  
- Habilita aplicar `ROLLBACK` oportunamente  
- Evita que queden registros parciales o inconsistentes  

SQL Server también admite:

- **Transacciones anidadas**  
- Uso de `@@TRANCOUNT`  
- `SAVEPOINT`  

Lo que permite:

- Comportamientos predecibles en procedimientos que llaman a otros  
- Reutilizar código  
- Simplificar mantenimiento  
- Manejar escenarios complejos con seguridad  

El control transaccional asegura:

- Reglas de negocio coherentes  
- Datos íntegros  
- Operaciones confiables  

En un sistema como SISGYM, donde múltiples operaciones dependen unas de otras, las transacciones son la base para garantizar que la información refleje siempre un estado correcto y consistente.

---

## CAPÍTULO III – METODOLOGÍA DE DESARROLLO  

La metodología del proyecto siguió un enfoque **sistemático y progresivo**, desde el análisis conceptual del dominio hasta la implementación en SQL Server, garantizando coherencia, integridad y eficiencia.

---

### 1. Identificación y relevamiento de entidades del dominio

Se analizó el funcionamiento real de un gimnasio para identificar entidades esenciales:

- Socio  
- Entrenador  
- Sede  
- Turno  
- Suscripción  
- Pago  
- Asistencia  
- Contacto  
- Localidad  
- Provincia  
- País  

El relevamiento incluyó:

- Relaciones naturales entre entidades  
- Atributos clave y dependencias funcionales  
- Reglas de negocio críticas (por ejemplo, evitar superposición de turnos en una misma sede)  
- Procesos operativos del gimnasio y su reflejo en los datos  

Esta etapa permitió comprender el comportamiento esperado del sistema y definir el marco conceptual.

---

### 2. Diseño conceptual: modelo entidad–relación (ER)

Con las entidades identificadas se elaboró un **modelo ER** que representa:

- Entidades principales del sistema  
- Atributos relevantes y claves candidatas  
- Tipos de relaciones (1:1, 1:N, N:M)  
- Cardinalidades, dependencias y restricciones conceptuales  

El objetivo fue obtener una visión abstracta y precisa del sistema, independiente del motor de base de datos, como base para el diseño lógico.

> Se elaboró un **DER (Diagrama Entidad–Relación)** que refleja el diseño conceptual de SISGYM.

---

### 3. Normalización y diseño lógico

A partir del modelo conceptual se aplicaron las formas normales (1FN, 2FN y 3FN) para:

- Eliminar redundancia  
- Evitar anomalías de inserción, actualización y eliminación  
- Definir claves primarias, foráneas y dominios consistentes  
- Establecer reglas de integridad necesarias  

Esto garantizó un **modelo lógico eficiente** y libre de inconsistencias estructurales.

---

### 4. Construcción del modelo físico en SQL Server

El modelo físico se implementó mediante:

- Creación de tablas y columnas con tipos de datos adecuados  
- Definición de claves primarias (PK) y foráneas (FK)  
- Implementación de restricciones `CHECK`, `UNIQUE` y `DEFAULT`  
- Generación de dominios y validaciones internas  
- Carga inicial de datos según las reglas definidas  

Todo se implementó en la base **proyectoBD**, replicando fielmente el modelo lógico.

---

### 5. Implementación de procedimientos almacenados, funciones e índices

Sobre el modelo físico se implementó lógica de negocio con:

- Procedimientos para creación, modificación y eliminación de sedes  
- Procedimientos transaccionales para registrar entrenadores y turnos  
- Funciones para detectar superposiciones de horarios  
- Mecanismos para validar datos críticos antes de su inserción  

Además, se incorporaron:

- Índices **clustered**  
- Índices **nonclustered**  

Basados en análisis de **planes de ejecución**, con el objetivo de:

- Optimizar consultas frecuentes  
- Reducir costos de lectura  

---

### 6. Manejo de transacciones y control de errores

Las operaciones sensibles se desarrollaron usando:

- Transacciones ACID  
- Bloques `TRY/CATCH`  
- `THROW` para relanzar errores  

Esto permitió:

- Evitar inserciones parciales ante fallos  
- Garantizar integridad entre entidades relacionadas  
- Asegurar que operaciones complejas (por ejemplo, crear entrenador + turno) se ejecuten de forma atómica  

---

### 7. Pruebas del sistema y verificación

La verificación incluyó:

- Ejecución de procedimientos en distintos escenarios  
- Validación de reglas de negocio:
  - Superposición de turnos  
  - DNI duplicados  
  - Fechas inválidas  
- Comparación de rendimiento con y sin índices mediante planes `.sqlplan`  
- Pruebas de integridad referencial mediante inserciones y eliminaciones controladas  

Esta etapa confirmó que el sistema se alinea con los requerimientos del dominio.

---

## CAPÍTULO IV – DESARROLLO DEL TEMA / RESULTADOS  

Este capítulo integra la aplicación concreta de los tres temas obligatorios del proyecto:

- Procedimientos y funciones  
- Manejo transaccional  
- Índices  

Y la **implementación práctica de la replicación transaccional**, todo sobre la base SISGYM.

---

### 1. Implementación de Funciones y Procedimientos Almacenados  

La lógica de negocio se implementó mediante:

- **Funciones definidas por el usuario (UDF)**  
- **Procedimientos almacenados**  

Lo que permitió:

- Centralizar validaciones  
- Encapsular cálculos internos  
- Gestionar operaciones multitabla  

#### 1.1 Funciones

Funciones relevantes:

- `fn_total_pagado_por_socio`  
  - Calcula el total de dinero pagado por un socio sumando los montos de todos sus pagos.  
- `fn_turno_ocupado`  
  - Indica si en una sede ya existe un turno que se superpone con un rango horario dado (1 ocupado, 0 disponible).  

Estas funciones encapsulan lógica derivada sin alterar la normalización del modelo.

#### 1.2 Procedimientos almacenados

Procedimientos implementados:

- CRUD para entidades fundamentales (`socio`, `sede`, etc.)  
- Validación de solapamiento de turnos mediante lógica auxiliar  

Ejemplos:

- `sp_registrar_socio_suscripcion_pago`  
- `sp_Socio_Alta`: alta de socio + devolución de `id_socio`  
- `sp_insertar_suscripcion_y_pago`: crea suscripción, calcula vencimiento, inserta pago asociado y devuelve IDs  
- `sp_registrar_entrenador_y_turno`: alta de entrenador y turno, validando DNI y solapamiento horario  
- `sp_baja_logica_entrenador`: baja lógica y reasignación de turnos  
- `sp_baja_logica_socio`: cambia estado de socio a 'Inactivo'  
- `sp_reactivar_entrenador`: reactivar entrenador  
- `sp_reactivar_socio`: reactivar socio  
- `sp_eliminar_sede`: elimina sede solo si no tiene turnos asociados  
- `sp_crear_sede`: crea nueva sede y devuelve `id_sede` generado  

Estos procedimientos garantizan:

- Modularidad  
- Consistencia  
- Repetibilidad de las operaciones  

---

### 2. Manejo Transaccional en SQL Server  

La gestión de transacciones ACID fue clave para asegurar integridad ante operaciones multitabla.

#### 2.1 COMMIT y ROLLBACK en operaciones reales

Las transacciones explícitas se aplicaron en:

- Alta de socios  
- Registro de suscripciones  
- Creación de pagos  

Si todo se ejecuta correctamente:

- Se realiza `COMMIT`  

Si ocurre un error:

- Se ejecuta `ROLLBACK` y se deshace todo el bloque  

#### 2.2 TRY…CATCH y manejo controlado de errores  

Se desarrollaron pruebas que demostraron:

- Procedimientos exitosos, verificando estados finales  
- Validaciones automáticas mediante `CHECK` y claves compuestas  

Esto:

- Demostró escenarios reales de recuperación ante errores  
- Aseguró atomicidad incluso en flujos complejos  

---

### 3. Optimización mediante Índices  

Se analizaron tres escenarios:

- Consulta sin índices (`Table Scan`)  
- Índice **clustered**  
- Índice **nonclustered** de cobertura (`INCLUDE`)  

Resultados:

- Reducción significativa de lecturas lógicas  
- Menor costo en el plan de ejecución  
- Acceso directo mediante `Index Seek`  
- Mejor desempeño del índice clustered en grandes volúmenes, por el orden físico de las páginas  

Conclusión:

- Los índices estratégicos son fundamentales para el patrón de consultas de SISGYM.  

---

### 4. Implementación de Replicación Transaccional  

Este apartado describe el proceso de implementación de la **replicación transaccional** en SQL Server dentro del proyecto SISGYM. La solución permitió sincronizar datos entre varias computadoras utilizando **SQL Server Developer** y **SQL Server Express** conectados mediante una red virtual.

---

#### 4.1 Configuración del Entorno

Para la arquitectura **Maestro–Esclavo** se definieron los roles:

**Publicador**  
- A cargo de **Joaquín**, usando **SQL Server Developer Edition**, que soporta replicación transaccional.

**Suscriptores**  
- Los demás integrantes del grupo, usando **SQL Server Express**, que permite recibir publicaciones.

**Red virtual**  
- Conexión entre equipos mediante **Hamachi**, simulando una misma red local.

---

#### 4.2 Configuración de la Comunicación entre Servidores

Pasos realizados:

- Apertura de puertos en cada suscriptor:
  - `TCP 1433` (SQL Server)  
  - Puertos del **SQL Server Agent**  
- Intercambio de direcciones **IP de Hamachi**.  
- Conexión desde el publicador a cada instancia remota utilizando:


### <IP_Hamachi>\<TCP=1433>


- Verificación de conectividad mediante **SQL Server Management Studio** con autenticación SQL o Windows.

---

#### 4.3 Creación del Publicador

Configuración en la instancia de Joaquín:

- Habilitar opción **Replication**  
- Seleccionar **Transactional Replication**  

**Base de datos publicada**: `proyectoBD`, incluyendo tablas como:

- sede  
- socio  
- entrenador  
- turno  
- suscripción  
- provincia  
- localidad  
- país  
- asistencia  
- contacto  

**Artículos incluidos en la publicación**:

- Todas las tablas  
- PK, FK, `CHECK`, `UNIQUE`  
- Índices  
- Datos iniciales  
- Relaciones completas  

Los suscriptores recibieron una réplica funcional de toda la estructura y los datos.

---

#### 4.4 Configuración del Distribuidor  

El mismo servidor publicador actuó como **distribuidor**:

- Creación de la base `distribution`  
- Configuración de agentes de distribución responsables del envío de transacciones  

Esto habilitó un flujo continuo y confiable de datos hacia los suscriptores.

---

#### 4.5 Configuración de los Suscriptores  

Cada integrante realizó:

- Instalación de **SQL Server Express**  
- Envío de su IP de Hamachi e instancia SQL  
- Pruebas de conectividad desde el publicador  

En el servidor de Joaquín:

- Registro de cada equipo como **suscriptor**  
- Creación de **Push Subscriptions**  

Al activarse la suscripción:

- Los suscriptores recibieron todas las tablas  
- Se replicaron PK, FK y restricciones  
- Se copiaron todos los datos iniciales  
- Las estructuras quedaron idénticas  

---

#### 4.6 Funcionamiento del Modelo Maestro–Esclavo  

En la replicación transaccional:

- El **publicador** es el único que realiza:
  - `INSERT`, `UPDATE`, `DELETE`  
- Los **suscriptores** reciben automáticamente cada cambio  

Es un modelo **unidireccional**:

- El publicador gestiona modificaciones  
- Los suscriptores trabajan en modo lectura  

**Beneficios observados**:

- Sincronización casi en tiempo real  
- Integridad de datos garantizada  
- Estructuras e índices replicados  
- Flujo continuo de información hacia todos los nodos  

**Resultado**:

- Todo el grupo contó con una copia sincronizada de la base  
- Se pudo trabajar en paralelo sin inconsistencias  
- Se comprobó en la práctica el funcionamiento de la replicación transaccional  
- Cada cambio del publicador se propagó automáticamente  

Este procedimiento refleja cómo funciona la replicación en entornos reales con un servidor central y nodos de consulta distribuidos.

---

### 5. Resultados Globales  

La integración de:

- Funciones  
- Procedimientos almacenados  
- Transacciones  
- Índices  
- Replicación  

Permitió obtener una base de datos:

- Robusta  
- Segura  
- Eficiente  

Los mecanismos implementados:

- Reforzaron la integridad del modelo  
- Optimizaron el rendimiento de consultas  
- Permitieron trabajar con tecnologías usadas en entornos profesionales reales  

> **Diccionario de datos**  
> Disponible en:  
> `https://github.com/Valent-2202/proyectoBD/blob/master/docs/Diccionario_Proyecto_grupo6.pdf`

---

## CAPÍTULO V – CONCLUSIONES  

El proyecto permitió integrar de manera ordenada los contenidos teóricos y prácticos de la asignatura, aplicándolos a un caso concreto como el sistema **SISGYM**.

A partir de:

- El análisis del dominio  
- La construcción del modelo conceptual  
- La normalización  

Se logró diseñar una base de datos:

- Estructurada  
- Coherente  
- Alineada a los principios del modelado relacional  

La implementación física en SQL Server, junto a:

- Claves primarias y foráneas  
- Restricciones lógicas  
- Procedimientos almacenados  
- Funciones  
- Índices  

Aseguró:

- Centralización de reglas de negocio  
- Buen rendimiento de consultas  
- Manejo adecuado de los datos  

El uso de:

- Transacciones ACID  
- Mecanismos de control de errores  
- Replicación transaccional  

Fue esencial para:

- Mantener integridad en operaciones críticas  
- Evitar estados inconsistentes  
- Comprender tecnologías utilizadas en escenarios distribuidos  

---

## BIBLIOGRAFÍA  

- Chen, P. (1976).  
  *The entity–relationship model: Toward a unified view of data.*  
  ACM Transactions on Database Systems, 1(1), 9–36.  

- Escobar Domínguez, Ó., Pulido Romero, E., & Núñez Pérez, J. Á. (2019).  
  *Base de datos.* Grupo Editorial Patria.  
  Disponible en eLibro: `https://elibro.net/es/ereader/unne/121283`  

- Microsoft Corporation. (2023).  
  *SQL Server Documentation.*  
  `https://learn.microsoft.com/sql/`  

---

## Repositorio del Proyecto

> **SISGYM – Grupo 6**  
> Repositorio en GitHub:  
> `https://github.com/Valent-2202/proyectoBD`
