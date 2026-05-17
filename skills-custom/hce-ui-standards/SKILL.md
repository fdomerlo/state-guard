---
name: hce-ui-standards
description: Estándares estrictos de UX/UI médica para Historias Clínicas Electrónicas. Impone reglas para evitar fatiga de alertas, reducir carga cognitiva y asegurar accesibilidad en entornos clínicos.
---
# SKILL: Healthcare UX/UI Standards (NIST/AHRQ Compliance)

## CONTEXTO DEL SISTEMA
Estás desarrollando la interfaz de usuario para una Historia Clínica Electrónica (HCE). El diseño debe priorizar la seguridad del paciente, la mitigación de errores médicos y la velocidad de operación en un entorno de alta carga cognitiva. 
**Stack tecnológico obligatorio:** HTML, TailwindCSS, HTMX, Alpine.js.

## INSTRUCCIONES PARA EL AGENTE (REGLAS ESTRICTAS)

### 1. Mitigación de Fatiga de Alertas (Alert Fatigue)
**Regla Estricta:** Los colores semánticos de advertencia (Rojo, Amarillo, Naranja) están estrictamente reservados para condiciones que alteren inmediatamente la conducta clínica.
* **PROHIBIDO:** Usar `bg-red-*` o `text-red-*` para validaciones de formularios menores, estados vacíos, o índices fuera de rango leve.
* **PERMITIDO:** Usar rojo/amarillo EXCLUSIVAMENTE para alergias severas (ej. Penicilina), trastornos de coagulación, o fallos críticos de seguridad (ej. Consentimiento revocado).
* **Alternativa:** Para notificaciones estándar o índices epidemiológicos regulares, utiliza variaciones sutiles de la paleta neutral (`bg-gray-100`, `text-slate-700`) o acentos fríos (`blue`, `teal`).

### 2. Reducción de la Carga Cognitiva (Arquitectura del Dashboard)
**Regla Estricta:** La información de soporte vital y alertas pre-clínicas deben ser visibles en el primer nivel de escaneo visual sin requerir interacción. (No clicks, no modals, no scroll).
* **PROHIBIDO:** Ocultar antecedentes de riesgo sistémico como alergias, grupo sanguíneo o directivas anticipadas detrás de clicks, ventanas modales o requerir scroll. Deben estar siempre en el header del paciente.
* **PERMITIDO:** Un panel persistente o cabecera inmovilizada que muestre Edad, Signos Vitales Críticos y Patologías Activas.
* **Estilo Tailwind:** Prioriza tipografías legibles y alto contraste. Usa `tracking-tight` y `leading-snug` para agrupar datos médicos relacionados.

### 3. Flujos Asimétricos (Entrada vs. Auditoría)
**Regla Estricta:** El diseño debe distinguir contextualmente la tarea que se está realizando.
* **Para Anamnesis/Carga (Modo Alumno):** 
	* Utiliza validación en línea mediante HTMX (`hx-post`, `hx-trigger="blur"`).
    * Minimiza los campos de texto libre; favorece botones de selección rápida (Radio groups / Toggles diseñados con Tailwind).
* **Para Urgencias (Modo Triage):** 
	* Minimizar interacciones. Los formularios deben soportar ingreso de datos sin levantar las manos del teclado (full keyboard navigation con Tailwind).
* **Para Auditoría/Firma (Modo Docente):** 
	* El diseño debe priorizar el contraste y la escaneabilidad. 
	* Los botones de acción crítica (Firma, Aprobación) deben requerir confirmación explícita si alteran la inmutabilidad legal, pero sin abusar de ventanas modales que tapen el contexto clínico subyacente.

### 4. Accesibilidad y Entorno Físico (Boxes Odontológicos/Guardias)
**Regla Estricta:** Las interfaces serán operadas principalmente en tablets y monitores con guantes de látex o iluminación clínica intensa.
* **Tamaño de objetivos:** Todo botón o zona interactiva debe tener un tamaño mínimo de `h-10 w-10` o `min-h-[44px]` (Touch targets).
* **Contraste:** Cumplir WCAG AA mínimo. Evitar grises claros sobre fondos blancos (`text-gray-400` sobre `bg-white`).
* **Densidad:** Usa paddings amplios (`p-4`, `gap-4`) en listados de tratamientos para evitar toques accidentales en filas contiguas.

## EJEMPLO DE CÓDIGO APROBADO (Componente de Alerta Crítica)

```html
<div class="border-l-4 border-red-600 bg-red-50 p-4 mb-4" role="alert">
    <div class="flex items-center">
        <svg class="h-5 w-5 text-red-600 mr-2" fill="currentColor" viewBox="0 0 20 20">...</svg>
        <h3 class="text-sm font-bold text-red-800">ALERGIA SEVERA: PENICILINA</h3>
    </div>
    <div class="mt-2 text-sm text-red-700">
        <p>Anafilaxia documentada. Evitar todo derivado betalactámico.</p>
    </div>
    <div class="border-l-4 border-slate-400 bg-slate-50 p-4 mb-4">
	    <h3 class="text-sm font-medium text-slate-700">Índice O'Leary: 18%</h3>
	    <p class="text-xs text-slate-500">Registrado el 24/02/2026</p>
	</div>
</div>