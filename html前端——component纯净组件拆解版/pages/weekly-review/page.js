(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_weekly_dashboard = await loadComponentTemplate('weekly-dashboard');

  const c_score_change = await loadComponentTemplate('score-change');

  const c_weekly_progress = await loadComponentTemplate('weekly-progress');

  const c_next_week_focus = await loadComponentTemplate('next-week-focus');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_weekly_dashboard + c_score_change + c_weekly_progress + c_next_week_focus + `</div>`;

})();

