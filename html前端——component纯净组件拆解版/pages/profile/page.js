(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_user_info_card = await loadComponentTemplate('user-info-card');

  const c_target_score_card = await loadComponentTemplate('target-score-card');

  const c_three_row_navigation = await loadComponentTemplate('three-row-navigation');

  const c_two_row_navigation = await loadComponentTemplate('two-row-navigation');

  const c_learning_stats = await loadComponentTemplate('learning-stats');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_user_info_card + c_target_score_card + c_three_row_navigation + c_two_row_navigation + c_learning_stats + `</div>`;

  document.querySelector('.phone-frame').insertAdjacentHTML('beforeend', getTabBar('profile'));

})();

