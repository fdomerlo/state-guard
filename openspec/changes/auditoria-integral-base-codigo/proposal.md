# Propuesta: Auditoría Integral del Repositorio agentify-sdd

## Intención

Corregir deuda técnica remanente, inconsistencias entre documentación y código, y errores de lógica identificados en el repositorio agentify-sdd. El sistema SDD presenta brechas entre lo documentado y lo implementado que afectan la experiencia de usuario y la mantenibilidad del proyecto.

## Alcance

### Dentro del Alcance
- Corregir README.md agregando comando `/sdd-propose` omitido en la tabla de comandos
- Actualizar `orchestrator-core.md` para clarificar diferencia entre meta-comandos y comandos directos
- Corregir incoherencia en `openspec-convention.md` (tabla vs descripción de sdd-archive)
- Refactorizar `scripts/install.sh`: eliminar placeholders, corregir URL de error, reemplazar `|| true` por manejo de errores explícito, y externalizar script inline de Python
- Generar reporte de hallazgos accionable con plan de mitigación

### Fuera del Alcance
- Modificar funcionalidades core de las skills
- Implementar cambios (solo hasta tasks.md según solicitud del usuario)
- Ejecutar verificación automatizada

## Enfoque

Ejecutar corrección incremental de documentación (esfuerzo bajo) como primera fase para victorias rápidas. Luego realizar auditoría de coherencia de contratos (esfuerzo medio) para validar consistencia entre archivos _shared e implementaciones. Finalmente, programar refactorización de install.sh para iteración posterior dado su mayor riesgo de regresión.

## Áreas Afectadas

| Área                                   | Impacto      | Descripción                                              |
|-----------------------------------------|--------------|----------------------------------------------------------|
| `README.md`                            | Modificado   | Agregar comando `/sdd-propose` faltante                 |
| `skills/_shared/orchestrator-core.md`   | Modificado   | Aclarar clasificación de meta-comandos                  |
| `skills/_shared/openspec-convention.md` | Modificado   | Corregir tabla vs descripción de sdd-archive           |
| `scripts/install.sh`                    | Modificado   | Eliminar placeholders, corregir URL, mejorar manejo de errores |

## Riesgos

| Riesgo                                 | Probabilidad | Mitigación                                   |
|----------------------------------------|--------------|----------------------------------------------|
| Regresión en script de instalación    | Media        | Ejecutar install_test.sh antes de deployment |
| Inconsistencia temporal entre archivos | Baja         | Actualizar documentos relacionados en una sesión |

## Plan de Rollback

Revertir cambios en archivos modificados mediante git checkout. El script install.sh mantiene compatibilidad hacia atrás si se preservan los flags existentes.

## Dependencias

- Ninguna dependencia externa

## Criterios de Éxito

- [ ] README.md incluye `/sdd-propose` en tabla de comandos
- [ ] orchestrator-core.md define claramente meta-comandos vs comandos directos
- [ ] openspec-convention.md coherente entre tabla y descripción de sdd-archive
- [ ] install.sh sin placeholders y con manejo de errores explícito
- [ ] Reporte de hallazgos generado con priorización de deuda técnica
