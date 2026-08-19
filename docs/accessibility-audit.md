# Accessibility Audit Baseline

Date: 2026-08-18  
Baseline: `f4f1a1e`  
Target: WCAG 2.1 Level AA

This is a code-level baseline audit, not a conformance claim. It covers all
application views, shared layout and components, the five explicit themes plus
system theme behavior, keyboard-related JavaScript, existing system tests, and
prior desktop/mobile visual verification. Exact contrast ratios were calculated
from the authored theme colors.

The browser-assisted DOM scan could not be completed because the local browser
session was blocked by its URL security policy after an initial connection
failure. A future remediation pass must include an automated accessibility scan,
keyboard-only walkthrough, 200% zoom and 320 CSS-pixel reflow checks, and manual
VoiceOver testing before making a conformance statement.

## Blocking Findings

### A11Y-01: Form control boundaries do not meet non-text contrast

Severity: High  
Relevant criterion: 1.4.11 Non-text Contrast (AA)

Inputs use the panel color for their background, so their border is the visual
means of identifying the control on panels. Border-to-panel contrast is 1.35:1
in Light, 1.41:1 in Dark, 1.52:1 in Paper, and 2.58:1 in Amber. Terminal passes
at 4.06:1. Required component boundaries need 3:1 contrast against adjacent
colors.

Recommended remediation: add a dedicated control-border token that reaches 3:1
in every theme without making all decorative panel borders equally prominent.
Add automated contrast assertions for every supported theme.

### A11Y-02: Flash messages impose an unadjustable ten-second time limit

Severity: High  
Relevant criterion: 2.2.1 Timing Adjustable (A)

Every notice and alert is removed after ten seconds. A close button lets users
shorten the time, but there is no way to pause, extend, or disable it. Some
success notices have an equivalent persistent result in the page, but messages
such as authentication failures may not.

Recommended remediation: keep the requested countdown for messages whose result
is also available persistently, but make alerts and unique instructions
persistent. Alternatively provide a user preference to disable auto-dismissal
or a conforming pause/extension mechanism.

### A11Y-04: Removing an existing nested row can lose keyboard focus

Severity: High  
Relevant criterion: 2.4.3 Focus Order (A)

After confirmation, removing a contact or run hides or deletes the button that
held focus. No surviving element receives focus and no removal result is
announced. Adding a row also provides no announcement or deliberate focus move.

Recommended remediation: after removal, focus the next row's remove control,
the previous row, or the Add control; announce the result in an existing live
region. After addition, focus the first field in the new row and provide concise
screen-reader context.

### A11Y-05: Repeated table actions lack programmatic row context

Severity: High  
Relevant criteria: 1.3.1 Info and Relationships (A), 2.4.4 Link Purpose in
Context (A)

Bookings, patrons, and spaces tables repeat links named only “Edit”; spaces also
repeat “Delete.” The item-name cells are ordinary `td` elements rather than row
headers, and the action-column headers are empty, so assistive technology cannot
reliably derive which record each action affects.

Recommended remediation: make the record-name cell a `th scope="row"`, give
column headers explicit scope and accessible action text, and label controls as
“Edit [record]” or “Delete [record]” while preserving concise visible text.

## Additional Findings

### A11Y-03: Repeated navigation lacks a keyboard-friendly skip link

Severity: Medium  
Relevant criterion: 2.4.1 Bypass Blocks (A)

The semantic `main` landmark provides a bypass mechanism for assistive
technologies that support landmark navigation. A visible-on-focus skip link
would also let keyboard users bypass the brand, primary navigation, and account
controls without requiring an assistive-technology shortcut.

Recommended remediation: make the first focusable element a “Skip to main
content” link and give `main` a stable target.

### A11Y-06: Current booking filter state is visual only

Severity: Medium  
Relevant criteria: 1.3.1 Info and Relationships (A), 4.1.2 Name, Role, Value (A)

The selected booking filter is represented by the `active` class and color.
Expose it programmatically, for example with `aria-current="page"`.

### A11Y-07: Server validation errors are not associated with fields

Severity: Medium  
Relevant criteria: 1.3.1 Info and Relationships (A), 3.3.1 Error Identification
(A)

The alert summary identifies errors in text, but invalid inputs are not marked
with `aria-invalid`, error text is not connected with `aria-describedby`, and
focus is not directed to the summary or first invalid field after a failed save.

Recommended remediation: render field-level messages with stable IDs, associate
them with their controls, and add a tested focus strategy while retaining the
summary.

### A11Y-08: Data-table relationships should be made explicit

Severity: Medium  
Relevant criterion: 1.3.1 Info and Relationships (A)

Tables use `thead` and `th`, but do not declare column scopes, captions, or row
headers. Add `scope="col"`, useful captions or accessible names, and row headers
so relationships survive alternate presentation and assistive navigation.

## Verified Strengths

- Pages declare English, provide descriptive titles, and use a single `main`
  landmark with generally logical heading levels.
- Rails labels are programmatically associated with the form controls reviewed;
  native input types and required attributes are used where appropriate.
- The account disclosure and confirmation modal build on native `details` and
  `dialog`; Escape handling and focus-visible styles are present.
- Focus indicators have at least 5.11:1 contrast against their adjacent surface
  in every theme measured.
- Normal and muted text colors meet 4.5:1 in every theme measured. The lowest
  measured normal-text pair is Light muted text on the page background at
  4.70:1.
- Status pills include text and do not communicate state by color alone.
- Flash messages use `status` or `alert` roles and a labeled dismiss button.
- The prior narrow-width browser check found no page-level horizontal overflow;
  wide data tables are contained in dedicated horizontal scrollers.
