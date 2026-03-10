---
name: sdd-archive
description: >
  Sincroniza especificaciones delta con las especificaciones principales y archiva un cambio completado.
  Disparador: Cuando el orquestador te lanza para archivar un cambio después de la implementación y verificación.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable del **ARCHIVADO**. Fusionás las specs delta en las specs principales (fuente de verdad), y luego movés la carpeta del cambio al archivo. Completás el ciclo SDD.

## Qué Recibís

Del orquestador:
- Nombre del cambio
- Modo de almacenamiento de artefactos (`openspec | none`)

## Execution and Persistence Contract

Lee y sigue `skills/_shared/persistence-contract.md` para las reglas de resolución de modo.

- Si el modo es `openspec`: Lee y sigue `skills/_shared/openspec-convention.md`. Recupera `verify-report`, `proposal`, `spec`, `design` y `tasks` como dependencias. Realiza la fusión de specs y movimiento de carpetas al archivo.
- Si el modo es `none`: Devuelve solo el resumen de cierre. No realizar operaciones de archivado de archivos.

## Qué Hacer

### Paso 1: Sincronizar Specs Delta con Specs Principales

Para cada spec delta en `openspec/changes/{nombre-del-cambio}/specs/`:

#### Si Existe la Spec Principal (`openspec/specs/{dominio}/spec.md`)

Lee la spec principal existente y aplica el delta:

```
PARA CADA SECCIÓN en spec delta:
├── Requisitos AGREGADOS → Agregar a la sección de Requisitos de la spec principal
├── Requisitos MODIFICADOS → Reemplazar el requisito coincidente en la spec principal
└── Requisitos ELIMINADOS → Eliminar el requisito coincidente de la spec principal
```

**Fusionar con cuidado:**
- Hacer coincidir requisitos por nombre (ej: "### Requisito: Expiración de Sesión")
- Preservar TODOS LOS OTROS requisitos que no están en el delta
- Mantener el formato Markdown y la jerarquía de encabezados correctos

#### Si NO Existe la Spec Principal

La spec delta ES una spec completa (no un delta). Copiarla directamente:

```bash
# Copiar nueva spec a las specs principales
openspec/changes/{nombre-del-cambio}/specs/{dominio}/spec.md
  → openspec/specs/{dominio}/spec.md
```

### Paso 2: Mover al Archivo

Mover toda la carpeta del cambio al archivo con prefijo de fecha:

```
openspec/changes/{nombre-del-cambio}/
  → openspec/changes/archive/YYYY-MM-DD-{nombre-del-cambio}/
```

Usar la fecha de hoy en formato ISO (ej: `2026-02-16`).

### Paso 3: Verificar el Archivado

Confirmar:
- [ ] Specs principales actualizadas correctamente
- [ ] Carpeta del cambio movida al archivo
- [ ] El archivo contiene todos los artefactos (proposal, specs, design, tasks)
- [ ] El directorio de cambios activos ya no tiene este cambio

### Paso 4: Devolver Resumen

Devuelve al orquestador:

```markdown
## Cambio Archivado

**Cambio**: {nombre-del-cambio}
**Archivado en**: openspec/changes/archive/{YYYY-MM-DD}-{nombre-del-cambio}/

### Specs Sincronizadas
| Dominio    | Acción             | Detalles                                         |
|------------|--------------------|--------------------------------------------------|
| {dominio}  | Creado/Actualizado | {N agregados, M modificados, K eliminados}       |

### Contenido del Archivo
- proposal.md ✅
- specs/ ✅
- design.md ✅
- tasks.md ✅ ({N}/{N} tareas completas)

### Fuente de Verdad Actualizada
Las siguientes specs ahora reflejan el nuevo comportamiento:
- `openspec/specs/{dominio}/spec.md`

### Ciclo SDD Completo
El cambio ha sido planificado, implementado, verificado y archivado completamente.
Listo para el siguiente cambio.
```

## Reglas

- NUNCA archivar un cambio que tenga issues CRITICAL en su reporte de verificación
- SIEMPRE sincronizar las specs delta ANTES de mover al archivo
- Al fusionar en specs existentes, PRESERVAR los requisitos que no están mencionados en el delta
- Usar formato de fecha ISO (YYYY-MM-DD) como prefijo de la carpeta de archivo
- Si la fusión sería destructiva (eliminando secciones grandes), ADVERTIR al orquestador y pedir confirmación
- El archivo es un RASTRO DE AUDITORÍA — nunca eliminar ni modificar cambios archivados
- Si `openspec/changes/archive/` no existe, crearlo
- Aplicar cualquier `rules.archive` de `openspec/config.yaml`
- Devolver un envelope estructurado con: `status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended` y `risks`
