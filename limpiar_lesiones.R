library(dplyr)
les <- readRDS("lesiones.rds")

# No son lesiones: disciplina, selección, decisiones técnicas
no_lesion <- c("Red Card", "Yellow Cards", "Suspended", "International duty",
               "Coach's decision", "Inactive", "Lacking Match Fitness",
               "Transfer negotiations", "Personal reasons", "Rest",
               "Not in squad", "Contract issues")

no_lesion <- c("Red Card", "Yellow Cards", "Suspended", "International duty",
               "Coach's decision", "Inactive", "Lacking Match Fitness",
               "Transfer negotiations", "Personal reasons", "Rest",
               "Not in squad", "Contract issues",
               "Red card Suspended", "Suspension", "other", "Fitness")

clasificar <- function(m) {
  m <- tolower(trimws(ifelse(is.na(m), "", m)))
  case_when(
    grepl("hamstring",                                m) ~ "Isquiotibiales",
    grepl("thigh|quadriceps",                         m) ~ "Muslo/Cuádriceps",
    grepl("calf",                                     m) ~ "Gemelo/Sóleo",
    grepl("groin|adductor",                           m) ~ "Aductores",
    grepl("muscle|muscular|torn muscle fibre",        m) ~ "Muscular sin especificar",
    grepl("knee|meniscus|cruciate|acl|ligament",      m) ~ "Rodilla",
    grepl("ankle|foot|toe|metatars",                  m) ~ "Tobillo/Pie",
    grepl("achilles|tendon",                          m) ~ "Tendón",
    grepl("back|hip|pelvi|abdominal",                 m) ~ "Tronco",
    grepl("shoulder|arm|wrist|hand|elbow|collarbone", m) ~ "Miembro superior",
    grepl("illness|virus|covid|fever",                m) ~ "Enfermedad",
    grepl("concussion|head|face|nose|eye",            m) ~ "Cabeza",
    grepl("broken|fracture",                          m) ~ "Fractura",
    grepl("wound|contusion",                          m) ~ "Traumatismo",
    grepl("injury|injured|knock|doubtful",            m) ~ "Sin especificar",
    TRUE ~ "Otro"
  )
}

lim <- les %>%
  filter(tipo == "Missing Fixture",          # se perdió el partido de verdad
         !motivo %in% no_lesion,
         !is.na(motivo)) %>%
  mutate(grupo = clasificar(motivo))

saveRDS(lim, "lesiones_limpio.rds")

cat(sprintf("De %d a %d registros\n", nrow(les), nrow(lim)))
print(sort(table(lim$grupo), decreasing = TRUE))
cat(sprintf("\nJugadores: %d | Equipos: %d\n",
            length(unique(lim$jugador_id)), length(unique(lim$equipo_id))))