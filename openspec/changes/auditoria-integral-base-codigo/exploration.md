# Exploración: Auditoría integral del repositorio agentify-sdd

## Estado Actual

El repositorio agentify-sdd es un meta-proyecto SDD (Spec-Driven Development) que consiste en skills Markdown para orquestar agentes de IA, scripts Bash/PowerShell para instalación, y un sistema de archivos OpenSpec para persistencia. Tras analizar los archivos principales del código base, se identificaron múltiples inconsistencias, deuda técnica remanente y errores de lógica potenciales que requieren corrección.

El sistema actualmente funciona con 15 skills SDD (sdd-apply, sdd-archive, sdd-changelog, sdd-design, sdd-explore, sdd-fix, sdd-init, sdd-propose, sdd-review, sdd-spec, sdd-split, sdd-status, sdd-tasks, sdd-verify) más skill-registry para un total de 15 habilidades. El script de instalación soporta múltiples agentes de IA (Claude Code, OpenCode, Gemini CLI, Codex, VS Code, Antigravity, Cursor) con configuración específica por plataforma.

La instalación se realiza mediante scripts Bash (install.sh) y PowerShell (install.ps1) que copian skills, inyectan configuración en archivos de entorno de cada herramienta, y validan la estructura del repositorio. El sistema de almacenamiento OpenSpec define convenciones estrictas para rutas de artefactos, schema de state.yaml, y transiciones de fase.

## Áreas Afectadas

- `scripts/install.sh` — Presenta deuda técnica en forma de placeholder genérico en mensaje de error (línea 310), uso de `|| true` que oculta errores silenciosamente (línea 364), y script inline de Python complejo que dificulta mantenimiento. Adicionalmente, el mensaje de error sugiere clonar desde una URL placeholder en lugar de la URL real del repositorio.

- `skills/_shared/openspec-convention.md` — La tabla de rutas de artefactos (línea 41) indica que sdd-archive actualiza specs, pero la convención de archivo establece que solo debe mover la carpeta. Esta incoherencia entre el contrato y el comportamiento esperado puede causar confusión en implementadores.

- `README.md` — La tabla de comandos (líneas 25-42) omite el comando `/sdd-propose` a pesar de que la skill existe y está completamente implementada. Esta omisión genera una brecha entre la documentación principal y la funcionalidad real del sistema.

- `skills/_shared/orchestrator-core.md` — La documentación de comandos (línea 59) clasifica `/sdd-ff` como meta-comando sin explicar claramente la diferencia entre meta-comandos y comandos directos. Esta ambigüedad puede confundir a usuarios nuevos que consulten la documentación.

- `scripts/install_test.sh` — Los tests esperan 17 comandos de OpenCode pero el glob muestra 16 archivos más sdd-design.md, totalizando 17. La validación es correcta pero el test podría ser más explícito sobre qué comandos espera.

## Enfoques

1. **Corrección incremental de documentación** — Enfocarse en actualizar únicamente los archivos de documentación que presentan inconsistencias menores, como el README.md y las descripciones en orchestrator-core.md. Este enfoque prioriza cambios de bajo riesgo que mejoran la coherencia sin alterar la funcionalidad.

   - Ventajas: Bajo riesgo de introducir errores, cambios rápidos de implementar, mejora inmediata de la experiencia de usuario. No requiere modificaciones en scripts o lógica de negocio.
   
   - Desventajas: No aborda la deuda técnica en el código de instalación, deja pendiente el problema del placeholder de URL, no resuelve el problema de manejo de errores silenciosos.
   
   - Esfuerzo: Bajo

