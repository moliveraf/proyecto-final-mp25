
# 02. CARGAR DATOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# Importar datos originales de SINCA - Parque O'Higgins

sinca_parque <- read_delim(
  "00_Datos/01_Datos_crudos/SINCA/SINCA_Parque_OHiggins_MP25_2026.csv",
  delim = ";",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sinca_parque)

# Importar datos originales de SINCA - Cerro Navia

sinca_cerro <- read_delim(
  "00_Datos/01_Datos_crudos/SINCA/SINCA_Cerro_Navia_MP25_2026.csv",
  delim = ";",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sinca_cerro)

# Importar datos originales de SINCA - Puente Alto

sinca_puente <- read_delim(
  "00_Datos/01_Datos_crudos/SINCA/SINCA_Puente_Alto_MP25_2026.csv",
  delim = ";",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sinca_puente)

# ----------------------------------------------------------------------------

# Importar datos del sensor CH4 - Cerro Navia

  sensor_ch4 <- read_csv(
    "00_Datos/01_Datos_crudos/Sensores_bajo_costo/SENSOR_Cerro_Navia_CH4_MP25_2026.csv",
    show_col_types = FALSE
  )

# Revisar las primeras observaciones
head(sensor_ch4)

# Importar datos del sensor CH56 - Parque O'Higgins

sensor_ch56 <- read_csv(
  "00_Datos/01_Datos_crudos/Sensores_bajo_costo/SENSOR_Parque_OHiggins_CH56_MP25_2026.csv",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sensor_ch56)

# Importar datos del sensor CH2 - Puente Alto

sensor_ch2 <- read_csv(
  "00_Datos/01_Datos_crudos/Sensores_bajo_costo/SENSOR_Puente_Alto_CH2_MP25_2026.csv",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sensor_ch2)

# ----------------------------------------------------------------------------

# Revisar la estructura de los datos importados

glimpse(sinca_parque)
glimpse(sinca_cerro)
glimpse(sinca_puente)

glimpse(sensor_ch56)
glimpse(sensor_ch4)
glimpse(sensor_ch2)


