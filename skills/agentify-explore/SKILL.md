---
name: agentify-explore
description: >
  Explora e investiga ideas antes de comprometerse con un cambio.
  Disparador: Cuando el usuario ejecuta /agentify-explore para reflexionar sobre una funcionalidad, investigar el código base o aclarar requisitos.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# Agentify-Explore Skill

## Propósito

Skill responsable de la **EXPLORACIÓN**. Investiga el código base, analiza problemas, compara enfoques y produce un análisis estructurado. Por defecto, solo investiga e informa; únicamente crea `exploration.md` cuando la exploración está vinculada a un cambio con nombre.

## Qué Hacer

### Paso 0: Auto-descubrimiento del Stack (Cold Boot)

Antes de analizar el problema reportado por el usuario, debes entender el entorno físico del proyecto. 

Ejecuta comandos de terminal para descubrir la arquitectura base:

1. Lista archivos manifiesto en la raíz: `ls package.json pyproject.toml composer.json go.mod Cargo.toml docker-compose.yml 2>/dev/null`
2. Lee los manifiestos encontrados para identificar:
   - Lenguaje y versión del runtime (ej. Python, Node, PHP).
   - Framework principal (ej. Django, Laravel, React).
   - Herramientas de infraestructura o dependencias clave.

Este contexto DEBE influenciar directamente tu análisis posterior para no sugerir arquitecturas incompatibles con la realidad actual del código.

### Paso 1: Comprender la Solicitud

Analiza qué quiere explorar el usuario:

- ¿Es una nueva funcionalidad? ¿Una corrección de bug? ¿Una refactorización?
- ¿Qué dominio involucra?

### Paso 2: Investigar el Código Base

Lee el código relevante para entender:

- Arquitectura y patrones actuales
- Archivos y módulos que serían afectados
- Comportamiento existente relacionado con la solicitud
- Posibles restricciones o riesgos

```text
INVESTIGAR:
├── Leer puntos de entrada y archivos clave
├── Buscar funcionalidad relacionada
├── Revisar tests existentes (si los hay)
├── Identificar patrones ya en uso
└── Identificar dependencias y acoplamiento
```

### Paso 3: Analizar Opciones

Si existen múltiples enfoques, compáralos:

```text
| Enfoque  | Ventajas | Desventajas | Complejidad   |
|----------|----------|-------------|---------------|
| Opción A | ...      | ...         | Baja/Med/Alta |
| Opción B | ...      | ...         | Baja/Med/Alta |
```

### Paso 4: Guardar la Exploración (opcional)

Si hay un nombre de cambio (es decir, esta exploración forma parte de `/agentify-new`), guarda el análisis en:

```text
.agentify/changes/{nombre-del-cambio}/
└── exploration.md          ← Lo creas tú
```

Si no se proporcionó nombre de cambio (`/agentify-explore` independiente), omite la creación del archivo — solo devuelve el análisis.

### Paso 5: Reportar

```markdown
## Exploración: {tema}

### Estado Actual
{Cómo funciona el sistema hoy en relación a este tema}

### Áreas Afectadas
- `ruta/al/archivo.ext` — {por qué se ve afectado}

### Enfoques
1. **{Nombre del enfoque}** — {descripción breve}
   - Ventajas: {lista}
   - Desventajas: {lista}
   - Esfuerzo: {Bajo/Medio/Alto}

### Recomendación
{Tu enfoque recomendado y por qué}

### Riesgos
- {Riesgo 1}

### Listo para Propuesta
{Sí/No — y qué debería hacer el usuario a continuación}
```

## Reglas

- El ÚNICO archivo que PODÉS crear es `exploration.md` dentro de la carpeta del cambio (si se proporcionó un nombre de cambio)
- NO modificar ningún código o archivo existente
- SIEMPRE leer código real, nunca asumir sobre el código base
- Mantener el análisis CONCISO — enfocado y accionable
- Si no encontrás suficiente información, decirlo claramente
- Si la solicitud es demasiado vaga para explorar, indicar qué aclaraciones se necesitan
