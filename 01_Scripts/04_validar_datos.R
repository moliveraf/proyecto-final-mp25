
# 04. DICCIONARIO Y VALIDACIÓN DE DATOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile
# Fuentes: SINCA y sensores de bajo costo calibrados

# 1. CREAR EL DICCIONARIO DE DATOS

diccionario <- tribble(
  ~variable, ~tipo, ~valores_esperados, ~NA_permitido,

  "fuente", "Categórica",
  "SINCA, Sensor de bajo costo", "No",

  "comuna", "Categórica",
  "Santiago, Cerro Navia, Puente Alto", "No",

  "mp25", "Numérica",
  "µg/m³; revisar valores <2 o >200", "No",

  "fecha_hora", "Fecha-hora",
  "Marzo a septiembre de 2026", "No"
)

# Mostrar el diccionario
diccionario
# ----------------------------------------------------------------------------

# 2. ORGANIZAR LOS DATOS PARA LA VALIDACIÓN

# Parque O'Higgins
sinca_parque_validacion <- sinca_parque |>
  mutate(
    fuente = "SINCA",
    comuna = "Santiago",
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    ),
    fecha_hora = ymd_hm(
      paste(`FECHA (YYMMDD)`, `HORA (HHMM)`)
    )
  )

# Cerro Navia
sinca_cerro_validacion <- sinca_cerro |>
  mutate(
    fuente = "SINCA",
    comuna = "Cerro Navia",
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    ),
    fecha_hora = ymd_hm(
      paste(`FECHA (YYMMDD)`, `HORA (HHMM)`)
    )
  )

# Puente Alto
sinca_puente_validacion <- sinca_puente |>
  mutate(
    fuente = "SINCA",
    comuna = "Puente Alto",
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    ),
    fecha_hora = ymd_hm(
      paste(`FECHA (YYMMDD)`, `HORA (HHMM)`)
    )
  )

# Unir las tres estaciones SINCA
datos_sinca <- bind_rows(
  sinca_parque_validacion,
  sinca_cerro_validacion,
  sinca_puente_validacion
)

# Comprobar registros por comuna
datos_sinca |>
  count(comuna)

# ----------------------------------------------------------------------------

# 3. REVISAR LA ESTRUCTURA ORIGINAL DE LOS SENSORES

# Sensor CH56 - Parque O'Higgins
names(sensor_ch56)
head(sensor_ch56$date)

# Sensor CH4 - Cerro Navia
names(sensor_ch4)
head(sensor_ch4$date)

# Sensor CH2 - Puente Alto
names(sensor_ch2)
head(sensor_ch2$date)

# 4. REVISAR NOMBRES DE VARIABLES Y FORMATO DE FECHAS - SENSORES

# Sensor CH56 - Parque O'Higgins
names(sensor_ch56)
head(sensor_ch56$date)

# Sensor CH4 - Cerro Navia
names(sensor_ch4)
head(sensor_ch4$date)

# Sensor CH2 - Puente Alto
names(sensor_ch2)
head(sensor_ch2$date)

# 5. PREPARAR FECHAS Y CONCENTRACIONES - SENSOR CH56

sensor_ch56_validacion <- sensor_ch56 |>
  mutate(
    fuente = "Sensor de bajo costo",
    comuna = "Santiago",
    mp25 = PM25_S2_calibrados,
    fecha_hora = dmy_hm(date, quiet = TRUE)
  )

# Comprobar las primeras fechas
head(sensor_ch56_validacion$fecha_hora)

# Contar fechas sin hora identificable
sum(is.na(sensor_ch56_validacion$fecha_hora))

# 6. PREPARAR FECHAS Y CONCENTRACIONES - SENSOR CH4

sensor_ch4_validacion <- sensor_ch4 |>
  mutate(
    fuente = "Sensor de bajo costo",
    comuna = "Cerro Navia",
    mp25 = PM25_P4_calibrados,
    fecha_hora = dmy_hm(date, quiet = TRUE)
  )

# Comprobar las primeras fechas
head(sensor_ch4_validacion$fecha_hora)

# Contar fechas sin hora identificable
sum(is.na(sensor_ch4_validacion$fecha_hora))


# 7. PREPARAR FECHAS Y CONCENTRACIONES - SENSOR CH2

