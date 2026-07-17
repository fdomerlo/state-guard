---
name: boot
description: >
  Despierta a State Guard, carga el contrato del DAG y sincroniza el estado actual sin modificar nada.
  Disparador: Para iniciar o retomar una sesión sin alterar el hilo de ejecución.
license: MIT
---

# Boot Skill (Arranque en Frío)

## Propósito
Activar el framework de memoria transaccional (State Guard) en el orquestador y sincronizar el contexto del proyecto sin forzar el inicio de ninguna fase de desarrollo.

## Instrucciones OBLIGATORIAS (Ejecutar en orden estricto)

1. **Cargar el Contrato Base:** Ejecuta tu herramienta de lectura de archivos para asimilar el contrato principal del DAG y las transacciones.
   - Archivo: `~/.agents/skills/state-guard/_shared/memory-guard.md`
   - *Aplica absolutamente todas las reglas allí descritas desde este momento.*

2. **Sincronizar el Estado:** Averigua dónde estamos parados. Ejecuta el siguiente comando en la terminal para leer el estado de la base de datos:
   - Comando: `~/.agents/skills/state-guard/bin/state_manager.py status`

3. **Reporte y Standby:** Informa al usuario de manera breve y profesional:
   - Confirma que "State Guard está Activo y el contrato DAG fue cargado".
   - Muestra el estado del proyecto según lo que devolvió el comando `status` (¿Hay un cambio activo? ¿Qué fase está bloqueada/habilitada en `lock_phase`?).
   - Queda a la espera de las instrucciones del usuario, sugiriendo amablemente el comando lógico a seguir (ej. `/continue` si hay trabajo pendiente, o `/new` si está todo libre).
