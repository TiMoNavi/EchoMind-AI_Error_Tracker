(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');
  const c_top_dashboard = await loadComponentTemplate('top-dashboard');
  const c_recommendation_list = await loadComponentTemplate('recommendation-list');
  const c_recent_upload = await loadComponentTemplate('recent-upload');
  const c_action_overlay = await loadComponentTemplate('action-overlay');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame" data-tabs="home">` + c_top_frame + c_top_dashboard + c_recommendation_list + c_recent_upload + c_action_overlay + `</div>`;

// Inject tab bar
  document.querySelector('.phone-frame').insertAdjacentHTML('beforeend', getTabBar('home'));
  // Mini trend
  setTimeout(() => drawTrendLine('mini-trend', [55,57,59,61,60,63], '#007AFF'), 200);

})();

