# REPLICA DE BASES DE DATOS GRUPO N°6

A continuación se documenta el proceso completo de configuración de la replicación transaccional utilizando SQL Server Developer como publicador y servidores remotos unidos mediante Hamachi como suscriptores. Todas las imágenes se encuentran en la carpeta `imagenes_rp/` en la raíz del proyecto.

---

## 1. Base de datos lista para replicar

### La base estaba lista con todas sus tablas preparadas para ser publicadas.

![BD inicial](imagenes_rp/imagen_antes_de_suscriptores_y_publicaciones.png)



## 1.1. Carpeta del snapshot generada

### Snapshot listo para distribución.

![Carpeta snapshot](imagenes_rp/carpeta_de_instancia_de_publicacion.png)

---

## 1.2 Base distribuidora

### La base distribuidora queda configurada para manejar los snapshots y enviar cambios.

![Distribución](imagenes_rp/base_De_datos_de_distribucion4.png)



---

## 2. Instalación y configuración de Hamachi

### Se configuró la VPN para permitir comunicación entre las máquinas remotas.
![Hamachi instaldo](imagenes_rp/se_instalo_una_red_privadaHamachiVPN8.png)


---
### Se verificó la conectividad correcta

![Hamachi comprobación](imagenes_rp/hamachi.jpn.jpeg)


.
---

## 3. Creación de la publicación

### Desde SQL Server Developer se inicia el asistente.

![Creando publicacion](imagenes_rp/creando_la_publicacion.png)



---
### Se continua con la selección de opciones iniciales.

![Añadiendo publicacion](imagenes_rp/añadiendo_publicacion5.png)



---

## 4. Selección de tablas
### Se eligen todas las tablas necesarias para los suscriptores.
![Tablas seleccionadas](imagenes_rp/todas_las_tablas_que_tendra_el_suscriptor.png)

---

## 5. Finalización de la publicación
### Confirmación del asistente.
![Finalizando publicacion](imagenes_rp/terminando_la_publicacion6.png)


---

### Publicación creada correctamente.

![Configuración terminada](imagenes_rp/se_termino_la_configuracion_7.png)


---

## 6. Creación del suscriptor
### Se inicia el proceso para agregar un suscriptor.

![Añadiendo suscriptores](imagenes_rp/añadiendo_suscriptores.png)



---

## 7. Configuración interna del suscriptor
![Paso 1](imagenes_rp/añadiendole_al_suscriptor_parte2.png)

---
### 7.1 Se añade un suscriptor a partir de la IP de hamachiVPN y el puerto TCP = 1433

![Paso 2](imagenes_rp/añadiendole_al_suscriptor_parte3333.png)



---


### 7.2 se elige que base de datos va a tener el suscriptor

![Paso 3](imagenes_rp/añadiendole_al_suscriptor_parte4.png)


---

### 7.3 Se le crea una base de datos

![Paso 4](imagenes_rp/añadiendole_al_suscriptor_parte5.png)


---

### 7.4 Se selecciona el agente del distribuidor que sera inicion de sesion de SQL server 

![Paso 5](imagenes_rp/añadiendole_al_suscriptor_parte6.png)


---
### 7.5 añadir datos del suscriptor y poner Ejecutar en la cuenta de servicio de Agent SQL server 

![Paso 6](imagenes_rp/añadiendole_al_suscriptor_parte7.png)


---

### 7.6 Se inicializa la suscripcion 

![Paso 7](imagenes_rp/añadiendole_al_suscriptor_parte8.png)

 

---

### 7.8 Configuración detallada del suscriptor.

![Paso 8](imagenes_rp/añadiendole_al_suscriptor_parte9.png)



---
### 8 Estado de Agente con snapshot

![Paso 9](imagenes_rp/estado_de_agente.png)



---
## Fin del proceso
El sistema de replicación queda habilitado entre maestro  (publicador) y esclavos (suscriptores) vía VPN Hamachi.
