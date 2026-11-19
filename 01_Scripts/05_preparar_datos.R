

# 05. PREPARAR DATOS PROCESADOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# Este script prepara los datos de SINCA y de los
# sensores de bajo costo calibrados para el análisis.
# Se excluyen mediante na.omit() los registros con
# concentraciones faltantes de MP2.5 y aquellos
# sin fecha u hora identificable (NA).
# Se conservan las concentraciones atípicas
# para su posterior evaluación.
# Los archivos originales no se modifican.


# 1. SELECCIONAR REGISTROS DISPONIBLES PARA EL ANÁLISIS

# Seleccionar las variables de interés
# y excluir los registros con valores faltantes
datos_procesados <- datos_validacion |>
  select(fuente, comuna, fecha_hora, mp25) |>
  na.omit()

# Comprobar los registros por fuente y comuna
datos_procesados |>
  group_by(fuente, comuna) |>
  summarise(
    n_registros = n(),
    .groups = "drop"
  )
# ----------------------------------------------------------------------------

# 2. ORGANIZAR LOS DATOS PROCESADOS DE SINCA

# Parque O'Higgins
sinca_parque_procesado <- datos_procesados |>
  filter(fuente == "SINCA", comuna == "Santiago") |>
  select(fecha_hora, mp25)

# Cerro Navia
sinca_cerro_procesado <- datos_procesados |>
  filter(fuente == "SINCA", comuna == "Cerro Navia") |>
  select(fecha_hora, mp25)

# Puente Alto
sinca_puente_procesado <- datos_procesados |>
  filter(fuente == "SINCA", comuna == "Puente Alto") |>
  select(fecha_hora, mp25)

# Comprobar las dimensiones
dim(sinca_parque_procesado)
dim(sinca_cerro_procesado)
dim(sinca_puente_procesado)

# ----------------------------------------------------------------------------
# 3. ORGANIZAR LOS DATOS PROCESADOS DE LOS SENSORES

# Sensor CH56 - Parque O'Higgins
sensor_ch56_procesado <- datos_procesados |>
  filter(
    fuente == "Sensor de bajo costo",
    comuna == "Santiago"
  ) |>
  select(fecha_hora, mp25)

# Sensor CH4 - Cerro Navia
sensor_ch4_procesado <- datos_procesados |>
  filter(
    fuente == "Sensor de bajo costo",
    comuna == "Cerro Navia"
  ) |>
  select(fecha_hora, mp25)

# Sensor CH2 - Puente Alto
sensor_ch2_procesado <- datos_procesados |>
  filter(
    fuente == "Sensor de bajo costo",
    comuna == "Puente Alto"
  ) |>
  select(fecha_hora, mp25)

# Comprobar las dimensiones
dim(sensor_ch56_procesado)
dim(sensor_ch4_procesado)
dim(sensor_ch2_procesado)

# ----------------------------------------------------------------------------
# 4. CREAR CARPETAS PARA LOS DATOS PROCESADOS

# Carpeta SINCA
dir.create(
  "00_Datos/02_Datos_procesados/SINCA",
  recursive = TRUE,
  showWarnings = FALSE
)

# Carpeta de sensores
dir.create(
  "00_Datos/02_Datos_procesados/Sensores_bajo_costo",
  recursive = TRUE,
  showWarnings = FALSE
)

# ----------------------------------------------------------------------------
# 5. GUARDAR BASES DE DATOS PROCESADAS

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

# ----------------------------------------------------------------------------

# 6. VERIFICAR LOS ARCHIVOS GUARDADOS

# Comprobar los archivos de SINCA
list.files("00_Datos/02_Datos_procesados/SINCA")

# Comprobar los archivos de los sensores
list.files("00_Datos/02_Datos_procesados/Sensores_bajo_costo")

# ----------------------------------------------------------------------------
# 7. VERIFICAR LOS DATOS PROCESADOS

# Leer el archivo procesado del sensor CH56
verificacion <- read_csv(
  "00_Datos/02_Datos_procesados/Sensores_bajo_costo/Sensor_CH56.csv",
  show_col_types = FALSE
)

# Comprobar las dimensiones
dim(verificacion)

# Comprobar los valores faltantes de MP2.5
sum(is.na(verificacion$mp25))

# Comprobar las fechas y horas faltantes
sum(is.na(verificacion$fecha_hora))

# ----------------------------------------------------------------------------
# 8. COMPROBAR VALORES FALTANTES EN LAS SEIS BASES

# Estaciones SINCA
sum(is.na(sinca_parque_procesado))
sum(is.na(sinca_cerro_procesado))
sum(is.na(sinca_puente_procesado))

# Sensores de bajo costo
sum(is.na(sensor_ch56_procesado))
sum(is.na(sensor_ch4_procesado))
sum(is.na(sensor_ch2_procesado))

# ----------------------------------------------------------------------------
# 9. RESUMEN DE DATOS PROCESADOS DE SINCA Y SENSORES

# Contar los registros originales por fuente y comuna
registros_originales <- datos_validacion |>
  count(fuente, comuna, name = "n_originales")

# Contar los registros después de la limpieza
registros_procesados <- datos_procesados |>
  count(fuente, comuna, name = "n_procesados")

# Unir y resumir los registros originales y procesados
resumen_datos_procesados <- registros_originales |>
  left_join(
    registros_procesados,
    by = c("fuente", "comuna")
  ) |>
  mutate(
    n_procesados = coalesce(n_procesados, 0L),
    estacion_sensor = case_when(
      fuente == "SINCA" & comuna == "Santiago" ~ "Parque O'Higgins",
      fuente == "SINCA" & comuna == "Cerro Navia" ~ "Cerro Navia",
      fuente == "SINCA" & comuna == "Puente Alto" ~ "Puente Alto",
      fuente == "Sensor de bajo costo" & comuna == "Santiago" ~ "CH56",
      fuente == "Sensor de bajo costo" & comuna == "Cerro Navia" ~ "CH4",
      fuente == "Sensor de bajo costo" & comuna == "Puente Alto" ~ "CH2"
    ),
    n_excluidos = n_originales - n_procesados,
    porcentaje_conservado = round(
      100 * n_procesados / n_originales, 2
    )
  ) |>
  select(
    fuente, comuna, estacion_sensor,
    n_originales, n_excluidos, n_procesados,
    porcentaje_conservado
  )

# Mostrar la tabla resumen de datos procesados
print(resumen_datos_procesados, width = Inf)

# Crear la carpeta para guardar la tabla
dir.create(
  "04_Tablas/03_Preparacion",
  recursive = TRUE,
  showWarnings = FALSE
)

# Guardar la tabla resumen de datos procesados
write_csv(
  resumen_datos_procesados,
  "04_Tablas/03_Preparacion/01_resumen_datos_procesados_sinca_sensores.csv"
)

# Comprobar la tabla guardada
list.files("04_Tablas/03_Preparacion")
