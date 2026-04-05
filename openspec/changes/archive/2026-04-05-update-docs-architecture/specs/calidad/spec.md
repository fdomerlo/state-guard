# Especificación de Calidad - Documentación de Arquitectura

## Propósito

Esta especificación define los requisitos de calidad para actualizar la documentación oficial del proyecto, asegurando que los usuarios comprendan las nuevas funcionalidades de recuperación de sesión, optimización de tokens y arquitectura modular.

## Requisitos

### Requisito: Documentación de sdd-checkpoint

El sistema DEBE documentar el comando sdd-checkpoint en MANUAL.md para permitir a los usuarios guardar el estado de la sesión manualmente.

#### Escenario: Checkpoint documentado en MANUAL

- GIVEN MANUAL.md existe en la raíz del proyecto
- WHEN se agrega sección de herramientas de recuperación con sdd-checkpoint
- THEN la documentación explica que el comando guarda resumen en session_summary y permite recuperaciónmanual
- AND incluye ejemplo de uso: `/sdd-checkpoint`

#### Escenario: Checkpoint visible en tabla de comandos

- GIVEN MANUAL.md contiene tabla de comandos disponibles
- WHEN se actualiza la tabla
- THEN incluye fila con "sdd-checkpoint" y descripción breve

---

### Requisito: Documentación de sdd-rollback

El sistema DEBE documentar el comando sdd-rollback en MANUAL.md como herramienta de recuperación de emergencia.

#### Escenario: Rollback documentado en MANUAL

- GIVEN MANUAL.md existe en la raíz del proyecto
- WHEN se agrega documentación de sdd-rollback
- THEN la documentación lo presenta como "botón de pánico" para revertir cambios corruptos
- AND explica que purga la carpeta del cambio y restaura archivos desde git

#### Escenario: Advertencia de uso

- GIVEN MANUAL.md documenta sdd-rollback
- WHEN el usuario lee la documentación
- THEN encuentra advertencia clara sobre pérdida de trabajo no commiteado

---

### Requisito: Actualización de README con batching

El sistema DEBE actualizar README.md para documentar la estrategia de batching de tareas como método de optimización de tokens.

#### Escenario: README menciona batching

- GIVEN README.md existe en la raíz del proyecto
- WHEN se actualiza la sección de arquitectura
- THEN menciona explícitamente "batching de tareas" como característica de optimización
- AND explica brevemente su propósito: reducir overhead de contexto

---

### Requisito: Actualización de README con inyección modular

El sistema DEBE documentar la inyección modular de contexto en README.md para usuarios que implementan agentes.

#### Escenario: README menciona inyección modular

- GIVEN README.md existe en la raíz del proyecto
- WHEN se actualiza sección de arquitectura o diseño
- THEN incluye referencia a "inyección modular de contexto"
- AND la describe como técnica para cargar contexto relevante por tarea

---

### Requisito: Actualización de AGENTS.md para specs delta

El sistema DEBE actualizar AGENTS.md para especificar que los sub-agentes leen únicamente specs delta durante cambios.

#### Escenario: AGENTS refleja specs delta

- GIVEN AGENTS.md existe en la raíz del proyecto
- WHEN se actualizan las directivas de contexto
- THEN añadedirectiva que especifica: "sub-agentes leen specs delta de openspec/changes/{nombre}/specs/"
- AND excluye specs principales para evitar contaminación de contexto

---

### Requisito: Consistencia entre documentos

El sistema DEBE mantener consistencia terminológica entre MANUAL.md, README.md y AGENTS.md.

#### Escenario: Terminología unificada

- GIVEN los tres archivos se actualizan
- WHEN se comparan términos usados
- THEN todos usan "specs delta" para cambios activos
- AND usan "batching de tareas" consistentemente
- AND usan "inyección modular de contexto" sin variaciones

---

## Criterios de Verificación

- [ ] MANUAL.md contiene documentación de sdd-checkpoint con ejemplo
- [ ] MANUAL.md contiene documentación de sdd-rollback con advertencia
- [ ] README.md menciona batching de tareas
- [ ] README.md menciona inyección modular de contexto
- [ ] AGENTS.md especifica lectura de specs delta por sub-agentes
- [ ] Terminología consistente en los tres documentos