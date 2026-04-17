# Propuesta: Script de Mantenimiento y Limpieza

## Intención

Crear un script de mantenimiento `scripts/cleanup.sh` seguro que facilite y automatice la desinstalación o limpieza del entorno Agentify SDD, removiendo configuraciones inyectadas y copias de destrezas/skills a lo largo de los IDEs y clientes orquestales (CLI) soportados.

## Alcance

### Dentro del Alcance
- Script compatible íntegramente con POSIX shell (`scripts/cleanup.sh`).
- Identificación y eliminación controlada de carpetas de skills para Antigravity, Claude Code, Gemini CLI y OpenCode.
- Limpieza no destructiva para archivos de reglas del usuario. El script deberá purgar los bloques inyectados de Agentify (ej. `.agent/rules/sdd-orchestrator.md`, `CLAUDE.md`, `GEMINI.md`, `opencode.json`) preservando otras descripciones customizadas del usuario.
- Implementación de un flag direccional `--hard` para erradicar permanentemente el historial local del proyecto alojado en la carpeta `openspec/changes`.
- Prompts interactivos mandatorios previos a ejecutar limpiezas.

### Fuera del Alcance
- Desinstalación de herramientas per se, de CLI o de binarios como Node, npm o similares instaladores subyacentes.
- Administración y limpieza de carpetas fuera de contextos configurados explícitamente u ocultos que demanden root/SUDO.

## Enfoque

Implementaremos el modulo de scripting inspirados en el parser de `install.sh`. Aprovecharemos validaciones elementales tipo `[ -d "$DIR" ]` para confirmar la existencia de locaciones sin arriesgar eliminaciones falsas (`rm -rf` sin control). Las desinyecciones sobre archivos combinados (como `CLAUDE.md`) operarán puramente con iteradores purificadores tipo awk, buscando el marcador explícito `<!-- BEGIN SDD ORCHESTRATOR -->` para borrar solamente ese bloque textual.

## Áreas Afectadas

| Área | Impacto | Descripción |
|---|---|---|
| `scripts/cleanup.sh` | Crear | Script principal iterativo. |
| `scripts/install_test.sh` | Modificar | (Opcional, de ser necesario para testing unrolling) |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| Eliminación accidental de reglas no SDD del usuario debido a truncado severo. | Media | Uso riguroso de tags delimitadores para cortar solamente chunks SDD. |
| Uso excesivo generalizado del flag hard | Baja | Solicitud de re-confirmación manual bloqueante. |

## Plan de Rollback

Al tratarse de una nueva feature contenida, basta con eliminar el archivo `scripts/cleanup.sh` del árbol y revertir con git. En caso de fallas durante runtime del cliente por el script en vivo, se puede sugerir usar `git checkout` en caso de eliminación dudosa de su propio historial.

## Dependencias

- `awk`, `sed` en sub-entornos.

## Criterios de Éxito

- [ ] Instancias son detectadas y vaciadas equitativamente (Antigravity, Claude, Gemini, etc).
- [ ] No detona solicitudes nativas del wrapper SUDO.
- [ ] Opciones y prompts destructivos corren con el resguardo demandado mediante inputs explícitos.
