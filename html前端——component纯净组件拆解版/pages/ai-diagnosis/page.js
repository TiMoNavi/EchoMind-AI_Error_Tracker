(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');
  const c_main_content = await loadComponentTemplate('main-content');
  const c_action_overlay = await loadComponentTemplate('action-overlay');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_main_content + c_action_overlay + `</div>`;

})();

