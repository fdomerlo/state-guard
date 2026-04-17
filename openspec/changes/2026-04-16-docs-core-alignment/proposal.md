# Propuesta: Alineación de Core Documentación SDD

## Intención

Afinar, actualizar y unificar el glosario y cuerpo principal de la documentación del proyecto (`README.md`, `MANUAL.md`, `AGENTS.md` y `CHANGELOG.md`) con las recientes modificaciones arquitectónicas en variables de estado, la redefinición determinista de los contratos por fase (particularmente en delegación), y los blindajes provistos a the shell scripts core a lo largo del soporte nativo POSIX y el scope-limiting rollaback.

## Alcance

### Dentro del Alcance
- **README.md**: Alteraciones puntuales para reforzar las menciones al pilar base referenciando la simplificación de "Arquitectura de Estado" y la supresión de falsos loops de memoria de los LLM interactuando.
- **MANUAL.md**:
  - Destrucción de documentaciones referidas al viejo field semántico de estado (`blocked`).
  - Documentar el "Paso 0", cortafuegos de dependencias operativas, que aborta `sdd-archive` ante existencias de logs `CRITICAL`.
  - Revisar y limpiar caracteres inválidos o "hallucinatory formatting" (ej. "报告" cerca de su línea 159).
  - Incluir el comportamiento del "Warm-boot" mediante la inyección y lectura del parametro temporal `session_summary`.
- **AGENTS.md**:
  - Completar un mapeo total en la tabla de comandos y skills, inyectando las directivas SDD accesorias y transversales faltantes (ej:/sdd-spec, /sdd-design, /sdd-tasks, /sdd-review, /sdd-split).
  - Estipular en la sección correspondiente el nuevo contrato del sub-agente frente el `tasks.md`, indicando que la modificación recae inherentemente en sus rutinas y no el orquestador principal.
  - Sintonizar los límites estáticos del framework en ventanas de conteos textuales.
- **CHANGELOG.md**:
  - Acuñación de una v1.1 general detallando este salto modular (Esquemas de estado, Delegación, POSIX scripts y limitación de rollback history cleanup).

### Fuera del Alcance
- Reducción o reescritura de workflows enteros.

## Enfoque

Emplearemos una serie de modificaciones interlineales guiadas por diff limitados con `multi_replace_file_content` para sostener inalterada la mayoría del contenido, con la estricta limitante de usar un tono pragmático y de alta ingeniería en cada texto ingresado.

## Áreas Afectadas

| Área | Impacto | Descripción |
|---|---|---|
| `README.md` | Bajo | Ajuste de features introductorios |
| `MANUAL.md` | Moderado | Actualización del framework flow |
| `AGENTS.md` | Significativo | Tabla ampliada y re-definición de políticas del límite |
| `CHANGELOG.md` | Bajo | Registro del bump de la v1.1. |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| Invalidez del formato MD por mala sintaxis de tablas o anidados. | Baja | Las herramientas de inyección mantendrán pipes de validación y testeo estructural previo a persistir los commits |

## Plan de Rollback

Se utilizará una iteración estricta de revisión; de fallar, siempre podemos revertir mediante checkout al último árbol persistido.

## Dependencias

- Nínguna.

## Criterios de Éxito

- [ ] Todas las 4 piezas documentales presentan sus estipulaciones obligatorias actualizadas en concordancia a las reglas de negocio declaradas.
- [ ] Residuos e incoherencias legadas removidos.
