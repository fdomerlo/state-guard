# Diseño: Auditoría Integral del Repositorio agentify-sdd

## Enfoque Técnico

Ejecutar auditoría sistemática comparando archivos del código base contra las specs definidas en `specs/calidad/spec.md`. Categorizar hallazgos en errores críticos, incoherencias y mejoras de documentación. Cada hallazgo incluye ubicación exacta, problema y corrección propuesta.

## Hallazgos de Auditoría

### 🔴 Errores Críticos

#### Hallazgo: Comando `/sdd-propose` faltante en README

- **Archivo**: `README.md`
- **Línea**: 25-42 (tabla de comandos)
- **Problema**: La tabla de comandos no incluye `/sdd-propose`, aunque está implementado en `orchestrator-core.md:58` y es requerido por la spec.
- **Corrección**: Agregar fila en la tabla entre `/sdd-review` y `/sdd-spec`:
  ```
  | `/sdd-propose <nombre>` | Crea o itera sobre una propuesta de cambio de manera independiente. |
  ```

#### Hallazgo: Placeholder en URL de error de validación

- **Archivo**: `scripts/install.sh`
- **Línea**: 311
- **Problema**: El mensaje de error muestra `https://github.com/TU-USUARIO/agentify-sdd.git` en lugar de una URL válida del repositorio.
- **Corrección**: Reemplazar con variable `$REPO_URL` o hardcodear la URL canónica `https://github.com/ctrbts/agentify-sdd.git`.

### 🟡 Incoherencias

#### Hallazgo: Falta diferenciación visual de meta-comandos

- **Archivo**: `skills/_shared/orchestrator-core.md`
- **Líneas**: 45-59
- **Problema**: La lista de comandos no distingue visualmente entre meta-comandos (/sdd-new, /sdd-continue, /sdd-ff) y comandos directos (/sdd-propose, /sdd-spec, etc.). La nota en línea 59 es insuficiente.
- **Corrección**: Crear dos subsecciones: "Meta-comandos de Orquestación" y "Skills Directos". Alternativamente, usar emoji o badge visual.

#### Hallazgo: Descripción parcial de sdd-archive en convención

- **Archivo**: `skills/_shared/openspec-convention.md`
- **Línea**: 40-41
- **Problema**: La tabla indica "Mueve" y "Actualiza" para sdd-archive, pero la descripción de archivos en líneas 172-179 solo menciona el movimiento, no la fusión de deltas.
- **Corrección**: En sección "Estructura del Archivo Histórico" agregar: "Al archivar, los specs delta en `specs/{dominio}/` se fusionan automáticamente con los specs principales."

### 🟢 Mejoras de Documentación (Aprobadas)

**Nota del arquitecto**: Los siguientes items fueron revisados y aprobada su corrección:
- El script Python inline se mantiene dentro de install.sh (archivo autónomo)
- El uso de `|| true` se conserva intencionalmente para idempotencia en sistemas Windows/WSL

## Decisiones de Arquitectura

### Decisión: Priorización de correcciones

**Elección**: Corregir primero errores críticos (README + URL), luego incoherencias, luego mejoras.
**Justificación**: Los errores críticos rompen funcionalidad visible. Las incoherencias confunden a nuevos operadores. Las mejoras son técnicas pero de menor impacto.

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `README.md` | Modificar | Agregar fila `/sdd-propose` en tabla de comandos |
| `scripts/install.sh` | Modificar | Corregir URL placeholder |
| `skills/_shared/orchestrator-core.md` | Modificar | Separar meta-comandos de comandos directos |
| `skills/_shared/openspec-convention.md` | Modificar | Documentar fusión de deltas en sección de archivo |

## Preguntas Abiertas

Ninguna. Plan limpio y aprobado.
