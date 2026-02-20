# Component 纯净组件拆解版

## 目录结构
```text
project/
  pages/
    index/
      index.html
      page.css
      page.js
      components/
        top-frame/
          <component>.html
          <component>.css
          <component>.js
        top-dashboard/
          <component>.html
          <component>.css
          <component>.js
        recommendation-list/
          <component>.html
          <component>.css
          <component>.js
        recent-upload/
          <component>.html
          <component>.css
          <component>.js
        action-overlay/
          <component>.html
          <component>.css
          <component>.js
    community/
      index.html
      page.css
      page.js
      components/
        top-frame-and-tabs/
          <component>.html
          <component>.css
          <component>.js
        board-my-requests/
          <component>.html
          <component>.css
          <component>.js
        board-feature-boost/
          <component>.html
          <component>.css
          <component>.js
        board-feedback/
          <component>.html
          <component>.css
          <component>.js
    ... 其他页面同结构 ...
  shared/
    app.js
    styles.css
    utils.js
  assets/
```

## 运行入口
- 首页入口：`pages/index/index.html`
- 其它页面：`pages/<page>/index.html`

## 拆分原则
- 每个页面只保留三类主文件：`index.html`、`page.css`、`page.js`。
- 组件按功能区拆分到 `components/<component>/<component>.html|<component>.css|<component>.js`，不做按钮级碎片拆分。
- `page.js` 只负责按页面顺序装配组件，并保留页面级状态与跳转逻辑。
- `shared/app.js` 提供 `loadComponentTemplate()`，运行时按组件路径加载对应 html/css/js。

## 路由与一致性
- `shared/app.js` 的 `navigateTo('xxx.html')` 已适配到 `pages/xxx/index.html`。
- 页面交互、样式和跳转保持与示例版一致（仅重组结构，不改业务表现）。

