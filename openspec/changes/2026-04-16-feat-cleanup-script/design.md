# Diseño: Script de Mantenimiento y Limpieza

## Enfoque Técnico

Construiremos `scripts/cleanup.sh` modelando el esquema pre-existente validado en `install.sh`. Se evadirán manipulaciones sobre json complejas (mediante el parser binario `jq`) para preferir implementaciones `0-dependency` (cero dependencias externas al shell nativo del usuario). Valida todo purgado de chunks a través de expresiones genéricas apoyadas en tags string HTML integrados por nuestros bloques.

## Decisiones de Arquitectura

### Decisión: Bloqueo Selectivo sobre configs Inyectadas

**Elección**: Módulo awk con flag switch mode buscará interceptar en el buffer interlineal del texto la clave `<!-- BEGIN SDD ORCHESTRATOR -->`, desactivando la impresión sobre el tmp transcríbete hasta hallar el `END`.
**Alternativas consideradas**: Usar `jq -del` con filtros sed para `opencode.json`.
**Justificación**: Mantiene la herramienta POSIX-strict, aprovechando que el instalador de la plataforma preexistencia en todos los casos el bloque general concatenado.

### Decisión: Prompting sobre bandera Opcional (`--hard`)

**Elección**: Interrupción real estipulada en la terminal mediante `read -r -p "Proceder? [y/N] " input`.
**Alternativas consideradas**: Aceptación implícita de flag destructivo y volcado imperativo al runtime.
**Justificación**: Prevenir el borrado masivo por invocación imprudente mediante alias, loops o equivocaciones operacionales.

## Flujo de Datos

    Usuario Ejecuta Script ──→ Identifica OS paths resolutivos
                                        │
             ┌──────────────────────────┴─────────────────────────┐
             │ (Target Tool config dir)                           │ (Flag --hard)
   ¿Localiza Bloque Taggeado?                               Muestra Prompt Advirte
      Sí ──→ Lee saltando las lineas del bloque SDD           Responde Y ──→ Rm -rf changes/
      No ──→ Ignora la retranscripciones                      Responde N ──→ Salida preventiva
             
## Cambios de Archivos

| Archivo | Acción | Descripción |
|---|---|---|
| `scripts/cleanup.sh` | Crear | Script shell iterador y manager del limpiado de entorno universal. |

## Interfaces / Contratos

```bash
# Invocaciones Posibles Previstas
bash scripts/cleanup.sh
bash scripts/cleanup.sh --hard
```

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|---|---|---|
| Integración | Respeto a variables base contextuales extra-SDD. | Si hubiese que agregarlo futuramente en `install_test`: mockear un `CLAUDE.md` con custom instructions arriba del límite de SDD, ejecutar el script de testeo final constatando que el bloque original sobrevive. |

## Migración / Despliegue

Script provisto directamente dentro del árbol de repositorio y versiones sin requerimientos colaterales. No aplica migración al considerarse herramienta standalone de mantenimiento.

## Preguntas Abiertas
- Ninguna.
