(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_exam_heatmap = await loadComponentTemplate('exam-heatmap');

  const c_question_type_browser = await loadComponentTemplate('question-type-browser');

  const c_recent_exams = await loadComponentTemplate('recent-exams');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_exam_heatmap + c_question_type_browser + c_recent_exams + `</div>`;

  document.querySelector('.phone-frame').insertAdjacentHTML('beforeend', getTabBar('global'));

})();

