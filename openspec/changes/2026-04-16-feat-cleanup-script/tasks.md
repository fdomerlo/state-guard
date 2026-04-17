# Tareas: Script de Mantenimiento y Limpieza

## Fase 1: Creación y Preparativos de Core CLI

- [x] 1.1 Crear el archivo principal `scripts/cleanup.sh` especificando su shebang general e iniciar variables del enrutador de OS-Detection que replicarán los mismos scopes dinámicos ya manejados y logrados por `install.sh`.
- [x] 1.2 Implementar los headers y las sub-rutinas modulares genéricas a nivel shell. Una para remover (`rm -rf`) directorios de manera tolerante (ej. checkeando su existencia previniendo el return non-0) y la sub-rutina de expurgo usando `awk` para buscar y remover exclusívamente líneas contenidas entre las marcas `<!-- BEGIN SDD ORCHESTRATOR -->` y `END`.

## Fase 2: Implementación de Limpiado Per Agente y Rutina

- [x] 2.1 Escribir rutinas segmentadas (por switch case o función individual) encargadas de depurar instanciaciones de `Claude Code`, `OpenCode`, `Gemini CLI`, el fallback de `Antigravity` y la variable de entorno local del proyecto base (`./skills/`).
- [x] 2.2 Diseñar el output loop de menú interactivo principal para ejecutar el script genéricamente como consola en caso de no proveer comandos parametrizados (Ej. "1) Clean Claude Code, 2) Clean All...").

## Fase 3: Adición de Opcionalidades Críticas y Flags

- [x] 3.1 Instanciar el parsing iterativo centralizado de flags ejecutores de arranque (`while [ $# -gt 0 ]`), introduciendo el hook logico del pathing flag `--hard`.
- [x] 3.2 Desarrollar el prompt estricto con `read` para alertar y solicitar interrupción controlada y explícita antes de ejecutar el drop de `openspec/changes/*`. Completar el script con reports terminales amigables con colores (`\033[...]`) de ser posible.
