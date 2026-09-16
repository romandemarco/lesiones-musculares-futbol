library(dplyr)

lim <- readRDS("lesiones_limpio.rds")

# Un episodio = ausencias consecutivas del mismo jugador, mismo tipo de lesión,
# separadas por menos de 45 días. Si pasan más de 45 días o cambia el motivo,
# se cuenta como lesión nueva.
ep <- lim %>%
  arrange(jugador_id, fecha) %>%
  group_by(jugador_id) %>%
  mutate(
    dias_desde_anterior = as.numeric(fecha - lag(fecha)),
    nuevo = is.na(dias_desde_anterior) | dias_desde_anterior > 45 | grupo != lag(grupo),
    episodio = cumsum(nuevo)
  ) %>%
  group_by(jugador_id, jugador, episodio) %>%
  summarise(
    liga   = first(liga),
    equipo = first(equipo),
    grupo  = first(grupo),
    motivo = first(motivo),
    inicio = min(fecha),
    fin    = max(fecha),
    partidos_perdidos = n(),
    dias   = as.numeric(max(fecha) - min(fecha)),
    .groups = "drop"
  )

saveRDS(ep, "episodios.rds")

cat(sprintf("\n%d episodios de %d jugadores\n\n",
            nrow(ep), length(unique(ep$jugador_id))))

ep %>%
  group_by(grupo) %>%
  summarise(
    episodios     = n(),
    part_media    = round(mean(partidos_perdidos), 1),
    part_mediana  = median(partidos_perdidos),
    part_max      = max(partidos_perdidos),
    dias_media    = round(mean(dias), 0)
  ) %>%
  arrange(desc(episodios)) %>%
  as.data.frame() %>%
  print(row.names = FALSE)