# Propuesta: Refactorización Core Modular

## Intención

Reducir el consumo de tokens en fases avanzadas (sdd-apply, sdd-verify) mediante la división del archivo monolítico `orchestrator-core.md` (~1298 palabras) en módulos especializados, y restringir la lectura de specs históricos. El objetivo es evitar la compactación del contexto y mantener la capacidad de los sub-agentes dentro de los límites de la ventana de contexto.

## Alcance

### Dentro del Alcance
- Dividir `skills/_shared/orchestrator-core.md` extrayendo 4 módulos a archivos separados en `_shared/`
- Modificar `sdd-apply/SKILL.md` para prohibir carga de `specs/` completo
- Modificar `sdd-verify/SKILL.md` para prohibir carga de `specs/` completo
- Implementar batching de tareas: pasar solo bloque de 3 tareas al sub-agente
- El orquestador actualiza `[x]` en tasks.md (no el sub-agente)

### Fuera del Alcance
- Modificar otras skills que no sean apply/verify
- Cambiar el formato de specs delta (se mantiene igual)
- Modificar la estructura de changes/

## Enfoque

1. Crear 4 nuevos módulos en `skills/_shared/`:
   - `orchestrator-delegation.md`: Reglas de delegación
   - `orchestrator-state.md`: Gestión de state.yaml + recovery
   - `orchestrator-commands.md`: Meta-comandos + grafo
   - `orchestrator-context.md`: Protocolo de contexto

2. Reducir `orchestrator-core.md` a ~600 palabras con referencias a los módulos

3. Actualizar sdd-apply y sdd-verify para consumir solo:
   - Specs delta activas (`openspec/changes/{nombre}/specs/`)
   - Diseño actual (`design.md` del cambio)
   - Bloque de tareas (no tasks.md completo)

## Áreas Afectadas

| Área | Impacto | Descripción |
|------|---------|-------------|
| `skills/_shared/orchestrator-core.md` | Modificado | Reducido a ~600 palabras |
| `skills/_shared/orchestrator-delegation.md` | Nuevo | Reglas de delegación |
| `skills/_shared/orchestrator-state.md` | Nuevo | Gestión de estado |
| `skills/_shared/orchestrator-commands.md` | Nuevo | Meta-comandos |
| `skills/_shared/orchestrator-context.md` | Nuevo | Protocolo de contexto |
| `skills/sdd-apply/SKILL.md` | Modificado | Restricción contexto + batching |
| `skills/sdd-verify/SKILL.md` | Modificado | Restricción contexto |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|------------|
| Referencias rotas enorchestrator-core.md | Baja | Verificar links tras migración |
| Sub-agente sin contexto suficiente | Media | Incluir diseño en cada batch |

## Plan de Rollback

```bash
git checkout -- skills/
```

## Criterios de Éxito

- [ ] orchestrator-core.md reducido a ~600 palabras (referencias a módulos)
- [ ] 4 nuevos módulos creados en _shared/
- [ ] sdd-apply tiene prohibido cargar specs/ completo
- [ ] sdd-verify tiene prohibido cargar specs/ completo
- [ ] sdd-apply recibe solo bloque de tareas (no tasks.md completo)
- [ ] El orquestador actualiza [x] en tasks.md
