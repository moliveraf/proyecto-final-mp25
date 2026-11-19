

# 06. COMPARAR SINCA Y SENSORES DE BAJO COSTO
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# Este script compara las concentraciones de MP2.5
# de SINCA y los sensores de bajo costo calibrados,
# utilizando registros coincidentes por fecha y hora.
# Se realizan estadísticas descriptivas, visualizaciones
# y una revisión de las concentraciones atípicas.


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


# ----------------------------------------------------------------------------

# 8. DIAGRAMAS DE CAJA DE MP2.5 - SINCA Y SENSORES

# Organizar los datos para el gráfico
datos_grafico <- comparacion_mp25 |>
  pivot_longer(
    cols = c(mp25_sinca, mp25_sensor),
    names_to = "fuente",
    values_to = "mp25"
  ) |>
  mutate(
    fuente = recode(
      fuente,
      "mp25_sinca" = "SINCA",
      "mp25_sensor" = "Sensor calibrado"
    ),
    fuente = factor(
      fuente,
      levels = c("SINCA", "Sensor calibrado")
    )
  )

# Crear el diagrama de caja
grafico_cajas <- ggplot(
  datos_grafico,
  aes(x = fuente, y = mp25, fill = fuente)
) +
  geom_boxplot(
    width = 0.55,
    alpha = 0.8,
    outlier.size = 1,
    outlier.alpha = 0.5
  ) +
  facet_wrap(~ comuna, nrow = 1) +
  scale_fill_manual(
    values = c(
      "SINCA" = "#2878B5",
      "Sensor calibrado" = "#E69F00"
    )
  ) +
  scale_y_continuous(
    breaks = seq(0, 450, 50)
  ) +
  labs(
    title = "Distribución de MP2.5 por comuna",
    subtitle = "Comparación de mediciones coincidentes entre SINCA y sensores calibrados",
    x = NULL,
    y = "Concentración de MP2.5 (µg/m³)",
    fill = "Fuente de medición"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold"),
    axis.text.x = element_text(size = 9)
  )

# Mostrar el gráfico
grafico_cajas


# ----------------------------------------------------------------------------

# 9. VISUALIZAR DIAGRAMAS DE CAJA CON ESCALA AMPLIADA

# Ampliar la visualización sin eliminar observaciones
grafico_cajas +
  coord_cartesian(ylim = c(0, 150)) +
  labs(
    subtitle = "Vista ampliada de 0 a 150 µg/m³; se conservan todas las observaciones"
  )


# ----------------------------------------------------------------------------

# 10. REVISAR CONCENTRACIONES NEGATIVAS Y EXTREMAS

# Identificar las concentraciones negativas y aquellas
# fuera del intervalo de revisión establecido
# en el diccionario de datos (2 a 200 µg/m³).
# Estos límites constituyen criterios de revisión,
# no criterios de eliminación automática.

revision_concentraciones <- comparacion_mp25 |>
  group_by(comuna) |>
  summarise(
    negativos_sinca = sum(mp25_sinca < 0),
    negativos_sensor = sum(mp25_sensor < 0),
    menores_2_sinca = sum(mp25_sinca < 2),
    menores_2_sensor = sum(mp25_sensor < 2),
    mayores_200_sinca = sum(mp25_sinca > 200),
    mayores_200_sensor = sum(mp25_sensor > 200),
    .groups = "drop"
  )

# Mostrar la tabla completa de concentraciones negativas y extremas
print(revision_concentraciones, width = Inf)

# Identificar los registros con concentraciones superiores a 200 µg/m³

concentraciones_extremas <- comparacion_mp25 |>
  filter(
    mp25_sinca > 200 | mp25_sensor > 200
  ) |>
  select(comuna, fecha_hora, mp25_sinca, mp25_sensor)

# Mostrar las concentraciones extremas
print(concentraciones_extremas, width = Inf)

# Revisar el comportamiento horario durante un episodio extremo

episodio_santiago <- comparacion_mp25 |>
  filter(
    comuna == "Santiago",
    as.Date(fecha_hora) == as.Date("2026-06-22")
  ) |>
  arrange(fecha_hora)

# Mostrar los registros horarios del episodio
print(episodio_santiago, n = Inf, width = Inf)

# Visualizar el comportamiento horario durante el episodio extremo

