

# 06. COMPARAR SINCA Y SENSORES DE BAJO COSTO
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# 1. REVISAR PERIODOS DE MEDICION

# Estaciones SINCA

# Parque O'Higgins
range(sinca_parque_procesado$fecha_hora)

# Cerro Navia
range(sinca_cerro_procesado$fecha_hora)

# Puente Alto
range(sinca_puente_procesado$fecha_hora)


# Sensores de bajo costo

# Sensor CH56 - Parque O'Higgins
range(sensor_ch56_procesado$fecha_hora)

# Sensor CH4 - Cerro Navia
range(sensor_ch4_procesado$fecha_hora)

# Sensor CH2 - Puente Alto
range(sensor_ch2_procesado$fecha_hora)

# ----------------------------------------------------------------------------

# 2. UNIR DATOS DE SINCA Y SENSOR CH56 - PARQUE O'HIGGINS

# Identificar las concentraciones de cada fuente
sinca_parque_comp <- sinca_parque_procesado |>
  rename(mp25_sinca = mp25)

sensor_ch56_comp <- sensor_ch56_procesado |>
  rename(mp25_sensor = mp25)

# Unir las bases por fecha y hora
comparacion_parque <- full_join(
  sinca_parque_comp,
  sensor_ch56_comp,
  by = "fecha_hora"
)

# Seleccionar las observaciones coincidentes
comparacion_parque <- comparacion_parque |>
  filter(
    !is.na(mp25_sinca),
    !is.na(mp25_sensor)
  )

# Comprobar las primeras observaciones
head(comparacion_parque)

# Contar las observaciones coincidentes
nrow(comparacion_parque)
# ----------------------------------------------------------------------------

# 3. UNIR DATOS DE SINCA Y SENSOR CH4 - CERRO NAVIA

# Identificar las concentraciones de cada fuente
sinca_cerro_comp <- sinca_cerro_procesado |>
  rename(mp25_sinca = mp25)

sensor_ch4_comp <- sensor_ch4_procesado |>
  rename(mp25_sensor = mp25)

# Unir las bases por fecha y hora
comparacion_cerro <- full_join(
  sinca_cerro_comp,
  sensor_ch4_comp,
  by = "fecha_hora"
)

# Seleccionar las observaciones coincidentes
comparacion_cerro <- comparacion_cerro |>
  filter(
    !is.na(mp25_sinca),
    !is.na(mp25_sensor)
  )

# Comprobar las primeras observaciones
head(comparacion_cerro)

# Contar las observaciones coincidentes
nrow(comparacion_cerro)

# ----------------------------------------------------------------------------

# 4. UNIR DATOS DE SINCA Y SENSOR CH2 - PUENTE ALTO

# Identificar las concentraciones de cada fuente
sinca_puente_comp <- sinca_puente_procesado |>
  rename(mp25_sinca = mp25)

sensor_ch2_comp <- sensor_ch2_procesado |>
  rename(mp25_sensor = mp25)

# Unir las bases por fecha y hora
comparacion_puente <- full_join(
  sinca_puente_comp,
  sensor_ch2_comp,
  by = "fecha_hora"
)

# Seleccionar las observaciones coincidentes
comparacion_puente <- comparacion_puente |>
  filter(
    !is.na(mp25_sinca),
    !is.na(mp25_sensor)
  )

# Comprobar las primeras observaciones
head(comparacion_puente)

# Contar las observaciones coincidentes
nrow(comparacion_puente)

# ----------------------------------------------------------------------------

# 5. UNIR LAS TRES COMPARACIONES DE SINCA Y SENSORES

# Identificar cada zona de estudio
comparacion_parque <- comparacion_parque |>
  mutate(comuna = "Santiago")

comparacion_cerro <- comparacion_cerro |>
  mutate(comuna = "Cerro Navia")

comparacion_puente <- comparacion_puente |>
  mutate(comuna = "Puente Alto")

# Reunir las tres comparaciones
comparacion_mp25 <- bind_rows(
  comparacion_parque,
  comparacion_cerro,
  comparacion_puente
)

# Comprobar los registros por comuna
comparacion_mp25 |>
  group_by(comuna) |>
  summarise(
    n_registros = n(),
    .groups = "drop"
  )

# Comprobar las primeras observaciones
head(comparacion_mp25)

# ----------------------------------------------------------------------------

# 6. CALCULAR ESTADISTICAS DESCRIPTIVAS POR COMUNA

# Comparar las concentraciones de SINCA y sensores
resumen_comparacion <- comparacion_mp25 |>
  group_by(comuna) |>
  summarise(
    n_registros = n(),
    promedio_sinca = mean(mp25_sinca),
    promedio_sensor = mean(mp25_sensor),
    mediana_sinca = median(mp25_sinca),
    mediana_sensor = median(mp25_sensor),
    .groups = "drop"
  )

# Mostrar los resultados
resumen_comparacion

# ----------------------------------------------------------------------------
# 7. GUARDAR COMPARACIONES DE SINCA Y SENSORES

# Parque O'Higgins
write_csv(
  comparacion_parque,
  "00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores/Comparacion_Parque_OHiggins.csv"
)

# Cerro Navia
write_csv(
  comparacion_cerro,
  "00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores/Comparacion_Cerro_Navia.csv"
)

# Puente Alto
write_csv(
  comparacion_puente,
  "00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores/Comparacion_Puente_Alto.csv"
)

# Comparación general
write_csv(
  comparacion_mp25,
  "00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores/Comparacion_MP25_General.csv"
)

# Comprobar los archivos guardados
list.files(
  "00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores"
)

