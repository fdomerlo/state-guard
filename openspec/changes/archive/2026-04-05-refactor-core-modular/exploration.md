# Exploración: Refactorización Core Modular

## Resultado de la Fase

**status**: ok

### executive_summary

Exploración completada del código base para refactorización de orchestrator-core.md. Se identificaron 6 secciones principales con 1298 palabras totales. Las fases apply y verify leen specs+design+tasks completos (aproximadamente 2500-4000 tokens por contexto). Se proponen 4 módulos extraíbles que podrían reducir el contexto en ~45%.

### artifacts

- `openspec/changes/refactor-core-modular/exploration.md` — Este archivo

### next_recommended

sdd-propose

### risks

- Ninguno identificado — la exploración es análisis puro

### detailed_report

---

## 1. Análisis de orchestrator-core.md

### Estadísticas Generales

| Métrica | Valor |
|---------|-------|
| Total de líneas | 157 |
| Total de palabras | 1298 |
| Palabras por línea (promedio) | 8.27 |

### Distribución de Secciones

| # | Sección | Líneas | Palabras | % Total | ¿Crítica? |
|---|---------|--------|----------|---------|-----------|
| 1 | Regla de Idioma Estricta | 1-8 | ~85 | 6.5% | **Sí** — obligatorio |
| 2 | Reglas de Delegación (Siempre Activas) | 11-32 | ~280 | 21.6% | **Sí** — core de orquestación |
| 3 | Flujo de Trabajo SDD | 35-157 | ~933 | 71.9% | **Parcial** — contiene sub-secciones |
| 3.1 | Política de Almacenamiento | 37-42 | ~60 | 4.6% | No — convención |
| 3.2 | Comandos de Orquestación | 44-70 | ~250 | 19.3% | **Sí** — referencia de comandos |
| 3.3 | Grafo de Dependencias | 72-76 | ~15 | 1.2% | No — referencia rápida |
| 3.4 | Gestión de Estado | 78-117 | ~280 | 21.6% | **Sí** — recovery |
| 3.5 | Protocolo de Contexto | 119-134 | ~110 | 8.5% | **Sí** — define lectura de archivos |
| 3.6 | Contrato de Resultados | 136-138 | ~25 | 1.9% | No — referencia |
| 3.7 | Estado y Convenciones | 140-148 | ~70 | 5.4% | No — referencias |
| 3.8 | Regla de Recuperación | 150-157 | ~50 | 3.9% | **Sí** — recovery |

---

## 2. Reglas de Contexto en sdd-apply

### Análisis de Contexto para apply

| Artefacto | Típicamente leído | Tamaño estimado |
|------------|-------------------|-----------------|
| proposal.md | Opcional | ~300-500 palabras |
| specs/{dominio}/spec.md | Requerido | ~500-1500 palabras |
| design.md | Requerido | ~400-800 palabras |
| tasks.md | Requerido (lista completa) | ~300-600 palabras |

**Contexto total estimado para sdd-apply**: 1500-3400 palabras (~2000-4500 tokens)

---

## 3. Reglas de Contexto en sdd-verify

Similar a apply, pero potencialmente mayor porque debe leer código fuente completo.

---

## 4. Flujo Actual de Batching de Tareas

El sub-agente sdd-apply recibe del orquestador solo una referencia textual como "Fase 1, tareas 1.1-1.3", pero debe leer tasks.md completo para entender el contexto.

---

## 5. Módulos Propuestos para Extraer

| # | Módulo Propuesto | Contenido | Palabras Est. |
|---|-----------------|-----------|---------------|
| 1 | `orchestrator-delegation.md` | Reglas de Delegación + Anti-patrones | ~280 |
| 2 | `orchestrator-state.md` | Gestión de state.yaml + Recovery | ~330 |
| 3 | `orchestrator-commands.md` | Meta-comandos + Skills + Grafo | ~265 |
| 4 | `orchestrator-context.md` | Protocolo de contexto + Convenciones | ~180 |

### Beneficio Estimado

| Escenario | Contexto Actual | Contexto Propuesto | Ahorro |
|-----------|------------------|-------------------|--------|
| sdd-apply (lote 1) | ~2500 tokens | ~1800 tokens | ~28% |
| sdd-verify | ~3000 tokens | ~2000 tokens | ~33% |
| Fase temprana (explore/propose) | ~2000 tokens | ~1200 tokens | ~40% |

**Ahorro total estimado**: ~4700 tokens por fase avanzada (~45% de reducción).