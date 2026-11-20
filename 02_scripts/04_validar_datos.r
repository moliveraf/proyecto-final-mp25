

# 04. DICCIONARIO Y VALIDACIÓN DE DATOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile
# Fuentes: SINCA y sensores de bajo costo calibrados

# Este script establece los criterios de validación,
# organiza las bases de datos e identifica valores
# faltantes, concentraciones atípicas y registros duplicados.
# Los datos originales no se modifican.
# Límite de detección del sensor: 1 µg/m³ (según especificación indicada).
# Se adopta 2 a 200 µg/m³ como intervalo de referencia para la revisión.
# Los negativos y faltantes se excluirán en el script 05.
# Los valores no negativos inferiores a 2 y los superiores a 200
# se conservan con alerta; el límite de detección corresponde al sensor.
# Pendiente respaldar el límite de detección con la ficha técnica.


# 1. CREAR EL DICCIONARIO DE DATOS

# Diccionario único elaborado con tribble(), según el ejercicio del curso.
# Se documentan las variables comunes a SINCA y sensores calibrados.
# Los NA de mp25 se identifican aquí y se excluyen en el script 05.
diccionario_manual_sinca_sensores <- tribble(
  ~variable, ~etiqueta, ~tipo, ~unidad, ~valores_validos, ~na_datos_originales,
  "fuente", "Fuente de medición", "categórica", NA_character_,
  "SINCA, Sensor de bajo costo", "No",
  "comuna", "Comuna de medición", "categórica", NA_character_,
  "Santiago, Cerro Navia, Puente Alto", "No",
  "mp25", "Concentración horaria de MP2.5", "numérica", "µg/m³",
  "No negativos; referencia de revisión 2 a 200 µg/m³; los valores fuera del intervalo requieren revisión, no exclusión automática; límite de detección declarado del sensor: 1 µg/m³ (pendiente de verificar)", "Sí",
  "fecha_hora", "Fecha y hora de medición", "fecha-hora", NA_character_,
  "2026-03-01 a 2026-09-30", "No"
)

print(diccionario_manual_sinca_sensores, width = Inf)

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


# ----------------------------------------------------------------------------

# 4. PREPARAR FECHAS Y CONCENTRACIONES - SENSOR CH56

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


# ----------------------------------------------------------------------------

# 5. PREPARAR FECHAS Y CONCENTRACIONES - SENSOR CH4

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


# ----------------------------------------------------------------------------

# 6. PREPARAR FECHAS Y CONCENTRACIONES - SENSOR CH2

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

# 7. UNIR LOS DATOS PARA LA VALIDACIÓN

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

# 8. COMPROBAR REGISTROS DUPLICADOS POR FECHA Y HORA

# Identificar fechas y horas repetidas dentro de
# cada fuente y comuna.
# Se excluyen las fechas faltantes de esta revisión.

revision_duplicados <- datos_validacion |>
  filter(!is.na(fecha_hora)) |>
  group_by(fuente, comuna) |>
  summarise(
    registros_duplicados = sum(duplicated(fecha_hora)),
    .groups = "drop"
  )

# Mostrar el número de registros duplicados
print(revision_duplicados, width = Inf)

# Identificar las fechas y horas que se repiten
registros_duplicados <- datos_validacion |>
  filter(!is.na(fecha_hora)) |>
  group_by(fuente, comuna, fecha_hora) |>
  filter(n() > 1) |>
  ungroup() |>
  arrange(fuente, comuna, fecha_hora)

# Mostrar los registros con fechas y horas repetidas
print(registros_duplicados, width = Inf)


# ----------------------------------------------------------------------------

# 9. CREAR FUNCIÓN DE VALIDACIÓN DE DATOS

validar_mp25 <- function(datos) {
  # Estructural: fuente y comuna válidas (NA no permitido)
  fuente_ok <- all(datos$fuente %in% c("SINCA", "Sensor de bajo costo"))
  comuna_ok <- all(datos$comuna %in% c("Santiago", "Cerro Navia", "Puente Alto"))

  # Contenido: intervalo de referencia (no es criterio de exclusión)
  mp25_ok <- all(datos$mp25 >= 2 & datos$mp25 <= 200, na.rm = TRUE)

  # Dominio: concentraciones no negativas
  dominio_ok <- all(datos$mp25 >= 0, na.rm = TRUE)

  # Contenido: periodo de estudio
  fecha_ok <- all(as.Date(datos$fecha_hora) >= as.Date("2026-03-01") &
                    as.Date(datos$fecha_hora) <= as.Date("2026-09-30"),
                  na.rm = TRUE)

  # Contenido: disponibilidad de concentración y fecha
  mp25_na_ok <- all(!is.na(datos$mp25))
  fecha_na_ok <- all(!is.na(datos$fecha_hora))

  marca <- function(x) ifelse(isTRUE(x), "OK", "FALLA")

  cat("Fuente válida (estructural): ", marca(fuente_ok), "\n")
  cat("Comuna válida (estructural): ", marca(comuna_ok), "\n")
  cat("MP2.5 entre 2 y 200 (contenido; revisión): ", marca(mp25_ok), "\n")
  cat("MP2.5 no negativo (dominio): ", marca(dominio_ok), "\n")
  cat("Periodo de estudio válido (contenido): ", marca(fecha_ok), "\n")
  cat("MP2.5 sin NA (contenido): ", marca(mp25_na_ok), "\n")
  cat("Fecha y hora sin NA (contenido): ", marca(fecha_na_ok), "\n")
}

