# Spec: Persistencia y Ejecución

## Propósito

Esta especificación define el modelo de persistencia y ejecución del framework Agentify SDD. El framework asume por diseño que el 100% de los sub-agentes tienen acceso a herramientas nativas de I/O (filesystem, ejecución de comandos).

## Requisitos

### Requisito: Persistencia Implícita en File System

El framework SHALL asumir que toda persistencia de artefactos se realiza directamente en el File System siguiendo la convención OpenSpec. No DEBE existir una variable de configuración para alternar este comportamiento.

#### Escenario: Escritura de Artefacto

- GIVEN un sub-agente genera un artefacto (propose, spec, design, task)
- WHEN el sistema solicita la persistencia
- THEN el archivo DEBE escribirse en `openspec/changes/{nombre-cambio}/` de forma automática
- AND no se DEBE consultar ninguna variable de "modo" para esta operación

### Requisito: Verificación de Implementación

La verificación de implementación DEBE asumir exclusivamente la persistencia en disco. La skill sdd-verify DEBE fallar si detecta lógica condicional basada en modos de almacenamiento inexistentes o variables de modo obsoletas.

### Requisito: Documentación de Capacidades Requeridas

El framework DEBE documentar claramente que requiere agentes con capacidades nativas de I/O.

#### Escenario: Usuario Consulta Capacidades Requeridas

- GIVEN un usuario consulta la documentación del framework
- WHEN el usuario revisa los requisitos de ejecución
- THEN el documento DEBE indicar que se requieren agentes CLI con acceso a filesystem y herramientas
- AND el documento DEBE listar los agentes compatibles: Claude Code, OpenCode, Gemini CLI, Antigravity

---

## Historia del Cambio

### Cambio: purga-compatibilidad-inline-core (2026-04-06)

Este requisito fue añadido como un cambio para eliminar el soporte del modo `none` (fallback para editores inline/pasivos) del framework Agentify SDD.

**Requisitos ELIMINADOS por este cambio:**
- Soporte de Modo None en Persistencia (REQ-01)
- Fallback de Registry para Editores Inline (REQ-02)

**Requisitos MODIFICADOS por este cambio:**
- Modo de Persistencia Válido (anteriormente soportaba múltiples modos)
- Verificación de Implementación (anteriormente incluía lógica condicional para modo `none`)
- Skills de Fases Sin Menciones a Modo None (anteriormente contenía menciones históricas)

---

## Criterios de Verificación

1. Solo el modo `openspec` es aceptado en inicialización
2. Referencias al modo `none` son detectadas por sdd-review
3. Todas las skills mencionan exclusivamente `openspec`
4. La documentación indica agentes CLI como requisito
