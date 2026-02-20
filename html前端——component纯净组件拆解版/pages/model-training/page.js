(async function () {
  const c_top_frame = await loadComponentTemplate('top-frame');

  const c_step_stage_nav = await loadComponentTemplate('step-stage-nav');

  const c_training_dialogue = await loadComponentTemplate('training-dialogue');

  const c_action_overlay = await loadComponentTemplate('action-overlay');

  const stepCards = {
    1: await loadComponentTemplate('step-1-identification-training'),
    2: await loadComponentTemplate('step-2-decision-training'),
    3: await loadComponentTemplate('step-3-equation-training'),
    4: await loadComponentTemplate('step-4-trap-analysis'),
    5: await loadComponentTemplate('step-5-complete-solve'),
    6: await loadComponentTemplate('step-6-variation-training'),
  };

  let currentStep = 2;

  function syncContentTop() {
    const stageNav = document.querySelector('.mt-stage-nav');
    const pageContent = document.getElementById('mt-page-content');
    if (!stageNav || !pageContent) return;
    pageContent.style.top = `${stageNav.offsetTop + stageNav.offsetHeight}px`;
  }

  function renderStepCard() {
    const mount = document.getElementById('mt-step-card-host');
    if (!mount) return;
    mount.innerHTML = stepCards[currentStep] || '';
  }

  function updateStepNavState() {
    for (let i = 1; i <= 6; i++) {
      const dot = document.getElementById(`mt-dot-${i}`);
      if (dot) {
        dot.classList.remove('completed', 'current', 'pending');
        if (i < currentStep) dot.classList.add('completed');
        else if (i === currentStep) dot.classList.add('current');
        else dot.classList.add('pending');
      }

      const label = document.getElementById(`mt-label-${i}`);
      if (label) {
        if (i === currentStep) {
          label.style.color = 'var(--accent)';
          label.style.fontWeight = '600';
        } else {
          label.style.color = 'var(--text-secondary)';
          label.style.fontWeight = '500';
        }
      }

      if (i <= 5) {
        const line = document.getElementById(`mt-line-${i}`);
        if (line) line.classList.toggle('completed', i < currentStep);
      }
    }
  }

  function switchModelTrainingStep(step) {
    const next = Number(step);
    if (!stepCards[next]) return;
    currentStep = next;
    renderStepCard();
    updateStepNavState();
  }

  window.switchModelTrainingStep = switchModelTrainingStep;

  const root = document.getElementById('page-root');
  if (!root) return;
  root.innerHTML = `<div class="phone-frame">` + c_top_frame + c_step_stage_nav + c_training_dialogue + c_action_overlay + `</div>`;

  syncContentTop();
  switchModelTrainingStep(currentStep);
  window.addEventListener('resize', syncContentTop);

})();

