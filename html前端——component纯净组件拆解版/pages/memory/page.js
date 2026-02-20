(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_review_dashboard = await loadComponentTemplate('review-dashboard');

  const c_card_category_list = await loadComponentTemplate('card-category-list');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_review_dashboard + c_card_category_list + `</div>`;

  document.querySelector('.phone-frame').insertAdjacentHTML('beforeend', getTabBar('memory'));

})();

