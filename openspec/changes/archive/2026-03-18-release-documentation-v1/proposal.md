# Propuesta: release-documentation-v1

## Intención

Reescribir completamente la documentación del proyecto para el lanzamiento de la versión 1.0. El objetivo es separar el contenido en dos documentos complementarios: un README.md con pitch comercial y quickstart (enfoque en adopción rápida), y un MANUAL.md con guía técnica profunda (enfoque en arquitectura y uso avanzado). La documentación actual es excesivamente técnica (672 líneas en README) y no refleja la propuesta de valor de forma clara para nuevos usuarios.

## Alcance

### Dentro del Alcance
- Reescribir `README.md` con propuesta de valor clara, instalación para Unix/Windows, y tabla de 15 comandos
- Reescribir `MANUAL.md` con arquitectura DRY, State Machine ACID, config.yaml y flujos avanzados
- Eliminar contenido obsoleto y redundante
- Mantener tono profesional, pragmático y directo
- Preservar diagramas Mermaid esenciales (no los complejos actuales)

### Fuera del Alcance
- Modificar scripts de instalación (`install.sh`, `install.ps1`) — ya están correctos
- Modificar archivos del core del orquestador (`orchestrator-core.md`, `openspec-convention.md`)
- Crear documentación adicional más allá de README y MANUAL

## Enfoque

Se seguirá el **Enfoque 2: Reescritura Completa** recomendado en la exploración. Este enfoque separa claramente README (Pitch + Quickstart) de MANUAL (Guía Técnica), reorganiza la información existente y le da formato profesional. El trabajo se dividirá en dos fases: primero README con la propuesta de valor y comandos, luego MANUAL con la arquitectura técnica.

## Áreas Afectadas

| Archivo | Impacto | Descripción |
|---------|---------|-------------|
| `README.md` | Modificado | Reescritura completa: pitch comercial, instalación, tabla de comandos |
| `MANUAL.md` | Modificado | Reescritura completa: arquitectura DRY, State Machine ACID, config.yaml, flujos avanzados |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|--------------|------------|
| Perder información valiosa de los diagramas actuales | Media | Preservar diagramas Mermaid esenciales, mover detalles técnicos a MANUAL |
| Inconsistencia entre documentación y código real | Baja | Verificar contra los scripts y archivos del orquestador antes de escribir |
| Comandos desactualizados en la tabla | Baja | Verificar contra los archivos en `examples/opencode/commands/` — la exploración ya identificó los 15 comandos正确os |

## Plan de Rollback

1. Si la documentación nueva genera confusión en usuarios, mantener los documentos originales en una carpeta `docs/legacy/` antes de reemplazarlos
2. Si hay errores factuales, el proceso de verificación (`sdd-verify`) detectará inconsistencias con el código
3. El rollback es simple: restaurar los archivos originales desde git (`git checkout README.md MANUAL.md`)

## Dependencias

- Ninguna dependencia externa requerida
- La exploración ya identificó el estado actual de los archivos y la arquitectura a documentar

## Criterios de Éxito

- [ ] README.md contiene propuesta de valor clara en las primeras 3 líneas
- [ ] README.md muestra instalación para Unix (`bash scripts/install.sh`) y Windows (`powershell .\scripts\install.ps1`)
- [ ] README.md incluye tabla con los 15 comandos disponibles
- [ ] MANUAL.md explica la arquitectura DRY (compilación dinámica del orquestador)
- [ ] MANUAL.md explica el State Machine ACID (state.yaml y prevención de colisiones)
- [ ] MANUAL.md detalla el uso de config.yaml (glosario, kebab-case, test_command)
- [ ] MANUAL.md cubre flujos avanzados: /sdd-split, /sdd-review, /sdd-fix
- [ ] Tono de ambos documentos es profesional, pragmático y directo
- [ ] La verificación contra el código confirma que la documentación refleja el comportamiento real
