---
name: skill-registry
description: >
  Escanea el directorio ./skills/ e identifica skills no-SDD (excluyendo sdd-* y _shared).
  Genera un índice en ./.agentify/skill-registry.md con nombre, descripción, trigger y ubicación de cada skill descubierta.
license: MIT
metadata:
  author: ctrbts-steve
  version: "1.0"
---

**Disparador**: Ejecutar al inicio de una tarea o manualmente para actualizar el índice de skills disponibles.

## Propósito

Eres un sub-agente responsable de **escanear y registrar skills** disponibles en el proyecto. Tu objetivo es generar un índice actualizado de todas las skills no-SDD que el orquestador puede usar además de las fases SDD conocidas.

## Qué Recibís

Del orquestador:
- Directorio de skills a escanear (opcional, por defecto `./skills/`)

## Qué Hacer

### Paso 1: Ejecutar el Script de Escaneo

Ejecuta el script bash POSIX incluido en este skill:

```sh
sh skills/skill-registry/scan.sh [directorio-skills]
```

El script:
- Escanea `./skills/` (o el directorio proporcionado)
- Ignora directorios que comienzan con `sdd-` y `_shared`
- Extrae nombre, descripción, trigger y ubicación de cada `SKILL.md`
- Genera el índice en `./.agentify/skill-registry.md`

### Paso 2: Devolver Resumen

RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md`

### Fallback (Para agentes sin Bash)

Si tu entorno de ejecución no te permite ejecutar scripts de bash (como en Cursor, VSCode Copilot o Codex), TIENES PROHIBIDO fallar silenciosamente. DEBES escanear manualmente el directorio local `./skills/`, ignorar las carpetas que empiecen con `sdd-` y la carpeta `_shared`, leer la descripción de los `SKILL.md` restantes, y generar tú mismo el archivo `.agentify/skill-registry.md` escribiendo la tabla Markdown con el formato requerido.

## Reglas

- Ejecutar el script desde la raíz del proyecto
- El script es POSIX puro (`#!/bin/sh`), no requiere bash ni dependencias externas
- El índice generado sobrescribe el anterior si existe
- Si no hay skills adicionales, el índice debe indicarlo explícitamente
