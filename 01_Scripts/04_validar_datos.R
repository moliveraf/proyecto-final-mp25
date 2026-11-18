
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
