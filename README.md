# Agentify SDD — Orquestador de Desarrollo Guiado por Especificaciones

Agentify SDD es un marco de orquestación de agentes de IA que estructura el desarrollo de software en fases definidas: explorar, proponer, especificar, diseñar, planificar, implementar, verificar y archivar. Para equipos que necesitan código auditable, mantenible y construido sobre especificaciones claras.

---

## Instalación

### Unix / Linux / macOS

```bash
bash scripts/install.sh
```

### Windows

```powershell
powershell .\scripts\install.ps1
```

---

## Comandos

| Comando | Descripción | Tipo |
|---------|-------------|------|
| `/sdd-init` | Inicializa el contexto SDD en el proyecto. Detecta el stack y crea la estructura `openspec/`. | Skill Directa |
| `/sdd-new <nombre>` | Inicia un nuevo cambio. Delega exploración y propuesta a sub-agentes especializados. | **Meta-comando** |
| `/sdd-continue` | Ejecuta la siguiente fase pendiente en el grafo de dependencias. | **Meta-comando** |
| `/sdd-ff` | Fast-forward de planificación: ejecuta propuesta → specs → diseño → tareas sin intervención. | **Meta-comando** |
| `/sdd-status` | Muestra el estado de todos los cambios activos mediante tabla con indicadores visuales. | Skill Directa |
| `/sdd-fix` | Audita y repara estados corruptos en `state.yaml`. Detecta artefactos faltantes y retrocede fases. | Skill Directa |
| `/sdd-changelog` | Genera un changelog automático a partir de los cambios archivados. | Skill Directa |
| `/sdd-explore <tema>` | Investiga una idea antes de comprometerse. Lee el código base, compara enfoques e identifica riesgos. | Fase (Explore) |
| `/sdd-propose <nombre>` | Crea o itera sobre una propuesta de cambio de manera independiente. | Fase (Propose) |
| `/sdd-spec` | Escribe especificaciones delta para un cambio SDD. | Fase (Spec) |
| `/sdd-design` | Crea el documento de diseño técnico para un cambio. | Fase (Design) |
| `/sdd-tasks` | Desglosa un cambio en tareas de implementación. | Fase (Tasks) |
| `/sdd-apply` | Implementa las tareas de un cambio. Escribe código siguiendo specs y diseño, marca tareas completadas. | Fase (Apply) |
| `/sdd-verify` | Valida la implementación contra las especificaciones. Ejecuta tests y genera reporte de cumplimiento. | Fase (Verify) |
| `/sdd-archive` | Cierra un cambio: fusiona las specs delta en las specs principales y mueve el cambio al archivo. | Fase (Archive) |
| `/sdd-split` | Divide proposals monolíticas en sub-cambios manejables. Útil para cambios demasiado grandes. | Skill Directa |
| `/sdd-review` | Realiza auditoría estática de código comparando contra las especificaciones. | Skill Directa |

---

## Inicio Rápido

### 1. Inicializar el proyecto

```bash
/sdd-init
```

### 2. Crear un nuevo cambio

```bash
/sdd-new mi-nueva-funcionalidad
```

### 3. Continuar con las siguientes fases

```bash
/sdd-continue
```

El orquestador ejecutará cada fase secuencialmente, mostrando resúmenes y solicitando aprobación entre fases.

### 4. Implementar

```bash
/sdd-apply
```

### 5. Verificar

```bash
/sdd-verify
```

### 6. Git Commit (PASO OBLIGATORIO)

Antes de proceder al archivado, es **estrictamente obligatorio** guardar los cambios en el control de versiones. El comando `/sdd-archive` fallará si detecta cambios sin commitear.

```bash
git add .
git commit -m "feat: implementar mi-nueva-funcionalidad"
```

### 7. Archivar

Cierra el ciclo del cambio, fusionando especificaciones y moviendo los artefactos al histórico.

```bash
/sdd-archive
```

---

## Arquitectura

```mermaid
graph LR
    subgraph "Fases SDD"
        E[Explore] --> P[Propose]
        P --> S[Spec]
        S --> D[Design]
        D --> T[Tasks]
        T --> A[Apply]
        A --> V[Verify]
        V --> R[Archive]
    end
    
    subgraph "Almacenamiento"
        O[(OpenSpec)]
    end
    
    E -.-> O
    P -.-> O
    S -.-> O
    D -.-> O
    A -.-> O
    V -.-> O
```

**OpenSpec** guarda cada artefacto como archivo Markdown en el repositorio, permitiendo versionado y revisión en Pull Requests.

---

## Conceptos Clave

### Specs Delta

Los cambios describen qué es diferente del estado actual, no reescriben todo. Al archivar, estos deltas se fusionan automáticamente en `openspec/specs/`.

### State Machine ACID

El archivo `state.yaml` rastrea el estado de cada cambio, previniendo colisiones en trabajo concurrente.

### Skills como Código y Optimización Extrema de Tokens

Cada sub-agente es un archivo Markdown puro que cualquier asistente de IA puede ejecutar. Sin dependencias externas. El orquestador usa "inyección dinámica de rutas" para proveer solo el contexto estrictamente necesario a cada sub-agente, omitiendo contratos globales y logrando ahorrar miles de tokens de contexto por invocación.

### Modo OpenSpec

El sistema utiliza **OpenSpec** como modo de persistencia:

- Los artefactos se almacenan como archivos Markdown en el repositorio
- Permite versionado y revisión en Pull Requests
- Carpeta de archivo: `openspec/changes/archive/YYYY-MM-DD-{change-name}/`

---

## Documentación Adicional

- [MANUAL.md](MANUAL.md) — Guía técnica: arquitectura DRY, State Machine ACID, configuración y flujos avanzados.

---

## Licencia

MIT
