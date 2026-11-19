
# 08. REGRESIÓN LINEAL Y R2 DE SINCA Y SENSORES
# Proyecto final: Análisis de MP2.5 en Santiago de Chile
# Ejecutar previamente el script 01. Requiere el CSV generado en el script 06.

# 1. CARGAR MEDICIONES COINCIDENTES DE SINCA Y SENSORES
datos_modelos <- read_csv(
  "00_Datos/02_Datos_procesados/Comparacion_SINCA_Sensores/Comparacion_MP25_General.csv",
  show_col_types = FALSE
)

# ----------------------------------------------------------------------------
# 2. AJUSTAR MODELOS LINEALES POR COMUNA
# Se usa SINCA como referencia (X) y el sensor como respuesta (Y).
ajustar_modelos <- function(datos) {
  datos |>
    group_by(comuna, estacion_sinca, sensor) |>
    nest() |>
    ungroup() |>
    mutate(
      modelo = map(data, ~ lm(mp25_sensor ~ mp25_sinca, data = .x)),
      n_pares = map_int(data, nrow),
      intercepto = map_dbl(modelo, ~ unname(coef(.x)[1])),
      pendiente = map_dbl(modelo, ~ unname(coef(.x)[2])),
      r2 = map_dbl(modelo, ~ summary(.x)$r.squared)
    )
}
modelos_completos <- ajustar_modelos(datos_modelos)
resumen_modelos <- modelos_completos |>
  select(-data, -modelo)
print(resumen_modelos, width = Inf)

# ----------------------------------------------------------------------------
# 3. GENERAR GRÁFICOS DE DISPERSIÓN Y REGRESIÓN
graficar_modelos <- function(datos, resumen, subtitulo, limites = NULL) {
  etiquetas <- resumen |>
    mutate(etiqueta = sprintf("R² = %.3f\nn = %d", r2, n_pares))
  ggplot(datos, aes(x = mp25_sinca, y = mp25_sensor)) +
    geom_point(color = "#4682B4", alpha = 0.25, size = 1) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey45") +
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE, color = "#C58B18") +
    geom_text(data = etiquetas, aes(x = -Inf, y = Inf, label = etiqueta),
              inherit.aes = FALSE, hjust = -0.1, vjust = 1.2, size = 3.5) +
    facet_wrap(~ comuna, nrow = 1) +
    coord_equal(xlim = limites, ylim = limites) +
    labs(title = "Relación entre concentraciones de MP2.5 de SINCA y sensores",
         subtitle = subtitulo,
         x = "MP2.5 SINCA (µg/m³)", y = "MP2.5 sensor calibrado (µg/m³)",
         caption = "Línea amarilla: regresión lineal. Línea discontinua: identidad (1:1).") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold"), strip.text = element_text(face = "bold"))
}
grafico_regresion <- graficar_modelos(datos_modelos, resumen_modelos,
                                      "Todas las mediciones horarias coincidentes")
print(grafico_regresion)

# Ampliar la visualización sin excluir datos ni recalcular el R2.
grafico_regresion_ampliado <- graficar_modelos(
  datos_modelos, resumen_modelos,
  "Todas las mediciones horarias coincidentes",
  limites = c(0, 200)
)
print(grafico_regresion_ampliado)

# ----------------------------------------------------------------------------
# 4. ANÁLISIS DE SENSIBILIDAD A CONCENTRACIONES SUPERIORES A 200
# Excluir el par completo si cualquiera de las dos fuentes supera 200.
episodios_extremos <- datos_modelos |>
  filter(mp25_sinca > 200 | mp25_sensor > 200) |>
  arrange(comuna, fecha_hora)
print(episodios_extremos, width = Inf)

datos_sin_extremos <- datos_modelos |>
  filter(mp25_sinca <= 200, mp25_sensor <= 200)
modelos_sin_extremos <- ajustar_modelos(datos_sin_extremos)
resumen_sin_extremos <- modelos_sin_extremos |> select(-data, -modelo)
resumen_sensibilidad <- resumen_modelos |>
  inner_join(resumen_sin_extremos, by = c("comuna", "estacion_sinca", "sensor"),
             suffix = c("_completo", "_sin_extremos")) |>
  mutate(n_excluidos = n_pares_completo - n_pares_sin_extremos,
         diferencia_r2 = r2_sin_extremos - r2_completo)
print(resumen_sensibilidad, width = Inf)
grafico_sensibilidad <- graficar_modelos(datos_sin_extremos, resumen_sin_extremos,
                                        "Pares sin concentraciones superiores a 200 µg/m³",
                                        limites = c(0, 200))
print(grafico_sensibilidad)

# Figura comparativa: títulos horizontales encima de cada trío.
# Se reutilizan los gráficos existentes, sin recalcular los modelos.
preparar_fila <- function(grafico, titulo) {
  grafico +
    coord_equal(xlim = c(0, 200), ylim = c(0, 200), expand = FALSE) +
    scale_x_continuous(breaks = seq(0, 200, 50)) +
    scale_y_continuous(breaks = seq(0, 200, 50)) +
    labs(title = titulo, subtitle = NULL, x = NULL, y = NULL, caption = NULL) +
    theme(plot.title = element_text(face = "bold", size = 13, hjust = 0.5,
                                    margin = margin(b = 10)),
          panel.spacing.x = grid::unit(1.6, "lines"),
          plot.margin = margin(8, 16, 8, 16))
}
fila_completa <- preparar_fila(grafico_regresion_ampliado,
                              "A. Todas las mediciones coincidentes")
