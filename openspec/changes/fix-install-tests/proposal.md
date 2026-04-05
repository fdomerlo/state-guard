# Propuesta: Actualizar Suite de Pruebas de Instalación

## Intención

Actualizar la suite de pruebas del script de instalación (`scripts/install_test.sh`) para reflejar los nuevos recuentos de skills y comandos introducidos en la versión reciente del proyecto. Los nuevos skills `sdd-checkpoint` y `sdd-rollback` fueron añadidos al conjunto de habilidades SDD, incrementando el total de 15 a 17 skills y los comandos de OpenCode de 17 a 19. Las pruebas actuales fallarán porque esperan los valores antiguos. Este cambio garantiza que la suite de pruebas valide correctamente la instalación de la versión actual.

## Alcance

### Dentro del Alcance
- Modificar el array `EXPECTED_SKILLS` para incluir `sdd-checkpoint` y `sdd-rollback`
- Actualizar todos los conteos de skills de 15 a 17 (9 instancias)
- Actualizar los conteos de comandos OpenCode de 17 a 19 (3 instancias)
- Actualizar el total de all-global de 75 a 85 (5×17) en dos lugares
- Cambiar el mensaje de verificación de output de "15 skills installed" a "17 skills installed"

### Fuera del Alcance
- NO modificar la lógica de las pruebas, solo los valores esperados
- NO agregar nuevas pruebas
- NO alterar el comportamiento del script de instalación

## Enfoque

El cambio es una actualización de valores constantes en el archivo de pruebas. Se identificaron las cinco áreas específicas que requieren modificación mediante análisis del código fuente. No se requiere refactorización ni arquitectura nueva. El enfoque consiste en realizar sustituciones exactas de cadena sin alterar la funcionalidad de las pruebas.

## Áreas Afectadas

| Área                      | Impacto    | Descripción                                                |
|---------------------------|------------|-------------------------------------------------------------|
| `scripts/install_test.sh` | Modificado | Actualizar recuentos de skills y comandos esperados       |

## Riesgos

| Riesgo                              | Probabilidad | Mitigación                                   |
|-------------------------------------|--------------|----------------------------------------------|
| Olvidar alguna instancia de conteo   | Baja         | Verificación manual exhaustiva del archivo  |
| Cambiar lógica en lugar de valores  | Baja         | Revisión sistemática de las modificaciones  |

## Plan de Rollback

Para revertir este cambio, se restaurará el archivo `scripts/install_test.sh` mediante `git checkout scripts/install_test.sh`. Los valores revertidos serán: array `EXPECTED_SKILLS` con 15 elementos, todos los `assert_eq "15"` restaurados, todos los `assert_eq "17"` restaurados para comandos, total all-global de 75, y grep de "15 skills installed".

## Dependencias

- Ninguna. Este cambio es independiente y no requiere prerequisitos.

## Criterios de Éxito

- [ ] Todas las pruebas en `scripts/install_test.sh` pasan exitosamente
- [ ] Los valores esperados coinciden con los skills y comandos reales instalados
- [ ] Los mensajes de output reflejan el conteo correcto de skills instalados