<p align="center">
  <h1 align="center">sdd-core</h1>
  <p align="center">
    <strong>Orquestación de Equipos de Agentes con Sub-Agentes de IA</strong>
    <br />
    <em>Un orquestador + sub-agentes especializados para el desarrollo estructurado de software.</em>
    <br />
    <em>Cero dependencias. Markdown puro. Funciona en cualquier entorno.</em>
  </p>
</p>

<p align="center">
  <a href="#inicio-rápido">Inicio Rápido</a> &bull;
  <a href="#cómo-funciona">Cómo Funciona</a> &bull;
  <a href="#comandos">Comandos</a> &bull;
  <a href="#instalación">Instalación</a> &bull;
  <a href="#estructura-del-proyecto">Estructura</a> &bull;
  <a href="#herramientas-compatibles">Herramientas</a>
</p>

---

## El Problema

Los asistentes de IA para código son poderosos, pero tienen dificultades con funcionalidades complejas:

- **Sobrecarga de contexto** — Las conversaciones largas llevan a compresión, pérdida de detalles y alucinaciones
- **Sin estructura** — "Construime el modo oscuro" produce resultados impredecibles
- **Sin revisión** — El código se escribe antes de que alguien acuerde qué construir
- **Sin memoria** — Las especificaciones viven en el historial de chat que desaparece

## La Solución

**sdd-core** es un patrón de orquestación de equipos de agentes donde un coordinador liviano delega todo el trabajo real a sub-agentes especializados. Cada sub-agente comienza con contexto fresco, ejecuta una tarea enfocada y devuelve un resultado estructurado.

```
VOS: "Quiero agregar exportación CSV a la aplicación"

ORQUESTADOR (delegate-only, contexto mínimo):
  → lanza sub-agente EXPLORADOR     → devuelve: análisis del código base
  → muestra resumen, vos aprobás
  → lanza sub-agente PROPONENTE     → devuelve: artefacto de propuesta
  → lanza sub-agente ESPECIFICADOR  → devuelve: artefacto de spec
  → lanza sub-agente DISEÑADOR      → devuelve: artefacto de diseño
  → lanza sub-agente PLANIFICADOR   → devuelve: artefacto de tareas
  → muestra todo, vos aprobás
  → lanza sub-agente IMPLEMENTADOR  → devuelve: código escrito, tareas tachadas
  → lanza sub-agente VERIFICADOR    → devuelve: artefacto de verificación
  → lanza sub-agente ARCHIVADOR     → devuelve: cambio cerrado
```

**La idea clave**: el orquestador NUNCA realiza el trabajo de fase directamente. Solo coordina sub-agentes, rastrea el estado y sintetiza resúmenes. Esto mantiene el hilo principal pequeño y estable.

---

> ### 🌐 Skills Localizadas al Español
>
> Todos los prompts de los sub-agentes (`SKILL.md`) han sido **traducidos íntegramente al español**. Esto fuerza a la IA a pensar, especificar y planificar nativamente en castellano, garantizando que toda la documentación técnica generada — propuestas, specs, diseños y reportes de verificación — sea legible y auditable sin necesidad de traducción.

---

> ### 📁 Persistencia 100% Local (OpenSpec)
>
> `sdd-core` utiliza **exclusivamente `openspec`** como backend de persistencia. Todos los artefactos son archivos Markdown que viven **directamente en el repositorio del usuario**, bajo el directorio `openspec/`. No hay servidores externos, no hay dependencias MCP, no hay cuentas que configurar.
>
> El modo `none` (efímero) está disponible como fallback, pero se recomienda siempre inicializar con `/sdd-init` para activar la persistencia local.

---

## Cómo Funciona

### El Grafo de Dependencias

Las fases del flujo SDD están organizadas como un DAG (Grafo Acíclico Dirigido):

