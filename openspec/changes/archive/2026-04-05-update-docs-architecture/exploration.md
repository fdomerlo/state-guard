# Exploration: update-docs-architecture

## Summary

**status**: ok

**change**: update-docs-architecture

---

## Exploration Results

### 1. MANUAL.md - Estado Actual

**Existe**: Sí (`MANUAL.md` en raíz)

**Estructura actual**:
- Arquitectura DRY (compilación dinámica del orquestador, mecanismo de carga de skills)
- State Machine ACID (estructura de state.yaml)
- Configuración con config.yaml
- Flujos Avanzados (/sdd-split, /sdd-archive, /sdd-review, /sdd-fix)
- Estructura de Archivos OpenSpec

**Recomendaciones para actualización**:
- Agregar documentación de `sdd-checkpoint` para recuperación de sesión
- Agregar documentación de `sdd-rollback` para reversión de emergencia
- Actualizar sección de arquitectura para reflejar la nueva arquitectura modular

---

### 2. README.md - Estado Actual

**Existe**: Sí (`README.md` en raíz)

**Secciones actuales**:
- Instalación
- Comandos (tabla con comandos)
- Inicio Rápido
- Arquitectura (diagrama Mermaid con fases SDD)
- Conceptos Clave

**Recomendaciones para actualización**:
- Actualizar tabla de comandos para incluir `/sdd-checkpoint` y `/sdd-rollback`
- Agregar nueva sección sobre "Herramientas de Recuperación de Sesión"
- Actualizar diagrama de arquitectura

---

### 3. AGENTS.md - Estado Actual

**Existe**: Sí (`AGENTS.md` en raíz)

**Directivas actuales**:
- Descripción del Proyecto
- Comandos Disponibles
- Convenciones de Estilo
- State Machine
- Recuperación de Estado

**Recomendaciones para actualización**:
- Agregar directivas para sdd-checkpoint y sdd-rollback
- Documentar estrategias de optimización de tokens

---

### 4. Docs de Referencia

**sdd-checkpoint**: Skill existente con funcionalidad de checkpoint de sesión. Guarda `session_summary` en state.yaml.

**sdd-rollback**: Skill existente con funcionalidad de reversión de emergencia. Purga carpeta y restaura git.

---

## detailed_report

- MANUAL.md: requiere actualizar con nuevas features
- README.md: requiere actualizar tabla de comandos y arquitectura
- AGENTS.md: requiere agregar recuperación de sesión
- sdd-checkpoint: Skill existente con funcionalidad de checkpoint de sesión
- sdd-rollback: Skill existente con funcionalidad de reversión de emergencia

### next_recommended

sdd-propose