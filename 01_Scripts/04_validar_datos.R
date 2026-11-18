
# 04. VALIDACIÓN DE DATOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# 1. DEFINIR CRITERIOS DE VALIDACIÓN

# Se revisarán las fechas, los valores faltantes
# y las concentraciones de MP2.5.

# Los valores fuera del rango operativo
# se identificarán para revisión, sin eliminarlos.

# 2. PREPARAR LAS CONCENTRACIONES DE MP2.5 - SINCA

# Parque O'Higgins
sinca_parque <- sinca_parque |>
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    )
  )

# Revisar las primeras observaciones
head(sinca_parque$mp25)

# Cerro Navia
sinca_cerro <- sinca_cerro |>
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    )
  )

# Revisar las primeras observaciones
head(sinca_cerro$mp25)

# Puente Alto
sinca_puente <- sinca_puente |>
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    )
  )

# Revisar las primeras observaciones
head(sinca_puente$mp25)
----------------------------------------------------------------------------

  # 3. PREPARAR FECHAS Y HORAS DE SINCA

  # Parque O'Higgins
  sinca_parque <- sinca_parque |>
  mutate(
    fecha_hora = ymd_hm(
      paste(`FECHA (YYMMDD)`, `HORA (HHMM)`)
    )
  )

# Revisar las primeras fechas
head(sinca_parque$fecha_hora)

# Cerro Navia
sinca_cerro <- sinca_cerro |>
  mutate(
    fecha_hora = ymd_hm(
      paste(`FECHA (YYMMDD)`, `HORA (HHMM)`)
    )
  )

# Puente Alto
sinca_puente <- sinca_puente |>
  mutate(
    fecha_hora = ymd_hm(
      paste(`FECHA (YYMMDD)`, `HORA (HHMM)`)
    )
  )

# Comprobar las fechas
head(sinca_cerro$fecha_hora)
head(sinca_puente$fecha_hora)

# 4. REVISAR VALORES FALTANTES DE MP2.5 - SINCA

sum(is.na(sinca_parque$mp25))
sum(is.na(sinca_cerro$mp25))
sum(is.na(sinca_puente$mp25))

# 5. IDENTIFICAR CONCENTRACIONES FUERA DEL INTERVALO DE REFERENCIA

# Se utiliza un intervalo exploratorio de 2 a 200 µg/m³.
# Los valores fuera de este intervalo se identifican
# para su revisión, sin eliminarlos.

# Parque O'Higgins
sum(
  sinca_parque$mp25 < 2 | sinca_parque$mp25 > 200,
  na.rm = TRUE
)

# Cerro Navia
sum(
  sinca_cerro$mp25 < 2 | sinca_cerro$mp25 > 200,
  na.rm = TRUE
)

# Puente Alto
sum(
  sinca_puente$mp25 < 2 | sinca_puente$mp25 > 200,
  na.rm = TRUE
)

# 6. DIFERENCIAR CONCENTRACIONES BAJAS Y ALTAS

# Parque O'Higgins
sum(sinca_parque$mp25 < 2, na.rm = TRUE)
sum(sinca_parque$mp25 > 200, na.rm = TRUE)

# Cerro Navia
sum(sinca_cerro$mp25 < 2, na.rm = TRUE)
sum(sinca_cerro$mp25 > 200, na.rm = TRUE)

# Puente Alto
sum(sinca_puente$mp25 < 2, na.rm = TRUE)
sum(sinca_puente$mp25 > 200, na.rm = TRUE)

# 7. REVISAR CONCENTRACIONES SUPERIORES A 200 µg/m³- SINCA

# Identificar la observación de Cerro Navia
sinca_cerro |>
  filter(mp25 > 200) |>
  select(fecha_hora, mp25,
         `Registros validados`,
         `Registros preliminares`)
----------------------------------------------------------------------

# 8. REVISAR CONCENTRACIONES CALIBRADAS DE LOS SENSORES

# Sensor CH56 - Parque O'Higgins
  head(sensor_ch56$PM25_S2_calibrados)

# Sensor CH4 - Cerro Navia
head(sensor_ch4$PM25_P4_calibrados)

# Sensor CH2 - Puente Alto
head(sensor_ch2$PM25_P1_calibrados)

# 9. REVISAR VALORES FALTANTES DE MP2.5 - SENSORES

# Sensor CH56 - Parque O'Higgins
sum(is.na(sensor_ch56$PM25_S2_calibrados))

# Sensor CH4 - Cerro Navia
sum(is.na(sensor_ch4$PM25_P4_calibrados))