```
                    propuesta
                   (nodo raíz)
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
      specs                       diseño
   (requisitos               (enfoque técnico
    + escenarios)              + decisiones)
         │                           │
         └─────────────┬─────────────┘
                       │
                       ▼
                     tareas
                (checklist de
                implementación)
                       │
                       ▼
                    aplicar
                (escribir código)
                       │
                       ▼
                   verificar
               (puerta de calidad)
                       │
                       ▼
                   archivar
              (fusionar specs,
               cerrar cambio)
```

### Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│  ORQUESTADOR (tu agente principal)                        │
│                                                           │
│  Responsabilidades:                                       │
│  • Detectar cuándo se necesita SDD                        │
│  • Lanzar sub-agentes via Task tool                       │
│  • Mostrar resúmenes al usuario                           │
│  • Pedir aprobación entre fases                           │
│  • Rastrear estado: qué artefactos existen, qué sigue     │
│                                                           │
│  Uso de contexto: MÍNIMO (solo estado + resúmenes)        │
└──────────────┬───────────────────────────────────────────┘
               │
               │ Task(subagent_type: 'general', prompt: 'Lee skill...')
               │
    ┌──────────┴──────────────────────────────────────────┐
    │                                                      │
    ▼          ▼          ▼         ▼         ▼           ▼
┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐
│EXPLORAR││PROPONER││ SPECS  ││DISEÑAR ││ TAREAS ││APLICAR │ ...
│        ││        ││        ││        ││        ││        │
│Contexto││Contexto││Contexto││Contexto││Contexto││Contexto│
│ fresco ││ fresco ││ fresco ││ fresco ││ fresco ││ fresco │
└────────┘└────────┘└────────┘└────────┘└────────┘└────────┘
```

### Contrato de Resultado del Sub-Agente

Cada sub-agente devuelve un payload estructurado:

```json
{
  "status": "ok | warning | blocked | failed",
  "executive_summary": "resumen corto para tomar decisiones",
  "detailed_report": "análisis detallado opcional para trabajo complejo",
  "artifacts": [
    {
      "name": "design",
      "store": "openspec | none",
      "ref": "ruta-al-archivo | null"
    }
  ],
  "next_recommended": ["tasks"],
  "risks": ["lista de riesgos opcional"]
}
```

### Estructura de Artefactos (OpenSpec)

En modo `openspec`, cada cambio genera una carpeta autocontenida en el repositorio:

```
openspec/
├── config.yaml                        ← Contexto del proyecto (stack, convenciones)
├── specs/                             ← Fuente de verdad: cómo funciona el sistema HOY
│   ├── auth/spec.md
│   ├── exportar/spec.md
│   └── ui/spec.md
└── changes/
    ├── agregar-exportacion-csv/       ← Cambio activo
    │   ├── proposal.md                ← POR QUÉ + ALCANCE + ENFOQUE
    │   ├── specs/                     ← Specs delta (AGREGADOS/MODIFICADOS/ELIMINADOS)
    │   │   └── exportar/spec.md
    │   ├── design.md                  ← CÓMO (decisiones de arquitectura)
    │   └── tasks.md                   ← QUÉ (checklist de implementación)
    └── archive/                       ← Cambios completados (rastro de auditoría)
        └── 2026-02-16-fix-auth/
