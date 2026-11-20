

# 07. BOXPLOTS DE MP2.5: SINCA Y SENSORES CALIBRADOS
# Proyecto final: Análisis de MP2.5 en Santiago de Chile
# Ejecutar previamente los scripts 01 al 06.
# Se utilizan exclusivamente las mediciones horarias coincidentes.

# 1. ORGANIZAR LOS DATOS PARA LOS BOXPLOTS

datos_boxplot <- comparacion_mp25 |>
  select(comuna, estacion_sinca, sensor, fecha_hora,
         mp25_sinca, mp25_sensor) |>
  pivot_longer(
    cols = c(mp25_sinca, mp25_sensor),
    names_to = "fuente",
    values_to = "mp25"
  ) |>
  mutate(
    fuente = factor(
      fuente,
      levels = c("mp25_sinca", "mp25_sensor"),
      labels = c("SINCA", "Sensor calibrado")
    ),
    comuna = factor(
      comuna,
      levels = c("Cerro Navia", "Puente Alto", "Santiago")
    )
  )

# ----------------------------------------------------------------------------

# 2. ESTADÍSTICAS DESCRIPTIVAS POR COMUNA Y FUENTE DE MEDICIÓN

estadisticas_boxplot <- datos_boxplot |>
  group_by(comuna, estacion_sinca, sensor, fuente) |>
  summarise(
    n_registros = n(),
    promedio = mean(mp25),
    desviacion = sd(mp25),
    minimo = min(mp25),
    q1 = quantile(mp25, 0.25),
    mediana = median(mp25),
    q3 = quantile(mp25, 0.75),
    maximo = max(mp25),
    .groups = "drop"
  )

print(estadisticas_boxplot, width = Inf)

# ----------------------------------------------------------------------------

# 3. BOXPLOT CON ESCALA COMPLETA

grafico_cajas <- ggplot(
  datos_boxplot,
  aes(x = fuente, y = mp25, fill = fuente)
) +
  geom_boxplot(
    width = 0.60,
    colour = "#404040",
    linewidth = 0.5,
    outlier.alpha = 0.25,
    outlier.size = 0.9
  ) +
  facet_wrap(~ comuna, nrow = 1) +
  scale_x_discrete(
    expand = expansion(add = 1.1)
  ) +
  scale_y_continuous(
    breaks = scales::breaks_pretty(n = 8),
    expand = expansion(mult = c(0, 0.05))
  ) +
  scale_fill_manual(
    values = c(
      "SINCA" = "#4682B4",
      "Sensor calibrado" = "#EAB54A"
    )
  ) +
  labs(
    title = "Distribución de MP2.5 por comuna",
    subtitle = paste(
      "Comparación de mediciones horarias coincidentes",
      "entre SINCA y sensores calibrados"
    ),
    x = NULL,
    y = "Concentración de MP2.5 (µg/m³)",
    fill = "Fuente de medición"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold", size = 17
    ),
    plot.subtitle = element_text(
      size = 12, margin = margin(b = 10)
    ),
    legend.position = "top",
    legend.title = element_text(
      size = 14, face = "bold"
    ),
    legend.text = element_text(size = 14),
    legend.key.size = grid::unit(0.7, "cm"),
    legend.spacing.x = grid::unit(0.3, "cm"),
    strip.text = element_text(
      face = "bold", size = 15,
      margin = margin(t = 8, b = 8)
    ),
    strip.background = element_rect(
      fill = "#EAEAEA",
      colour = "#BDBDBD",
      linewidth = 0.5
    ),
    panel.border = element_rect(
      colour = "#BDBDBD",
      fill = NA,
      linewidth = 0.5
    ),
    panel.spacing.x = grid::unit(1.2, "cm"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(
      colour = "#E5E5E5",
      linewidth = 0.4
    ),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(size = 12),
    axis.title.y = element_text(
      size = 13,
      margin = margin(r = 12)
    ),
    plot.margin = margin(15, 20, 15, 15)
  )

print(grafico_cajas)

# ----------------------------------------------------------------------------

# 4. BOXPLOT CON ESCALA AMPLIADA
# coord_cartesian modifica la ventana visible,
# sin eliminar observaciones ni modificar los cuartiles.
# Los límites horizontales conservan los márgenes laterales.

grafico_cajas_ampliado <- grafico_cajas +
  scale_y_continuous(
    breaks = seq(0, 150, by = 25),
    expand = expansion(mult = c(0, 0))
  ) +
  coord_cartesian(
    xlim = c(0, 3),
    ylim = c(0, 150),
    expand = FALSE
  ) +
  labs(
    caption = paste(
      "Visualización ampliada entre 0 y 150 µg/m³.",
      "Las observaciones superiores a 150 µg/m³",
      "quedan fuera de la ventana visible."
    )
  ) +
  theme(
    plot.caption = element_text(
      size = 10,
      colour = "#555555",
      hjust = 1,
      margin = margin(t = 10)
    )
  )

print(grafico_cajas_ampliado)

# ----------------------------------------------------------------------------

# 5. GUARDAR FIGURAS Y TABLA

carpeta_figuras <- "03_figuras/01_comparacion_sinca_sensores/01_boxplots"
carpeta_tablas <- "04_tablas/05_boxplots"

dir.create(carpeta_figuras, recursive = TRUE, showWarnings = FALSE)
dir.create(carpeta_tablas, recursive = TRUE, showWarnings = FALSE)

# Guardar gráfico con escala completa

ggsave(
  file.path(carpeta_figuras, "01_boxplot_sinca_sensores_por_comuna.png"),
  plot = grafico_cajas,
  width = 12, height = 6, dpi = 300, bg = "white"
)

# Guardar gráfico con escala ampliada

ggsave(
  file.path(carpeta_figuras, "02_boxplot_sinca_sensores_por_comuna_ampliado.png"),
  plot = grafico_cajas_ampliado,
  width = 12, height = 6, dpi = 300, bg = "white"
)

# Exportar estadísticas descriptivas

write_csv(
  estadisticas_boxplot,
  file.path(carpeta_tablas, "01_estadisticas_descriptivas_sinca_sensores_por_comuna.csv")
)

# Comprobar los archivos guardados

list.files(carpeta_figuras)
list.files(carpeta_tablas)

