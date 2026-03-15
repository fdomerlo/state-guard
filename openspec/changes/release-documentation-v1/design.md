# Diseño: release-documentation-v1

## Enfoque Técnico

Este cambio implica una **reescritura completa** de la documentación del proyecto, separando el contenido en dos documentos complementarios:

1. **README.md**: Punto de entrada principal con pitch comercial, quickstart y referencia de comandos
2. **MANUAL.md**: Guía técnica profunda con arquitectura DRY, State Machine ACID, configuración y flujos avanzados

El enfoque sigue la estrategia definida en la propuesta: separar claramente la documentación de adopción rápida (README) de la documentación técnica profunda (MANUAL), eliminando contenido redundante y obsoleto.

## Decisiones de Arquitectura

### Decisión: Separación README vs MANUAL

**Elección**: Crear dos documentos con responsabilidades claramente diferenciadas
**Alternativas consideradas**:
- Mantener un solo documento unificado
- Crear más de dos documentos (getting-started.md, architecture.md, etc.)
**Justificación**: La propuesta identifica que el README actual (672 líneas) es "excesivamente técnico" y no refleja la propuesta de valor. Separar en dos documentos permite que nuevos usuarios vean un pitch claro en <30 segundos, mientras que desarrolladores que necesitan profundidad tienen un MANUAL dedicado. La exploración ya recomendó este enfoque.

### Decisión: Preservación de Diagramas Mermaid

**Elección**: Mantener solo diagramas Mermaid esenciales en README, mover detalles técnicos a MANUAL
**Alternativas consideradas**:
- Eliminar todos los diagramas
- Mantener todos los diagramas actuales
**Justificación**: El README actual tiene diagramas complejos (3 niveles de profundidad) que dificultan la lectura rápida. El MANUAL preservará los diagramas técnicos relevantes. La propuesta especifica preservar "diagramas Mermaid esenciales (no los complejos actuales)".

### Decisión: Eliminación de Contenido Obsoleto

**Elección**: Eliminar información desactualizada y redundante entre documentos
**Alternativas consideradas**:
- Mantener todo el contenido actual y agregar nuevo
- Archivar contenido viejo sin eliminar
**Justificación**: La especificación de MANUAL requiere "eliminar contenido obsoleto y redundante". Esto incluye información de configuración que ya no aplica, comandos que cambiaron, y redundancias entre README y MANUAL actuales.

### Decisión: Tono y Estilo

**Elección**: Tono profesional, pragmático y directo en ambos documentos
**Alternativas consideradas**:
- Tono más conversacional
- Tono académico/extenso
**Justificación**: Las specs de ambos documentos exigen "tono profesional, pragmático y directo". El proyecto usa Castellano para auditoría humana, por lo que el tono debe ser claro y conciso.

## Flujo de Datos

