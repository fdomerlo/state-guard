# Tareas: optimize-minimax-config

## Resumen

- **Cambio**: optimize-minimax-config
- **Modo**: openspec
- **Estado**: Lista para implementación
- **Archivos afectados**: 1 (`openspec/config.yaml`)

---

## Lista de Tareas

### 1. Infraestructura

#### 1.1 Leer archivo actual de configuración

- [x] Leer el archivo `openspec/config.yaml` actual para identificar la estructura exacta y los números de línea donde se insertarán las nuevas reglas
- **Criterio de completado**: Estructura del archivo documentada (fases, reglas existentes, sangría)
- **Fase SDD**: prepare

#### 1.2 Validar configuración inicial

- [x] Ejecutar validación YAML del archivo original antes de cualquier modificación
- **Criterio de completado**: `python3 -c "import yaml; yaml.safe_load(open('openspec/config.yaml'))"` ejecuta sin errores
- **Fase SDD**: prepare

---

### 2. Implementación

#### 2.1 Inyectar reglas en fase `design`

- [x] Agregar 2 nuevas reglas al final de la lista de la fase `design`:
  - "Explotar razonamiento arquitectónico: DEBES incluir diagramas Mermaid exhaustivos (State, Sequence o Class) para cualquier flujo no trivial."
  - "Priorizar modularidad extrema: Diseña el sistema asumiendo que el código será escrito por un modelo de IA con ventana de contexto limitada. Interfaces claras y acoplamiento nulo."
- **Criterio de completado**: Las 2 reglas aparecen como elementos de lista dentro de la fase `design`
- **Fase SDD**: apply

#### 2.2 Inyectar regla en fase `tasks`

- [x] Agregar 1 nueva regla al final de la lista de la fase `tasks`:
  - "Granularidad Atómica: Cada tarea debe ser lo suficientemente pequeña para implementarse en un solo archivo o módulo lógico. Evitar 'tareas monstruo'."
- **Criterio de completado**: La regla aparece como elemento de lista dentro de la fase `tasks`
- **Fase SDD**: apply

#### 2.3 Inyectar reglas en fase `apply`

- [x] Agregar 2 nuevas reglas al final de la lista de la fase `apply`:
  - "Código Defensivo y Pragmatismo: Aplica principios SOLID, DRY y Clean Code. Prefiere Early Returns (Guard Clauses). NUNCA sobre-ingeniar."
  - "Completitud: No uses placeholders como '...código restante aquí...'. Si escribes un archivo, escríbelo completo y listo para producción."
- **Criterio de completado**: Las 2 reglas aparecen como elementos de lista dentro de la fase `apply`
- **Fase SDD**: apply

---

### 3. Testing

#### 3.1 Validar sintaxis YAML

- [x] Verificar que el archivo modificado sea YAML válido
- **Comando**: `python3 -c "import yaml; yaml.safe_load(open('openspec/config.yaml'))"`
- **Criterio de completado**: No se lanza ninguna excepción
- **Fase SDD**: verify

#### 3.2 Verificar preservación de contexto

- [x] Confirmar que las secciones `context:` y `glossary:` no fueron modificadas
- **Criterio de completado**: Contenido de ambas secciones coincide exactamente con el original
- **Fase SDD**: verify

#### 3.3 Verificar distribución de reglas

- [x] Confirmar que las 5 reglas están en las fases correctas (design: 2, tasks: 1, apply: 2)
- **Criterio de completado**: Conteo de reglas por fase coincide con las especificaciones
- **Fase SDD**: verify

---

## Métricas

| Métrica | Valor |
|---------|-------|
| Total de tareas | 8 |
| Tareas de infraestructura | 2 |
| Tareas de implementación | 3 |
| Tareas de testing | 3 |

---

## Notas

- Este es un cambio simple de configuración que no requiere dependencias externas
- El plan de rollback es: `git checkout openspec/config.yaml`
- Las tareas de implementación pueden completarse en una sola sesión