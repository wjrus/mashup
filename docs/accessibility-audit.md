# Accessibility Audit and Remediation Record

Baseline date: 2026-08-18

Remediation pass: 2026-08-19

Target: WCAG 2.1 Level AA

This is a code-level audit and remediation record, not a conformance claim. It
covers application views, shared components, all five explicit themes plus
system theme behavior, keyboard-related JavaScript, request tests, and browser
system tests.

Before making a conformance statement, complete an automated accessibility scan,
a keyboard-only walkthrough, 200% zoom and 320 CSS-pixel reflow checks, and
manual VoiceOver testing. The original browser-assisted DOM scan could not run
because the local browser session was blocked by its URL security policy.

## Remediated Findings

### A11Y-01: Form control boundaries lacked non-text contrast

Relevant criterion: 1.4.11 Non-text Contrast (AA)

Status: Remediated

Each theme now has a dedicated control-border token with at least 3:1 contrast
against its panel surface. Automated tests calculate and enforce control, text,
muted-text, and focus-indicator contrast for every theme.

### A11Y-02: Flash messages imposed an unadjustable time limit

Relevant criterion: 2.2.1 Timing Adjustable (A)

Status: Remediated

Errors and warnings remain until explicitly dismissed. Success notices may
close after ten seconds, pause while hovered or focused, and remain persistent
when reduced motion is requested. All messages retain a labeled dismiss button
and render at the start of main content rather than as a fixed overlay.

### A11Y-03: Repeated navigation lacked a keyboard skip link

Relevant criterion: 2.4.1 Bypass Blocks (A)

Status: Remediated

The first focusable control is a visible-on-focus skip link. Activating it
explicitly focuses the main landmark, including in browsers that do not move
focus to fragment targets automatically.

### A11Y-04: Dynamic nested rows could lose keyboard focus

Relevant criterion: 2.4.3 Focus Order (A)

Status: Remediated

Adding a contact or booking run moves focus to its first field and announces the
addition. Removing one moves focus to a surviving remove control or the Add
button and announces the result through a polite live region.

### A11Y-05: Repeated table actions lacked row context

Relevant criteria: 1.3.1 Info and Relationships (A), 2.4.4 Link Purpose in
Context (A)

Status: Remediated

Repeated action controls now include the record name in their accessible label.
Record names are scoped row headers and action columns have accessible headings.

### A11Y-06: Current navigation and booking filters were visual only

Relevant criteria: 1.3.1 Info and Relationships (A), 4.1.2 Name, Role, Value (A)

Status: Remediated

The current primary navigation destination and active booking filter expose
`aria-current="page"`.

### A11Y-07: Server validation errors were not associated with fields

Relevant criteria: 1.3.1 Info and Relationships (A), 3.3.1 Error Identification
(A)

Status: Remediated

Invalid controls expose `aria-invalid`, reference their field-level message with
`aria-describedby`, and retain an error summary. After an invalid submission,
the summary receives focus so keyboard and screen-reader users encounter it
immediately. This applies to top-level forms, nested contacts and runs, and
booking documents.

### A11Y-08: Data-table relationships were not explicit

Relevant criterion: 1.3.1 Info and Relationships (A)

Status: Remediated

Data tables now have accessible captions, scoped column headers, and scoped row
headers.

## Verified Strengths

- Pages declare English, provide descriptive titles, and use a single `main`
  landmark with generally logical heading levels.
- Rails labels are programmatically associated with reviewed controls; native
  input types and required attributes are used where appropriate.
- The account disclosure and confirmation modal build on native `details` and
  `dialog`; Escape handling and focus-visible styles are present.
- Normal and muted text meet 4.5:1, while controls and focus indicators meet
  3:1, across every authored theme according to automated contrast tests.
- Status pills include text and do not communicate state by color alone.
- Browser system tests cover skip navigation, dynamic-row focus management,
  validation error focus and relationships, custom destructive confirmation,
  dismissible notices, action alignment, and narrow-width overflow.
