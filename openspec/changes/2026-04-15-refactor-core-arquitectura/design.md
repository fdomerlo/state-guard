# Diseño: Refactor Core Arquitectura

## Enfoque Técnico

El enfoque estructural busca aliviar dependencias rígidas modificando puntualmente las especificaciones de sub-agentes base del framework. Refactorizaremos el diseño de los `state.yaml`, instruiremos a las rutinas a tolerar valores antiguos de la propiedad abolida en modo retrocompatible, consolidaremos una sintaxis POSIX restrictiva en scripts clave e implementaremos revisiones pasivas de control previo en el empaquetado del archivo.

## Decisiones de Arquitectura

### Decisión: Manejo de Retrocompatibilidad en sdd-fix

**Elección**: El sub-agente asignado a auditar la corrección en `skills/sdd-fix/SKILL.md` indicará purgar limpiamente los casos en que detecte `blocked` en boolean al reescribir/evaluar. Analizará `status`; de no hallarlo y solo presentarse `blocked: true`, forzará la transcripción al estado `status: blocked` para luego truncar el boleano.
**Alternativas consideradas**: Generar un scrapper masivo que sobreescriba todos los previos manual e inicialmente.
**Justificación**: Una migración pasiva a través de parseos lazy (como se solicita) reduce impacto a IO y no compromueve corrimientos con estados que los usuarios ya hayan marcado para resguardo.

### Decisión: Soporte Shell Neutro (POSIX en `install.sh`)

**Elección**: Ajustaremos las comparaciones relativas a dependencias shell strict, empleando `[ "$1" = "--all-global" ]` y evitando operadores doble-corchete o sintaxis array exclusivas de Bash que romperían invocaciones base vía `/bin/sh`.
**Alternativas consideradas**: Enforce del framework a Bash v4+.
**Justificación**: Contradice la necesidad solicitada de persistencia universal sin roturas en plataformas Mac/Linux nativas.

## Flujo de Datos

La estructura se aligera logrando un ducto recto:
    Orquestador ──→ state.yaml (Solo key "Status" provee info general de sanidad)
                        │ │
                        │ └──── Archivo retro-compatible persistente
                        │
                  Sub-Agente ─── Evalúa el archivo
                  
## Cambios de Archivos

| Archivo | Acción | Descripción |
|---|---|---|
| `skills/_shared/orchestrator-state.md` | Modificar | Expurga de toda inyección booleana "blocked" en los plantillados base. |
| `skills/sdd-fix/SKILL.md` | Modificar | Ajuste de su lógica instructiva para admitir esquemas viejos y resolver la migración on-fly. |
| `skills/sdd-status/SKILL.md` | Modificar | Implementar renderizado basado en `status`. |
| `skills/sdd-apply/SKILL.md` | Modificar | Anexar el contrato explícito instruyendo al agente a encargarse del chequeo de tasks. |
| `skills/sdd-archive/SKILL.md` | Modificar | Declarar formalmente el "Paso 0" inhibitorio si halla logs CRITICAL. |
| `scripts/install.sh` | Modificar | Corrección POSIX del parser de flags orientados a delegación para antigravity. |
| `skills/sdd-rollback/SKILL.md` | Modificar | Limitar reversiones en cascada, removiendo limpieza paramétrica global. |

## Interfaces / Contratos

```yaml
# Nuevo Contrato Expectante de State.yaml (esquema unificado)
change: ...
started_at: "..."
last_updated: "..."
current_phase: tasks
status: active # Enum: active, done, blocked.
completed_phases: []
pending_phases: []
blocked_reason: null # Continua persistiendo para contextos. Desaparece el flag booleano.
```

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|---|---|---|
| Unidad/Manual | Compatibilidad de sintaxis `install.sh` | Validar via test shell el paso `[ ]` en /bin/sh. |

## Migración / Despliegue

La migración alinea transparentemente en tiempo real las instancias previas de `state.yaml` empleando el enrutador propuesto en `sdd-fix`.

## Preguntas Abiertas
- Ninguna.
