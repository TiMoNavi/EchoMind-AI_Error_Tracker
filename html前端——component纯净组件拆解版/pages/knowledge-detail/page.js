(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_mastery_dashboard = await loadComponentTemplate('mastery-dashboard');

  const c_concept_test_records = await loadComponentTemplate('concept-test-records');

  const c_related_models = await loadComponentTemplate('related-models');

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_mastery_dashboard + c_concept_test_records + c_related_models + `</div>`;

})();