```

---

## Inicio Rápido

### 1. Instalar las skills

```bash
git clone https://github.com/TU-USUARIO/sdd-core.git
cd sdd-core
./scripts/install.sh
```

El instalador pregunta qué herramienta usás y copia las skills al lugar correcto.

### 2. Agregar el orquestador a tu agente

Consultá la sección [Instalación](#instalación) para tu herramienta específica.

### 3. Usarlo

Abrí tu asistente de IA en cualquier proyecto y escribí:

```
/sdd-init
```

Luego empezá a construir:

```
/sdd-new agregar-exportacion-csv
```

O dejá que lo detecte automáticamente — describí una funcionalidad importante y el orquestador sugerirá usar SDD.

---

## Comandos

| Comando | Qué Hace |
|---------|----------|
| `/sdd-init` | Inicializa el contexto SDD. Detecta el stack y crea la estructura `openspec/`. |
| `/sdd-explore <tema>` | Investiga una idea. Lee el código base, compara enfoques. No crea archivos. |
| `/sdd-new <nombre>` | Inicia un nuevo cambio delegando exploración + propuesta a sub-agentes. |
| `/sdd-continue` | Ejecuta la siguiente fase lista en el grafo de dependencias. |
| `/sdd-ff <nombre>` | Fast-forward de planificación con sub-agentes (propuesta → specs → diseño → tareas). |
| `/sdd-apply` | Implementa tareas en lotes. Marca ítems como completos sobre la marcha. |
| `/sdd-verify` | Valida la implementación contra las specs. Reporta CRITICAL / WARNING / SUGGESTION. |
| `/sdd-archive` | Cierra un cambio, fusiona las specs delta en las specs principales y archiva. |

### Ejemplo de Flujo

```
Vos: /sdd-new agregar-modo-oscuro

IA:  Lanzando sub-agente explorador...
     ✓ Código base analizado. React + Tailwind detectados.
     ✓ Tema actual: modo claro hardcodeado en globals.css

     Lanzando sub-agente proponente...
     ✓ proposal.md creado
       Intención: Agregar toggle de modo oscuro con detección de preferencia del sistema
       Alcance: Contexto de tema, componente toggle, variables CSS

     ¿Continúo con specs y diseño? (o revisá la propuesta primero)

Vos: Adelante

IA:  ✓ specs/ui/spec.md — 3 requisitos, 7 escenarios
     ✓ design.md — Variables CSS, React Context, localStorage
     ✓ tasks.md — 3 fases, 8 tareas

     Listo para implementar. Ejecutá /sdd-apply para comenzar.

Vos: /sdd-apply

IA:  Implementando Fase 1 (Fundación)...
     ✓ 1.1 Creado ThemeContext
     ✓ 1.2 Agregadas propiedades CSS personalizadas
     ✓ 1.3 Agregada persistencia en localStorage

     3/8 tareas completas. ¿Continúo con Fase 2?
```

---

## Los Sub-Agentes

Cada sub-agente es un archivo `SKILL.md` — instrucciones en Markdown puro que cualquier asistente de IA puede seguir. **Todos los prompts están íntegramente en español.**

| Sub-Agente | Archivo de Skill | Qué Hace |
|------------|-----------------|----------|
| **Init** | `sdd-init/SKILL.md` | Detecta el stack del proyecto, crea la estructura `openspec/` |
| **Explorador** | `sdd-explore/SKILL.md` | Lee el código base, compara enfoques, identifica riesgos |
| **Proponente** | `sdd-propose/SKILL.md` | Crea `proposal.md` con intención, alcance y plan de rollback |
| **Especificador** | `sdd-spec/SKILL.md` | Escribe specs delta (AGREGADOS/MODIFICADOS/ELIMINADOS) con Given/When/Then |
| **Diseñador** | `sdd-design/SKILL.md` | Crea `design.md` con decisiones de arquitectura y justificación |
| **Planificador** | `sdd-tasks/SKILL.md` | Desglosa en checklist de tareas numeradas por fase |
| **Implementador** | `sdd-apply/SKILL.md` | Escribe código siguiendo specs y diseño, marca tareas completas. Soporta flujo TDD. |
| **Verificador** | `sdd-verify/SKILL.md` | Valida la implementación contra specs con ejecución real de tests. Matriz de cumplimiento. |
| **Archivador** | `sdd-archive/SKILL.md` | Fusiona specs delta en las specs principales, mueve al archivo |

### Convenciones Compartidas

Las 9 skills referencian dos archivos de convención en `skills/_shared/`:

| Archivo | Propósito |
|---------|-----------|
| `persistence-contract.md` | Reglas de resolución de modo — cómo se comportan `openspec` y `none`, qué lee/escribe cada modo y la política de fallback |
| `openspec-convention.md` | Rutas del filesystem para cada artefacto, estructura de directorios, referencia de `config.yaml` y layout del archivo |

### Mejoras de Skills v2.0

- **sdd-apply v2.0** — Soporte de flujo TDD. Cuando está habilitado (vía `openspec/config.yaml`), el implementador sigue un ciclo RED-GREEN-REFACTOR: escribir primero un test fallido, implementar hasta que pase, luego refactorizar.
- **sdd-verify v2.0** — Realiza ejecución real de tests en lugar de solo análisis estático. Ejecuta la suite de tests y los comandos de build del proyecto, produce una matriz de cumplimiento de specs mapeando cada requisito a PASS/FAIL/SKIP, y reporta issues en niveles CRITICAL/WARNING/SUGGESTION.

---

## Instalación

Guías de configuración para todas las herramientas soportadas:

- [Claude Code](#claude-code) — Soporte completo de sub-agentes via Task tool
- [OpenCode](#opencode) — Soporte completo de sub-agentes via Task tool
- [Gemini CLI](#gemini-cli) — Ejecución inline de skills
- [Codex](#codex) — Ejecución inline de skills
- [VS Code (Copilot)](#vs-code-copilot) — Modo agente con archivos de contexto
- [Antigravity](#antigravity) — Soporte nativo de skills con rutas `~/.gemini/antigravity/skills/` y `.agent/`
- [Cursor](#cursor) — Ejecución inline de skills

### Claude Code

**1. Copiar skills:**

```bash
# Usando el script de instalación
./scripts/install.sh  # Elegir opción 1: Claude Code

