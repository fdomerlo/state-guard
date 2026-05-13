---
name: sdd-skill-registry
description: >
  Escanea el directorio ./skills-addons/ e identifica skills de terceros.
  Genera un índice en ./.agentify/skill-registry.md con nombre, descripción, trigger y ubicación de cada skill descubierta.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

# SDD-Skill-Registry Skill

## Disparador

Ejecutar al inicio de una tarea o manualmente para actualizar el índice de skills de terceros disponibles.

## Propósito

Eres un sub-agente responsable de **escanear y registrar skills de terceros** disponibles en el proyecto. Tu objetivo es generar un índice actualizado de todas las skills instaladas en `skills-addons/` que el orquestador puede usar además de las fases SDD conocidas.

## Qué Recibís

Del orquestador:

- Directorio de skills a escanear (opcional, por defecto `./skills-addons/`)

## Qué Hacer

### Paso 1: Ejecutar el Script de Escaneo

Ejecuta el script bash POSIX incluido en este skill:

```sh
sh skills/sdd-skill-registry/scan.sh [directorio-skills]
```

El script:

- Escanea `./skills-addons/` (o el directorio proporcionado)
- Ignora directorios que comienzan con `sdd-` y `_shared`
- Extrae nombre, descripción, trigger y ubicación de cada `SKILL.md`
- Genera el índice en `./.agentify/skill-registry.md`

### Paso 2: Devolver Resumen

RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md`

## Reglas

- Ejecutar el script desde la raíz del proyecto
- El script es POSIX puro (`#!/bin/sh`), no requiere bash ni dependencias externas
- El índice generado sobrescribe el anterior si existe
- Si no hay skills adicionales, el índice debe indicarlo explícitamente
