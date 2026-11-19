
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
    names_to = "fuente", values_to = "mp25"
  ) |>
  mutate(fuente = factor(fuente,
                         levels = c("mp25_sinca", "mp25_sensor"),
                         labels = c("SINCA", "Sensor calibrado")))

# ----------------------------------------------------------------------------
# 2. ESTADÍSTICAS DESCRIPTIVAS POR COMUNA Y FUENTE DE MEDICION

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

grafico_cajas <- ggplot(datos_boxplot, aes(x = fuente, y = mp25, fill = fuente)) +
  geom_boxplot(width = 0.6, outlier.alpha = 0.45, outlier.size = 1.2) +
  facet_wrap(~ comuna, nrow = 1) +
  scale_fill_manual(values = c("SINCA" = "#4682B4",
                               "Sensor calibrado" = "#EAB54A")) +
  labs(title = "Distribución de MP2.5 por comuna",
       subtitle = "Comparación de mediciones coincidentes entre SINCA y sensores calibrados",
       x = NULL, y = "Concentración de MP2.5 (µg/m³)",
       fill = "Fuente de medición") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top",
        plot.title = element_text(face = "bold"),
        strip.text = element_text(face = "bold"),
        panel.grid.minor = element_blank())
print(grafico_cajas)

# ----------------------------------------------------------------------------
# 4. BOXPLOT CON ESCALA AMPLIADA
# coord_cartesian modifica la ventana visible, no los datos ni los cuartiles.
grafico_cajas_ampliado <- grafico_cajas +
  coord_cartesian(ylim = c(0, 150), expand = FALSE)
print(grafico_cajas_ampliado)

# ----------------------------------------------------------------------------
# 5. GUARDAR FIGURAS Y TABLA
carpeta_figuras <- "02_Figuras/03_Comparacion_SINCA_Sensores/01_Boxplots"
carpeta_tablas <- "04_Tablas/05_Boxplots"
dir.create(carpeta_figuras, recursive = TRUE, showWarnings = FALSE)
dir.create(carpeta_tablas, recursive = TRUE, showWarnings = FALSE)

ggsave(file.path(carpeta_figuras, "01_boxplot_sinca_sensores_por_comuna.png"),
       plot = grafico_cajas, width = 12, height = 6, dpi = 300, bg = "white")
ggsave(file.path(carpeta_figuras, "02_boxplot_sinca_sensores_por_comuna_ampliado.png"),
       plot = grafico_cajas_ampliado, width = 12, height = 6, dpi = 300, bg = "white")
write_csv(estadisticas_boxplot,
          file.path(carpeta_tablas, "01_estadisticas_descriptivas_sinca_sensores_por_comuna.csv"))

# Comprobar los archivos guardados
list.files(carpeta_figuras)
list.files(carpeta_tablas)
