# Especificaciones Delta: refactor-workflow-optimization

## 1. Regla de Concurrencia (Stateless)

### SCENARIO: Usuario ejecuta comando sin especificar change cuando existe un único cambio activo

**Given** el usuario ejecuta un comando del orquestador (`/sdd-continue`, `/sdd-apply` o `/sdd-verify`)  
**And** NO especifica el argumento `[change]`  
**And** existe EXACTAMENTE UNA carpeta en `openspec/changes/` (ignorando `archive/`)  
**When** el orquestador procesa el comando  
**Then** DEBE ejecutar el comando sobre el único cambio activo sin pedir confirmación  

---

### SCENARIO: Usuario ejecuta comando sin especificar change cuando existen múltiples cambios activos

**Given** el usuario ejecuta un comando del orquestador (`/sdd-continue`, `/sdd-apply` o `/sdd-verify`)  
**And** NO especifica el argumento `[change]`  
**And** existen DOS O MÁS carpetas en `openspec/changes/` (ignorando `archive/`)  
**When** el orquestador procesa el comando  
**Then** DEBE detenerse inmediatamente  
**And** DEBE listar todos los cambios activos con su estado  
**And** DEBE pedir al usuario que especifique explícitamente cuál cambio quiere usar  
**And** NO DEBE ejecutar ningún comando hasta que el usuario proporcione un `[change]` válido  

---

### SCENARIO: Usuario ejecuta comando especificando un change válido

**Given** el usuario ejecuta un comando del orquestador (`/sdd-continue`, `/sdd-apply` o `/sdd-verify`)  
**And** especifica un argumento `[change]` válido  
**When** el orquestador procesa el comando  
**Then** DEBE ejecutar el comando sobre el cambio especificado  

---

### SCENARIO: Usuario ejecuta comando especificando un change inválido

**Given** el usuario ejecuta un comando del orquestador (`/sdd-continue`, `/sdd-apply` o `/sdd-verify`)  
**And** especifica un argumento `[change]` que NO existe en `openspec/changes/`  
**When** el orquestador procesa el comando  
**Then** DEBE mostrar error indicando que el cambio no existe  
**And** DEBE listar los cambios disponibles  

---

## 2. Regla de Paralelismo Condicional

### SCENARIO: Herramienta con soporte nativo de sub-agentes ejecuta spec y design

**Given** el usuario ejecuta `/sdd-continue` o `/sdd-ff`  
**And** las siguientes fases a ejecutar son `spec` Y `design`  
**And** la variable `{{TOOL_NAME}}` indica una herramienta con soporte nativo de sub-agentes (Claude Code, OpenCode)  
**When** el orquestador procesa el comando  
**Then** DEBE lanzar las fases `spec` y `design` en PARALELO  

---

### SCENARIO: Herramienta inline ejecuta spec y design

**Given** el usuario ejecuta `/sdd-continue` o `/sdd-ff`  
**And** las siguientes fases a ejecutar son `spec` Y `design`  
**And** la variable `{{TOOL_NAME}}` indica una herramienta de ejecución inline (Gemini CLI, Codex)  
**When** el orquestador procesa el comando  
**Then** DEBE ejecutar las fases `spec` y `design` de forma SECUENCIAL  

---

### SCENARIO: Fases diferentes a spec y design

**Given** el usuario ejecuta `/sdd-continue` o `/sdd-ff`  
**And** las siguientes fases NO son simultáneamente `spec` y `design`  
**When** el orquestador procesa el comando  
**Then** DEBE ejecutar las fases de forma SECUENCIAL independientemente de la herramienta  

---

### SCENARIO: Herramienta no reconocida

**Given** el usuario ejecuta `/sdd-continue` o `/sdd-ff`  
**And** la variable `{{TOOL_NAME}}` contiene un valor no reconocido o está vacía  
**When** el orquestador procesa el comando  
**Then** DEBE ejecutar las fases de forma SECUENCIAL como fallback seguro  

---

## 3. Regla del Loop de Fix (/sdd-fix)

### SCENARIO: Usuario ejecuta /sdd-fix con change válido que tiene verify-report.md fallido

**Given** el usuario ejecuta `/sdd-fix [change]`  
**And** el cambio especificado existe  
**And** existe un archivo `verify-report.md` en el directorio del cambio  
**And** el reporte indica que la verificación FALLÓ  
**When** el orquestador procesa el comando  
**Then** DEBE leer el `verify-report.md`  
**And** DEBE extraer los errores encontrados  
**And** DEBE lanzar la fase `sdd-apply` pasándole explícitamente los errores como contexto  
**And** DEBE actualizar el archivo `tasks.md` con las correcciones realizadas  

