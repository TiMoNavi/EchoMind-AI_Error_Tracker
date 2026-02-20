(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_knowledge_tree = await loadComponentTemplate('knowledge-tree');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_knowledge_tree + `</div>`;

  document.querySelector('.phone-frame').insertAdjacentHTML('beforeend', getTabBar('global'));

})();

