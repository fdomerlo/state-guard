# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **Arquitectura de Meta-Skills**: Universalización de los comandos de gestión de SDD (`/sdd-new`, `/sdd-continue`, `/sdd-ff`). Extraídos desde el namespace legado de OpenCode hacia `skills/` estándar como herramientas de primera clase deterministas compatibles con **todos** los agentes (Claude Code, Gemini CLI, OpenCode, Antigravity).
- **Anti-Batching Consolidado**: `/sdd-ff` ahora integra soporte de persistencia ACID explícito para garantizar que el DAG no se corrompe por alucinaciones o consolidación forzosa en un solo prompt del LLM.

### Fixed
- **Suite de Pruebas Dinámica**: Reparado `scripts/install_test.sh` y eliminado dependencias estáticas de aserciones legacy. Ahora la CI soporta dinámicamente las 20 skills universales sin fallar por rutas inexistentes.
