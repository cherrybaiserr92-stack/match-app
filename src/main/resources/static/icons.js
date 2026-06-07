/* ═══════════════════════════════════════════
   СДВИГ · Icon Library
   24×24, 1.75px stroke, rounded caps
═══════════════════════════════════════════ */

const ICONS = {

    // ── Navigation ──────────────────────────
    folder: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>
  <line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="16" x2="12" y2="16"/>
</svg>`,

    gamepad: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <rect x="2" y="7" width="20" height="11" rx="5.5"/>
  <path d="M14.5 12h3M16 10.5v3"/>
  <circle cx="7.5" cy="12" r=".8" fill="currentColor" stroke="none"/>
  <circle cx="10" cy="12" r=".8" fill="currentColor" stroke="none"/>
</svg>`,

    badge: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2L3.5 6.5v5.5C3.5 17.4 7.2 22 12 22s8.5-4.6 8.5-10V6.5z"/>
  <circle cx="12" cy="11" r="2.5"/>
  <path d="M9 17c.5-1.7 1.8-2.5 3-2.5s2.5 1 3 2.5"/>
</svg>`,

    bag: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
  <line x1="3" y1="6" x2="21" y2="6"/>
  <path d="M16 10a4 4 0 0 1-8 0"/>
</svg>`,

    // ── Stats ────────────────────────────────
    bolt: `<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M13 2L4.5 13H10L9.5 22L19.5 11H14L13 2Z" stroke="none"/>
</svg>`,

    diamond: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 3h12l4 6-10 12L2 9z"/>
  <path d="M2 9h20M10.5 3l1.5 6 1.5-6M14 15l-2-6-2 6"/>
</svg>`,

    shield: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
  <path d="M9 12l2 2 4-4" stroke-width="1.75"/>
</svg>`,

    // ── Actions ──────────────────────────────
    checkCircle: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <path d="M8 12l3 3 5-5"/>
</svg>`,

    xCircle: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <path d="M9 9l6 6M15 9l-6 6"/>
</svg>`,

    arrowLeft: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 12H5M12 5l-7 7 7 7"/>
</svg>`,

    // ── Hint system ──────────────────────────
    lightbulb: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M9 21h6M12 3a6 6 0 0 1 6 6c0 2.3-1.2 4.3-3 5.4V17H9v-2.6C7.2 13.3 6 11.3 6 9a6 6 0 0 1 6-6z"/>
  <line x1="10" y1="20" x2="14" y2="20"/>
</svg>`,

    lock: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <rect x="5" y="11" width="14" height="10" rx="2"/>
  <path d="M8 11V7a4 4 0 0 1 8 0v4"/>
  <circle cx="12" cy="16" r="1.5" fill="currentColor" stroke="none"/>
</svg>`,

    lockOpen: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <rect x="5" y="11" width="14" height="10" rx="2"/>
  <path d="M8 11V7a4 4 0 0 1 7.4-1.4"/>
  <circle cx="12" cy="16" r="1.5" fill="currentColor" stroke="none"/>
</svg>`,

    // ── Misc ─────────────────────────────────
    star: `<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M12 2l3.1 6.3L22 9.3l-5 4.9 1.2 6.9-6.2-3.3-6.2 3.3L7 14.2 2 9.3l6.9-1z" stroke="none"/>
</svg>`,

    gift: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="20 12 20 22 4 22 4 12"/>
  <rect x="2" y="7" width="20" height="5"/>
  <line x1="12" y1="22" x2="12" y2="7"/>
  <path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/>
  <path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/>
</svg>`,

    coffee: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M18 8h1a4 4 0 0 1 0 8h-1"/>
  <path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/>
  <line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/>
</svg>`,

    x: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
  <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
</svg>`,

    check: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="20 6 9 17 4 12"/>
</svg>`,

    user: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
  <circle cx="12" cy="7" r="4"/>
</svg>`,

    search: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="11" cy="11" r="8"/>
  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
</svg>`,

    chevronRight: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="9 18 15 12 9 6"/>
</svg>`,
};

// Helper: inject SVG into element
function setIcon(el, name, cls) {
    if (!el || !ICONS[name]) return;
    el.innerHTML = ICONS[name];
    if (cls) el.querySelector('svg')?.classList.add(cls);
}

// Helper: SVG string with optional class
function icon(name, cls) {
    if (!ICONS[name]) return '';
    const tmp = document.createElement('div');
    tmp.innerHTML = ICONS[name];
    const svg = tmp.querySelector('svg');
    if (svg && cls) svg.classList.add(cls);
    return tmp.innerHTML;
}