# Sensor CH2 - Puente Alto
sum(is.na(sensor_ch2$PM25_P1_calibrados))

# 10. PREPARAR FECHAS Y HORAS DE LOS SENSORES

# Sensor CH56 - Parque O'Higgins
sensor_ch56 <- sensor_ch56 |>
  mutate(
    fecha_hora = dmy_hm(date)
  )

# Revisar las primeras fechas
head(sensor_ch56$fecha_hora)

# Sensor CH4 - Cerro Navia
sensor_ch4 <- sensor_ch4 |>
  mutate(
    fecha_hora = dmy_hm(date)
  )

# Revisar las primeras fechas
head(sensor_ch4$fecha_hora)

# Sensor CH2 - Puente Alto

sensor_ch2 <- sensor_ch2 |>
  mutate(
    fecha_hora = date
  )

# Revisar las primeras fechas
head(sensor_ch2$fecha_hora)

# 11. REVISAR CONCENTRACIONES FUERA DEL INTERVALO DE REFERENCIA - SENSORES

# Intervalo exploratorio: 2 a 200 µg/m³
# Se identifican observaciones para revisión, sin eliminarlas.

# Sensor CH56 - Parque O'Higgins
sum(
  sensor_ch56$PM25_S2_calibrados < 2 |
    sensor_ch56$PM25_S2_calibrados > 200,
  na.rm = TRUE
)

# Sensor CH4 - Cerro Navia
sum(
  sensor_ch4$PM25_P4_calibrados < 2 |
    sensor_ch4$PM25_P4_calibrados > 200,
  na.rm = TRUE
)

# Sensor CH2 - Puente Alto
sum(
  sensor_ch2$PM25_P1_calibrados < 2 |
    sensor_ch2$PM25_P1_calibrados > 200,
  na.rm = TRUE
)

# 12. DIFERENCIAR CONCENTRACIONES BAJAS Y ALTAS - SENSORES

# Sensor CH56 - Parque O'Higgins
sum(sensor_ch56$PM25_S2_calibrados < 2, na.rm = TRUE)
sum(sensor_ch56$PM25_S2_calibrados > 200, na.rm = TRUE)

# Sensor CH4 - Cerro Navia
sum(sensor_ch4$PM25_P4_calibrados < 2, na.rm = TRUE)
sum(sensor_ch4$PM25_P4_calibrados > 200, na.rm = TRUE)

# Sensor CH2 - Puente Alto
sum(sensor_ch2$PM25_P1_calibrados < 2, na.rm = TRUE)
sum(sensor_ch2$PM25_P1_calibrados > 200, na.rm = TRUE)

# 13. REVISAR CONCENTRACIONES SUPERIORES A 200 µg/m³ - SENSORES

# Identificar las observaciones del sensor CH56 - Parque O'Higgins
sensor_ch56 |>
  filter(PM25_S2_calibrados > 200) |>
  select(fecha_hora, PM25_S2_calibrados)
-----------------------------------------------------------------------
# 14. REVISAR ZONAS HORARIAS DE SINCA Y SENSORES

# Estaciones SINCA
tz(sinca_parque$fecha_hora)
tz(sinca_cerro$fecha_hora)
tz(sinca_puente$fecha_hora)

# Sensores de bajo costo
tz(sensor_ch56$fecha_hora)
tz(sensor_ch4$fecha_hora)
tz(sensor_ch2$fecha_hora)

# 15. COMPARAR FECHAS ORIGINALES DE SINCA Y SENSORES

# SINCA - Parque O'Higgins
head(sinca_parque$`FECHA (YYMMDD)`)
head(sinca_parque$`HORA (HHMM)`)

# Sensor CH56 - Parque O'Higgins
head(sensor_ch56$date)

# 16. REVISAR PERIODOS DE MEDICION DE SINCA Y SENSORES

# Estaciones SINCA
range(sinca_parque$fecha_hora, na.rm = TRUE)
range(sinca_cerro$fecha_hora, na.rm = TRUE)
range(sinca_puente$fecha_hora, na.rm = TRUE)

# Sensores de bajo costo
range(sensor_ch56$fecha_hora, na.rm = TRUE)
range(sensor_ch4$fecha_hora, na.rm = TRUE)
range(sensor_ch2$fecha_hora, na.rm = TRUE)

# 17. REVISAR FECHAS Y HORAS DUPLICADAS EN LOS SENSORES

# Sensor CH56 - Parque O'Higgins
sum(duplicated(sensor_ch56$fecha_hora))