fila_sensibilidad <- preparar_fila(grafico_sensibilidad,
                                  "B. Mediciones sin concentraciones superiores a 200 µg/m³")

# Componer ambas filas con ejes comunes y alineación automática.
# gtable es una dependencia de ggplot2; no requiere cargar otra librería.
grob_completo <- ggplotGrob(fila_completa)
grob_sensibilidad <- ggplotGrob(fila_sensibilidad)
anchos_comunes <- grid::unit.pmax(grob_completo$widths, grob_sensibilidad$widths)
grob_completo$widths <- anchos_comunes
grob_sensibilidad$widths <- anchos_comunes

grafico_comparativo <- rbind(grob_completo, grob_sensibilidad, size = "first")
grafico_comparativo$respect <- TRUE

# Ambos títulos de eje comparten exactamente la misma fuente.
fuente_ejes <- grid::gpar(fontsize = 14, fontface = "plain", fontfamily = "sans")
eje_y <- grid::textGrob("MP2.5 sensor calibrado (µg/m³)", rot = 90,
                        gp = fuente_ejes)
eje_x <- grid::textGrob("MP2.5 SINCA (µg/m³)", gp = fuente_ejes)

# Quitar el margen exterior izquierdo de las filas para acercar el eje Y.
grafico_comparativo$widths[1] <- grid::unit(2, "mm")
grafico_comparativo <- gtable::gtable_add_cols(
  grafico_comparativo, grid::grobWidth(eje_y) + grid::unit(4, "mm"), pos = 0)
grafico_comparativo <- gtable::gtable_add_grob(
  grafico_comparativo, eje_y, t = 1, b = nrow(grafico_comparativo), l = 1,
  clip = "off", name = "eje_y_comun")

# Centrar el eje X y los encabezados respecto a los paneles.
paneles <- grafico_comparativo$layout[grepl("^panel", grafico_comparativo$layout$name), ]
izquierda <- min(paneles$l)
derecha <- max(paneles$r)
agregar_texto <- function(tabla, texto, altura, posicion, nombre) {
  tabla <- gtable::gtable_add_rows(tabla, altura, pos = posicion)
  fila <- if (posicion == 0) 1 else nrow(tabla)
  gtable::gtable_add_grob(tabla, texto, t = fila, l = izquierda, r = derecha,
                         clip = "off", name = nombre)
}
grafico_comparativo <- agregar_texto(
  grafico_comparativo, eje_x, grid::unit(9, "mm"), -1, "eje_x_comun")
grafico_comparativo <- agregar_texto(
  grafico_comparativo,
  grid::textGrob("Línea amarilla: regresión lineal. Línea discontinua: identidad (1:1).",
                 gp = grid::gpar(fontsize = 10, fontfamily = "sans")),
  grid::unit(7, "mm"), -1, "leyenda_lineas")
grafico_comparativo <- agregar_texto(
  grafico_comparativo,
  grid::textGrob("Relación entre concentraciones de MP2.5 de SINCA y sensores",
                 gp = grid::gpar(fontsize = 17, fontface = "bold", fontfamily = "sans")),
  grid::unit(10, "mm"), 0, "titulo_general")
grid::grid.newpage()
grid::grid.draw(grafico_comparativo)

# ----------------------------------------------------------------------------
# 5. GUARDAR TABLAS Y FIGURAS

base_figuras <- "02_Figuras/03_Comparacion_SINCA_Sensores"

carpeta_modelos <- file.path(base_figuras, "03_Modelos_lineales")
carpeta_sensibilidad <- file.path(base_figuras, "04_Analisis_sensibilidad")
carpeta_tablas <- "04_Tablas/06_Regresion_lineal"

# Crear carpetas
for (carpeta in c(carpeta_modelos, carpeta_sensibilidad, carpeta_tablas)) {
  dir.create(carpeta, recursive = TRUE, showWarnings = FALSE)
}

# Guardar regresión con escala completa
ggsave(
  file.path(carpeta_modelos, "01_regresion_lineal_r2_sinca_sensores_por_comuna.png"),
  grafico_regresion,
  width = 12, height = 6, dpi = 300, bg = "white"
)

# Guardar figura comparativa de seis paneles
ggsave(
  file.path(carpeta_sensibilidad, "02_comparacion_regresiones_r2_sinca_sensores.png"),
  grafico_comparativo,
  width = 15, height = 10, dpi = 300, bg = "white"
)

# Guardar tablas de resultados
write_csv(
  resumen_modelos,
  file.path(carpeta_tablas, "01_modelos_lineales_r2_sinca_sensores.csv")
)

write_csv(
  episodios_extremos,
  file.path(carpeta_tablas, "02_pares_extremos_sinca_sensores.csv")
)

write_csv(
  resumen_sensibilidad,
  file.path(carpeta_tablas, "03_sensibilidad_r2_sinca_sensores.csv")
)

# Comprobar los archivos guardados
print(list.files(carpeta_modelos))
print(list.files(carpeta_sensibilidad))
print(list.files(carpeta_tablas))
