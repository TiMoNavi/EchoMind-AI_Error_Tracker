import asyncio
import math
import os
import re
import shutil
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from playwright.async_api import async_playwright

ROOT = Path(r"d:\AI\AI+high school homework\EchoMind-AI_Error_Tracker\html前端——component纯净组件拆解版")
PAGES_DIR = ROOT / "pages"
OUT_DIR = ROOT / "page-annotations"
BASE_URL = "http://localhost:5500"
VIEWPORT = {"width": 1200, "height": 980}

MODULE_ORDER = {
    "index": ["top-frame", "top-dashboard", "recommendation-list", "recent-upload", "action-overlay"],
    "community": ["top-frame-and-tabs", "board-my-requests", "board-feature-boost", "board-feedback"],
    "flashcard-review": ["top-frame", "flashcard"],
    "global-exam": ["top-frame", "exam-heatmap", "question-type-browser", "recent-exams"],
    "global-knowledge": ["top-frame", "knowledge-tree"],
    "global-model": ["top-frame", "model-tree"],
    "knowledge-detail": ["top-frame", "mastery-dashboard", "concept-test-records", "related-models"],
    "memory": ["top-frame", "review-dashboard", "card-category-list"],
    "model-detail": ["top-frame", "mastery-dashboard", "prerequisite-knowledge-list", "related-question-list", "training-record-list"],
    "model-training": [
        "top-frame",
        "step-stage-nav",
        "step-1-identification-training",
        "step-2-decision-training",
        "step-3-equation-training",
        "step-4-trap-analysis",
        "step-5-complete-solve",
        "step-6-variation-training",
        "training-dialogue",
        "action-overlay",
    ],
    "prediction-center": ["top-frame", "score-card", "trend-card", "score-path-table", "priority-model-list"],
    "profile": ["top-frame", "user-info-card", "target-score-card", "three-row-navigation", "two-row-navigation", "learning-stats"],
    "question-aggregate": ["top-frame", "single-question-dashboard", "exam-analysis", "question-history-list"],
    "question-detail": ["top-frame", "question-content", "answer-result", "question-relations", "question-source"],
    "upload-history": ["top-frame", "history-panel", "history-filter", "history-date-scroll", "history-record-list"],
    "weekly-review": ["top-frame", "weekly-dashboard", "score-change", "weekly-progress", "next-week-focus"],
    "knowledge-learning": [
        "top-frame",
        "step-stage-nav",
        "step-1-concept-present",
        "step-2-understanding-check",
        "step-3-discrimination-training",
        "step-4-practical-application",
        "step-5-concept-test",
        "action-overlay",
    ],
}


def sanitize(name: str) -> str:
    return re.sub(r"[^a-zA-Z0-9_-]+", "-", name).strip("-")


def clamp_rect(rect, w, h):
    x, y, rw, rh = rect
    vals = [x, y, rw, rh]
    if any(v is None or not math.isfinite(float(v)) for v in vals):
        return 0, 0, min(w, 1), min(h, 1)
    x1 = max(0, int(round(x)))
    y1 = max(0, int(round(y)))
    x2 = min(w, int(round(x + rw)))
    y2 = min(h, int(round(y + rh)))
    if x2 <= x1:
        x2 = min(w, x1 + 1)
    if y2 <= y1:
        y2 = min(h, y1 + 1)
    return x1, y1, x2, y2