# O manualmente
cp -r skills/_shared skills/sdd-* ~/.claude/skills/
```

**2. Agregar el orquestador a `~/.claude/CLAUDE.md`:**

Agregá el contenido de [`examples/claude-code/CLAUDE.md`](examples/claude-code/CLAUDE.md) a tu `CLAUDE.md` existente.

El ejemplo es intencionalmente liviano para evitar sobrecarga de tokens en los prompts de sistema. Las reglas de persistencia y artefactos viven en `~/.claude/skills/_shared/*.md`.

**3. Verificar:**

Abrí Claude Code y escribí `/sdd-init` — debería reconocer el comando.

---

### OpenCode

**1. Copiar skills y comandos:**

```bash
# Usando el script de instalación (instala skills + comandos)
./scripts/install.sh  # Elegir opción 2: OpenCode

# O manualmente
cp -r skills/_shared skills/sdd-* ~/.config/opencode/skills/
cp examples/opencode/commands/sdd-*.md ~/.config/opencode/commands/
```

**2. Agregar el agente orquestador a `~/.config/opencode/opencode.json`:**

Fusioná el bloque `agent` de [`examples/opencode/opencode.json`](examples/opencode/opencode.json) en tu configuración existente.

**3. Verificar:**

Abrí OpenCode, usá el selector de agente (Tab), elegí `sdd-orchestrator` y escribí `/sdd-init`.

---

### Gemini CLI

**1. Copiar skills:**

```bash
./scripts/install.sh  # Elegir opción Gemini CLI

# O manualmente
cp -r skills/_shared skills/sdd-* ~/.gemini/skills/
```

**2. Agregar el orquestador a `~/.gemini/GEMINI.md`:**

Agregá el contenido de [`examples/gemini-cli/GEMINI.md`](examples/gemini-cli/GEMINI.md) al archivo de prompt del sistema de Gemini.

**3. Verificar:**

Abrí Gemini CLI y escribí `/sdd-init`.

> **Nota:** Gemini CLI no tiene una herramienta Task nativa para delegación de sub-agentes. Las skills funcionan como instrucciones inline. Para la mejor experiencia de sub-agentes, usá Claude Code o OpenCode.

---

### Codex

**1. Copiar skills:**

```bash
./scripts/install.sh  # Elegir opción Codex

# O manualmente
cp -r skills/_shared skills/sdd-* ~/.codex/skills/
```

**2. Agregar instrucciones del orquestador a `~/.codex/agents.md`.**

**3. Verificar:**

Abrí Codex y escribí `/sdd-init`.

> **Nota:** Al igual que Gemini CLI, Codex ejecuta las skills inline en lugar de como verdaderos sub-agentes.

---

### VS Code (Copilot)

**1. Copiar skills al workspace:**

```bash
# Por proyecto (recomendado)
cp -r skills/_shared skills/sdd-* ./tu-proyecto/.vscode/skills/

# O usando el script
./scripts/install.sh  # Elegir opción VS Code
```

**2. Agregar instrucciones del orquestador:**

Creá un archivo `.instructions.md` en la carpeta de prompts de usuario de VS Code:

- macOS: `~/Library/Application Support/Code/User/prompts/sdd-orchestrator.instructions.md`
- Linux: `~/.config/Code/User/prompts/sdd-orchestrator.instructions.md`
- Windows: `%APPDATA%\Code\User\prompts\sdd-orchestrator.instructions.md`

**3. Verificar:**

Abrí VS Code, el panel de Chat (`Ctrl+Cmd+I`) y escribí `/sdd-init`.

---

### Antigravity

**1. Copiar skills:**

```bash
# Global (disponible en todos los proyectos)
./scripts/install.sh  # Elegir opción Antigravity

# O manualmente (global)
cp -r skills/_shared skills/sdd-* ~/.gemini/antigravity/skills/

# Específico del workspace (por proyecto)
mkdir -p .agent/skills
cp -r skills/_shared skills/sdd-* .agent/skills/
```

**2. Agregar instrucciones del orquestador:**

Agregá el orquestador SDD como regla global en `~/.gemini/GEMINI.md`, o creá una regla de workspace en `.agent/rules/sdd-orchestrator.md`.

Consultá [`examples/antigravity/sdd-orchestrator.md`](examples/antigravity/sdd-orchestrator.md) para el contenido de la regla.

**3. Verificar:**

Abrí Antigravity y escribí `/sdd-init` en el panel del agente.

> **Nota:** Antigravity usa `.agent/skills/` y `.agent/rules/` para configuración de workspace, y `~/.gemini/antigravity/skills/` para configuración global. **No** usa rutas de `.vscode/`.

---

### Cursor

**1. Copiar skills:**

```bash
./scripts/install.sh  # Elegir opción Cursor

# O por proyecto
cp -r skills/_shared skills/sdd-* ./tu-proyecto/skills/
```

**2. Agregar el orquestador a `.cursorrules`:**

Agregá el contenido de [`examples/cursor/.cursorrules`](examples/cursor/.cursorrules) a tu archivo `.cursorrules`.

> **Nota:** Cursor no tiene una herramienta Task para verdadera delegación de sub-agentes. Las skills siguen funcionando — Cursor las lee como instrucciones — pero el orquestador corre inline. Para la mejor experiencia, usá Claude Code o OpenCode.

---

### Otras Herramientas

Las skills son Markdown puro. Cualquier asistente de IA que pueda leer archivos puede usarlas.

1. **Copiá las skills** a donde tu herramienta lee instrucciones.
2. **Agregá las instrucciones del orquestador** al prompt de sistema o archivo de reglas de tu herramienta.
3. **Adaptá el patrón de sub-agentes:**
   - Si tu herramienta tiene Task/sub-agente → usá el patrón de `examples/claude-code/CLAUDE.md`
   - Si no → el orquestador lee las skills inline (funciona igual, usa más contexto)

---

## Estructura del Proyecto

```
sdd-core/
├── README.md                          ← Estás aquí
├── LICENSE
├── skills/                            ← Las 9 skills de sub-agentes + convenciones compartidas
│   ├── _shared/                       ← Convenciones compartidas (referenciadas por todas las skills)
│   │   ├── persistence-contract.md    ← Reglas de resolución de modo (openspec/none)
│   │   └── openspec-convention.md     ← Rutas de archivos, estructura de directorios, referencia de config
│   ├── sdd-init/SKILL.md
│   ├── sdd-explore/SKILL.md
│   ├── sdd-propose/SKILL.md
│   ├── sdd-spec/SKILL.md
│   ├── sdd-design/SKILL.md
│   ├── sdd-tasks/SKILL.md
│   ├── sdd-apply/SKILL.md             ← v2.0: Soporte de flujo TDD
│   ├── sdd-verify/SKILL.md            ← v2.0: Ejecución real de tests + matriz de cumplimiento
│   └── sdd-archive/SKILL.md
├── examples/                          ← Ejemplos de configuración por herramienta
│   ├── claude-code/CLAUDE.md
│   ├── opencode/
│   │   ├── opencode.json              ← Config de agente orquestador
│   │   └── commands/sdd-*.md          ← Slash commands para OpenCode
│   ├── gemini-cli/GEMINI.md
│   ├── codex/agents.md
│   ├── vscode/copilot-instructions.md
│   ├── antigravity/sdd-orchestrator.md
│   └── cursor/.cursorrules
└── scripts/
    ├── install.sh                     ← Instalador interactivo (Bash)
    ├── install.ps1                    ← Instalador interactivo (PowerShell)
    └── install_test.sh                ← Suite de tests del instalador
```

---

## Conceptos

### Specs Delta

En lugar de reescribir specs completas, los cambios describen qué es diferente:

```markdown
## Requisitos AGREGADOS

### Requisito: Exportación CSV
El sistema SHALL soportar la exportación de datos a formato CSV.

#### Escenario: Exportar todas las observaciones
- GIVEN el usuario tiene observaciones almacenadas
- WHEN el usuario solicita exportación CSV
- THEN se genera un archivo CSV con todas las observaciones
- AND los encabezados de columna coinciden con los campos de observación

## Requisitos MODIFICADOS

### Requisito: Exportación de Datos
El sistema SHALL soportar múltiples formatos de exportación.
(Anteriormente: El sistema SHALL soportar exportación JSON.)
```

Cuando se archiva el cambio, estos deltas se fusionan automáticamente en las specs principales.

### Palabras Clave RFC 2119

Las specs usan lenguaje estandarizado para la fuerza de los requisitos:

| Palabra Clave | Significado |
|---------------|-------------|
| **MUST / SHALL** | Requisito absoluto |
| **SHOULD** | Recomendado, pueden existir excepciones |
| **MAY** | Opcional |

### El Ciclo de Archivo

```
1. Las specs describen el comportamiento actual
2. Los cambios proponen modificaciones (como deltas)
3. La implementación hace reales los cambios
4. El archivo fusiona los deltas en las specs
5. Las specs ahora describen el nuevo comportamiento
6. El próximo cambio construye sobre las specs actualizadas
```

---

## Herramientas Compatibles

| Herramienta | Sub-agentes reales | Skills inline | Comandos slash |
|-------------|:-----------------:|:-------------:|:--------------:|
| Claude Code | ✅ | ✅ | — |
| OpenCode | ✅ | ✅ | ✅ |
| Antigravity | ✅ | ✅ | — |
| Gemini CLI | — | ✅ | — |
| Codex | — | ✅ | — |
| VS Code | — | ✅ | — |
| Cursor | — | ✅ | — |

---

## Contribuir

Los PRs son bienvenidos. Las skills son Markdown — fáciles de mejorar.

**Para agregar un nuevo sub-agente:**

1. Crear `skills/sdd-{nombre}/SKILL.md` siguiendo el formato existente (en español)
2. Agregarlo al grafo de dependencias en las instrucciones del orquestador
3. Actualizar los ejemplos y el README

**Para mejorar un sub-agente existente:**

1. Editar el `SKILL.md` directamente
2. Probar ejecutando SDD en un proyecto real
3. Enviar PR con ejemplos del antes/después

---

## Licencia

MIT
