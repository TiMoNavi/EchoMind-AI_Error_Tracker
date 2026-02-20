/* ============================================
   AI Learning Product v2.0 - App Logic
   ============================================ */

// Navigation helper
function navigateTo(page) {
    window.location.href = page;
}

// Tab bar HTML generator
function getTabBar(active) {
    const tabs = [
        { id: 'home', label: '主页', page: 'index.html', icon: '<svg viewBox="0 0 24 24"><path d="M3 9.5L12 3l9 6.5V20a1 1 0 01-1 1H4a1 1 0 01-1-1V9.5z"/><path d="M9 21V12h6v9"/></svg>' },
        { id: 'global', label: '全局', page: 'global-knowledge.html', icon: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 3c-2.5 3-4 6.5-4 9s1.5 6 4 9c2.5-3 4-6.5 4-9s-1.5-6-4-9z"/><path d="M3.5 9h17M3.5 15h17"/></svg>' },
        { id: 'memory', label: '记忆', page: 'memory.html', icon: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="3"/><path d="M8 8h8M8 12h5"/></svg>' },
        { id: 'community', label: '社区', page: 'community.html', icon: '<svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>' },
        { id: 'profile', label: '我的', page: 'profile.html', icon: '<svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>' }
    ];

    return `<nav class="tab-bar">${tabs.map(t => `
    <a class="tab-item ${t.id === active ? 'active' : ''}" onclick="navigateTo('${t.page}')">
      <span class="tab-icon">${t.icon}</span>
      <span class="tab-label">${t.label}</span>
    </a>`).join('')}</nav>`;
}

// Status bar HTML
function getStatusBar() {
    return `<div class="status-bar"><span class="time">13:42</span><span class="icons">5G ||||</span></div>`;
}

// Level helpers
function getLevelText(level) {
    const texts = {
        0: '未接触',
        1: '卡住',
        2: '薄弱',
        3: '待巩固',
        4: '已掌握',
        5: '稳定'
    };
    return texts[level] || '未知';
}

function getLevelModelText(level) {
    const texts = {
        0: '未接触',
        1: '建模卡住',
        2: '列式卡住',
        3: '执行卡住',
        4: '做对过',
        5: '稳定掌握'
    };
    return texts[level] || '未知';
}

function getLevelKPText(level) {
    const texts = {
        0: '未接触',
        1: '记不住',
        2: '理解不深',
        3: '使用出错',
        4: '能正确使用',
        5: '稳定掌握'
    };
    return texts[level] || '未知';
}

function getLevelClass(level) {
    return 'l' + level;
}

// Toggle tree
function toggleTree(el) {
    el.classList.toggle('open');
    const content = el.nextElementSibling;
    if (content) {
        content.style.display = content.style.display === 'none' ? 'block' : 'none';
    }
}

// Show/hide modal
function showModal(id) {
    document.getElementById(id).classList.add('show');
}

function hideModal(id) {
    document.getElementById(id).classList.remove('show');
}

// Flip flashcard
function flipCard(el) {
    el.classList.toggle('flipped');
}

// Simple chart drawing (SVG polyline)
function drawTrendLine(svgId, data, color) {
    const svg = document.getElementById(svgId);
    if (!svg || !data.length) return;
    const w = svg.clientWidth;
    const h = svg.clientHeight;
    const padding = 20;
    const maxVal = Math.max(...data);
    const minVal = Math.min(...data);
    const range = maxVal - minVal || 1;

    let points = data.map((v, i) => {
        const x = padding + (i / (data.length - 1)) * (w - padding * 2);
        const y = h - padding - ((v - minVal) / range) * (h - padding * 2);
        return `${x},${y}`;
    }).join(' ');

    // Gradient area
    const firstX = padding;
    const lastX = padding + (w - padding * 2);
    const areaPoints = `${firstX},${h - padding} ${points} ${lastX},${h - padding}`;

    svg.innerHTML = `
    <defs>
      <linearGradient id="grad-${svgId}" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stop-color="${color}" stop-opacity="0.15"/>
        <stop offset="100%" stop-color="${color}" stop-opacity="0"/>
      </linearGradient>
    </defs>
    <polygon points="${areaPoints}" fill="url(#grad-${svgId})"/>
    <polyline points="${points}" fill="none" stroke="${color}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    ${data.map((v, i) => {
        if (i === data.length - 1) {
            const x = padding + (i / (data.length - 1)) * (w - padding * 2);
            const y = h - padding - ((v - minVal) / range) * (h - padding * 2);
            return `<circle cx="${x}" cy="${y}" r="4" fill="${color}" stroke="#fff" stroke-width="2"/>`;
        }
        return '';
    }).join('')}
  `;
}

// Demo data
const DEMO = {
    subjects: ['物理', '数学'],
    chapters_physics: [
        {
            name: '力学', sections: [
                {
                    name: '力的概念', kps: [
                        { name: '力的定义', level: 5 },
                        { name: '力的三要素', level: 4 },
                        { name: '力的单位', level: 5 }
                    ]
                },
                {
                    name: '牛顿运动定律', kps: [
                        { name: '牛顿第一定律', level: 4 },
                        { name: '牛顿第二定律', level: 3 },
                        { name: '牛顿第三定律', level: 5 }
                    ]
                },
                {
                    name: '摩擦力', kps: [
                        { name: '静摩擦力', level: 2 },
                        { name: '滑动摩擦力', level: 3 }
                    ]
                }
            ]
        },
        {
            name: '静电场', sections: [
                {
                    name: '电荷', kps: [
                        { name: '电荷量', level: 4 },
                        { name: '元电荷', level: 4 },
                        { name: '起电方式', level: 5 }
                    ]
                },
                {
                    name: '库仑定律', kps: [
                        { name: '库仑定律公式', level: 3 },
                        { name: '适用条件', level: 2 }
                    ]
                }
            ]
        },
        {
            name: '电磁感应', sections: [
                {
                    name: '法拉第电磁感应定律', kps: [
                        { name: '感应电动势', level: 1 },
                        { name: '磁通量变化率', level: 0 }
                    ]
                },
                {
                    name: '楞次定律', kps: [
                        { name: '楞次定律内容', level: 1 },
                        { name: '应用方法', level: 0 }
                    ]
                }
            ]
        }
    ],
    models_physics: [
        {
            name: '力学', models: [
                { name: '匀变速直线运动', level: 4, subproblems: ['加速问题', '减速问题', '追及问题'] },
                { name: '牛顿第二定律应用', level: 3, subproblems: ['单物体', '连接体'], cross: null },
                { name: '板块运动', level: 1, subproblems: ['相对滑动', '共速问题'], cross: null },
                { name: '动能定理', level: 4, subproblems: ['单过程', '多过程'], cross: '能量' }
            ]
        },
        {
            name: '静电场', models: [
                { name: '库仑力平衡', level: 2, subproblems: ['两个点电荷', '三个点电荷'] },
                { name: '电场中的功能关系', level: 0, subproblems: ['匀强电场', '点电荷电场'] }
            ]
        },
        {
            name: '电磁感应', models: [
                { name: '单棒切割', level: 1, subproblems: ['恒力切割', '安培力制动'] },
                { name: '磁流体发电机', level: 0, subproblems: ['基本原理'] }
            ]
        }
    ],
    targetScore: 70,
    predictedScore: 63,
    todayClosures: 3,
    weekClosures: 12,
    weekStudyMin: 145,
    scoreHistory: [55, 57, 59, 61, 60, 63]
};

// Page init
document.addEventListener('DOMContentLoaded', function () {
    // Auto-inject status bar if not present
    const frame = document.querySelector('.phone-frame');
    if (frame && !frame.querySelector('.status-bar')) {
        frame.insertAdjacentHTML('afterbegin', getStatusBar());
    }

    // Auto-inject tab bar if needed
    if (frame && frame.dataset.tabs) {
        frame.insertAdjacentHTML('beforeend', getTabBar(frame.dataset.tabs));
    }

    // Init charts
    const trendSvg = document.getElementById('trend-chart');
    if (trendSvg) {
        setTimeout(() => drawTrendLine('trend-chart', DEMO.scoreHistory, '#007AFF'), 100);
    }
});
