(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_single_question_dashboard = await loadComponentTemplate('single-question-dashboard');

  const c_exam_analysis = await loadComponentTemplate('exam-analysis');

  const c_question_history_list = await loadComponentTemplate('question-history-list');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_single_question_dashboard + c_exam_analysis + c_question_history_list + `</div>`;

})();