2. **Refactorización completa del script de instalación** — Realizar una revisión profunda del install.sh para corregir errores de lógica, eliminar el uso de `|| true` que oculta fallos, reemplazar el script inline de Python por alternativas más mantenibles, y corregir el mensaje de error con la URL correcta del repositorio.

   - Ventajas: Elimina deuda técnica significativa, mejora la robustez del sistema de instalación, previene errores silenciosos que pueden ser difíciles de diagnosticar, proporciona mensajes de error más útiles para usuarios.
   
   - Desventajas: Mayor riesgo de introducir regresiones si no se testean todos los casos, requiere tiempo de desarrollo y pruebas exhaustivas, puede afectar la compatibilidad con versiones anteriores si se modifican comportamientos esperados.
   
   - Esfuerzo: Alto

3. **Auditoría completa de coherencia de contratos** — Verificar que todos los archivos de convención (_shared) coincidan exactamente con las implementaciones en las skills. Específicamente, revisar la tabla de artefactos de openspec-convention.yaml y confirmar que sdd-archive solo mueve archivos sin actualizar specs delta.

   - Ventajas: Garantiza consistencia entre documentación y código, previene confusiones futuras durante desarrollo, establece un precedente de disciplina en el proyecto.
   
   - Desventajas: Requiere análisis detallado de cada skill para verificar adherencia a convenciones, puede revelar inconsistencias adicionales no previstas inicialmente.
   
   - Esfuerzo: Medio

## Recomendación

Se recomienda adoptar un enfoque híbrido que combine los tres enfoques propuestos. Primero, ejecutar la corrección incremental de documentación (esfuerzo bajo) para resolver las omisiones en README.md y las ambigüedades en orchestrator-core.md. Esto proporciona victorias rápidas mientras se planifica el trabajo más significativo.

Segundo, realizar la auditoría de coherencia de contratos (esfuerzo medio) como segunda prioridad, antes de abordar la refactorización del script de instalación. Este orden asegura que la documentación esté corregida antes de que cambios mayores en el código puedan volver a introducir inconsistencias.

Tercero, programar la refactorización del install.sh (esfuerzo alto) para una iteración posterior, dado que requiere pruebas extensivas y tiene mayor potencial de impacto en usuarios existentes. Este trabajo debe incluir tests adicionales que validen el comportamiento de manejo de errores.

La razón de este orden es pragmática: los cambios de documentación tienen el mayor retorno sobre inversión inicial con el menor riesgo, y establecen las bases para un trabajo de refactorización más complejo donde las convenciones actualizadas servirán como referencia para validación.

## Riesgos

- Riesgo de regresión en script de instalación: Al modificar install.sh, existe la posibilidad de introducir errores que afecten la experiencia de usuario durante la instalación. Para mitigar este riesgo, se debe ejecutar el suite completo de tests (install_test.sh) antes de cualquier deployment y considerar un período de beta testing con usuarios del repositorio.

- Riesgo de inconsistencia temporal: Mientras se corrigen documentos en diferentes archivos, podría crearse un período donde algunas partes estén actualizadas y otras no. Para mitigar este riesgo, se deben actualizar todos los documentos relacionados en una sola sesión de trabajo o usar un checklist de verificación.

- Riesgo de documentación desactualizada futura: Sin un proceso de revisión de documentación vinculado al flujo SDD, las nuevas skills o comandos podrían sufrir el mismo problema de desincronización. Se recomienda incluir una verificación de coherencia de documentación como parte del checklist de la skill sdd-verify.

## Listo para Propuesta

Sí. El orquestador debe comunicar al usuario que se ha completado una auditoría integral del código base y se identificaron las siguientes áreas de mejora: corrección de documentación en README.md (agregar comando /sdd-propose faltante), refinamiento de descripciones en orchestrator-core.md para aclarar la diferencia entre meta-comandos y comandos directos, y refactorización programada del script install.sh para mejorar robustez y corregir manejo de errores.

La auditoría reveló que el sistema core está bien diseñado y las skills están correctamente implementadas. Los problemas encontrados son de naturaleza cosmética y de mantenimiento, no críticos para el funcionamiento del sistema. La propuesta debería presentarse como mejoras incrementales de calidad más que como correcciones de bugs críticos.
