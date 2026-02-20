(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_flashcard = await loadComponentTemplate('flashcard');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_flashcard + `</div>`;

})();

