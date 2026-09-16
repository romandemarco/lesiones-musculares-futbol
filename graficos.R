# ==============================================================================
# graficos.R — Gráficos para el informe de lesiones musculares
# ==============================================================================
library(dplyr); library(ggplot2)

mus <- readRDS("musculares.rds")
ep  <- readRDS("episodios.rds")
mus$mes <- format(mus$inicio, "%m")
dir.create("img", showWarnings = FALSE)

# Paleta
AZUL  <- "#1F4E79"
ROJO  <- "#C0392B"
GRIS  <- "#95A5A6"
TEXTO <- "#2C3E50"

tema <- theme_minimal(base_size = 13) +
  theme(
    plot.background   = element_rect(fill = "white", colour = NA),
    panel.background  = element_rect(fill = "white", colour = NA),
    panel.grid.minor  = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(colour = "grey88", linewidth = .4),
    plot.title    = element_text(face = "bold", size = 15, colour = TEXTO,
                                 margin = margin(b = 4)),
    plot.subtitle = element_text(size = 11, colour = "grey35",
                                 margin = margin(b = 14)),
    plot.caption  = element_text(size = 9, colour = "grey50", hjust = 0,
                                 margin = margin(t = 12)),
    axis.text     = element_text(colour = TEXTO),
    axis.title    = element_text(colour = "grey35", size = 10),
    axis.ticks    = element_blank(),
    legend.position = "top",
    legend.text   = element_text(colour = TEXTO),
    plot.margin   = margin(16, 20, 12, 16)
  )

sv <- function(g, f, w = 8, h = 4.8) {
  ggsave(file.path("img", f), g, width = w, height = h, dpi = 200, bg = "white")
}

# ------------------------------------------------------------------ 1. Recurrencia
d1 <- mus %>%
  group_by(jugador_id, grupo) %>% summarise(n = n(), .groups = "drop") %>%
  group_by(grupo) %>%
  summarise(pct = 100 * sum(n > 1) / n(), jug = n(), .groups = "drop") %>%
  filter(grupo != "Muscular sin especificar")

g1 <- ggplot(d1, aes(reorder(grupo, pct), pct)) +
  geom_col(fill = AZUL, width = .62) +
  geom_text(aes(label = sprintf("%.1f%%", pct)), hjust = -0.2,
            size = 4.2, colour = TEXTO, fontface = "bold") +
  geom_text(aes(y = 0.6, label = sprintf("n=%d", jug)), hjust = 0,
            size = 3.2, colour = "white") +
  coord_flip(ylim = c(0, 23)) +
  labs(       title = "El gemelo recae la mitad que los isquiotibiales",
       subtitle = "Porcentaje de jugadores que sufre más de un episodio del mismo tipo",
       x = NULL, y = "% de jugadores con recaída",
       caption = "Premier League, LaLiga, Serie A, Bundesliga y Ligue 1 · temporadas 2024/25 a 2026/27") +
  tema
sv(g1, "recurrencia.png")

# ------------------------------------------------------------------ 2. Duración
sel <- c("Isquiotibiales", "Muslo/Cuádriceps", "Gemelo/Sóleo",
         "Aductores", "Rodilla", "Tobillo/Pie")

g2 <- ep %>% filter(grupo %in% sel) %>%
  mutate(fam = ifelse(grupo %in% c("Rodilla", "Tobillo/Pie"), "Otras", "Musculares")) %>%
  ggplot(aes(reorder(grupo, partidos_perdidos, median), partidos_perdidos, fill = fam)) +
  geom_boxplot(alpha = .85, outlier.alpha = .18, outlier.size = 1, width = .58) +
  scale_fill_manual(values = c("Musculares" = AZUL, "Otras" = GRIS)) +
  coord_flip(ylim = c(0, 26)) +
  labs(title = "Las musculares son cortas; la rodilla tiene cola larga",
       subtitle = "Partidos perdidos por episodio. La caja abarca el 50% central de los casos",
       x = NULL, y = "Partidos perdidos", fill = NULL,
       caption = "Los puntos son casos atípicos. Rodilla: mediana 5,5 pero el 10% supera los 24 partidos") +
  tema +
  theme(panel.grid.major.x = element_line(colour = "grey88", linewidth = .4))
