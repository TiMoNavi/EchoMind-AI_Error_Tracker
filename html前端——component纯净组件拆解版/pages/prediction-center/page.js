(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_score_card = await loadComponentTemplate('score-card');

  const c_trend_card = await loadComponentTemplate('trend-card');

  const c_score_path_table = await loadComponentTemplate('score-path-table');

  const c_priority_model_list = await loadComponentTemplate('priority-model-list');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_score_card + c_trend_card + c_score_path_table + c_priority_model_list + `</div>`;

  setTimeout(() => drawTrendLine('trend-chart', [55, 57, 59, 61, 60, 63], '#007AFF'), 200);

})();

