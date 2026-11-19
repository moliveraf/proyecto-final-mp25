

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

# Explorar las concentraciones originales de MP2.5
# ignorando los NA durante los cálculos estadísticos,
# sin modificar las bases de datos originales.


# ESTACIONES SINCA

# Parque O'Higgins
sinca_parque |>
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    )
  ) |>
  summarise(
    promedio = mean(mp25, na.rm = TRUE),
    mediana = median(mp25, na.rm = TRUE),
    desviacion = sd(mp25, na.rm = TRUE),
    minimo = min(mp25, na.rm = TRUE),
    maximo = max(mp25, na.rm = TRUE)
  )

# Cerro Navia
sinca_cerro |>
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    )
  ) |>
  summarise(
    promedio = mean(mp25, na.rm = TRUE),
    mediana = median(mp25, na.rm = TRUE),
    desviacion = sd(mp25, na.rm = TRUE),
    minimo = min(mp25, na.rm = TRUE),
    maximo = max(mp25, na.rm = TRUE)
  )

# Puente Alto
sinca_puente |>
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    )
  ) |>
  summarise(
    promedio = mean(mp25, na.rm = TRUE),
    mediana = median(mp25, na.rm = TRUE),
    desviacion = sd(mp25, na.rm = TRUE),
    minimo = min(mp25, na.rm = TRUE),
    maximo = max(mp25, na.rm = TRUE)
  )


# SENSORES DE BAJO COSTO CALIBRADOS

# Sensor CH56 - Parque O'Higgins
sensor_ch56 |>
  summarise(
    promedio = mean(PM25_S2_calibrados, na.rm = TRUE),
    mediana = median(PM25_S2_calibrados, na.rm = TRUE),
    desviacion = sd(PM25_S2_calibrados, na.rm = TRUE),
    minimo = min(PM25_S2_calibrados, na.rm = TRUE),
    maximo = max(PM25_S2_calibrados, na.rm = TRUE)
  )

# Sensor CH4 - Cerro Navia
sensor_ch4 |>
  summarise(
    promedio = mean(PM25_P4_calibrados, na.rm = TRUE),
    mediana = median(PM25_P4_calibrados, na.rm = TRUE),
    desviacion = sd(PM25_P4_calibrados, na.rm = TRUE),
    minimo = min(PM25_P4_calibrados, na.rm = TRUE),
    maximo = max(PM25_P4_calibrados, na.rm = TRUE)
  )

# Sensor CH2 - Puente Alto
sensor_ch2 |>
  summarise(
    promedio = mean(PM25_P1_calibrados, na.rm = TRUE),
    mediana = median(PM25_P1_calibrados, na.rm = TRUE),
    desviacion = sd(PM25_P1_calibrados, na.rm = TRUE),
    minimo = min(PM25_P1_calibrados, na.rm = TRUE),
    maximo = max(PM25_P1_calibrados, na.rm = TRUE)
  )