async def compute_boxes(page, slug: str, modules):
    js = r'''
({ slug, modules }) => {
  const q = (s) => document.querySelector(s);
  const rectObj = (el) => {
    if (!el) return null;
    const r = el.getBoundingClientRect();
    if (!r || r.width <= 0 || r.height <= 0) return null;
    return {x: r.left, y: r.top, w: r.width, h: r.height};
  };
  const phone = rectObj(q('.phone-frame')) || {x: 0, y: 0, w: window.innerWidth, h: window.innerHeight};
  const pageContent = q('.page-content');
  const pageContentRect = rectObj(pageContent);

  const add = [];
  const addBox = (name, r, note='') => {
    if (!r) return;
    add.push({name, rect: [r.x, r.y, r.w, r.h], note});
  };

  const addTopFrame = (name = 'top-frame', top = null) => {
    if (!modules.includes(name)) return;
    const targetTop = top ?? (pageContentRect ? pageContentRect.y : phone.y + phone.h * 0.22);
    addBox(name, {x: phone.x, y: phone.y, w: phone.w, h: Math.max(1, targetTop - phone.y)});
  };

  const addActionOverlay = (name = 'action-overlay') => {
    if (!modules.includes(name)) return;
    const sels = ['.chat-input-bar', '.fab', '.bottom-sheet', '.modal-overlay.show'];
    const rects = sels.map(s => rectObj(q(s))).filter(Boolean);
    if (rects.length > 0) {
      const minX = Math.min(...rects.map(r => r.x));
      const minY = Math.min(...rects.map(r => r.y));
      const maxR = Math.max(...rects.map(r => r.x + r.w));
      const maxB = Math.max(...rects.map(r => r.y + r.h));
      addBox(name, {x: minX, y: minY, w: maxR - minX, h: maxB - minY});
    } else if (pageContentRect) {
      addBox(name, {x: phone.x, y: pageContentRect.y + pageContentRect.h - 88, w: phone.w, h: 88}, '未检测到显式浮层，按底部操作区估算');
    }
  };

  const headers = () => Array.from(document.querySelectorAll('.section-header'));
  const headerByText = (text) => headers().find(h => (h.textContent || '').includes(text));
  const listGroups = () => Array.from(document.querySelectorAll('.list-group'));
  const cards = () => Array.from(document.querySelectorAll('.card'));

  if (slug === 'index') {
    const recHeader = q('.section-header');
    const allCards = Array.from(document.querySelectorAll('.card'));
    const recentCard = allCards.find(c => c.textContent && c.textContent.includes('最近上传'));
    const scroll = q('.scroll-content');
    const fab = q('.fab');

    if (pageContentRect) {
      addBox('top-frame', {x: phone.x, y: phone.y, w: phone.w, h: Math.max(1, pageContentRect.y - phone.y)});
      if (recHeader) {
        const rr = recHeader.getBoundingClientRect();
        addBox('top-dashboard', {x: phone.x, y: pageContentRect.y, w: phone.w, h: Math.max(1, rr.top - pageContentRect.y)});
        if (recentCard) {
          const rc = recentCard.getBoundingClientRect();
          addBox('recommendation-list', {x: phone.x, y: rr.top, w: phone.w, h: Math.max(1, rc.top - rr.top)});
          const sc = scroll ? scroll.getBoundingClientRect() : pageContentRect;
          addBox('recent-upload', {x: phone.x, y: rc.top, w: phone.w, h: Math.max(1, sc.bottom - rc.top)});
        }
      }
    }
    const fr = rectObj(fab);
    if (fr) addBox('action-overlay', fr);
  } else if (slug === 'community') {
    if (pageContentRect) {
      addBox('top-frame-and-tabs', {x: phone.x, y: phone.y, w: phone.w, h: Math.max(1, pageContentRect.y - phone.y)});
    }
    const tab0 = rectObj(q('#comm-tab-0'));
    if (tab0) {
      addBox('board-my-requests', tab0);
      addBox('board-feature-boost', tab0, '切换“新功能加速”后显示在同一区域');
      addBox('board-feedback', tab0, '切换“改版建议”后显示在同一区域');
    }
  } else if (slug === 'flashcard-review') {
    addTopFrame('top-frame');
    const flashcard = rectObj(q('.flashcard'));
    if (flashcard) addBox('flashcard', flashcard);
  } else if (slug === 'global-exam') {
    addTopFrame('top-frame');
    const headers = Array.from(document.querySelectorAll('.section-header'));
    const cards = Array.from(document.querySelectorAll('.card'));
    const lists = Array.from(document.querySelectorAll('.list-group'));

    if (headers[0]) {
      const h = headers[0].getBoundingClientRect();
      const c = cards[0] ? cards[0].getBoundingClientRect() : h;
      addBox('exam-heatmap', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, c.bottom - h.top)}, '热力图按题号分值与掌握状态参数动态渲染');
    }
    if (headers[1]) {
      const h = headers[1].getBoundingClientRect();
      const l = lists[0] ? lists[0].getBoundingClientRect() : h;
      addBox('question-type-browser', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, l.bottom - h.top)});
    }
    if (headers[2]) {
      const h = headers[2].getBoundingClientRect();
      const l = lists[1] ? lists[1].getBoundingClientRect() : h;
      addBox('recent-exams', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, l.bottom - h.top)});
    }
  } else if (slug === 'global-knowledge') {
    addTopFrame('top-frame');
    const filterRect = rectObj(q('.filter-bar'));
    const trees = Array.from(document.querySelectorAll('.tree-l1')).map(rectObj).filter(Boolean);
    if (trees.length > 0) {
      const top = filterRect ? Math.min(filterRect.y, trees[0].y) : trees[0].y;
      const bottom = Math.max(...trees.map(t => t.y + t.h));
      addBox('knowledge-tree', {x: phone.x, y: top, w: phone.w, h: Math.max(1, bottom - top)}, '可折叠展开的多层知识点树组件');
    }
  } else if (slug === 'global-model') {
    addTopFrame('top-frame');
    const filterRect = rectObj(q('.filter-bar'));
    const trees = Array.from(document.querySelectorAll('.tree-l1')).map(rectObj).filter(Boolean);
    if (trees.length > 0) {
      const top = filterRect ? Math.min(filterRect.y, trees[0].y) : trees[0].y;
      const bottom = Math.max(...trees.map(t => t.y + t.h));
      addBox('model-tree', {x: phone.x, y: top, w: phone.w, h: Math.max(1, bottom - top)}, '可折叠展开的多层模型树组件');
    }
  } else if (slug === 'knowledge-detail') {
    addTopFrame('top-frame');
    const firstCard = rectObj(q('.card'));
    const sectionHeaders = headers();
    const lists = listGroups();

    if (firstCard) {
      const dashBottom = sectionHeaders[0] ? sectionHeaders[0].getBoundingClientRect().top : firstCard.y + firstCard.h;
      addBox('mastery-dashboard', {x: phone.x, y: firstCard.y, w: phone.w, h: Math.max(1, dashBottom - firstCard.y)});
    }
    if (sectionHeaders[0]) {
      const h = sectionHeaders[0].getBoundingClientRect();
      const l = lists[0] ? lists[0].getBoundingClientRect() : h;
      addBox('concept-test-records', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, l.bottom - h.top)});
    }
    if (sectionHeaders[1]) {
      const h = sectionHeaders[1].getBoundingClientRect();
      const l = lists[1] ? lists[1].getBoundingClientRect() : h;
      addBox('related-models', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, l.bottom - h.top)});
    }
  } else if (slug === 'memory') {
    addTopFrame('top-frame');
    const section = headerByText('卡片分类');
    const firstCard = cards()[0] ? cards()[0].getBoundingClientRect() : null;
    const firstList = listGroups()[0] ? listGroups()[0].getBoundingClientRect() : null;

    if (firstCard) {
      const bottom = section ? section.getBoundingClientRect().top : firstCard.bottom;
      addBox('review-dashboard', {x: phone.x, y: firstCard.top, w: phone.w, h: Math.max(1, bottom - firstCard.top)});
    }
    if (section && firstList) {
      const h = section.getBoundingClientRect();
      const lists = listGroups().map(g => g.getBoundingClientRect());
      const last = lists[lists.length - 1];
      addBox('card-category-list', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, last.bottom - h.top)});
    }
  } else if (slug === 'model-detail') {
    addTopFrame('top-frame');
    const sectionHeaders = headers();
    const lists = listGroups();
    const allCards = cards();

    if (allCards[0]) {
      const c = allCards[0].getBoundingClientRect();
      const b = sectionHeaders[0] ? sectionHeaders[0].getBoundingClientRect().top : c.bottom;
      addBox('mastery-dashboard', {x: phone.x, y: c.top, w: phone.w, h: Math.max(1, b - c.top)});
    }
    if (sectionHeaders[0]) {
      const h = sectionHeaders[0].getBoundingClientRect();
      const b = sectionHeaders[1] ? sectionHeaders[1].getBoundingClientRect().top : (lists[0] ? lists[0].getBoundingClientRect().bottom : h.bottom);
      addBox('prerequisite-knowledge-list', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, b - h.top)});
    }
    if (sectionHeaders[1]) {
      const h = sectionHeaders[1].getBoundingClientRect();
      const b = sectionHeaders[2] ? sectionHeaders[2].getBoundingClientRect().top : (lists[1] ? lists[1].getBoundingClientRect().bottom : h.bottom);
      addBox('related-question-list', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, b - h.top)});
    }
    if (sectionHeaders[2]) {
      const h = sectionHeaders[2].getBoundingClientRect();
      const l = lists[2] ? lists[2].getBoundingClientRect() : h;
      addBox('training-record-list', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, l.bottom - h.top)});
    }
  } else if (slug === 'model-training') {
    const stageNav = rectObj(q('.mt-stage-nav'));
    addTopFrame('top-frame', stageNav ? stageNav.y : null);
    if (stageNav) addBox('step-stage-nav', stageNav);

    const stepHost = rectObj(q('#mt-step-card-host')) || rectObj(q('.card')) || pageContentRect;
    if (stepHost) {
      addBox('step-1-identification-training', stepHost, '点击顶部阶段 1 显示');
      addBox('step-2-decision-training', stepHost, '当前默认显示阶段 2');
      addBox('step-3-equation-training', stepHost, '点击顶部阶段 3 显示');
      addBox('step-4-trap-analysis', stepHost, '点击顶部阶段 4 显示');
      addBox('step-5-complete-solve', stepHost, '点击顶部阶段 5 显示');
      addBox('step-6-variation-training', stepHost, '点击顶部阶段 6 显示');
    }

    const chat = rectObj(q('.chat-container'));
    const quick = rectObj(q('.chat-container + div'));
    const summary = rectObj(q('.card.card-sm'));
    const parts = [chat, quick, summary].filter(Boolean);
    if (parts.length > 0) {
      const minX = Math.min(...parts.map(r => r.x));
      const minY = Math.min(...parts.map(r => r.y));
      const maxR = Math.max(...parts.map(r => r.x + r.w));
      const maxB = Math.max(...parts.map(r => r.y + r.h));
      addBox('training-dialogue', {x: minX, y: minY, w: maxR - minX, h: maxB - minY}, '步骤切换时该对话区保持不变');
    }
    addActionOverlay('action-overlay');
  } else if (slug === 'prediction-center') {
    addTopFrame('top-frame');
    const allCards = cards().map(c => c.getBoundingClientRect());
    const allLists = listGroups().map(l => l.getBoundingClientRect());
    const hPath = headerByText('提分路径');
    const hPriority = headerByText('优先训练模型');

    if (allCards[0]) addBox('score-card', allCards[0]);
    if (allCards[1]) addBox('trend-card', allCards[1], '折线图由趋势数据动态绘制');
    if (hPath) {
      const h = hPath.getBoundingClientRect();
      const bottom = allCards[2] ? allCards[2].bottom : (hPriority ? hPriority.getBoundingClientRect().top : h.bottom);
      addBox('score-path-table', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, bottom - h.top)});
    }
    if (hPriority) {
      const h = hPriority.getBoundingClientRect();
      const l = allLists[0] || h;
      addBox('priority-model-list', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, l.bottom - h.top)});
    }
  } else if (slug === 'profile') {
    addTopFrame('top-frame');
    const allCards = cards().map(c => c.getBoundingClientRect());
    const allLists = listGroups().map(l => l.getBoundingClientRect());
    if (allCards[0]) addBox('user-info-card', allCards[0]);
    if (allCards[1]) addBox('target-score-card', allCards[1]);
    if (allLists[0]) addBox('three-row-navigation', allLists[0]);
    if (allLists[1]) addBox('two-row-navigation', allLists[1]);
    if (allCards[2]) addBox('learning-stats', allCards[2]);
  } else if (slug === 'question-aggregate') {
    addTopFrame('top-frame');
    const allCards = cards().map(c => c.getBoundingClientRect());
    const hList = headerByText('做过的题目');
    const firstList = listGroups()[0] ? listGroups()[0].getBoundingClientRect() : null;
    if (allCards[0]) addBox('single-question-dashboard', allCards[0]);
    if (allCards[1]) addBox('exam-analysis', allCards[1]);
    if (hList && firstList) {
      const h = hList.getBoundingClientRect();
      addBox('question-history-list', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, firstList.bottom - h.top)});
    }
  } else if (slug === 'question-detail') {
    addTopFrame('top-frame');
    const allCards = cards().map(c => c.getBoundingClientRect());
    if (allCards[0]) addBox('question-content', allCards[0]);
    if (allCards[1]) {
      const bottom = allCards[2] ? allCards[2].top : allCards[1].bottom;
      addBox('answer-result', {x: phone.x, y: allCards[1].top, w: phone.w, h: Math.max(1, bottom - allCards[1].top)});
    }
    if (allCards[2]) addBox('question-relations', allCards[2]);
    if (allCards[3]) addBox('question-source', allCards[3]);
  } else if (slug === 'upload-history') {
    addTopFrame('top-frame');
    if (pageContentRect) addBox('history-panel', pageContentRect);
    const filter = rectObj(q('.filter-bar'));
    if (filter) addBox('history-filter', filter);

    const dateHeaders = Array.from(document.querySelectorAll('.scroll-content > div'))
      .filter(el => /今天|^\d+月\d+日$/.test((el.textContent || '').trim()))
      .map(rectObj)
      .filter(Boolean);
    if (dateHeaders.length > 0) {
      const top = Math.min(...dateHeaders.map(r => r.y));
      const bottom = Math.max(...dateHeaders.map(r => r.y + r.h));
      addBox('history-date-scroll', {x: phone.x, y: top, w: phone.w, h: Math.max(1, bottom - top)}, '按日期分组滚动排序');
    }

    const allLists = listGroups().map(l => l.getBoundingClientRect());
    if (allLists.length > 0) {
      const top = Math.min(...allLists.map(r => r.top));
      const bottom = Math.max(...allLists.map(r => r.bottom));
      addBox('history-record-list', {x: phone.x, y: top, w: phone.w, h: Math.max(1, bottom - top)}, '支持下拉刷新历史列表');
    }
  } else if (slug === 'weekly-review') {
    addTopFrame('top-frame');
    const allCards = cards().map(c => c.getBoundingClientRect());
    const sectionHeaders = headers();
    const allLists = listGroups().map(l => l.getBoundingClientRect());
    if (allCards[0]) addBox('weekly-dashboard', allCards[0]);
    if (allCards[1]) addBox('score-change', allCards[1]);
    if (sectionHeaders[0] && allLists[0]) {
      const h = sectionHeaders[0].getBoundingClientRect();
      addBox('weekly-progress', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, allLists[0].bottom - h.top)});
    }
    if (sectionHeaders[1]) {
      const h = sectionHeaders[1].getBoundingClientRect();
      const c = allCards[2] || h;
      addBox('next-week-focus', {x: phone.x, y: h.top, w: phone.w, h: Math.max(1, c.bottom - h.top)});
    }
  } else if (slug === 'knowledge-learning') {
    const stageNav = rectObj(q('.kl-stage-nav'));
    addTopFrame('top-frame', stageNav ? stageNav.y : null);
    if (stageNav) addBox('step-stage-nav', stageNav);

    const stepHost = rectObj(q('#kl-step-card-host')) || rectObj(q('.kl-step-panel')) || pageContentRect;
    if (stepHost) {
      addBox('step-1-concept-present', stepHost, '点击顶部阶段 1 显示');
      addBox('step-2-understanding-check', stepHost, '点击顶部阶段 2 显示');
      addBox('step-3-discrimination-training', stepHost, '当前默认显示阶段 3');
      addBox('step-4-practical-application', stepHost, '点击顶部阶段 4 显示');
      addBox('step-5-concept-test', stepHost, '点击顶部阶段 5 显示');
    }
    addActionOverlay('action-overlay');
  } else {
    addTopFrame('top-frame');
    if (modules.includes('main-content') && pageContentRect) {
      addBox('main-content', pageContentRect);
    }
    addActionOverlay('action-overlay');
  }

  // Keep module order if possible
  const ordered = [];
  const map = new Map(add.map(x => [x.name, x]));
  for (const m of modules) {
    if (map.has(m)) ordered.push(map.get(m));
  }
  for (const x of add) {
    if (!ordered.find(o => o.name === x.name)) ordered.push(x);
  }

  return {
    viewport: {w: window.innerWidth, h: window.innerHeight},
    boxes: ordered
  };
}
'''
    return await page.evaluate(js, {"slug": slug, "modules": modules})


