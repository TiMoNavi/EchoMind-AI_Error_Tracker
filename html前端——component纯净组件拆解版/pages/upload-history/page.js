(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_history_filter = await loadComponentTemplate('history-filter');

  const c_history_timeline = await loadComponentTemplate('history-timeline');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_history_filter + c_history_timeline + `</div>`;

})();