cat("\n== Datos SINCA ==\n")
validar_mp25(datos_sinca)
cat("\n== Datos de sensores de bajo costo ==\n")
validar_mp25(datos_sensores)
cat("\n== Datos generales de SINCA y sensores ==\n")
validar_mp25(datos_validacion)


# ----------------------------------------------------------------------------

# 10. IDENTIFICAR REGISTROS QUE NO CUMPLEN LOS CRITERIOS

# Crear banderas de alerta siguiendo el ejemplo de la profesora
# Las categorías de concentración son mutuamente excluyentes.
datos_flags <- datos_validacion |>
  mutate(
    fila = row_number(),
    alerta_fuente = !(fuente %in% c("SINCA", "Sensor de bajo costo")),
    alerta_comuna = !(comuna %in% c("Santiago", "Cerro Navia", "Puente Alto")),
    alerta_na = is.na(mp25),
    alerta_fecha = is.na(fecha_hora),
    alerta_periodo = !is.na(fecha_hora) &
      (as.Date(fecha_hora) < as.Date("2026-03-01") |
       as.Date(fecha_hora) > as.Date("2026-09-30")),
    alerta_negativos = !is.na(mp25) & mp25 < 0,
    alerta_bajos = !is.na(mp25) & mp25 >= 0 & mp25 < 2,
    alerta_extremos = !is.na(mp25) & mp25 > 200,
    alerta_mp25 = alerta_negativos | alerta_bajos | alerta_extremos
  ) |>
  mutate(
    n_flags = alerta_fuente + alerta_comuna + alerta_na + alerta_fecha +
      alerta_periodo + alerta_negativos + alerta_bajos + alerta_extremos,
    motivos = pmap_chr(
      list(alerta_fuente, alerta_comuna, alerta_na, alerta_fecha,
           alerta_periodo, alerta_negativos, alerta_bajos, alerta_extremos),
      function(f, co, n, h, p, g, b, e) paste(
        c("Fuente inválida", "Comuna inválida", "MP2.5 faltante",
          "Fecha-hora faltante", "Fuera del periodo", "Concentración negativa",
          "Concentración no negativa inferior a 2", "Concentración superior a 200")[c(f, co, n, h, p, g, b, e)],
        collapse = ", "
      )
    )
  )

# Seleccionar los registros con al menos una alerta
filas_problematicas <- datos_flags |>
  filter(n_flags > 0) |>
  arrange(desc(n_flags)) |>
  select(fila, fuente, comuna, fecha_hora, mp25, n_flags, motivos)

cat("\nRegistros con al menos una alerta:", nrow(filas_problematicas), "\n")
print(filas_problematicas, width = Inf)

# Contar las observaciones por fuente y comuna
resumen_alertas <- datos_flags |>
  group_by(fuente, comuna) |>
  summarise(
    valores_na = sum(alerta_na),
    fechas_na = sum(alerta_fecha),
    negativos = sum(alerta_negativos),
    menores_2 = sum(alerta_bajos),
    mayores_200 = sum(alerta_extremos),
    fuentes_invalidas = sum(alerta_fuente),
    comunas_invalidas = sum(alerta_comuna),
    fechas_fuera_periodo = sum(alerta_periodo),
    total_alertas = sum(n_flags > 0),
    .groups = "drop"
  )

print(resumen_alertas, width = Inf)


# ----------------------------------------------------------------------------

# 11. IDENTIFICAR CONCENTRACIONES SUPERIORES A 200 µg/m3

concentraciones_superiores_200 <- datos_flags |>
  filter(mp25 > 200) |>
  select(fuente, comuna, fecha_hora, mp25)


print(concentraciones_superiores_200, width = Inf)

# ----------------------------------------------------------------------------

# 12. COMPROBAR REGISTROS DISPONIBLES ANTES DE LA LIMPIEZA

# Comprobación preliminar de concentración y fecha disponibles.
# La exclusión definitiva de faltantes y negativos se realiza en el script 05.
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


# ----------------------------------------------------------------------------
# 13. GUARDAR LAS TABLAS DE VALIDACIÓN

dir.create("04_tablas/02_validacion", recursive = TRUE,
           showWarnings = FALSE)

# Diccionario manual de SINCA y sensores
write_csv(diccionario_manual_sinca_sensores,
          "04_tablas/02_validacion/01_diccionario_datos_sinca_sensores.csv")

# Revisión de duplicados
write_csv(revision_duplicados,
          "04_tablas/02_validacion/02_revision_duplicados_sinca_sensores.csv")

# Resumen de alertas
write_csv(resumen_alertas,
          "04_tablas/02_validacion/03_resumen_alertas_sinca_sensores.csv")

# Concentraciones superiores a 200 µg/m³
write_csv(concentraciones_superiores_200,
          "04_tablas/02_validacion/04_concentraciones_superiores_200_sinca_sensores.csv")

# Reporte detallado de registros con alertas (para trazabilidad)
write_csv(filas_problematicas,
          "04_tablas/02_validacion/05_registros_con_alertas_sinca_sensores.csv")

# Comprobar las tablas guardadas
list.files("04_tablas/02_validacion")