def annotate_image(raw_path: Path, annotated_path: Path, crops_dir: Path, boxes):
    img = Image.open(raw_path).convert("RGBA")
    W, H = img.size

    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    base = ImageDraw.Draw(img)

    colors = [
        (255, 59, 48, 80),
        (52, 199, 89, 80),
        (0, 122, 255, 80),
        (255, 149, 0, 80),
        (175, 82, 222, 80),
        (90, 200, 250, 80),
    ]
    line_colors = [
        (255, 59, 48, 255),
        (52, 199, 89, 255),
        (0, 122, 255, 255),
        (255, 149, 0, 255),
        (175, 82, 222, 255),
        (90, 200, 250, 255),
    ]

    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except Exception:
        font = ImageFont.load_default()

    crops_dir.mkdir(parents=True, exist_ok=True)

    for i, b in enumerate(boxes, start=1):
        name = b["name"]
        rect = b["rect"]
        x1, y1, x2, y2 = clamp_rect(rect, W, H)
        if x2 < x1:
            x1, x2 = x2, x1
        if y2 < y1:
            y1, y2 = y2, y1
        if x2 == x1:
            x2 = min(W, x1 + 1)
        if y2 == y1:
            y2 = min(H, y1 + 1)

        fc = colors[(i - 1) % len(colors)]
        lc = line_colors[(i - 1) % len(line_colors)]

        draw.rectangle([x1, y1, x2, y2], fill=fc, outline=lc, width=4)

        label = f"{i}. {name}"
        tw = int(base.textlength(label, font=font)) + 14
        th = 24
        lx = x1 + 4
        ly = max(4, y1 - th - 4)
        if lx + tw > W:
            lx = W - tw - 4
        base.rectangle([lx, ly, lx + tw, ly + th], fill=lc)
        base.text((lx + 7, ly + 5), label, fill=(255, 255, 255, 255), font=font)

        crop_name = f"{raw_path.stem}__{i:02d}_{sanitize(name)}.png"
        crop = img.crop((x1, y1, x2, y2))
        crop.save(crops_dir / crop_name)

    out = Image.alpha_composite(img, overlay)
    out.convert("RGB").save(annotated_path)


