# Tareas: feat-productivity-tools

## Resumen del Cambio

Este cambio introduce dos nuevas skills SDD para enriquecer el flujo de trabajo: `sdd-review` (auditoría estática de código contra especificaciones) y `sdd-split` (división de proposals monolíticas en sub-cambios manejables). También actualiza el ecosistema SDD para registrar los nuevos comandos.

---

## Fase 1: Infraestructura de sdd-review

Esta fase establece la base de la skill de auditoría estática, creando la estructura del archivo SKILL.md y los componentes necesarios para el análisis.

- [x] 1.1 Crear estructura del archivo `skills/sdd-review/SKILL.md` con la cabecera estándar de skill SDD
- [x] 1.2 Implementar la sección de propósito en SKILL.md, diferenciando sdd-review de sdd-verify (estático vs dinámico)
- [x] 1.3 Implementar la lógica de recepción de contexto: lectura de proposal.md, specs/**/*.md y design.md
- [x] 1.4 Implementar el módulo de análisis estático de código: lectura de archivos fuente modificados, identificación de funciones y estructuras
- [x] 1.5 Implementar la lógica de comparación contra especificaciones: verificación de firmas de funciones, flujos de datos y cumplimiento de requisitos
- [x] 1.6 Implementar el generador de reporte con formato estructurado (APROBADO/ADVERTENCIAS/BLOQUEADO)
- [x] 1.7 Implementar las verificaciones de objetividad: no emitir opiniones sobre estilo, basarse exclusivamente en specs
- [x] 1.8 Implementar la integración con el orquestador: protocolo de contexto estándar y retorno estructurado

---

## Fase 2: Infraestructura de sdd-split

Esta fase construye la skill de división de proposals, estableciendo la estructura y los algoritmos necesarios para particionar propuestas grandes.

- [x] 2.1 Crear estructura del archivo `skills/sdd-split/SKILL.md` con la cabecera estándar de skill SDD
- [x] 2.2 Implementar la sección de propósito en SKILL.md: dividir proposals monolíticas en sub-cambios manejables
- [x] 2.3 Implementar la lógica de recepción de proposal: lectura y parseo de proposal.md, validación de existencia
- [x] 2.4 Implementar el algoritmo de identificación de componentes independientes: análisis de secciones y áreas afectadas
- [x] 2.5 Implementar el módulo de análisis de dependencias: mapeo de relaciones entre áreas, detección de dependencias circulares
- [x] 2.6 Implementar el generador de plan de partición: estructura con sub-cambios, dependencias y justificaciones
- [x] 2.7 Implementar la generación de comandos /sdd-new sugeridos en orden de implementación
- [x] 2.8 Implementar los criterios de partición: verificable en una oración, alcance menor, implementable en sesión razonable
- [x] 2.9 Implementar el retorno de resultado estructurado: status (aprobado/advertencias/bloqueado), plan, comandos, recomendaciones

---

## Fase 3: Integración con el Ecosistema

Esta fase actualiza los archivos del ecosistema SDD para registrar y soportar los nuevos comandos y skills.

- [x] 3.1 Leer el archivo actual `skills/_shared/orchestrator-core.md` para identificar la sección de comandos
- [x] 3.2 Agregar el comando `/sdd-review` a la lista de comandos disponibles en orchestrator-core.md
- [x] 3.3 Agregar el comando `/sdd-split` a la lista de comandos disponibles en orchestrator-core.md
- [x] 3.4 Actualizar el contador de comandos de 10 a 12 en orchestrator-core.md
- [x] 3.5 Leer el archivo actual `scripts/install.sh` para identificar el contador de skills
- [x] 3.6 Actualizar el contador de skills de 10 a 12 en install.sh
- [x] 3.7 Actualizar los mensajes de salida de install.sh para reflejar "12 skills"
- [x] 3.8 Leer el archivo actual `scripts/install_test.sh` para identificar EXPECTED_SKILLS
- [x] 3.9 Actualizar EXPECTED_SKILLS de 10 a 12 en install_test.sh
- [x] 3.10 Actualizar los mensajes de verificación en install_test.sh para reflejar 12 skills

---

## Fase 4: Verificación e Integración

Esta fase valida que las nuevas skills y las actualizaciones del ecosistema funcionen correctamente.

- [x] 4.1 Ejecutar `scripts/install.sh` y verificar que completa sin errores
- [x] 4.2 Ejecutar `scripts/install_test.sh` y verificar que pasa con EXPECTED_SKILLS=12
- [x] 4.3 Verificar que los archivos `skills/sdd-review/SKILL.md` y `skills/sdd-split/SKILL.md` existen en el directorio de instalación
- [x] 4.4 Verificar que los nuevos comandos aparecen en la lista de orchestrator-core.md
- [ ] 4.5 Crear un test de integración: invocar /sdd-review con un cambio de prueba y verificar el formato del reporte
- [ ] 4.6 Crear un test de integración: invocar /sdd-split con una proposal de prueba y verificar los comandos sugeridos

---

## Orden de Implementación Recomendado

El orden recomendado prioriza la creación de las skills antes de su integración:

1. **Fase 1** debe completarse completamente antes de la Fase 3, ya que sdd-review debe existir para poder ser registrada.
2. **Fase 2** puede ejecutarse en paralelo con la Fase 1, ya que son skills independientes.
3. **Fase 3** requiere que las dos skills existan previamente (Fase 1 y 2).
4. **Fase 4** debe ejecutarse al final para validar todo el cambio.

**Razón**: Este orden evita bloqueos donde se intenta registrar un comando que apunta a una skill que no existe aún.

---

## Dependencias entre Tareas

| Tarea | Depende de |
|-------|------------|
| 1.1-1.8 | Ninguna (Fase 1 completa) |
| 2.1-2.9 | Ninguna (Fase 2 completa) |
| 3.1-3.4 | 1.1-1.8 y 2.1-2.9 (las skills deben existir) |
| 3.5-3.7 | Ninguna (scripts independientes) |
| 3.8-3.10 | 3.5-3.7 (lectura previa del archivo) |
| 4.1-4.6 | 3.1-3.10 (todo debe estar integrado) |

---

## Notas de Verificación

- Las tareas 4.5 y 4.6 requieren un cambio de prueba con proposal y specs creadas específicamente para testing
- El test de idempotencia de install.sh (ejecutar dos veces) debe verificar que las skills no se duplican
- La verificación de orchestrator-core.md debe confirmar que los dos nuevos comandos siguen el mismo formato que los existentes
