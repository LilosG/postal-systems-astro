/**
 * Force hard navigation for the Services header link, even if other JS calls preventDefault().
 */
document.addEventListener(
  'click',
  function (e) {
    const a = e.target && e.target.closest && e.target.closest('a[href="/services"]');
    if (!a) return;
    // Ensure we always navigate to the page route, not a hash scroll.
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
    window.location.href = '/services';
  },
  { capture: true }
);
