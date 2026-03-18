# Especificación de Documentación - README

## Propósito

Este documento define las especificaciones para el archivo README.md del proyecto Agentify SDD. El README sirve como punto de entrada principal para nuevos usuarios, proporcionando una propuesta de valor clara, instrucciones de instalación rápidas y una referencia de comandos.

## Requisitos

### Requisito: Propuesta de Valor en Primeras Líneas

Las primeras tres líneas del README.md **DEBEN** contener una propuesta de valor clara que responda:
- Qué es el proyecto
- Para quién está diseñado
- Por qué debería usarlo

El sistema **DEBE** presentar esta información en máximo 3 líneas para captar la atención del usuario inmediatamente.

#### Escenario: Presentación Inicial del Proyecto

- GIVEN Un nuevo usuario que visita el repositorio
- WHEN Lee las primeras líneas del README
- THEN Encuentra respuesta a: qué es, para quién es, y por qué usarlo
- AND La información es concisa (máximo 3 líneas)

### Requisito: Instrucciones de Instalación para Unix

El README **DEBE** incluir instrucciones de instalación para sistemas Unix/Linux/macOS.

El sistema **DEBE** mostrar el comando:
```bash
bash scripts/install.sh
```

#### Escenario: Instalación en Unix

- GIVEN Un usuario en sistema Unix (Linux/macOS)
- WHEN Necesita instalar el proyecto
- THEN Encuentra el comando `bash scripts/install.sh` en el README
- AND El comando es ejecutable sin parámetros adicionales

### Requisito: Instrucciones de Instalación para Windows

El README **DEBE** incluir instrucciones de instalación para Windows.

El sistema **DEBE** mostrar el comando:
```powershell
powershell .\scripts\install.ps1
```

#### Escenario: Instalación en Windows

- GIVEN Un usuario en sistema Windows
- WHEN Necesita instalar el proyecto
- THEN Encuentra el comando `powershell .\scripts\install.ps1` en el README
- AND El comando es ejecutable sin parámetros adicionales

### Requisito: Tabla de Comandos Disponibles

El README **DEBE** incluir una tabla con los 15 comandos disponibles del orquestador SDD.

El sistema **DEBE** mostrar:
- Nombre del comando
- Descripción breve
- Total de 15 comandos documentados

#### Escenario: Referencia de Comandos

- GIVEN Un usuario que quiere conocer las capacidades del proyecto
- WHEN Busca la sección de comandos en el README
- THEN Encuentra una tabla con 15 comandos
- AND Cada comando tiene nombre y descripción breve

### Requisito: Tono Profesional y Directo

El README **DEBE** mantener un tono profesional, pragmático y directo.

El sistema **DEBE** evitar:
- Jerga innecesaria
- Explicaciones excesivamente largas
- Contenido obsoleto o redundante

#### Escenario: Tono del Documento

- GIVEN Un usuario leyendo el README
- WHEN Lee el contenido del documento
- THEN El tono es profesional, conciso y directo
- AND No contiene jerga innecesaria ni explicaciones excesivas

### Requisito: Preservación de Diagramas Esenciales

El README **DEBE** incluir diagramas Mermaid esenciales cuando sea necesario para la comprensión rápida.

El sistema **DEBE** mantener solo diagramas simples que ayuden a entender el concepto principal, no diagramas complejos técnicos.

#### Escenario: Diagramas en README

- GIVEN Un usuario que necesita entender la arquitectura básica
- WHEN Ve un diagrama en el README
- THEN El diagrama es simple (Mermaid) y esencial
- AND No contiene detalles técnicos complejos

## Criterios de Verificación

- Las primeras 3 líneas contienen propuesta de valor clara
- Sección de instalación Unix con comando `bash scripts/install.sh`
- Sección de instalación Windows con comando `powershell .\scripts\install.ps1`
- Tabla con exactamente 15 comandos del orquestador
- Tono profesional, pragmático y directo
- Diagramas Mermaid esenciales preservados (si aplica)
