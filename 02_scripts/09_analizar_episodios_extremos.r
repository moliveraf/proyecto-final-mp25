

# 09. ANÁLISIS TEMPORAL DE EPISODIOS EXTREMOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile

# Este script analiza el comportamiento temporal de SINCA
# y los sensores calibrados durante las 24 horas anteriores
# y posteriores a los episodios extremos identificados
# en el script 08.
#
# Ejecutar previamente el script 01 para cargar las librerías.


# 1. CARGAR LOS DATOS GENERADOS ANTERIORMENTE

# Mediciones horarias coincidentes (script 06)
comparacion_mp25 <- read_csv(
  "01_datos/02_datos_procesados/03_comparacion_sinca_sensores/04_mediciones_horarias_coincidentes_sinca_sensores_tres_comunas.csv",
  show_col_types = FALSE
)

# Pares de mediciones extremas (script 08)
episodios_extremos <- read_csv(
  "04_tablas/06_regresion_lineal/02_pares_extremos_sinca_sensores.csv",
  show_col_types = FALSE
)

# Comprobar las bases cargadas
glimpse(comparacion_mp25)
glimpse(episodios_extremos)


# 2. AGRUPAR LOS REGISTROS EXTREMOS POR EPISODIO

resumen_episodios <- episodios_extremos |>
  mutate(fecha = as.Date(fecha_hora)) |>
  group_by(comuna, estacion_sinca, sensor, fecha) |>
  summarise(
    inicio_episodio = min(fecha_hora),
    fin_episodio = max(fecha_hora),
    n_registros_extremos = n(),
    .groups = "drop"
  )

# Comprobar los episodios identificados
print(resumen_episodios, width = Inf)


# 3. DEFINIR LOS PERIODOS DE ANÁLISIS DE CADA EPISODIO

# Establecer las 24 horas anteriores y posteriores
# a cada episodio extremo

ventanas_temporales <- resumen_episodios |>
  mutate(
    inicio_ventana = inicio_episodio - hours(24),
    fin_ventana = fin_episodio + hours(24)
  )

# Comprobar los periodos definidos
print(ventanas_temporales, width = Inf)


# 3.1. SELECCIONAR LAS MEDICIONES HORARIAS DE MP2.5
# ANTES, DURANTE Y DESPUÉS DE CADA EPISODIO EXTREMO

datos_episodios <- ventanas_temporales |>
  group_by(comuna, estacion_sinca, sensor, fecha) |>
  nest() |>
  ungroup() |>
  mutate(
    mediciones = pmap(
      list(comuna, estacion_sinca, sensor, data),
      function(c, e, s, d) {
        comparacion_mp25 |>
          filter(
            comuna == c,
            estacion_sinca == e,
            sensor == s,
            fecha_hora >= d$inicio_ventana[1],
            fecha_hora <= d$fin_ventana[1]
          ) |>
          arrange(fecha_hora)
      }
    )
  )

# Comprobar las mediciones horarias seleccionadas
print(datos_episodios, width = Inf)


# 4. ORGANIZAR LAS CONCENTRACIONES HORARIAS DE MP2.5
# POR EPISODIO EXTREMO Y FUENTE DE MEDICIÓN

# Desanidar las mediciones y transformar los datos
# a formato largo mediante pivot_longer()

datos_graficos_episodios <- datos_episodios |>
  select(comuna, fecha, mediciones) |>
  unnest(
    mediciones,
    names_sep = "_"
  ) |>
  select(
    comuna,
    fecha,
    fecha_hora = mediciones_fecha_hora,
    SINCA = mediciones_mp25_sinca,
    `Sensor calibrado` = mediciones_mp25_sensor
  ) |>
  pivot_longer(
    cols = c(SINCA, `Sensor calibrado`),
    names_to = "fuente",
    values_to = "mp25"
  )

# Comprobar los datos organizados
glimpse(datos_graficos_episodios)


# 5. GENERAR LAS SERIES TEMPORALES DE LOS EPISODIOS EXTREMOS

# Identificar cada episodio y ordenar cronológicamente.
# Separar las curvas cuando existan horas sin
# mediciones coincidentes.

