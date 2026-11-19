

# Análisis exploratorio del MP2.5 en Santiago de Chile

## 1. Descripción del proyecto

Este proyecto tiene como objetivo analizar la variabilidad espacial y temporal de las concentraciones de material particulado fino (MP2.5) en Santiago de Chile, utilizando registros de estaciones oficiales de monitoreo de calidad del aire (SINCA) y mediciones de sensores de bajo costo calibrados.

El análisis se desarrolla mediante el lenguaje de programación R, aplicando procedimientos de importación, exploración, preparación, validación, análisis estadístico y visualización de datos ambientales.

Los resultados se integrarán en un informe reproducible elaborado con **Quarto**, que permitirá presentar la metodología, los gráficos, las tablas y las principales conclusiones del estudio.

## 2. Objetivos del proyecto

### Objetivo general

Analizar la variabilidad espacial y temporal de las concentraciones de MP2.5 en tres sectores de Santiago de Chile, mediante datos de estaciones SINCA y sensores de bajo costo calibrados.

### Objetivos específicos

1. Importar, organizar y explorar los registros de MP2.5 de las estaciones SINCA y los sensores de bajo costo.
2. Evaluar la disponibilidad y calidad de los datos mediante procedimientos de preparación y validación.
3. Caracterizar el comportamiento temporal de las concentraciones de MP2.5 en las estaciones estudiadas.
4. Comparar exploratoriamente las concentraciones registradas por SINCA y los sensores de bajo costo durante períodos coincidentes.
5. Elaborar visualizaciones, tablas y un informe reproducible que facilite la interpretación de los resultados.

## 3. Fuentes de datos

Se utilizan registros de tres estaciones SINCA y tres sensores de bajo costo calibrados, correspondientes a los siguientes sectores:

| Comuna | Estación SINCA | Sensor de bajo costo |
| ------ | -------------- | ------------------- |
| Santiago | Parque O'Higgins | CH56 |
| Cerro Navia | Cerro Navia | CH4 |
| Puente Alto | Puente Alto | CH2 |

### Procedencia de los datos

**Estaciones oficiales**

Sistema de Información Nacional de Calidad del Aire (SINCA), Ministerio del Medio Ambiente de Chile.

