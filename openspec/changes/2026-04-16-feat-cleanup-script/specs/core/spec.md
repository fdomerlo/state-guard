# Delta para Core Scripts

## Requisitos AGREGADOS

### Requisito: Limpieza del Entorno SDD

El sistema MUST proveer una herramienta (`scripts/cleanup.sh`) para borrar selectivamente dependencias copiadas e inyectadas del orquestador SDD en agentes soportados.

#### Escenario: Eliminar skills copiadas por agente
- GIVEN el script ejecutándose en Mac/Linux o entorno Windows simulado de bash
- WHEN el usuario instruye limpiar el entorno de un agente soportado
- THEN se remueve de ser hallado el directorio `.claude/skills/`, `.gemini/skills`, etc.

#### Escenario: Evitar sobreescrituras destructivas a configuraciones generales
- GIVEN el script eliminando componentes
- WHEN procesa archivos de dot local como `CLAUDE.md`, `GEMINI.md`, u `opencode.json`
- THEN DEBE remover iterativamente usando awk/sed SÓLO las líneas que se encuentren dentro de los delimitadores `<!-- BEGIN SDD ORCHESTRATOR -->` y `<!-- END SDD ORCHESTRATOR -->`
- AND salvar el resto original de usuario no interviniéndolo.

### Requisito: Compatibilidad OS sin SUDO

El script MUST funcionar universalmente valiéndose de sentencias nativas y puras POSIX (`[ `...` ]`) para comparadores de variables.

#### Escenario: Comprobación POSIX
- GIVEN un entorno que corre `/bin/sh`
- WHEN el script chequea directorios
- THEN usa `[ -d "$target" ]` o `[ -f "$file" ]` con quoting apropiado de variables sin arrojar excepciones.
- AND previene solicitar loggins root SUDO en cualquier proceso inherente.

### Requisito: Purga Histórica mediante '--hard'

El script MUST incorporar flag paramétrico opcional `--hard` permitiendo borrar adicionalmente todo el directorio histórico local de implementaciones orquestrales del proyecto que lo invoque.

#### Escenario: Borrado de histórico verificado
- GIVEN la invocación a la terminal usando `bash scripts/cleanup.sh --hard`
- WHEN el script intercepta las consecuencias procedimentales
- THEN pide y aguarda confirmación manual estricta del teclado y/N
- AND tras confirmar procede a realizar de manera pasiva el `rm -rf openspec/changes/`.
