# Delta para calidad

## Requisitos AGREGADOS

### Requisito: Completitud de comandos en documentación

La tabla de comandos del README.md SHALL incluir todos los comandos SDD disponibles para el usuario.

#### Escenario: Comando faltante en tabla de comandos

- GIVEN El usuario consulta la tabla de comandos en README.md
- WHEN Busca el comando `/sdd-propose`
- THEN El comando aparece enlistado con su descripción correspondiente

### Requisito: Clarificación de meta-comandos

El archivo orchestrator-core.md SHALL distinguir claramente entre comandos directos (skills) y meta-comandos (orquestación de fases).

#### Escenario: Identificación de meta-comandos

- GIVEN Un nuevo operador lee orchestrator-core.md
- WHEN Consulta la sección de comandos de orquestación
- THEN Los meta-comandos (`/sdd-new`, `/sdd-continue`, `/sdd-ff`) están marcados explícitamente como tales
- AND Los comandos directos (`/sdd-propose`, `/sdd-spec`, etc.) están diferenciados

### Requisito: Coherencia interna de documentación

El archivo openspec-convention.md SHALL mantener coherencia entre la tabla de rutas y las descripciones de cada skill.

#### Escenario: Descripción inconsistente de sdd-archive

- GIVEN Un operador lee la tabla de rutas y la descripción de sdd-archive
- WHEN Compara ambas secciones
- THEN Ambas indican las mismas acciones (mover a archive + fusionar deltas) sin contradicciones

### Requisito: Integridad del script de instalación

El script install.sh SHALL estar libre de placeholders y usar manejo de errores explícito.

#### Escenario: Placeholder en URL de error

- GIVEN Se ejecuta validate_source() y falla
- THEN El mensaje de error muestra una URL válida del repositorio, no un placeholder como "TU-USUARIO"

#### Escenario: Manejo de errores con operadores explícitos

- GIVEN El script encuentra una operación que puede fallar (mkdir, cp, chmod)
- WHEN La operación falla
- THEN El error se reporta claramente al usuario en lugar de silenciarse con `|| true`
- AND El flujo de ejecución se interrumpe apropiadamente si el error es crítico

### Requisito: Externalización de lógica inline

El script install.sh SHALL externalizar scripts Python inline a archivos separados cuando superen los 15 líneas.

#### Escenario: Script Python inline largo

- GIVEN El archivo install.sh contiene un bloque Python inline de más de 15 líneas
- WHEN Un desarrollador necesita mantener o debugear ese código
- THEN El código reside en un archivo dedicado en scripts/lib/ o similar
- AND install.sh lo invoca como script separado

## Requisitos MODIFICADOS

### Requisito: Mensajes de error informativos

El script install.sh SHALL mostrar mensajes de error claros con rutas específicas del sistema.

- GIVEN Una operación crítica falla
- WHEN El script reporta el error
- THEN Incluye información de contexto (ruta afectada, operación intentada) para facilitar diagnóstico

## Requisitos ELIMINADOS

### Requisito: (ninguno)

No se eliminan requisitos existentes en esta auditoría.
