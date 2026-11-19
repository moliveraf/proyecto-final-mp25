# 06. INTEGRAR MEDICIONES SINCA Y SENSORES
# Proyecto final: Análisis de MP2.5 en Santiago de Chile
# Ejecutar previamente los scripts 01 al 05.
# Integrar por comuna, fecha y hora e identificar estación y sensor.
# Se presupone una referencia horaria común entre ambas fuentes.

# 1. DEFINIR LA FUNCIÓN DE INTEGRACIÓN
integrar_mediciones <- function(sinca, sensor, comuna, estacion, codigo_sensor) {
  # Evitar multiplicar registros por fechas y horas duplicadas
  stopifnot(!anyNA(sinca$fecha_hora), !anyNA(sensor$fecha_hora),
            !anyDuplicated(sinca$fecha_hora),
            !anyDuplicated(sensor$fecha_hora))
  sinca |>
    select(fecha_hora, mp25_sinca = mp25) |>
    inner_join(
      sensor |> select(fecha_hora, mp25_sensor = mp25),
      by = "fecha_hora"
    ) |>
    mutate(comuna = comuna, estacion_sinca = estacion,
           sensor = codigo_sensor) |>
    arrange(fecha_hora)
}

# 2. INTEGRAR LAS MEDICIONES POR COMUNA
comparacion_parque <- integrar_mediciones(
  sinca_parque_procesado, sensor_ch56_procesado,
  "Santiago", "Parque O'Higgins", "CH56"
)
comparacion_cerro <- integrar_mediciones(
  sinca_cerro_procesado, sensor_ch4_procesado,
  "Cerro Navia", "Cerro Navia", "CH4"
)
comparacion_puente <- integrar_mediciones(
  sinca_puente_procesado, sensor_ch2_procesado,
  "Puente Alto", "Puente Alto", "CH2"
)

# 3. REUNIR LAS TRES COMUNAS
comparacion_mp25 <- bind_rows(
  comparacion_parque, comparacion_cerro, comparacion_puente
) |> arrange(comuna, fecha_hora)

stopifnot(!anyNA(comparacion_mp25),
          all(comparacion_mp25$mp25_sinca >= 0),
          all(comparacion_mp25$mp25_sensor >= 0),
          !anyDuplicated(comparacion_mp25[c("comuna", "fecha_hora")]))
print(head(comparacion_mp25))

# 4. RESUMIR LA DISPONIBILIDAD DE MEDICIONES COINCIDENTES
# Cada fila integrada representa un par de mediciones.
resumen_mediciones_coincidentes <- comparacion_mp25 |>
  group_by(comuna, estacion_sinca, sensor) |>
  summarise(n_pares_coincidentes = n(),
            primera_fecha_hora = min(fecha_hora),
            ultima_fecha_hora = max(fecha_hora), .groups = "drop")
print(resumen_mediciones_coincidentes, width = Inf)

# 5. GUARDAR LAS BASES INTEGRADAS Y LA TABLA RESUMEN
# Mantener las rutas anteriores para facilitar los análisis posteriores.
carpeta_comparacion <- "00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores"
dir.create(carpeta_comparacion, recursive = TRUE, showWarnings = FALSE)
write_csv(comparacion_parque, file.path(carpeta_comparacion, "Comparacion_Parque_OHiggins.csv"))
write_csv(comparacion_cerro, file.path(carpeta_comparacion, "Comparacion_Cerro_Navia.csv"))
write_csv(comparacion_puente, file.path(carpeta_comparacion, "Comparacion_Puente_Alto.csv"))
write_csv(comparacion_mp25, file.path(carpeta_comparacion, "Comparacion_MP25_General.csv"))

carpeta_tablas <- "04_Tablas/04_Integracion"
dir.create(carpeta_tablas, recursive = TRUE, showWarnings = FALSE)
write_csv(resumen_mediciones_coincidentes,
          file.path(carpeta_tablas, "01_mediciones_coincidentes_sinca_sensores.csv"))

# Comprobar los archivos guardados
print(list.files(carpeta_comparacion))
print(list.files(carpeta_tablas))
