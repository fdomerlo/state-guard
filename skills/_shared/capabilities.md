# Detección de Capacidades del Agente Host

## Propósito

Este módulo permite al Memory Guard adaptar su comportamiento según las capacidades del agente host que lo ejecuta. En lugar de mantener configuraciones separadas por herramienta, se define una tabla unificada de capacidades que el agente detecta automáticamente.

## Tabla de Capacidades

| Capacidad                  | Claude Code | OpenCode | Antigravity CLI |
| -------------------------- | :---------: | :------: | :-------------: |
| Sub-agentes reales (Task)  |      ✅      |    ✅     |        ✅        |
| Ejecución inline de skills |      ✅      |    ✅     |        ✅        |
| Ventana de contexto 200K+  |      ✅      |    ✅     |        ✅        |

## Auto-Detección del Host

El agente detecta su host por la presencia de archivos de configuración específicos:

```text
¿Existe ~/.claude/CLAUDE.md?           → Claude Code
¿Existe ~/.config/opencode/opencode.json? → OpenCode
¿Existe ~/.gemini/GEMINI.md?           → Antigravity CLI
```

Si no se puede detectar automáticamente, asumir capacidades máximas (ejecución inline + sub-agentes disponibles).

## Regla de Delegación Inteligente

```text
SI la fase es `apply`
  Y hay más de 10 tareas pendientes
  Y el host soporta sub-agentes reales:
    → Delegar a sub-agente con las tareas como instrucciones
    → El sub-agente persiste artefactos; vos persistís state.yaml
SINO:
    → Ejecutar inline con Memory Guard
```

## Adaptaciones por Host

### Claude Code / OpenCode / Antigravity CLI (con sub-agentes)

Modo híbrido: inline por defecto, delegación para fases pesadas. Al delegar:

1. Pasá al sub-agente las rutas de artefactos (NO el contenido)
2. El sub-agente lee del disco, ejecuta, persiste artefactos
3. El sub-agente retorna resumen de lo hecho
4. Vos ejecutás COMMIT en `state.yaml`

## Configuración del System Prompt por Host

Cada host necesita un system prompt mínimo que cargue el Memory Guard. El contenido es idéntico para todos:

```markdown
# SDD Memory Guard

Actúas como agente de desarrollo con memoria transaccional usando la metodología
Spec-Driven Development (SDD).

## REGLA DE IDIOMA ESTRICTA (CRÍTICA)

Todo tu output DEBE ser generado íntegramente en ESPAÑOL (Castellano).

## CARGA INICIAL

Cargá y seguí `{ruta-skills}/_shared/memory-guard.md` para todas las reglas de:
- Ejecución de fases y delegación inteligente
- Protocolo de transacciones y auto-persistencia
- Recovery ante pérdida de contexto

Cargá también al inicio:
- `{ruta-skills}/_shared/persistence-contract.md`
- `{ruta-skills}/_shared/openspec-convention.md`
```

La única variación es `{ruta-skills}`:

| Host            | `{ruta-skills}`             |
| --------------- | --------------------------- |
| Claude Code     | `~/.claude/skills`          |
| OpenCode        | `~/.config/opencode/skills` |
| Antigravity CLI | `~/.gemini/skills`          |
