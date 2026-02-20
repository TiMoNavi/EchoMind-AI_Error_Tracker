(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_question_content = await loadComponentTemplate('question-content');

  const c_answer_result = await loadComponentTemplate('answer-result');

  const c_question_relations = await loadComponentTemplate('question-relations');

  const c_question_source = await loadComponentTemplate('question-source');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_question_content + c_answer_result + c_question_relations + c_question_source + `</div>`;

})();

