/* СДВИГ · icons.js v5 — inline SVG icons */
(function(){
  const I = {
    bolt:'<path d="M13 2L4.5 13.5H11l-1 8.5L19.5 10H13l0-8z" fill="currentColor"/>',
    gem:'<path d="M6 3h12l3 6-9 12L3 9l3-6zm.8 2L5 9h4L7.5 5H6.8zm5.2 0L10 9h4l-2-4zm4.5 0H16.5L18 9h2l-1.5-4zM5.3 11l4.4 6-1.4-6H5.3zm5.2 0l1.5 7 1.5-7h-3zm5 0l-1.4 6 4.4-6h-3z" fill="currentColor"/>',
    cards:'<rect x="3" y="5" width="13" height="16" rx="2.5" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M17 7l3 .8a2 2 0 011.4 2.4l-2.6 9.6" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
    map:'<path d="M9 4L3 6.5v13L9 17l6 2.5 6-2.5v-13L15 6.5 9 4zm0 0v13m6-10.5v13" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linejoin="round"/>',
    agent:'<circle cx="12" cy="8.5" r="3.8" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M4.5 20a7.5 7.5 0 0115 0" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
    bag:'<path d="M5 8h14l-1 12H6L5 8zm3 0a4 4 0 018 0" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linejoin="round"/>',
    lock:'<rect x="5" y="10.5" width="14" height="10" rx="2.5" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M8 10.5V8a4 4 0 018 0v2.5" stroke="currentColor" stroke-width="1.8" fill="none"/>',
    arrows:'<path d="M9 6l-4 6 4 6m6-12l4 6-4 6" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
    back:'<path d="M14 6l-6 6 6 6" stroke="currentColor" stroke-width="2.2" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
    star:'<path d="M12 3l2.6 5.6 6.1.8-4.5 4.2 1.2 6L12 16.9 6.6 19.6l1.2-6L3.3 9.4l6.1-.8L12 3z" fill="currentColor"/>',
    // ── премиум-инструменты ──
    magnify:'<circle cx="10.5" cy="10.5" r="6" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="M15 15l5 5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/><circle cx="10.5" cy="10.5" r="3" fill="currentColor" opacity=".25"/>',
    lamp:'<path d="M9 18h6M10 21h4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M12 3a6 6 0 00-3.5 10.9c.3.2.5.6.5 1V16h6v-1.1c0-.4.2-.8.5-1A6 6 0 0012 3z" fill="currentColor" opacity=".22" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>',
    file:'<path d="M6 3h8l4 4v14a0 0 0 01 0 0H6a1 1 0 01-1-1V4a1 1 0 011-1z" fill="currentColor" opacity=".18" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M14 3v4h4M8.5 12h7M8.5 15.5h7M8.5 9h3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>',
    hourglass:'<path d="M7 3h10M7 21h10M8 3c0 4 8 5 8 9s-8 5-8 9M16 3c0 4-8 5-8 9s8 5 8 9" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M9.5 18.5h5L12 15z" fill="currentColor"/>',
    plus:'<path d="M12 6v12M6 12h12" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>'
  };
  function paint(){
    document.querySelectorAll('[data-ico]').forEach(el=>{
      const k=el.getAttribute('data-ico'); if(!I[k]||el.dataset.painted)return;
      el.innerHTML='<svg viewBox="0 0 24 24" width="22" height="22">'+I[k]+'</svg>';
      el.dataset.painted='1';
    });
    document.querySelectorAll('[data-tico]').forEach(el=>{
      const k=el.getAttribute('data-tico'); if(!I[k]||el.dataset.painted)return;
      el.innerHTML='<svg viewBox="0 0 24 24" width="26" height="26">'+I[k]+'</svg>';
      el.dataset.painted='1';
    });
  }
  window.Icons={ get:k=>'<svg viewBox="0 0 24 24" width="22" height="22">'+(I[k]||'')+'</svg>', paint };
  document.addEventListener('DOMContentLoaded',paint);
})();

