# Propuesta: Traducción de Descripciones de Skills al Castellano

## Intención

Traducir el campo `description` en el encabezado YAML de todos los archivos `SKILL.md` al español. Esto asegura coherencia con la política de localización del proyecto y mejora la claridad para los auditores y usuarios hispanohablantes.

## Alcance

- Modificar los 9 archivos `SKILL.md` identificados:
  - `sdd-apply/SKILL.md`
  - `sdd-archive/SKILL.md`
  - `sdd-design/SKILL.md`
  - `sdd-explore/SKILL.md`
  - `sdd-init/SKILL.md`
  - `sdd-propose/SKILL.md`
  - `sdd-spec/SKILL.md`
  - `sdd-tasks/SKILL.md`
  - `sdd-verify/SKILL.md`

## Enfoque

1. Leer el encabezado actual de cada skill.
2. Traducir la descripción manteniendo el formato YAML multilínea (`>`).
3. Actualizar los archivos.

## Plan de Rollback

- Revertir los cambios mediante Git (`git checkout skills/`).
