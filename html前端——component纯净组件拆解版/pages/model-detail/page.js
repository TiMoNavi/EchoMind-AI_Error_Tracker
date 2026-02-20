(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_mastery_dashboard = await loadComponentTemplate('mastery-dashboard');

  const c_prerequisite_knowledge_list = await loadComponentTemplate('prerequisite-knowledge-list');

  const c_related_question_list = await loadComponentTemplate('related-question-list');

  const c_training_record_list = await loadComponentTemplate('training-record-list');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_mastery_dashboard + c_prerequisite_knowledge_list + c_related_question_list + c_training_record_list + `</div>`;

})();