grafico_episodio <- episodio_santiago |>
  pivot_longer(
    cols = c(mp25_sinca, mp25_sensor),
    names_to = "fuente",
    values_to = "mp25"
  ) |>
  ggplot(aes(x = fecha_hora, y = mp25, color = fuente)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_color_manual(
    values = c(
      "mp25_sinca" = "#2878B5",
      "mp25_sensor" = "#E69F00"
    ),
    labels = c(
      "mp25_sinca" = "SINCA",
      "mp25_sensor" = "Sensor calibrado"
    )
  ) +
  scale_x_datetime(
    date_breaks = "3 hours",
    date_labels = "%H:%M"
  ) +
  labs(
    title = "Episodio extremo de MP2.5 en Santiago",
    subtitle = "22 de junio de 2026 - Parque O'Higgins y sensor CH56",
    x = "Hora registrada",
    y = "Concentración de MP2.5 (µg/m³)",
    color = "Fuente de medición"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

# Mostrar el gráfico del episodio
grafico_episodio

# Revisar el comportamiento horario del episodio del 17 de agosto

episodio_santiago_agosto <- comparacion_mp25 |>
  filter(
    comuna == "Santiago",
    as.Date(fecha_hora) == as.Date("2026-08-17")
  ) |>
  arrange(fecha_hora)

# Mostrar los registros horarios del episodio
print(episodio_santiago_agosto, n = Inf, width = Inf)

# Visualizar el episodio extremo del 17 de agosto

grafico_episodio_agosto <- episodio_santiago_agosto |>
  complete(
    fecha_hora = seq(
      min(fecha_hora),
      max(fecha_hora),
      by = "hour"
    )
  ) |>
  pivot_longer(
    cols = c(mp25_sinca, mp25_sensor),
    names_to = "fuente",
    values_to = "mp25"
  ) |>
  ggplot(aes(x = fecha_hora, y = mp25, color = fuente)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2, na.rm = TRUE) +
  scale_color_manual(
    values = c(
      "mp25_sinca" = "#2878B5",
      "mp25_sensor" = "#E69F00"
    ),
    labels = c(
      "mp25_sinca" = "SINCA",
      "mp25_sensor" = "Sensor calibrado"
    )
  ) +
  scale_x_datetime(
    date_breaks = "3 hours",
    date_labels = "%H:%M"
  ) +
  labs(
    title = "Episodio extremo de MP2.5 en Santiago",
    subtitle = "17 de agosto de 2026 - Parque O'Higgins y sensor CH56",
    x = "Hora registrada",
    y = "Concentración de MP2.5 (µg/m³)",
    color = "Fuente de medición"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

# Mostrar el gráfico del episodio
grafico_episodio_agosto

# 11. COMPROBAR LA REFERENCIA HORARIA DE LAS BASES

# Estaciones SINCA
tz(sinca_parque_procesado$fecha_hora)
tz(sinca_cerro_procesado$fecha_hora)
tz(sinca_puente_procesado$fecha_hora)

# Sensores de bajo costo
tz(sensor_ch56_procesado$fecha_hora)
tz(sensor_ch4_procesado$fecha_hora)
tz(sensor_ch2_procesado$fecha_hora)

# 12. EXCLUIR CONCENTRACIONES NEGATIVAS DEL ANÁLISIS

# Seleccionar pares de mediciones con concentraciones no negativas
comparacion_analisis <- comparacion_mp25 |>
  filter(
    mp25_sinca >= 0,
    mp25_sensor >= 0
  )

# Comprobar la cantidad de registros por comuna
comparacion_analisis |>
  group_by(comuna) |>
  summarise(
    n_registros = n(),
    .groups = "drop"
  )

# 13. GENERAR GRÁFICOS DE DISPERSIÓN POR COMUNA

grafico_dispersion <- ggplot(
  comparacion_analisis,
  aes(x = mp25_sinca, y = mp25_sensor)
) +
  geom_point(
    color = "#2878B5",
    alpha = 0.3,
    size = 1
  ) +
  geom_abline(
    intercept = 0,
    slope = 1,
    color = "gray40",
    linetype = "dashed"
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = FALSE,
    color = "#E69F00"
  ) +
  facet_wrap(~ comuna, nrow = 1) +
  coord_equal() +
  labs(
    title = "Relación entre SINCA y sensores calibrados",
    subtitle = "Comparación de concentraciones horarias por comuna",
    x = "MP2.5 SINCA (µg/m³)",
    y = "MP2.5 sensor calibrado (µg/m³)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

# Mostrar el gráfico de dispersión
grafico_dispersion

# Visualizar la dispersión con una escala ampliada

grafico_dispersion_ampliado <- grafico_dispersion +
  coord_equal(
    xlim = c(0, 150),
    ylim = c(0, 150)
  ) +
  labs(
    subtitle = "Vista ampliada de 0 a 150 µg/m³"
  )

# Mostrar el gráfico de dispersión ampliado
grafico_dispersion_ampliado

# 14. AJUSTAR MODELOS DE REGRESIÓN LINEAL POR COMUNA

# Agrupar y anidar los datos por comuna
modelos_mp25 <- comparacion_analisis |>
  group_by(comuna) |>
  nest() |>
  ungroup()

# Ajustar un modelo lineal para cada comuna
modelos_mp25 <- modelos_mp25 |>
  mutate(
    modelo = map(
      data,
      ~ lm(mp25_sensor ~ mp25_sinca, data = .x)
    )
  )

# Mostrar los modelos lineales por comuna
modelos_mp25

# 15. EXTRAER LOS RESULTADOS DE LOS MODELOS LINEALES

resultados_modelos <- modelos_mp25 |>
  mutate(
    intercepto = map_dbl(modelo, ~ coef(.x)[1]),
    pendiente = map_dbl(modelo, ~ coef(.x)[2]),
    r2 = map_dbl(modelo, ~ summary(.x)$r.squared)
  ) |>
  select(comuna, intercepto, pendiente, r2)

# Mostrar los resultados de los modelos por comuna
print(resultados_modelos, width = Inf)

# 16. VISUALIZAR LOS MODELOS LINEALES Y R2 POR COMUNA

# Preparar las etiquetas con las ecuaciones y el R2
etiquetas_modelos <- resultados_modelos |>
  mutate(
    etiqueta = sprintf(
      "y = %.3fx + %.2f\nR² = %.3f",
      pendiente, intercepto, r2
    )
  )

# Incorporar las ecuaciones y el R2 al gráfico
grafico_modelos <- grafico_dispersion_ampliado +
  geom_text(
    data = etiquetas_modelos,
    aes(label = etiqueta),
    x = 5,
    y = 145,
    hjust = 0,
    vjust = 1,
    size = 3.5,
    inherit.aes = FALSE
  ) +
  labs(
    title = "Regresión lineal entre SINCA y sensores",
    subtitle = "Modelos ajustados por comuna"
  )

# Mostrar el gráfico de los modelos lineales
grafico_modelos

