
# 05. PREPARAR DATOS PROCESADOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# Este script organiza y guarda los registros horarios
# de SINCA y de los sensores de bajo costo calibrados.
# Se conservan los valores NA de las concentraciones.
# Los datos originales no se modifican.


# 1. ORGANIZAR LOS REGISTROS HORARIOS DE SINCA

# Parque O'Higgins
sinca_parque_procesado <- sinca_parque |>
  select(fecha_hora, mp25)

# Cerro Navia
sinca_cerro_procesado <- sinca_cerro |>
  select(fecha_hora, mp25)

# Puente Alto
sinca_puente_procesado <- sinca_puente |>
  select(fecha_hora, mp25)

# Comprobar las dimensiones
dim(sinca_parque_procesado)
dim(sinca_cerro_procesado)
dim(sinca_puente_procesado)


# 2. ORGANIZAR LOS REGISTROS HORARIOS DE LOS SENSORES

# Sensor CH56 - Parque O'Higgins
sensor_ch56_procesado <- sensor_ch56_horario |>
  select(fecha_hora, PM25_S2_calibrados) |>
  rename(mp25 = PM25_S2_calibrados)

# Sensor CH4 - Cerro Navia
sensor_ch4_procesado <- sensor_ch4_horario |>
  select(fecha_hora, PM25_P4_calibrados) |>
  rename(mp25 = PM25_P4_calibrados)

# Sensor CH2 - Puente Alto
sensor_ch2_procesado <- sensor_ch2_horario |>
  select(fecha_hora, PM25_P1_calibrados) |>
  rename(mp25 = PM25_P1_calibrados)

# Comprobar las dimensiones
dim(sensor_ch56_procesado)
dim(sensor_ch4_procesado)
dim(sensor_ch2_procesado)


# 3. GUARDAR BASES DE DATOS PROCESADAS

# Estaciones SINCA
write_csv(
  sinca_parque_procesado,
  "00_Datos/02_Datos_procesados/SINCA/SINCA_Parque_OHiggins.csv"
)

write_csv(
  sinca_cerro_procesado,
  "00_Datos/02_Datos_procesados/SINCA/SINCA_Cerro_Navia.csv"
)

write_csv(
  sinca_puente_procesado,
  "00_Datos/02_Datos_procesados/SINCA/SINCA_Puente_Alto.csv"
)

# Sensores de bajo costo
write_csv(
  sensor_ch56_procesado,
  "00_Datos/02_Datos_procesados/Sensores_bajo_costo/Sensor_CH56.csv"
)

write_csv(
  sensor_ch4_procesado,
  "00_Datos/02_Datos_procesados/Sensores_bajo_costo/Sensor_CH4.csv"
)

write_csv(
  sensor_ch2_procesado,
  "00_Datos/02_Datos_procesados/Sensores_bajo_costo/Sensor_CH2.csv"
)


# 4. VERIFICAR LOS ARCHIVOS PROCESADOS

# Comprobar los archivos de SINCA
list.files("00_Datos/02_Datos_procesados/SINCA")

# Comprobar los archivos de los sensores
list.files("00_Datos/02_Datos_procesados/Sensores_bajo_costo")

# Leer el archivo procesado del sensor CH56
verificacion <- read_csv(
  "00_Datos/02_Datos_procesados/Sensores_bajo_costo/Sensor_CH56.csv",
  show_col_types = FALSE
)

# Comprobar las dimensiones
dim(verificacion)

# Comprobar los valores faltantes de MP2.5
sum(is.na(verificacion$mp25))
