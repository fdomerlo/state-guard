# Execution and Persistence Contract

- Utiliza únicamente las rutas y el contexto que el orquestador te provea directamente.
- Toda operación de persistencia debe realizarse dentro del marco del `state.yaml` actual.
- Recupera los artefactos de fases anteriores (`explore`, `proposal`, `spec`, `design`, `tasks`) como dependencias usando las rutas proporcionadas por el orquestador.
- Actualiza el estado o los archivos correspondientes según lo requiera tu fase.
