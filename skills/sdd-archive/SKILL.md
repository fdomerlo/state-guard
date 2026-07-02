---
name: sdd-archive
description: >
  Sincroniza especificaciones delta con las especificaciones principales y archiva un cambio completado.
  Disparador: Cuando el usuario ejecuta /sdd-archive para archivar un cambio después de la implementación y verificación.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# SDD-Archive Skill

## Propósito

Skill responsable del **ARCHIVADO**. Fusiona las specs delta en las specs principales (fuente de verdad), y luego mueve la carpeta del cambio al archivo. Completa el ciclo SDD.

## Qué Hacer

### Paso 0: Control de Bloqueantes Previos

Verifica explícitamente en el directorio del cambio si los archivos `review-report.md` o `verify-report.md` contienen reportes clasificados como **CRITICAL**. Si los contienen, **ABORTAR INMEDIATAMENTE** la ejecución. Solo se puede archivar una especificación que está funcional y validada.

### Paso 1: Verificar Estado Git Antes de Archivar

Antes de sincronizar specs y mover al archivo, DEBES verificar estrictamente el estado del repositorio mediante la terminal:

1. Ejecuta: `git status --porcelain`
2. Si la salida está **vacía**, el repositorio está limpio. Continúa con el Paso 2.
3. Si la salida **NO está vacía** (hay archivos listados), hay cambios sin commitear. DEBES BLOQUEAR el archivado, ejecutar ROLLBACK y exigir al usuario que haga commit.

### Paso 2: Sincronizar Specs Delta con Specs Principales

Para cada spec delta en `.agentify/changes/{nombre-del-cambio}/specs/`:

#### Si Existe la Spec Principal (`.agentify/specs/{dominio}/spec.md`)

```text
PARA CADA SECCIÓN en spec delta:
├── Requisitos AGREGADOS → Agregar a la spec principal
├── Requisitos MODIFICADOS → Reemplazar el requisito coincidente
└── Requisitos ELIMINADOS → Eliminar el requisito coincidente
```

**Fusionar con cuidado:**
- Hacer coincidir requisitos por nombre
- Preservar TODOS LOS OTROS requisitos que no están en el delta
- Mantener el formato Markdown correcto

#### Si NO Existe la Spec Principal

La spec delta es una spec completa. Copiarla directamente a `.agentify/specs/{dominio}/spec.md`.

### Paso 3: Mover al Archivo

```text
.agentify/changes/{nombre-del-cambio}/
  → .agentify/changes/archive/YYYY-MM-DD-{nombre-del-cambio}/
```

Usar la fecha de hoy en formato ISO.

### Paso 4: Verificar el Archivado

Confirmar:

- [ ] Specs principales actualizadas correctamente
- [ ] Carpeta del cambio movida al archivo
- [ ] El archivo contiene todos los artefactos
- [ ] El directorio de cambios activos ya no tiene este cambio

### Paso 5: Reportar

```markdown
## Cambio Archivado

**Cambio**: {nombre-del-cambio}
**Archivado en**: .agentify/changes/archive/{YYYY-MM-DD}-{nombre-del-cambio}/

### Specs Sincronizadas
| Dominio    | Acción             | Detalles                                         |
|------------|--------------------|--------------------------------------------------|
| {dominio}  | Creado/Actualizado | {N agregados, M modificados, K eliminados}       |

### Ciclo SDD Completo
El cambio ha sido planificado, implementado, verificado y archivado completamente.
Listo para el siguiente cambio.
```

## Reglas

- NUNCA archivar si `review-report.md` O `verify-report.md` contienen issues CRITICAL
- SIEMPRE verificar el estado git ANTES de sincronizar specs
- Si hay CUALQUIER cambio sin commitear, BLOQUEAR el archivado
- SIEMPRE sincronizar las specs delta ANTES de mover al archivo
- Al fusionar en specs existentes, PRESERVAR los requisitos no mencionados en el delta
- Usar formato de fecha ISO (YYYY-MM-DD) como prefijo de la carpeta de archivo
- Si la fusión sería destructiva (eliminando secciones grandes), ADVERTIR y pedir confirmación
- El archivo es un RASTRO DE AUDITORÍA — nunca eliminar ni modificar cambios archivados
- Si `.agentify/changes/archive/` no existe, crearlo
- Aplicar cualquier `rules.archive` de `.agentify/config.yaml`
