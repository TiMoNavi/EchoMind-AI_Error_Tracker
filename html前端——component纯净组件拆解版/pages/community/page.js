(async function () {
  const c_top_frame_and_tabs = await loadComponentTemplate('top-frame-and-tabs');
  const c_board_my_requests = await loadComponentTemplate('board-my-requests');
  const c_board_feature_boost = await loadComponentTemplate('board-feature-boost');
  const c_board_feedback = await loadComponentTemplate('board-feedback');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame_and_tabs + c_board_my_requests + c_board_feature_boost + c_board_feedback + `</div>`;

document.querySelector('.phone-frame').insertAdjacentHTML('beforeend', getTabBar('community'));

  // Expose for inline onclick handlers in tab buttons.
  window.switchCommTab = function (idx) {
    for (let i = 0; i < 3; i++) {
      document.getElementById('comm-tab-' + i).style.display = i === idx ? 'block' : 'none';
      document.getElementById('st' + (i + 1)).classList.toggle('active', i === idx);
    }
  };

})();