async def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    raw_dir = OUT_DIR / "raw"
    anno_dir = OUT_DIR / "annotated"
    crop_dir = OUT_DIR / "crops"
    for d in [raw_dir, anno_dir, crop_dir]:
        if d.exists():
            shutil.rmtree(d)
        d.mkdir(exist_ok=True)

    pages = sorted([p for p in PAGES_DIR.iterdir() if p.is_dir() and (p / "index.html").exists()], key=lambda x: x.name)

    report = []
    report.append("# 页面模块截图解析")
    report.append("")
    report.append("- 运行地址：`http://localhost:5500/pages/<page>/index.html`")
    report.append("- 说明：标注图中的编号与模块列表一一对应。")
    report.append("")

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(headless=True)
        context = await browser.new_context(viewport=VIEWPORT)
        page = await context.new_page()

        for p in pages:
            slug = p.name
            component_dirs = [d.name for d in (p / "components").iterdir() if d.is_dir()]
            modules = list(MODULE_ORDER.get(slug, sorted(component_dirs)))
            for m in component_dirs:
                if m not in modules:
                    modules.append(m)
            url = f"{BASE_URL}/pages/{slug}/index.html"

            await page.goto(url, wait_until="domcontentloaded")
            await page.wait_for_timeout(350)

            info = await compute_boxes(page, slug, modules)
            boxes = info.get("boxes", [])

            raw_path = raw_dir / f"{slug}.png"
            anno_path = anno_dir / f"{slug}-annotated.png"
            page_crop_dir = crop_dir / slug
            await page.screenshot(path=str(raw_path), full_page=False)
            annotate_image(raw_path, anno_path, page_crop_dir, boxes)

            report.append(f"## {slug}")
            report.append("")
            report.append(f"- 原图：`page-annotations/raw/{slug}.png`")
            report.append(f"- 标注图：`page-annotations/annotated/{slug}-annotated.png`")
            report.append("")
            report.append("模块编号：")
            for i, b in enumerate(boxes, start=1):
                note = b.get("note", "")
                if note:
                    report.append(f"- {i}. `{b['name']}`（{note}）")
                else:
                    report.append(f"- {i}. `{b['name']}`")
            report.append("")

        await browser.close()

    (OUT_DIR / "README.md").write_text("\n".join(report), encoding="utf-8")


if __name__ == "__main__":
    asyncio.run(main())



