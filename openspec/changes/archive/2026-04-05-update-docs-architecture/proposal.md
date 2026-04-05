# Proposal: update-docs-architecture

## Intención

Actualizar la documentación oficial del repositorio para reflejar la nueva arquitectura modular, las estrategias de ahorro de tokens y las herramientas de recuperación de sesión.

## Alcance

**Archivos objetivo**:
- `MANUAL.md` - Agregar documentación de comandos
- `README.md` - Actualizar arquitectura y tabla de comandos
- `AGENTS.md` - Actualizar directivas de contexto

**Características a documentar**:
1. `/sdd-checkpoint` - Guardado de sesión en state.yaml
2. `/sdd-rollback` - Reversión de emergencia (botón de pánico)
3. Batching de tareas - Optimización de tokens
4. Inyección modular de contexto
5. Specs Delta para sub-agentes

## Enfoque

1. **MANUAL.md**: Agregar sección "Herramientas de Recuperación" con checkpoint y rollback
2. **README.md**: Actualizar diagrama de arquitectura y tabla de comandos
3. **AGENTS.md**: Actualizar directivas para especificar que sub-agentes leen specs delta únicamente

## Reglas de Implementación

- Documentación pragmática y directa para usuarios técnicos
- Todo nuevo comando debe estar en MANUAL.md
- Enfoque en la utilidad práctica sobre extensión textual

## Criterios de Éxito

- [ ] MANUAL.md con sdd-checkpoint
- [ ] MANUAL.md con sdd-rollback
- [ ] README.md menciona batching de tareas
- [ ] README.md menciona inyección modular de contexto
- [ ] AGENTS.md refleja specs delta para sub-agentes