# Sensor CH4 - Cerro Navia
sum(duplicated(sensor_ch4$fecha_hora))

# Sensor CH2 - Puente Alto
sum(duplicated(sensor_ch2$fecha_hora))

# 18. REVISAR OBSERVACIONES CON FECHAS DUPLICADAS - SENSORES

# Sensor CH56 - Parque O'Higgins
sensor_ch56 |>
  filter(
    duplicated(fecha_hora) |
      duplicated(fecha_hora, fromLast = TRUE)
  ) |>
  select(fecha_hora, PM25_S2_calibrados) |>
  head(10)

# 19. REVISAR FECHAS FALTANTES EN LOS SENSORES

# Sensor CH56 - Parque O'Higgins
sum(is.na(sensor_ch56$fecha_hora))

# Sensor CH4 - Cerro Navia
sum(is.na(sensor_ch4$fecha_hora))

# Sensor CH2 - Puente Alto
sum(is.na(sensor_ch2$fecha_hora))

# 20. REVISAR FECHAS ORIGINALES NO CONVERTIDAS - SENSORES

# Sensor CH56 - Parque O'Higgins
sensor_ch56 |>
  filter(is.na(fecha_hora)) |>
  select(date, PM25_S2_calibrados) |>
  head(10)

# 21. REVISAR FORMATO DE FECHAS NO CONVERTIDAS - SENSOR CH56

# Mostrar las últimas fechas que no se convirtieron
sensor_ch56 |>
  filter(is.na(fecha_hora)) |>
  select(date, PM25_S2_calibrados) |>
  tail(10)

# 22. REVISAR FECHAS ORIGINALES NO CONVERTIDAS - SENSOR CH4

# Mostrar las primeras fechas que no se convirtieron
sensor_ch4 |>
  filter(is.na(fecha_hora)) |>
  select(date, PM25_P4_calibrados) |>
  head(10)

# Mostrar las últimas fechas que no se convirtieron
sensor_ch4 |>
  filter(is.na(fecha_hora)) |>
  select(date, PM25_P4_calibrados) |>
  tail(10)

# 23. REVISAR REGISTROS SIN HORA EN LOS SENSORES

# Sensor CH56 - Parque O'Higgins
sum(nchar(sensor_ch56$date) == 10, na.rm = TRUE)

# Sensor CH4 - Cerro Navia
sum(nchar(sensor_ch4$date) == 10, na.rm = TRUE)

# 24. REVISAR REGISTROS HORARIOS Y SIN HORA - SENSOR CH56

# Examinar los registros del 17 de abril de 2026
sensor_ch56 |>
  filter(substr(date, 1, 10) == "17/04/2026") |>
  select(date, PM25_S2_calibrados) |>
  head(30)

# 25. COMPARAR REGISTRO SIN HORA Y PROMEDIO HORARIO - SENSOR CH56

# Seleccionar los registros horarios del 17 de abril de 2026
sensor_ch56 |>
  filter(
    substr(date, 1, 10) == "17/04/2026",
    !is.na(fecha_hora)
  ) |>
  summarise(
    n_registros = n(),
    promedio_horario = mean(PM25_S2_calibrados, na.rm = TRUE)
  )

# 26. SEPARAR REGISTROS HORARIOS - SENSOR CH56

# Conservar las observaciones con fecha y hora identificables
sensor_ch56_horario <- sensor_ch56 |>
  filter(!is.na(fecha_hora))

# Comprobar la cantidad de registros
nrow(sensor_ch56_horario)

# 27. SEPARAR REGISTROS HORARIOS - SENSORES CH4 Y CH2

# Sensor CH4 - Cerro Navia
sensor_ch4_horario <- sensor_ch4 |>
  filter(!is.na(fecha_hora))

# Comprobar la cantidad de registros
nrow(sensor_ch4_horario)

# Sensor CH2 - Puente Alto
sensor_ch2_horario <- sensor_ch2 |>
  filter(!is.na(fecha_hora))

# Comprobar la cantidad de registros
nrow(sensor_ch2_horario)

# 28. COMPROBAR FECHAS Y HORAS DUPLICADAS - SENSORES HORARIOS

# Sensor CH56 - Parque O'Higgins
sum(duplicated(sensor_ch56_horario$fecha_hora))

# Sensor CH4 - Cerro Navia
sum(duplicated(sensor_ch4_horario$fecha_hora))

# Sensor CH2 - Puente Alto
sum(duplicated(sensor_ch2_horario$fecha_hora))
