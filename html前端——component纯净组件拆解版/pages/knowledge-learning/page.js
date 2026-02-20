(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_step_stage_nav = await loadComponentTemplate('step-stage-nav');

  const c_learning_dialogue = await loadComponentTemplate('learning-dialogue');

  const c_action_overlay = await loadComponentTemplate('action-overlay');

  const stepCards = {
    1: await loadComponentTemplate('step-1-concept-present'),
    2: await loadComponentTemplate('step-2-understanding-check'),
    3: await loadComponentTemplate('step-3-discrimination-training'),
    4: await loadComponentTemplate('step-4-practical-application'),
    5: await loadComponentTemplate('step-5-concept-test'),
  };

  let currentStep = 3;

  function syncContentTop() {
    const stageNav = document.querySelector('.kl-stage-nav');
    const pageContent = document.getElementById('kl-page-content');
    if (!stageNav || !pageContent) return;
    pageContent.style.top = `${stageNav.offsetTop + stageNav.offsetHeight}px`;
  }

  function renderStepCard() {
    const mount = document.getElementById('kl-step-card-host');
    if (!mount) return;
    mount.innerHTML = stepCards[currentStep] || '';
  }

  function updateStepNavState() {
    for (let i = 1; i <= 5; i++) {
      const dot = document.getElementById(`kl-dot-${i}`);
      if (dot) {
        dot.classList.remove('completed', 'current', 'pending');
        if (i < currentStep) dot.classList.add('completed');
        else if (i === currentStep) dot.classList.add('current');
        else dot.classList.add('pending');
      }

      const label = document.getElementById(`kl-label-${i}`);
      if (label) {
        if (i === currentStep) {
          label.style.color = 'var(--accent)';
          label.style.fontWeight = '600';
        } else {
          label.style.color = 'var(--text-secondary)';
          label.style.fontWeight = '500';
        }
      }

      if (i <= 4) {
        const line = document.getElementById(`kl-line-${i}`);
        if (line) {
          line.classList.toggle('completed', i < currentStep);
        }
      }
    }
  }

  function switchKnowledgeLearningStep(step) {
    const next = Number(step);
    if (!stepCards[next]) return;
    currentStep = next;
    renderStepCard();
    updateStepNavState();
  }

  window.switchKnowledgeLearningStep = switchKnowledgeLearningStep;

  const root = document.getElementById('page-root');
  if (!root) return;

  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_step_stage_nav + c_learning_dialogue + c_action_overlay + `</div>`;

  syncContentTop();
  switchKnowledgeLearningStep(currentStep);
  window.addEventListener('resize', syncContentTop);

})();