Sitio web: [SINCA](https://sinca.mma.gob.cl/).

**Sensores de bajo costo**

Registros de sensores de bajo costo calibrados, facilitados para el desarrollo de este proyecto académico.

Los archivos originales se conservan sin modificaciones para garantizar la trazabilidad de los análisis.

### Períodos de medición

| Fuente de medición | Fecha inicial | Fecha final |
| ------------------ | ------------- | ----------- |
| Estaciones SINCA | 01/03/2026 | 30/09/2026 |
| Sensor CH56 | 16/04/2026 | 27/08/2026 |
| Sensor CH4 | 19/03/2026 | 12/09/2026 |
| Sensor CH2 | 05/05/2026 | 31/08/2026 |

Los períodos de disponibilidad de los datos varían entre las fuentes de medición. Por esta razón, las comparaciones se realizan utilizando registros con fechas y horas coincidentes, considerando la necesidad de verificar su referencia horaria.

## 4. Organización del proyecto

El proyecto se organiza mediante carpetas y scripts independientes, con el propósito de facilitar su comprensión, mantenimiento, trazabilidad y reproducibilidad.

### Datos crudos

- `00_Datos/`: carpeta principal de datos.
- `00_Datos/01_Datos_crudos/`: almacenamiento de los registros originales.
- `00_Datos/01_Datos_crudos/SINCA/`: registros originales de las estaciones oficiales.
- `00_Datos/01_Datos_crudos/Sensores_bajo_costo/`: registros originales de los sensores calibrados.

### Datos procesados

- `00_Datos/02_Datos_procesados/`: almacenamiento de las bases preparadas para el análisis.
- `00_Datos/02_Datos_procesados/SINCA/`: registros horarios de las estaciones SINCA sin valores faltantes.
- `00_Datos/02_Datos_procesados/Sensores_bajo_costo/`: registros horarios de los sensores calibrados sin valores faltantes.
- `00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores/`: bases de datos con mediciones coincidentes por fecha y hora entre SINCA y los sensores.

Los datos procesados excluyen los registros con concentraciones faltantes y aquellos sin fecha u hora identificable. Las concentraciones fuera del intervalo de revisión establecido se conservan para su evaluación e interpretación posterior.

### Scripts de R

La carpeta `01_Scripts/` contiene los códigos empleados en las diferentes etapas del proyecto.

| Script | Descripción |
| ------ | ----------- |
| 01 | Carga de librerías y documentación de la gestión del ambiente. |
| 02 | Importación de las bases de datos originales. |
| 03 | Revisión y exploración inicial de los datos. |
| 04 | Validación de la estructura y el contenido de los datos. |
| 05 | Preparación y almacenamiento de las bases procesadas. |
| 06 | Comparación y análisis exploratorio de las concentraciones de MP2.5 entre SINCA y sensores. |

Los scripts se organizan de manera secuencial, facilitando la comprensión y reproducción de los procedimientos realizados.

### Comparación entre SINCA y sensores

A partir de la integración de las mediciones con fechas y horas coincidentes, se obtuvieron los siguientes registros:

| Comuna | Sensor | Pares de observaciones |
| ------ | ------ | ---------------------: |
| Santiago | CH56 | 2.956 |
| Cerro Navia | CH4 | 3.867 |
| Puente Alto | CH2 | 2.534 |
| **Total** | | **9.357** |

Estas bases constituyen el punto de partida para el análisis estadístico y la visualización de las concentraciones de MP2.5.

## 5. Reproducibilidad del proyecto

Para favorecer la reproducibilidad computacional del análisis de MP2.5, se utilizó el paquete `renv`, que permite gestionar el ambiente de trabajo y registrar las versiones de los paquetes empleados en el proyecto.

### Ambiente de trabajo

| Componente | Descripción |
| ---------- | ----------- |
| Lenguaje de programación | R |
| Versión de R | 4.6.1 |
| Entorno de desarrollo | RStudio |
| Versión de renv | 1.3.1 |
| Archivo de dependencias | `renv.lock` |
| Elaboración del informe | Quarto |
| Control de versiones | Git y GitHub |

### Gestión del ambiente

Los principales comandos para gestionar el ambiente del proyecto son:

| Comando | Descripción |
| ------- | ----------- |
| `renv::init()` | Inicializar el ambiente del proyecto. |
| `renv::snapshot()` | Registrar o actualizar las versiones de los paquetes. |
| `renv::status()` | Comprobar la consistencia del ambiente. |
| `renv::restore()` | Restaurar las dependencias registradas. |

### Restauración del ambiente

Para reproducir el ambiente de trabajo se deben realizar los siguientes pasos:

1. Descargar o clonar el repositorio desde GitHub.
2. Abrir el proyecto en RStudio, preferentemente con la versión de R registrada.
3. Restaurar las dependencias ejecutando en la consola:

   ```r
   renv::restore()
   ```

4. Comprobar la consistencia del ambiente:

   ```r
   renv::status()
   ```

5. Ejecutar los scripts siguiendo su orden numérico.

Para generar el informe final también será necesario disponer de Quarto.

La gestión de dependencias mediante `renv`, junto con la conservación de los datos originales, la organización de los scripts y el control de versiones mediante GitHub, contribuye a la trazabilidad y reproducibilidad del análisis.

## 6. Informe final en Quarto

Los resultados del proyecto se integrarán en un informe reproducible elaborado con **Quarto**, con el propósito de comunicar de manera clara, organizada y fundamentada los resultados del análisis de MP2.5.

### Contenido del informe

- Introducción y objetivos del proyecto.
- Descripción de las fuentes de datos.
- Metodología de preparación y validación de los datos.
- Análisis exploratorio de las concentraciones de MP2.5.
- Comparación entre las estaciones SINCA y los sensores de bajo costo calibrados.
- Análisis estadístico de las concentraciones.
- Tablas y visualizaciones de los resultados.
- Interpretación y discusión de los resultados.
- Conclusiones.
- Referencias bibliográficas.

### Presentación de los resultados

El informe combinará texto, código de R, tablas y gráficos en un mismo documento, facilitando la interpretación de los resultados, la comunicación científica y la reproducibilidad de los procedimientos realizados.

La versión final del informe se generará en formato HTML y se incorporará al repositorio de GitHub.

Una vez finalizado el proyecto, se incluirá en este apartado el enlace de acceso al informe elaborado con Quarto.