datos_series_temporales <- datos_graficos_episodios |>
  mutate(
    episodio = paste(
      comuna,
      format(fecha, "%d/%m/%Y"),
      sep = " - "
    ),
    episodio = factor(
      episodio,
      levels = unique(episodio[order(fecha)])
    ),
    fuente = factor(
      fuente,
      levels = c("SINCA", "Sensor calibrado")
    )
  ) |>
  group_by(episodio, fuente) |>
  arrange(fecha_hora, .by_group = TRUE) |>
  mutate(
    intervalo_horas = as.numeric(
      difftime(
        fecha_hora,
        lag(fecha_hora),
        units = "hours"
      )
    ),
    segmento = cumsum(
      is.na(intervalo_horas) | intervalo_horas > 1
    )
  ) |>
  ungroup()


# 5.1. SERIES TEMPORALES CON ESCALA COMPLETA

# Representar todas las concentraciones de MP2.5,
# incluyendo los valores superiores a 200 µg/m³.

grafico_episodios_extremos <- ggplot(
  datos_series_temporales,
  aes(
    x = fecha_hora,
    y = mp25,
    color = fuente
  )
) +
  geom_line(
    aes(group = interaction(fuente, segmento)),
    linewidth = 0.8
  ) +
  geom_point(size = 1.5) +
  geom_hline(
    yintercept = 200,
    linetype = "dashed",
    color = "gray40"
  ) +
  facet_wrap(
    ~ episodio,
    ncol = 2,
    scales = "free_x"
  ) +
  scale_color_manual(
    values = c(
      "SINCA" = "#4682B4",
      "Sensor calibrado" = "#E9B44C"
    )
  ) +
  scale_x_datetime(
    date_labels = "%d/%m\n%H:%M",
    date_breaks = "12 hours"
  ) +
  scale_y_continuous(
    breaks = seq(0, 450, by = 50)
  ) +
  coord_cartesian(
    ylim = c(0, 450)
  ) +
  labs(
    title = "Comportamiento temporal del MP2.5 durante episodios extremos",
    subtitle = "Mediciones coincidentes 24 horas antes y después de cada episodio",
    x = "Fecha y hora",
    y = "Concentración de MP2.5 (µg/m³)",
    color = "Fuente de medición",
    caption = "Línea discontinua: umbral de análisis de 200 µg/m³."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    plot.title = element_text(
      face = "bold",
      size = 15
    ),
    plot.subtitle = element_text(size = 12),
    strip.text = element_text(
      face = "bold",
      size = 11
    ),
    axis.title.y = element_text(
      size = 12,
      margin = margin(r = 10)
    ),
    axis.title.x = element_text(
      size = 12,
      margin = margin(t = 10)
    ),
    axis.text = element_text(size = 10),
    panel.grid.minor = element_blank(),
    panel.spacing = grid::unit(1.5, "lines"),
    plot.margin = margin(15, 15, 15, 15)
  )

# Visualizar la figura completa
print(grafico_episodios_extremos)


# 5.2. SERIES TEMPORALES CON ESCALA AMPLIADA

# Ampliar la visualización entre 0 y 150 µg/m³
# para observar con mayor detalle el comportamiento
# de las concentraciones habituales.
#
# coord_cartesian() modifica únicamente la escala
# visible, sin eliminar observaciones.

grafico_episodios_ampliado <- grafico_episodios_extremos +
  scale_y_continuous(
    breaks = seq(0, 150, by = 25)
  ) +
  coord_cartesian(
    ylim = c(0, 150)
  ) +
  labs(
    subtitle = "Mediciones coincidentes: visualización ampliada entre 0 y 150 µg/m³",
    caption = "La ampliación de escala no elimina observaciones; los picos superiores a 150 µg/m³ quedan fuera de la ventana visible."
  )

# Visualizar la figura ampliada
print(grafico_episodios_ampliado)


# 6. GUARDAR Y COMPROBAR LAS FIGURAS GENERADAS

carpeta_episodios <- paste0(
  "03_figuras/01_comparacion_sinca_sensores/",
  "04_episodios_extremos"
)

dir.create(
  carpeta_episodios,
  recursive = TRUE,
  showWarnings = FALSE
)

# Guardar la figura con escala completa
ggsave(
  filename = file.path(
    carpeta_episodios,
    "01_series_temporales_episodios_extremos.png"
  ),
  plot = grafico_episodios_extremos,
  width = 12,
  height = 8,
  dpi = 300,
  bg = "white"
)
cat(readLines("readme.md"), sep = "\n")
# Guardar la figura con escala ampliada
ggsave(
  filename = file.path(
    carpeta_episodios,
    "02_series_temporales_episodios_extremos_ampliado.png"
  ),
  plot = grafico_episodios_ampliado,
  width = 12,
  height = 8,
  dpi = 300,
  bg = "white"
)

# Comprobar las figuras guardadas
print(list.files(carpeta_episodios))
