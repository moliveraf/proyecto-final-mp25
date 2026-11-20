

# 05. DEPURAR DATOS DE SINCA Y SENSORES
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# Este script prepara los datos de SINCA y de los
# sensores de bajo costo calibrados para el análisis.
# Se excluyen mediante na.omit() los registros con
# concentraciones faltantes de MP2.5 y aquellos
# sin fecha u hora identificable (NA).
# Se excluyen también las concentraciones negativas.
# Límite de detección informado del sensor: 1 µg/m³.
# Intervalo de referencia: 2 a 200 µg/m³.
# Se conservan los valores no negativos inferiores a 2
# y los superiores a 200, con sus alertas del script 04.
# Los archivos originales no se modifican.


# 1. SELECCIONAR REGISTROS DISPONIBLES PARA EL ANÁLISIS

# Seleccionar las variables de interés
# y excluir los registros con valores faltantes
datos_procesados <- datos_flags |>
  filter(!alerta_negativos, !alerta_fuente, !alerta_comuna,
         !alerta_periodo) |>
  select(fuente, comuna, fecha_hora, mp25,
         alerta_bajos, alerta_extremos) |>
  na.omit()

# Agrupar y anidar las bases por fuente y comuna
datos_procesados_agrupados <- datos_procesados |>
  group_by(fuente, comuna) |>
  nest() |>
  ungroup()

print(datos_procesados_agrupados)

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
# 4. COMPROBAR LAS SEIS BASES MEDIANTE NEST Y MAP

# Función que resume los criterios de depuración de cada base
comprobar_datos_procesados <- function(datos) {
  datos |>
    summarise(
      n_registros = n(),
      valores_na = sum(is.na(mp25)),
      fechas_na = sum(is.na(fecha_hora)),
      negativos = sum(mp25 < 0, na.rm = TRUE),
      menores_2 = sum(alerta_bajos, na.rm = TRUE),
      mayores_200 = sum(alerta_extremos, na.rm = TRUE),
      duplicados = sum(duplicated(fecha_hora))
    )
}

# Aplicar la misma función a cada tabla anidada
comprobacion_datos_procesados <- datos_procesados_agrupados |>
  mutate(comprobacion = map(data, comprobar_datos_procesados)) |>
  select(fuente, comuna, comprobacion) |>
  unnest(comprobacion)

print(comprobacion_datos_procesados, width = Inf)

# Verificar los criterios obligatorios de depuración
stopifnot(
  nrow(comprobacion_datos_procesados) == 6L,
  all(comprobacion_datos_procesados$valores_na == 0),
  all(comprobacion_datos_procesados$fechas_na == 0),
  all(comprobacion_datos_procesados$negativos == 0)
)

# Los duplicados se notifican sin eliminarlos automáticamente.
if (any(comprobacion_datos_procesados$duplicados > 0)) {
  warning("Revisar fechas duplicadas antes de integrar las mediciones.")
}

# ----------------------------------------------------------------------------
# 5. CREAR CARPETAS PARA LOS DATOS PROCESADOS

# Carpeta SINCA
dir.create(
  "00_Datos/02_Datos_procesados/01_SINCA",
  recursive = TRUE,
  showWarnings = FALSE
)

# Carpeta de sensores
dir.create(
  "00_Datos/02_Datos_procesados/02_Sensores_bajo_costo",
  recursive = TRUE,
  showWarnings = FALSE
)

# ----------------------------------------------------------------------------
# 6. GUARDAR BASES DE DATOS PROCESADAS

# Estaciones SINCA

write_csv(
  sinca_parque_procesado,
  "00_Datos/02_Datos_procesados/01_SINCA/02_SINCA_Parque_OHiggins.csv"
)

write_csv(
  sinca_cerro_procesado,
  "00_Datos/02_Datos_procesados/01_SINCA/01_SINCA_Cerro_Navia.csv"
)

write_csv(
  sinca_puente_procesado,
  "00_Datos/02_Datos_procesados/01_SINCA/03_SINCA_Puente_Alto.csv"
)

# Sensores de bajo costo

write_csv(
  sensor_ch56_procesado,
  "00_Datos/02_Datos_procesados/02_Sensores_bajo_costo/02_Sensor_CH56.csv"
)

write_csv(
  sensor_ch4_procesado,
  "00_Datos/02_Datos_procesados/02_Sensores_bajo_costo/01_Sensor_CH4.csv"
)

write_csv(
  sensor_ch2_procesado,
  "00_Datos/02_Datos_procesados/02_Sensores_bajo_costo/03_Sensor_CH2.csv"
)

# ----------------------------------------------------------------------------

# 7. VERIFICAR LOS ARCHIVOS GUARDADOS

# Comprobar los archivos de SINCA
list.files("00_Datos/02_Datos_procesados/01_SINCA")

# Comprobar los archivos de los sensores
list.files("00_Datos/02_Datos_procesados/02_Sensores_bajo_costo")

# ----------------------------------------------------------------------------
# 8. VERIFICAR LOS DATOS PROCESADOS

# Leer el archivo procesado del sensor CH56
verificacion <- read_csv(
  "00_Datos/02_Datos_procesados/02_Sensores_bajo_costo/02_Sensor_CH56.csv",
  show_col_types = FALSE
)

# Comprobar las dimensiones
dim(verificacion)

# Comprobar los valores faltantes de MP2.5
sum(is.na(verificacion$mp25))

# Comprobar las fechas y horas faltantes
sum(is.na(verificacion$fecha_hora))

# ----------------------------------------------------------------------------
# 9. RESUMEN DE DATOS PROCESADOS DE SINCA Y SENSORES

# Contar los registros originales por fuente y comuna
registros_originales <- datos_validacion |>
  count(fuente, comuna, name = "n_originales")

# Contar los registros después de la limpieza
registros_procesados <- comprobacion_datos_procesados |>
  select(fuente, comuna, n_procesados = n_registros, menores_2, mayores_200)

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
    porcentaje_conservado, menores_2, mayores_200
  )

# Mostrar la tabla resumen de datos procesados
print(resumen_datos_procesados, width = Inf)

# Crear la carpeta para guardar la tabla
dir.create(
  "03_Tablas/03_Depuracion",
  recursive = TRUE,
  showWarnings = FALSE
)

# Guardar la tabla resumen de datos procesados
write_csv(
  resumen_datos_procesados,
  "03_Tablas/03_Depuracion/01_resumen_datos_procesados_sinca_sensores.csv"
)

# Comprobar la tabla guardada
list.files("03_Tablas/03_Depuracion")
