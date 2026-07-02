---
name: sdd-design
description: >
  Crea el documento de diseño técnico con decisiones de arquitectura y enfoque.
  Disparador: Cuando el usuario ejecuta /sdd-design para escribir o actualizar el diseño técnico de un cambio.
license: MIT
metadata:
  author: fdomerlo-steve
  version: "3.0"
---

# SDD-Design Skill

## Propósito

Skill responsable del **DISEÑO TÉCNICO**. Toma la propuesta y las specs, y produce un `design.md` que captura CÓMO se implementará el cambio — decisiones de arquitectura, flujo de datos, cambios de archivos y justificación técnica.

## Qué Hacer

### Paso 1: Leer el Código Base

Antes de diseñar, lee el código real que será afectado:

- Puntos de entrada y estructura de módulos
- Patrones y convenciones existentes
- Dependencias e interfaces
- Infraestructura de testing (si existe)

### Paso 2: Escribir design.md

Crea el documento de diseño:

```text
openspec/changes/{nombre-del-cambio}/
├── proposal.md
├── specs/
└── design.md              ← Lo creas tú
```

#### Formato del Documento de Diseño

```markdown
# Diseño: {Título del Cambio}

## Enfoque Técnico

{Descripción concisa de la estrategia técnica general.
¿Cómo se relaciona con el enfoque de la propuesta? Hace referencia a las specs.}

## Decisiones de Arquitectura

### Decisión: {Título de la Decisión}

**Elección**: {Qué elegimos}
**Alternativas consideradas**: {Qué descartamos}
**Justificación**: {Por qué esta elección sobre las alternativas}

### Decisión: {Título de la Decisión}

**Elección**: {Qué elegimos}
**Alternativas consideradas**: {Qué descartamos}
**Justificación**: {Por qué esta elección sobre las alternativas}

## Flujo de Datos

{Describe cómo fluyen los datos a través del sistema para este cambio.
Usa diagramas ASCII o Mermaid cuando sea útil.}

    Componente A ──→ Componente B ──→ Componente C
         │                              │
         └──────── Store ───────────────┘

## Cambios de Archivos

| Archivo                      | Acción    | Descripción                          |
|------------------------------|-----------|--------------------------------------|
| `ruta/a/nuevo-archivo.ext`   | Crear     | {Qué hace este archivo}              |
| `ruta/a/existente.ext`       | Modificar | {Qué cambia y por qué}              |
| `ruta/a/archivo-viejo.ext`   | Eliminar  | {Por qué se elimina}                 |

## Interfaces / Contratos

{Define cualquier nueva interfaz, contrato de API, definiciones de tipos o estructuras de datos.
Usa bloques de código con el lenguaje del proyecto.}

## Estrategia de Testing

| Capa        | Qué Testear | Enfoque  |
|-------------|-------------|----------|
| Unitario    | {Qué}       | {Cómo}   |
| Integración | {Qué}       | {Cómo}   |
| E2E         | {Qué}       | {Cómo}   |

## Migración / Despliegue

{Si este cambio requiere migración de datos, feature flags o despliegue por fases, describe el plan.
Si no aplica, indicar "No se requiere migración."}

## Preguntas Abiertas

- [ ] {Cualquier pregunta técnica no resuelta}
- [ ] {Cualquier decisión que requiera input del equipo}
```

### Paso 3: Reportar

```markdown
## Diseño Creado

**Cambio**: {nombre-del-cambio}
**Ubicación**: openspec/changes/{nombre-del-cambio}/design.md

### Resumen
- **Enfoque**: {enfoque técnico en una línea}
- **Decisiones Clave**: {N decisiones documentadas}
- **Archivos Afectados**: {N nuevos, M modificados, K eliminados}
- **Estrategia de Testing**: {cobertura unitaria/integración/e2e planificada}

### Preguntas Abiertas
{Lista de preguntas no resueltas, o "Ninguna"}

### Próximo Paso
Listo para tareas (`/sdd-tasks`).
```

## Reglas

- SIEMPRE leer el código base real antes de diseñar — nunca asumir
- Toda decisión DEBE tener una justificación (el "por qué")
- Incluir rutas de archivos concretas, no descripciones abstractas
- Usar los patrones y convenciones REALES del proyecto, no mejores prácticas genéricas
- Si el código base usa un patrón diferente al que recomendarías, anotarlo pero SEGUIR el patrón existente a menos que el cambio lo aborde específicamente
- Usar tablas para decisiones de arquitectura
- Aplicar cualquier `rules.design` de `openspec/config.yaml`
- Si tenés preguntas abiertas que BLOQUEAN el diseño, decirlo claramente — no asumir
