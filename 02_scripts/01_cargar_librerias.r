
# 01. CARGAR LIBRERÍAS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile


# 1. GESTIÓN DEL AMBIENTE Y REPRODUCIBILIDAD DEL PROYECTO

# Se utiliza renv para gestionar las dependencias
# y garantizar la reproducibilidad del proyecto.

# Comandos para ejecutar desde la consola:

# Instalar e inicializar renv (solo al crear el proyecto):
# install.packages("renv")
# renv::init()

# Instalar nuevas dependencias en el ambiente del proyecto:
# renv::install("datawizard")

# Registrar o actualizar las versiones de los paquetes:
# renv::snapshot()

# Comprobar el estado del ambiente:
# renv::status()

# Restaurar las dependencias desde renv.lock:
# renv::restore()


# 2. CARGAR LIBRERÍAS

# Manipulación, análisis y visualización de datos
library(tidyverse)

# Manipulación de fechas y horas
library(lubridate)

# Generación de diccionarios de datos
library(datawizard)
