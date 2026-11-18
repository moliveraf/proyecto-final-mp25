
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

# 7. REVISAR CONCENTRACIONES SUPERIORES A 200 µg/m³

# Identificar la observación de Cerro Navia
sinca_cerro |>
  filter(mp25 > 200) |>
  select(fecha_hora, mp25,
         `Registros validados`,
         `Registros preliminares`)