---

### SCENARIO: Usuario ejecuta /sdd-fix con change válido que tiene verify-report.md exitoso

**Given** el usuario ejecuta `/sdd-fix [change]`  
**And** el cambio especificado existe  
**And** existe un archivo `verify-report.md` en el directorio del cambio  
**And** el reporte indica que la verificación ÉXITO  
**When** el orquestador procesa el comando  
**Then** DEBE informar al usuario que no hay errores que corregir  
**And** NO DEBE ejecutar `sdd-apply`  

---

### SCENARIO: Usuario ejecuta /sdd-fix sin verify-report.md

**Given** el usuario ejecuta `/sdd-fix [change]`  
**And** el cambio especificado existe  
**And** NO existe un archivo `verify-report.md` en el directorio del cambio  
**When** el orquestador procesa el comando  
**Then** DEBE informar al usuario que no existe reporte de verificación  
**And** DEBE sugerir ejecutar `/sdd-verify` primero  

---

### SCENARIO: Usuario ejecuta /sdd-fix sin especificar change

**Given** el usuario ejecuta `/sdd-fix` sin argumento `[change]`  
**When** el orquestador procesa el comando  
**Then** DEBE aplicar la Regla de Concurrencia (Stateless) para determinar qué cambio usar  

---

## 4. Regla de Contexto Estricto en sdd-propose

### SCENARIO: Sub-agente sdd-propose genera propuesta con exploración previa

**Given** el sub-agente `sdd-propose` es invocado para un cambio  
**And** existe un archivo `exploration.md` en el directorio del cambio  
**OR** se le pasó contexto efímero de exploración  
**When** el sub-agente genera la propuesta  
**Then** DEBE incluir el contexto de exploración en el análisis  
**And** NO DEBE agregar advertencia de exploración faltante  

---

### SCENARIO: Sub-agente sdd-propose genera propuesta SIN exploración previa

**Given** el sub-agente `sdd-propose` es invocado para un cambio  
**And** NO existe un archivo `exploration.md` en el directorio del cambio  
**And** NO se le pasó contexto efímero de exploración  
**When** el sub-agente genera la propuesta  
**Then** DEBE agregar un bloque de ADVERTENCIA SEVERA en la sección RIESGOS  
**And** El mensaje DEBE decir exactamente: "La propuesta fue generada a ciegas sin fase de exploración previa y podría contener suposiciones inválidas"  

---

### SCENARIO: Validación de exploración durante ejecución

**Given** el sub-agente `sdd-propose` está en proceso de generar propuesta  
**When** termina de analizar el contexto  
**Then** DEBE verificar activamente la existencia de `exploration.md` o contexto efímero  
**And** si no encuentra ninguno, DEBE incluir la advertencia automáticamente en el output  

---

## 5. Integración sdd-apply con errores de verify

### SCENARIO: sdd-apply recibe errores del verify como contexto

**Given** la fase `sdd-apply` es ejecutada como parte del flujo `/sdd-fix`  
**And** se le pasa el contenido del `verify-report.md` con los errores  
**When** procesa las tareas de implementación  
**Then** DEBE priorizar la corrección de los errores identificados  
**And** DEBE documentar en `tasks.md` qué errores fueron corregidos  
**And** DEBE mantener el resto de las tareas sin cambios  

---

### SCENARIO: sdd-apply ejecutado normalmente (sin errores de verify)

**Given** la fase `sdd-apply` es ejecutada sin contexto de errores  
**When** procesa las tareas de implementación  
**Then** DEBE comportarse como antes (flujo normal)  

---

## 6. Integración sdd-verify genera reporte estructurado

### SCENARIO: sdd-verify genera reporte consumible por /sdd-fix

**Given** la fase `sdd-verify` es ejecutada  
**When** genera el resultado de verificación  
**Then** DEBE crear un archivo `verify-report.md` en formato estructurado  
**And** El reporte DEBE incluir:
- **Status**: ÉXITO o FALLO
- **Errores**: Lista de errores encontrados (si los hay)
- **Detalles**: Información específica de cada fallo

---

### SCENARIO: sdd-verify con verificación exitosa

**Given** la fase `sdd-verify` es ejecutada  
**And** todas las verificaciones pasan  
**When** genera el reporte  
**Then** DEBE crear `verify-report.md` con status ÉXITO  
**And** DEBE tener lista de errores vacía  

---

### SCENARIO: sdd-verify con verificación fallida

**Given** la fase `sdd-verify` es ejecutada  
**And** al menos una verificación falla  
**When** genera el reporte  
**Then** DEBE crear `verify-report.md` con status FALLO  
**And** DEBE listar cada error con su descripción  
