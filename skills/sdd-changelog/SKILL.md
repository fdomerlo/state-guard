---
name: sdd-changelog
description: >
  Genera automáticamente un CHANGELOG.md en la raíz del proyecto a partir de los cambios archivados en openspec/changes/archive/.
  Disparador: Cuando el usuario ejecuta /sdd-changelog o quiere generar un changelog desde los cambios archivados.
license: MIT
metadata:
  author: ctrbts-steve
  version: "1.0"
---

## Propósito

Eres un sub-agente responsable de **generar el changelog** del proyecto. Leés todos los cambios archivados en `openspec/changes/archive/` y generás un archivo `CHANGELOG.md` estructurado en la raíz del proyecto.

## Qué Recibís

Del orquestador:
- Nombre del proyecto (opcional, usa el directorio actual por defecto)
- Modo de almacenamiento de artefactos (`openspec | none`)

## Execution and Persistence Contract

Este sub-agente es responsable de la lectura directa en disco. El orquestador solo le provee el modo de almacenamiento y, opcionalmente, el nombre del proyecto.

- Si el modo es `openspec`: Escanea `openspec/changes/archive/` directamente en disco, lee los `proposal.md` de cada cambio archivado y genera el `CHANGELOG.md`.
- Si el modo es `none`: Devuelve solo el resumen sin escribir archivos.

## Qué Hacer

### Paso 1: Detectar el Directorio del Proyecto

Determiná la raíz del proyecto y el directorio de archive:

```
PROJECT_ROOT=.
ARCHIVE_DIR=openspec/changes/archive/
```

### Paso 2: Listar Cambios Archivados

Listá todas las carpetas en el directorio de archive que coincidan con el patrón `YYYY-MM-DD-*`:

```
openspec/changes/archive/
├── 2026-01-15-fix-auth-bug/
├── 2026-02-01-agregar-modo-oscuro/
└── 2026-03-01-mejora-rendimiento/
```

### Paso 3: Extraer Metadatos de Cada Cambio

Para cada carpeta archivada, leé el archivo `proposal.md` y extraé:

- **Título**: Nombre del cambio (del nombre de la carpeta, sin la fecha)
- **Intención**: Sección "## Intención" del proposal.md
- **Alcance**: Sección "### Dentro del Alcance" del proposal.md

### Paso 4: Generar CHANGELOG.md

Creá el archivo `CHANGELOG.md` en la raíz del proyecto con el siguiente formato:

```markdown
# Changelog

Todos los cambios completados y archivados en el proyecto.

Generado el: {Fecha de generación en formato ISO}

---

## [{Fecha}] {Nombre-del-Cambio}

**Intención**: {resumen de la intención}

**Alcance**:
- {item 1}
- {item 2}

---

## [{Fecha}] {Nombre-del-Cambio}

**Intención**: {resumen de la intención}

**Alcance**:
- {item 1}
```

**Ordenar los cambios por fecha (más reciente primero).**

### Paso 5: Manejar Archive Vacío

Si no hay cambios archivados, generá un CHANGELOG.md con el encabezado pero sin cambios:

```markdown
# Changelog

Todos los cambios completados y archivados en el proyecto.

Generado el: {Fecha}

---

Aún no hay cambios archivados. Los cambios aparecerán aquí después de ser archivados con /sdd-archive.
```

### Paso 6: Devolver Resumen

Devuelve al orquestador:

```markdown
## Changelog Generado

**Ubicación**: CHANGELOG.md
**Cambios incluidos**: {N}
**Fecha de generación**: {ISO date}

### Cambios Registrados
| Fecha       | Cambio              | Intención                              |
|-------------|---------------------|----------------------------------------|
| 2026-01-15 | fix-auth-bug        | Corregir bug en autenticación         |
| 2026-02-01  | agregar-modo-oscuro | Añadir tema oscuro a la aplicación    |

### Archivo
{CHANGELOG.md generado exitosamente / CHANGELOG.md actualizado}
```

## Reglas

- SIEMPRE extraer la intención y el alcance del proposal.md
- SIEMPRE ordenar los cambios por fecha (más reciente primero)
- Si el directorio de archive no existe, crear CHANGELOG.md vacío
- Si ya existe un CHANGELOG.md, regenerarlo completamente
- Usar el nombre de la carpeta (sin la fecha) como título del cambio
- Aplicar cualquier `rules.changelog` de `openspec/config.yaml` si existe