sensor_ch2_validacion <- sensor_ch2 |>
  mutate(
    fuente = "Sensor de bajo costo",
    comuna = "Puente Alto",
    mp25 = PM25_P1_calibrados,
    fecha_hora = date
  )

# Comprobar las primeras fechas
head(sensor_ch2_validacion$fecha_hora)

# Contar fechas sin hora identificable
sum(is.na(sensor_ch2_validacion$fecha_hora))

# ----------------------------------------------------------------------------

# 8. UNIR LOS DATOS PARA LA VALIDACIÓN

# Unir los tres sensores de bajo costo
datos_sensores <- bind_rows(
  sensor_ch56_validacion |>
    select(fuente, comuna, mp25, fecha_hora),

  sensor_ch4_validacion |>
    select(fuente, comuna, mp25, fecha_hora),

  sensor_ch2_validacion |>
    select(fuente, comuna, mp25, fecha_hora)
)

# Unir SINCA y sensores
datos_validacion <- bind_rows(
  datos_sinca |>
    select(fuente, comuna, mp25, fecha_hora),

  datos_sensores
)

# Comprobar los registros por fuente y comuna
datos_validacion |>
  count(fuente, comuna)
# ----------------------------------------------------------------------------

# 9. CREAR FUNCIÓN DE VALIDACIÓN DE DATOS

validar_mp25 <- function(datos) {

  # Estructural: fuentes permitidas (sin NA)
  fuente_ok <- all(
    !is.na(datos$fuente) &
      datos$fuente %in% c("SINCA", "Sensor de bajo costo")
  )

  # Estructural: comunas permitidas (sin NA)
  comuna_ok <- all(
    !is.na(datos$comuna) &
      datos$comuna %in% c(
        "Santiago", "Cerro Navia", "Puente Alto"
      )
  )

  # Contenido: concentraciones entre 2 y 200 µg/m3
  # No se permiten valores NA
  mp25_ok <- all(
    !is.na(datos$mp25) &
      datos$mp25 >= 2 & datos$mp25 <= 200
  )

  # Contenido: fechas dentro del periodo estudiado
  # No se permiten valores NA
  fecha_ok <- all(
    !is.na(datos$fecha_hora) &
      as.Date(datos$fecha_hora) >= as.Date("2026-03-01") &
      as.Date(datos$fecha_hora) <= as.Date("2026-09-30")
  )

  # Mostrar resultados
  marca <- function(x) ifelse(isTRUE(x), "OK", "FALLA")

  cat("Fuente valida (estructural): ",
      marca(fuente_ok), "\n")

  cat("Comuna valida (estructural): ",
      marca(comuna_ok), "\n")

  cat("MP2.5 entre 2 y 200, sin NA (contenido): ",
      marca(mp25_ok), "\n")

  cat("Fecha valida (contenido): ",
      marca(fecha_ok), "\n")
}

# 10. IDENTIFICAR REGISTROS QUE NO CUMPLEN LOS CRITERIOS

datos_flags <- datos_validacion |>
  mutate(
    alerta_na = is.na(mp25),
    alerta_fecha = is.na(fecha_hora),
    alerta_mp25 = !is.na(mp25) &
      (mp25 < 2 | mp25 > 200)
  )

# Contar las observaciones por fuente y comuna
datos_flags |>
  group_by(fuente, comuna) |>
  summarise(
    valores_na = sum(alerta_na),
    fechas_na = sum(alerta_fecha),
    menores_2 = sum(mp25 < 2, na.rm = TRUE),
    mayores_200 = sum(mp25 > 200, na.rm = TRUE),
    total_alertas = sum(
      alerta_na | alerta_fecha | alerta_mp25
    ),
    .groups = "drop"
  )
# ----------------------------------------------------------------------------

# 11. IDENTIFICAR CONCENTRACIONES SUPERIORES A 200 µg/m3

datos_flags |>
  filter(mp25 > 200) |>
  select(fuente, comuna, fecha_hora, mp25)

# ----------------------------------------------------------------------------

# 12. SELECCIONAR REGISTROS PARA EL ANÁLISIS

# Seleccionar registros con concentración y fecha disponibles
datos_analisis <- datos_flags |>
  filter(
    !is.na(mp25),
    !is.na(fecha_hora)
  )

# Comprobar registros disponibles por fuente y comuna
datos_analisis |>
  group_by(fuente, comuna) |>
  summarise(
    n_registros = n(),
    .groups = "drop"
  )
