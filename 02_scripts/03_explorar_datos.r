

# 03. EXPLORACIÓN INICIAL DE LOS DATOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile


# 1. EXPLORAR LA ESTRUCTURA DE LOS DATOS

# Estaciones SINCA
glimpse(sinca_parque)
glimpse(sinca_cerro)
glimpse(sinca_puente)

# Sensores de bajo costo
glimpse(sensor_ch56)
glimpse(sensor_ch4)
glimpse(sensor_ch2)


# 2. REVISAR VALORES FALTANTES (NA)

# Estaciones SINCA
colSums(is.na(sinca_parque))
colSums(is.na(sinca_cerro))
colSums(is.na(sinca_puente))

# Sensores de bajo costo
colSums(is.na(sensor_ch56))
colSums(is.na(sensor_ch4))
colSums(is.na(sensor_ch2))


# 3. REVISAR LAS FECHAS DE LOS SENSORES

# Primeras fechas registradas
head(sensor_ch56$date)
head(sensor_ch4$date)
head(sensor_ch2$date)

# Últimas fechas registradas
tail(sensor_ch56$date)
tail(sensor_ch4$date)
tail(sensor_ch2$date)


# 4. REVISAR LAS FECHAS DE LAS ESTACIONES SINCA

# Primeras fechas registradas
head(sinca_parque$`FECHA (YYMMDD)`)
head(sinca_cerro$`FECHA (YYMMDD)`)
head(sinca_puente$`FECHA (YYMMDD)`)

# Últimas fechas registradas
tail(sinca_parque$`FECHA (YYMMDD)`)
tail(sinca_cerro$`FECHA (YYMMDD)`)
tail(sinca_puente$`FECHA (YYMMDD)`)


# 5. ESTADÍSTICAS DESCRIPTIVAS INICIALES

# Unificar las concentraciones originales sin modificar las bases.
datos_exploracion <- bind_rows(
  sinca_parque |>
    transmute(fuente = "SINCA", comuna = "Santiago",
              estacion_sensor = "Parque O'Higgins",
              mp25 = coalesce(`Registros validados`,
                              `Registros preliminares`,
                              `Registros no validados`)),
  sinca_cerro |>
    transmute(fuente = "SINCA", comuna = "Cerro Navia",
              estacion_sensor = "Cerro Navia",
              mp25 = coalesce(`Registros validados`,
                              `Registros preliminares`,
                              `Registros no validados`)),
  sinca_puente |>
    transmute(fuente = "SINCA", comuna = "Puente Alto",
              estacion_sensor = "Puente Alto",
              mp25 = coalesce(`Registros validados`,
                              `Registros preliminares`,
                              `Registros no validados`)),
  sensor_ch56 |>
    transmute(fuente = "Sensor calibrado", comuna = "Santiago",
              estacion_sensor = "CH56", mp25 = PM25_S2_calibrados),
  sensor_ch4 |>
    transmute(fuente = "Sensor calibrado", comuna = "Cerro Navia",
              estacion_sensor = "CH4", mp25 = PM25_P4_calibrados),
  sensor_ch2 |>
    transmute(fuente = "Sensor calibrado", comuna = "Puente Alto",
              estacion_sensor = "CH2", mp25 = PM25_P1_calibrados)
)

# Calcular estadísticas por fuente, comuna y estación o sensor.
# Los valores negativos y extremos se conservan en esta exploración.
estadisticas_iniciales <- datos_exploracion |>
  group_by(fuente, comuna, estacion_sensor) |>
  summarise(
    n_registros = n(),
    n_disponibles = sum(!is.na(mp25)),
    promedio = mean(mp25, na.rm = TRUE),
    mediana = median(mp25, na.rm = TRUE),
    desviacion = sd(mp25, na.rm = TRUE),
    minimo = min(mp25, na.rm = TRUE),
    maximo = max(mp25, na.rm = TRUE),
    .groups = "drop"
  )

print(estadisticas_iniciales, width = Inf)

# 6. GUARDAR LA TABLA DE ESTADÍSTICAS DESCRIPTIVAS

dir.create("04_tablas/01_exploracion", recursive = TRUE,
           showWarnings = FALSE)

write_csv(
  estadisticas_iniciales,
  "04_tablas/01_exploracion/01_estadisticas_iniciales_sinca_sensores.csv"
)