sv(g2, "duracion.png", h = 5)

# ------------------------------------------------------------------ 3. Mensual
g3 <- mus %>% count(mes) %>%
  mutate(destacar = mes %in% c("08", "11")) %>%
  ggplot(aes(mes, n, fill = destacar)) +
  geom_col(width = .68) +
  geom_text(aes(label = n), vjust = -0.55, size = 3.6, colour = TEXTO) +
  scale_fill_manual(values = c("TRUE" = ROJO, "FALSE" = AZUL), guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, .12))) +
  labs(title = "Agosto y noviembre concentran los picos",
       subtitle = "Episodios musculares por mes de inicio, acumulado de tres temporadas",
       x = "Mes", y = "Episodios",
       caption = "Las musculares suben 87% entre 2024 y 2026. Rodilla y tobillo se mantienen estables,\nlo que descarta que el aumento se deba a mayor cobertura de datos.") +
  tema +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "grey88", linewidth = .4))
sv(g3, "mensual.png", h = 4.4)

# ------------------------------------------------------------------ 4. Agosto por año
musc_lab <- c("Isquiotibiales", "Muslo/Cuádriceps", "Gemelo/Sóleo",
              "Aductores", "Muscular sin especificar")

g4 <- ep %>%
  mutate(mes = format(inicio, "%m"), anio = format(inicio, "%Y"),
         tipo = ifelse(grupo %in% musc_lab, "Musculares", "Rodilla y tobillo")) %>%
  filter(mes == "08", grupo %in% c(musc_lab, "Rodilla", "Tobillo/Pie")) %>%
  count(anio, tipo) %>%
  ggplot(aes(anio, n, fill = tipo)) +
  geom_col(position = position_dodge(.78), width = .7) +
  geom_text(aes(label = n), position = position_dodge(.78),
            vjust = -0.5, size = 3.8, colour = TEXTO) +
  scale_fill_manual(values = c("Musculares" = ROJO, "Rodilla y tobillo" = GRIS)) +
  scale_y_continuous(expand = expansion(mult = c(0, .15))) +
  labs(title = "En agosto crecen las musculares y nada más",
       subtitle = "Episodios iniciados en agosto, por año",
       x = NULL, y = "Episodios", fill = NULL,
       caption = "Las musculares suben 69% entre 2024 y 2026. Rodilla y tobillo se mantienen estables,\nlo que descarta que el aumento se deba a mayor cobertura de datos.") +
  tema +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "grey88", linewidth = .4))
sv(g4, "agosto.png", h = 4.8)

# ------------------------------------------------------------------ 5. Recaídas tempranas
g5 <- mus %>% arrange(jugador_id, inicio) %>%
  group_by(jugador_id, grupo) %>%
  mutate(dias = as.numeric(inicio - lag(fin))) %>%
  filter(!is.na(dias), grupo != "Muscular sin especificar") %>% ungroup() %>%
  group_by(grupo) %>%
  summarise(n = n(), pct = 100 * sum(dias < 60) / n(), .groups = "drop") %>%
  filter(n >= 10) %>%
  ggplot(aes(reorder(grupo, pct), pct)) +
  geom_col(fill = ROJO, width = .62) +
  geom_text(aes(label = sprintf("%.0f%%", pct)), hjust = -0.2,
            size = 4.2, colour = TEXTO, fontface = "bold") +
  geom_text(aes(y = 1.2, label = sprintf("n=%d", n)), hjust = 0,
            size = 3.2, colour = "white") +
  coord_flip(ylim = c(0, 45)) +
  labs(title = "Más de un tercio de las recaídas ocurre antes de los 60 días",
       subtitle = "Porcentaje de recaídas que se producen en los dos meses posteriores al alta",
       x = NULL, y = "% de recaídas antes de 60 días",
       caption = "Sugiere retorno prematuro a la competencia. Solo subtipos con 10 o más recaídas registradas.") +
  tema
sv(g5, "recaidas_tempranas.png")

message("✅ 5 gráficos guardados en img/")