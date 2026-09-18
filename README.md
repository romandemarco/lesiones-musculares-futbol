# Lesiones musculares en el fútbol europeo

Análisis de 31.203 registros de ausencias en las cinco grandes ligas europeas,
temporadas 2024/25 a 2026/27. El foco está en las lesiones musculares:
frecuencia, duración y, sobre todo, recurrencia.

**[📊 Ver la presentación interactiva](https://romandemarco.github.io/lesiones-musculares-futbol/presentacion_lesiones.html)**

---

## La pregunta

"Muscular" agrupa cosas distintas: isquiotibiales, cuádriceps, gemelo,
aductores. ¿Se diferencian en algo que sirva para planificar?

## Los hallazgos

**En duración, no se diferencian.** Los cuatro subtipos tienen una mediana de
2 a 3 partidos perdidos, y en los cuatro el 90% de los casos se resuelve en
menos de nueve. Saber qué músculo se lesionó no ayuda a estimar cuánto tiempo
estará afuera el jugador.

**En recurrencia, sí.** Isquiotibiales y cuádriceps recaen el doble que aductores
y gemelo.

| Subtipo | Jugadores | Tasa de recaída |
|---|---|---|
| Isquiotibiales | 224 | 17,9% |
| Cuádriceps y muslo | 504 | 17,5% |
| Aductores | 167 | 11,4% |
| Gemelo y sóleo | 254 | 9,4% |

De cada seis jugadores que se lesionan los isquiotibiales o el cuádriceps, uno
vuelve a lesionarse el mismo músculo. En aductores y gemelo es uno de cada diez.

Dos explicaciones clínicas son posibles, y los datos no permiten separarlas: la
exigencia biarticular —los isquiotibiales cruzan cadera y rodilla, y en el
cuádriceps solo el recto femoral hace algo parecido— o el tipo de fibra, ya que
isquiotibiales y cuádriceps predominan en fibras rápidas y el sóleo en fibras
lentas. La fuente registra "lesión de muslo" sin aclarar qué músculo
exactamente.

## Validación contra la literatura

|  | Este análisis | UEFA Elite Club Injury Study |
|---|---|---|
| Recaída muscular | 17% | 16% |
| Musculares sobre el total | 39% | 31% |
| Isquiotibiales dentro de musculares | 20% | 37% |

La tasa de recaída coincide, pese a que este trabajo usa reportes públicos y el
estudio de la UEFA parte de partes médicos de clubes. La distribución por
subtipo sí difiere: los isquiotibiales aparecen sub-representados, y la causa
probable es que el 45% de los casos musculares no tiene subtipo especificado.

Las definiciones de recaída no son idénticas —la UEFA usa ventanas temporales
específicas y acá se cuenta cualquier repetición del mismo subtipo en tres
temporadas— así que la coincidencia vale como orden de magnitud.

---

## Método

**Fuente.** API-Football, endpoint `injuries`. Cada registro representa un
partido que un jugador se perdió, con el motivo declarado por el club.

**Limpieza.** Se descartaron 5.822 registros que no eran lesión: suspensiones,
convocatorias a selección, decisiones técnicas, negociaciones de traspaso. Los
motivos vienen como texto libre y con nomenclatura inconsistente entre
temporadas ("Muscle Injury" en una, "Injured Doubtful" en otra), por lo que se
agruparon mediante expresiones regulares en 16 categorías.

**Construcción de episodios.** La fuente registra una fila por partido perdido.
Para obtener lesiones con duración se agruparon las ausencias consecutivas del
mismo jugador y mismo tipo separadas por menos de 45 días. Resultado: 6.329
episodios de 2.640 jugadores.

**Control metodológico.** Medir la gravedad en partidos perdidos podría
confundir duración con densidad de calendario: la misma lesión cuesta más
partidos si el equipo juega cada tres días. Se verificó y no ocurre — la
relación es de 7,1 a 7,9 partidos perdidos cada 30 días de baja en las cinco
ligas.

## Limitaciones

- **No se pueden comparar ligas.** Premier especifica el subtipo en el 72% de
  los casos y LaLiga en el 39%. Las diferencias son de reporte, no clínicas.
- **La rodilla no se desagrega.** El 96% de los registros dice únicamente
  "Knee Injury": no se separa un esguince de una rotura de ligamento cruzado.
- **No hay exposición.** Sin minutos jugados no se puede calcular incidencia por
  1.000 horas, el estándar en epidemiología deportiva. Todas las cifras son
  conteos absolutos.
- **El 45% de las musculares no tiene subtipo.** Y si los clubes son más vagos
  con las lesiones graves, ese grupo estaría sesgado hacia casos serios.

---

## Archivos

| Archivo | |
|---|---|
| `bajar_lesiones.R` | Descarga vía API y armado de la base cruda |
| `limpiar_lesiones.R` | Filtrado y clasificación en 16 categorías |
| `episodios.R` | Construcción de episodios con duración |
| `graficos.R` | Gráficos del informe (ggplot2) |
| `presentacion_lesiones.html` | Presentación interactiva, autocontenida |
| `informe_lesiones.pptx` | Versión editable |

## Cómo reproducirlo

```r
# 1. Crear un archivo .Renviron con la clave de api-football.com:
#    API_FOOTBALL_KEY=tu_clave
# 2. Correr en orden (15 requests en total):
source("bajar_lesiones.R")
source("limpiar_lesiones.R")
source("episodios.R")
source("graficos.R")
```

Requiere `dplyr`, `httr`, `jsonlite` y `ggplot2`.

Los archivos `.rds` no están en el repositorio: se regeneran con el primer
script y los datos pertenecen al proveedor de la API.

---

## Líneas futuras

- Incorporar minutos jugados (`fixtures/lineups`) para calcular incidencia por
  exposición y modelar carga acumulada previa a la lesión.
- Cruzar con densidad de calendario: días de descanso entre partidos.
- Modelo de riesgo individual: estimar probabilidad de recaída en función del
  tiempo transcurrido desde el alta.

---

**Román Demarco** · Estudiante de Kinesiología y Fisiatría (UNAHUR)
romandemarco39@gmail.com · [github.com/romandemarco](https://github.com/romandemarco)
