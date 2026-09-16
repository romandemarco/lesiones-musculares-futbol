source("config.R")
source("api_client.R")
library(dplyr)

bajar_lesiones <- function(league_id, temporadas = c(2024, 2025, 2026)) {
  nn <- function(x) if (is.null(x) || length(x) == 0) NA else x[1]
  out <- lapply(temporadas, function(s) {
    r <- api_get("injuries", list(league = league_id, season = s))
    if (length(r$response) == 0) return(NULL)
    message(sprintf("  temporada %d: %d registros", s, length(r$response)))
    do.call(rbind, lapply(r$response, function(x) data.frame(
      jugador_id = nn(x$player$id),
      jugador    = nn(x$player$name),
      tipo       = nn(x$player$type),
      motivo     = nn(x$player$reason),
      equipo     = nn(x$team$name),
      equipo_id  = nn(x$team$id),
      fecha      = as.Date(substr(nn(x$fixture$date), 1, 10)),
      fixture_id = nn(x$fixture$id),
      temporada  = s,
      stringsAsFactors = FALSE
    )))
  })
  do.call(rbind, out)
}

message("Premier League...")
les <- cbind(bajar_lesiones(PREMIER_LEAGUE_ID), liga = "PL")
message("LaLiga...")
les <- rbind(les, cbind(bajar_lesiones(LALIGA_ID), liga = "ESP"))
message("Bundesliga...")
les <- rbind(les, cbind(bajar_lesiones(BUNDESLIGA_ID), liga = "GER"))
message("Serie A...")
les <- rbind(les, cbind(bajar_lesiones(SERIE_A_ID), liga = "ITA"))
message("Ligue 1...")
les <- rbind(les, cbind(bajar_lesiones(LIGUE_1_ID), liga = "FRA"))

saveRDS(les, "lesiones.rds")
message(sprintf("\n✅ %d registros guardados en lesiones.rds", nrow(les)))