```
┌─────────────────────────────────────────────────────────────┐
│                    DOCUMENTACIÓN ACTUAL                      │
│  ┌─────────────────┐          ┌─────────────────┐           │
│  │   README.md     │          │   MANUAL.md     │           │
│  │   (672 líneas)  │          │   (79 líneas)   │           │
│  └────────┬────────┘          └────────┬────────┘           │
└───────────┼───────────────────────────┼─────────────────────┘
            │                           │
            ▼                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    REESCRITURA                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 1. Análisis de contenido existente                      ││
│  2. Extracción de información válida                         ││
│  3. Separación por audiencia (quickstart vs técnico)         ││
│  4. Reescritura con tono apropiado                           ││
│  5. Verificación contra specs y código real                   ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
            │                           │
            ▼                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    DOCUMENTACIÓN NUEVA                       │
│  ┌─────────────────┐          ┌─────────────────┐           │
│  │   README.md     │          │   MANUAL.md      │           │
│  │   ~150 líneas   │          │   ~300 líneas   │           │
│  │   Pitch+Quick   │          │   DRY+ACID+Cfg  │           │
│  └─────────────────┘          └─────────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `README.md` | Modificar | Reescritura completa: pitch comercial, instalación Unix/Windows, tabla de 15 comandos |
| `MANUAL.md` | Modificar | Reescritura completa: arquitectura DRY, State Machine ACID, config.yaml, flujos avanzados |
| `docs/legacy/README.md` | Crear | Archivo temporal con contenido original (para rollback si es necesario) |
| `docs/legacy/MANUAL.md` | Crear | Archivo temporal con contenido original (para rollback si es necesario) |

**Nota**: Los archivos legacy solo se crean si es necesario para rollback. La propuesta indica que si la nueva documentación genera confusión, se mantienen los originales en `docs/legacy/`.

## Contenido del README (Especificaciones de la Spec)

El README **DEBE** contener:

1. **Propuesta de valor en las primeras 3 líneas**:
   - Qué es el proyecto
   - Para quién está diseñado
   - Por qué debería usarlo

2. **Instrucciones de instalación**:
   - Unix: `bash scripts/install.sh`
   - Windows: `powershell .\scripts\install.ps1`

3. **Tabla de 15 comandos**:
   - `/sdd-init` - Inicializa contexto SDD
   - `/sdd-explore` - Investiga una idea
   - `/sdd-new` - Inicia nuevo cambio
   - `/sdd-continue` - Ejecuta siguiente fase
   - `/sdd-ff` - Fast-forward de planificación
   - `/sdd-apply` - Implementa tareas
   - `/sdd-verify` - Valida implementación
   - `/sdd-archive` - Cierra cambio
   - `/sdd-status` - Muestra estado de cambios
   - `/sdd-split` - Divide proposals
   - `/sdd-review` - Auditoría estática
   - (y otros 4 comandos identificados en la exploración)

4. **Diagramas Mermaid esenciales** (simples, no complejos)

5. **Tono**: Profesional, pragmático, directo

## Contenido del MANUAL (Especificaciones de la Spec)

El MANUAL **DEBE** contener:

1. **Arquitectura DRY**:
   - Compilación dinámica del orquestador
   - Mecanismo de carga de skills y commands
   - Reutilización de código mediante herencia de skills

2. **State Machine ACID**:
   - Estructura de state.yaml
   - Prevención de colisiones en cambios concurrentes
   - Propiedades ACID (Atomicidad, Consistencia, Isolation, Durabilidad)

3. **config.yaml**:
   - Glosario de configuraciones disponibles
   - Convenciones de nomenclatura (kebab-case)
   - Descripción del parámetro test_command
   - Ejemplos de configuración

4. **Flujos avanzados**:
   - `/sdd-split`: División de proposals en sub-cambios
   - `/sdd-review`: Auditoría estática contra specs
   - `/sdd-fix`: Reparación de problemas comunes

5. **Tono**: Profesional, técnico, directo

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|------|-------------|---------|
| Revisión manual | Consistencia entre documentos | Verificar que no hay redundancias |
| Revisión manual | Veracidad técnica | Comparar contra código real (scripts, skills) |
| Revisión manual | Completitud de specs | Cada requisito de spec está cubierto |
| Verificación automática | Links rotos | Verificar que todos los links internos funcionan |

**Verificación contra código real**:
- Comandos de instalación: Verificar que `scripts/install.sh` y `scripts/install.ps1` existen y funcionan
- Comandos documentados: Verificar contra `examples/opencode/commands/` (la exploración ya identificó los 15 comandos correctos)
- Arquitectura DRY: Verificar que las skills en `skills/_shared/` contienen las convenciones compartidas
- State Machine: Verificar que `state.yaml` sigue el schema de `openspec-convention.md`

## Migración / Despliegue

No se requiere migración de datos. Este cambio solo afecta documentación.

**Plan de despliegue**:
1. Crear archivos temporales de rollback (si es necesario)
2. Reescribir README.md siguiendo specs
3. Reescribir MANUAL.md siguiendo specs
4. Verificar que la documentación nueva refleja el comportamiento real del código
5. Commit con mensaje descriptivo

**Plan de Rollback** (definido en propuesta):
1. Mantener documentos originales en `docs/legacy/` antes de reemplazar
2. Si hay errores factuales, `sdd-verify` los detectará
3. Rollback simple: `git checkout README.md MANUAL.md`

## Preguntas Abiertas

- [ ] ¿El MANUAL debe incluir ejemplos de código de las skills?
- [ ] ¿Los diagramas Mermaid del README deben ser interactivos (con zoom)?
- [ ] ¿Se debe incluir una sección de troubleshooting en el MANUAL?

**Respuesta sugerida**: Mantener el MANUAL enfococado en arquitectura y flujos. Los ejemplos de código van en las skills individuales. Los diagramas son estáticos (Mermaid estándar). Troubleshooting puede ser un documento separado si crece demasiado.

---

## Resumen del Diseño

| Aspecto | Decisión |
|---------|----------|
| Enfoque | Reescritura completa con separación clara README/MANUAL |
| Decisiones clave | 4 decisiones documentadas |
| Archivos afectados | 2 modificados, 2 de rollback opcional |
| Testing | Revisión manual de consistencia y veracidad |
| Migración | No requerida |
