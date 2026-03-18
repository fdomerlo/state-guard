# Delta para Ecosistema SDD

## Propósito

Actualización del ecosistema SDD para registrar y soportar las dos nuevas skills: `sdd-review` y `sdd-split`. Incluye modificaciones en el core del orquestador, scripts de instalación y tests de verificación.

## Requisitos AGREGADOS

### Requisito: Registro de Comando /sdd-review

El archivo `skills/_shared/orchestrator-core.md` DEBE incluir el comando `/sdd-review` en la lista de comandos disponibles:
- El comando DEBE estar documentado con su propósito
- DEBE indicar que invoca la skill `sdd-review`
- DEBE seguir el mismo formato que los comandos existentes

#### Escenario: Comando Registrado

- GIVEN el archivo orchestrator-core.md sin /sdd-review
- WHEN se agrega el registro del comando
- THEN DEBE aparecer en la sección de comandos disponibles
- AND DEBE incluir una descripción breve de su función

### Requisito: Registro de Comando /sdd-split

El archivo `skills/_shared/orchestrator-core.md` DEBE incluir el comando `/sdd-split` en la lista de comandos disponibles:
- El comando DEBE estar documentado con su propósito
- DEBE indicar que invoca la skill `sdd-split`
- DEBE seguir el mismo formato que los comandos existentes

#### Escenario: Comando Registrado

- GIVEN el archivo orchestrator-core.md sin /sdd-split
- WHEN se agrega el registro del comando
- THEN DEBE aparecer en la sección de comandos disponibles
- AND DEBE incluir una descripción breve de su función

### Requisito: Actualización de install.sh

El script `scripts/install.sh` DEBE actualizarse para copiar las 12 skills (no 10):
- El contador de skills DEBE ser 12
- DEBE incluir las rutas para sdd-review y sdd-split
- La instalación DEBE completar exitosamente con las nuevas skills

#### Escenario: Instalación con 12 Skills

- GIVEN el script install.sh con contador = 10
- WHEN se ejecuta el script
- THEN DEBE copiar las 12 skills al directorio destino
- AND NO DEBE haber errores de "archivo no encontrado"

### Requisito: Actualización de install_test.sh

El script `scripts/install_test.sh` DEBE actualizarse para verificar 12 skills:
- La variable EXPECTED_SKILLS DEBE ser 12
- DEBE verificar que las 12 skills existen después de la instalación
- Los tests DEBEN pasar con el nuevo conteo

#### Escenario: Test Pasa con 12 Skills

- GIVEN install_test.sh con EXPECTED_SKILLS = 10
- WHEN se ejecuta el test
- THEN DEBE fallar indicando que faltan skills
- AND DESPUÉS de actualizar a 12, DEBE pasar exitosamente

## Requisitos MODIFICADOS

### Requisito: Lista de Comandos del Orquestador

La lista de comandos en `orchestrator-core.md` DEBE actualizarse de 10 a 12 comandos:

| Comando              | Descripción                                     |
|----------------------|-------------------------------------------------|
| /sdd-init            | Inicializa el contexto SDD en un proyecto     |
| /sdd-explore         | Explora e investiga ideas antes de un cambio  |
| /sdd-new             | Crea una nueva propuesta de cambio             |
| /sdd-propose         | Crea o actualiza una propuesta de cambio       |
| /sdd-spec            | Escribe especificaciones delta                 |
| /sdd-design          | Crea el diseño técnico                         |
| /sdd-tasks           | Desglosa el cambio en tareas                  |
| /sdd-apply           | Implementa tareas del cambio                   |
| /sdd-verify          | Valida implementación vs specs                 |
| /sdd-archive         | Archiva un cambio completado                  |
| /sdd-review          | Audita código implementado contra specs        |
| /sdd-split           | Divide proposals monolíticas en sub-cambios   |

(Anteriormente: solo 10 comandos, sin /sdd-review ni /sdd-split)

#### Escenario: Comandos Actualizados

- GIVEN orchestrator-core.md con 10 comandos
- WHEN se agregan los dos nuevos comandos
- THEN la lista DEBE mostrar 12 comandos
- AND cada nuevo comando DEBE tener su descripción

### Requisito: Contador de Skills en install.sh

El contador en `scripts/install.sh` DEBE actualizarse:

```bash
# Antes
EXPECTED_SKILLS=10

# Después
EXPECTED_SKILLS=12
```

(Anteriormente: 10 skills)

#### Escenario: Contador Actualizado

- GIVEN install.sh con EXPECTED_SKILLS=10
- WHEN se ejecuta el script
- THEN DEBE operar con el nuevo valor de 12
- AND DEBE completar sin errores de verificación

### Requisito: Verificación de install_test.sh

El script `scripts/install_test.sh` DEBE actualizarse para verificar 12 skills:
- La verificación DEBE incluir checks para sdd-review y sdd-split
- Los mensajes de error DEBEN reflejar 12 skills esperadas

(Anteriormente: verificaba 10 skills)

#### Escenario: Test Verifica 12 Skills

- GIVEN install_test.sh verificando 10 skills
- WHEN se ejecuta antes del cambio
- THEN DEBE fallar porque faltan 2 skills
- AND DESPUÉS del cambio, DEBE pasar indicando 12 skills encontradas

## Requisitos ELIMINADOS

### Requisito: Contador de 10 Skills

El requisito de tener exactamente 10 skills DEBE eliminarse:
- El sistema DEBE soportar 12 skills
- Las referencias a "10 skills" en documentación DEBEN actualizarse

(Motivo: El ecosistema evoluciona para soportar más skills)

### Requisito: Test de 10 Skills

El test que verifica exactamente 10 skills DEBE eliminarse o actualizarse:
- El nuevo test DEBE verificar 12 skills

(Motivo: Mantener consistencia con el nuevo número de skills)
