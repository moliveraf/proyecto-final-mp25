
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
|---|---|---|
| Santiago | Parque O'Higgins | CH56 |
| Cerro Navia | Cerro Navia | CH4 |
| Puente Alto | Puente Alto | CH2 |

### Procedencia de los datos

**Estaciones oficiales:**

Sistema de Información Nacional de Calidad del Aire (SINCA), Ministerio del Medio Ambiente de Chile.

https://sinca.mma.gob.cl/

**Sensores de bajo costo:**

Registros de sensores de bajo costo calibrados, facilitados para el desarrollo de este proyecto académico.

Los archivos originales se conservan sin modificaciones para garantizar la trazabilidad de los análisis.

## 4. Organización del proyecto

El proyecto se organiza mediante carpetas y scripts independientes, con el propósito de facilitar su comprensión, mantenimiento y reproducibilidad.

### Datos

- `00_Datos/`: carpeta principal de datos.
- `00_Datos/01_Datos_crudos/SINCA/`: registros originales de las estaciones oficiales.
- `00_Datos/01
