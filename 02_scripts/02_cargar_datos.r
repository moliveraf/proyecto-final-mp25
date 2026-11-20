
# 02. CARGAR DATOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# Importar datos originales de SINCA - Parque O'Higgins

sinca_parque <- read_delim(
  "01_datos/01_datos_crudos/01_sinca/02_sinca_parque_ohiggins_mp25_2026.csv",
  delim = ";",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sinca_parque)

# Importar datos originales de SINCA - Cerro Navia

sinca_cerro <- read_delim(
  "01_datos/01_datos_crudos/01_sinca/01_sinca_cerro_navia_mp25_2026.csv",
  delim = ";",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sinca_cerro)

# Importar datos originales de SINCA - Puente Alto

sinca_puente <- read_delim(
  "01_datos/01_datos_crudos/01_sinca/03_sinca_puente_alto_mp25_2026.csv",
  delim = ";",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sinca_puente)

# ----------------------------------------------------------------------------

# Importar datos del sensor CH4 - Cerro Navia

  sensor_ch4 <- read_csv(
    "01_datos/01_datos_crudos/02_sensores_bajo_costo/01_sensor_cerro_navia_ch4_mp25_2026.csv",
    show_col_types = FALSE
  )

# Revisar las primeras observaciones
head(sensor_ch4)

# Importar datos del sensor CH56 - Parque O'Higgins

sensor_ch56 <- read_csv(
  "01_datos/01_datos_crudos/02_sensores_bajo_costo/02_sensor_parque_ohiggins_ch56_mp25_2026.csv",
  show_col_types = FALSE
)

# Revisar las primeras observaciones
head(sensor_ch56)

# Importar datos del sensor CH2 - Puente Alto

sensor_ch2 <- read_csv(
  "01_datos/01_datos_crudos/02_sensores_bajo_costo/03_sensor_puente_alto_ch2_mp25_2026.csv",
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


