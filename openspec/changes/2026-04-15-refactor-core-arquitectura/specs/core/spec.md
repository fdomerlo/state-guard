# Delta para Core Arquitectura

## Requisitos MODIFICADOS

### Requisito: Seguimiento de estado en state.yaml

El sistema MUST prescindir del uso del campo `blocked` booleano y registrar el estatus exclusivo mediante el valor del campo enumerado `status` (`active`, `done`, ó `blocked`).

#### Escenario: Actualización de estado bloqueado
- GIVEN un `state.yaml` de una iteración en proceso
- WHEN ocurra un bloqueo lógico
- THEN el campo `status` se actualizará a `blocked`
- AND no se asignará ningún booleano `blocked: true`.

### Requisito: Reparación de estado con sdd-fix

El sistema MUST procesar archivos `state.yaml` heredados o desactualizados (legacy) manteniéndolos compatibles, decodificando los estados independientemente de si contienen o no la bandera obsoleta `blocked`.

#### Escenario: sdd-fix leyendo formato clásico
- GIVEN un archivo `state.yaml` que contiene el viejo campo `blocked`
- WHEN el orquestador o usuario ejecuta `/sdd-fix`
- THEN el sistema omite el registro booleano base y opera evaluando puramente el campo `status`
- AND si detecta que `blocked: true` era la única advertencia de bloqueo, efectúa la mutación a `status: blocked` silenciosamente sin romper el parseo.

### Requisito: Modificación del script de instalación (POSIX)

El sistema MUST invocar a las rutinas de compilación (ej. `compile_and_append_config`) al utilizar `--all-global` con sintaxis estrictamente POSIX compliant para asegurar la compatibilidad sin dependencias de bashisms en equipos Mac/Linux.

#### Escenario: Instalación en entornos POSIX
- GIVEN el script `install.sh` ejecutado nativamente en sh en un entorno de Mac
- WHEN se provee el argumento `--all-global`
- THEN evalúa correctamente los argumentos y delega al conector de Antigravity exitosamente.

### Requisito: Control de rollback aislado

El comando de reversión MUST limitarse únicamente al entorno inmediato del respectivo cambio y abstenerse de aplicar purgas destructivas no trackeadas a través del repositorio principal.

#### Escenario: Ejecución asincronizada
- GIVEN modificaciones flotantes alrededor del entorno de trabajo de usuario además del cambio activo
- WHEN se invoca `/sdd-rollback`
- THEN se eliminan sistemáticamente las inclusiones de la carpeta del cambio
- AND se evita usar comandos destructivos indiscriminados como `git clean -fd`.
