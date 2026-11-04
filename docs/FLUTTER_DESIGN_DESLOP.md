# Flutter App 设计去 AI 味方案

> 范围：只谈 Flutter 设计语言，不评价后端数据完整性  
> 数据 WIP：12,145、第 5 天、固定天气等先不列为设计问题  
> 方法：design-taste-frontend 的 app-screen 规则 + kill-ai-slop 的视觉分类

## 0. 方向先说

保留：

- 暗色暖调：0B0908 ground，暖琥珀 accent
- PingFang SC
- 旧书店、晒书、雨、旧车票这些产品自己的世界
- 一个 accent，不做彩虹色

去掉：

- 玻璃拟态和背景模糊
- 双层渐变、径向光晕
- 所有面板都半透明
- 超大圆角 + 超大阴影
- 7.5–10sp 的极小字
- 同一张 book 图当所有头像/内容
- 选中态发光胶囊

风格结论：

~~~text
dark + warm amber + flat surfaces
elevation by lightness, not blur
colour only where it carries state
one typeface, fewer size steps
~~~

不是换成白底，也不是变成纯黑仪表盘。是同一个产品，去掉模板感。

---

## 1. 最重的 AI 味：底部 Dock

文件：lib/shared/widgets/dock.dart

命中：

- 第 34 行：ImageFilter.blur(sigmaX: 26)
- 第 37-42 行：渐变
- 第 46 行：BoxShadow blurRadius 46
- 第 81-91 行：选中态再叠一层渐变 + 边框 + shadow
- 第 108 行：字号 7.5

问题：

- 26px 模糊 + 46px 投影 + 半透明，是典型的“glass dock”
- 选中态用胶囊 + 渐变 + 阴影 + 放大 1.06，堆了四层视觉信号
- 7.5sp 文字几乎不可读

改法：

- 删除 BackdropFilter / blur
- 删除渐变
- 删除 46px 大阴影
- 底栏用实色 surface + 1px 顶部分隔线
- 选中只做：文字和图标变亮 + 2px amber 短线
- 不做胶囊底、不做放大、不做 glow

---

## 2. 全局玻璃面板

文件：

- lib/shared/widgets/glass_panel.dart
- lib/core/theme/app_colors.dart

命中：

- surfaceGlass = 0xCC1B1411
- GlassPanel 使用半透明背景 + 白色边框 + 大圆角
- 多个页面把它当默认卡片

问题：

- 所有内容都浮在背景上，缺少平面层级
- 背景图越复杂，面板越像“AI 玻璃卡”
- 圆角大、边框白、半透明，三者叠加是模板感来源

改法：

- GlassPanel 改名为 SurfacePanel（或保留名字但行为改实色）
- 背景用 AppColors.surface
- 边框用 1px AppColors.border
- 圆角从 18 降到 12
- 删除半透明；只保留一个真正需要浮起的层

建议只保留两个层级：

~~~text
ground   0B0908
surface  15100E
raised   211814  (只给弹层)
~~~

---

## 3. NowCard 双层渐变

文件：lib/features/today/presentation/widgets/now_card.dart

命中：

- 第 22-30 行：外层 RadialGradient
- 第 36-42 行：内层 LinearGradient
- 两层圆角不一致
- 文案里还有空泛收束句（数据 WIP 先不管）

问题：

- 外层 radial + 内层 linear，是 AI 卡片最常见的“氛围光”
- 两张圆角套在一起，不自然
- 里面还有一张发光的 hero 卡

改法：

- 只保留一个实色 surface
- 顶部放 1px amber 短线作为唯一 accent
- 删除 radialGlow
- 删除内层渐变
- 一个圆角：12

---

## 4. 极小字号与层级压缩

文件：lib/core/theme/app_text_styles.dart

当前：

~~~text
micro    7.5
label    8
caption  9
body     11
title    15
headline 26
~~~

问题：

- 7.5–9sp 在手机上基本不可读
- body 11 / title 15 差距不够
- 很多页面靠“更小”区分层级，结果是密密麻麻的 AI 仪表盘感

建议：

~~~text
micro    10
caption  11
body     13
bodyStrong 13
title    17
headline 26
~~~

同时：

- 正文不再低于 11
- 辅助不再低于 10
- 标题和正文至少 1.25×
- 不再为每个小标签单独配字号

---

## 5. 全局圆角过大

命中：

- Dock 胶囊 999
- NowCard 18
- GlassPanel 18
- 多个卡片 14–22
- 内部 chip 又是 9–13

问题：

- 所有东西都是大圆角，层级只剩“更圆”
- 内外圆角不嵌套，视觉发软
- 是“可爱 AI 模板”的常用手法

建议：

- 页面主面板：12
- 次级卡：10
- 内部 chip：6–8
- 只有真正的胶囊元素（比如状态点/按钮）用 pill
- 内圆角 = 外圆角 - padding

---

## 6. 背景图 + scrim + warm glow

文件：

- lib/features/shell/presentation/companion_shell.dart
- lib/core/theme/app_colors.dart

命中：

- 全屏 assets/media/bg.png
- scrimTop / scrimBottom
- warmGlow 径向渐变

问题：

- 背景图本身是产品资产，可以保留
- 但“背景图 + 暗角 + 暖光 + 半透明卡”组合，是生成式 UI 的默认氛围
- 每个页面都盖同一层，内容会失焦

建议：

- Today 保留全屏图，只保留一个顶部 scrim
- 其他页面改实色 ground，不重复铺同一张背景
- 删除 warmGlow
- 不在背景上再加径向暖光

---

## 7. 重复的 book 图

统计：44 次使用 book1/book2/book3。

问题：

- 同三张图承担头像、时间线、朋友圈、相册、平板
- 用户一眼能看出是占位图
- 这不是数据问题，是视觉系统没有头像/媒体策略

建议：

- 人物：稳定首字母 + 浅色底 + 1px 边
- 事件：没有真实图片就不显示缩略图
- 朋友圈：只显示真实 photos
- 相册：只显示真实 media
- book 图只留在 Golden / 空状态插画

---

## 8. 选中态和微动效

文件：

- dock.dart：AnimatedScale 1.06 + 180ms
- 选中胶囊渐变/阴影

问题：

- 点击态同时改大小、颜色、背景、阴影
- 这是“动效很多，但没有信息”的典型 AI UI

建议：

- 选中只改前景色 + 2px accent 线
- 删除放大
- 删除阴影
- 过渡 120–160ms，只过渡颜色

---

## 9. 哪些不能误删

保留：

- 暗色暖调
- 一个琥珀 accent
- PingFang
- 旧书店背景图（至少 Today）
- 全屏照片的真实 scrim
- 日记里的具体生活细节

删除：

- 玻璃
- 双层渐变
- 径向光晕
- 大阴影
- 极小字
- 重复占位图
- 装饰性胶囊

---

## 10. 落地顺序

### 第一刀：token

1. app_colors：surfaceGlass -> surface
2. app_text_styles：提升 7.5/8/9/11 四档
3. app_spacing/radius：收敛圆角

### 第二刀：组件

4. dock.dart：去 blur / 渐变 / 阴影 / 放大
5. glass_panel.dart：变实色 SurfacePanel
6. now_card.dart：单层实色
7. timeline_card / moment_card / profile_section：跟随 token

### 第三刀：页面

8. Today：只保留一个背景图 + 一个 scrim
9. Chat：实色气泡，不再玻璃
10. Profile：去掉玻璃统计块，改文字 + 分隔线
11. Moments：实色卡片

### 第四刀：验证

~~~bash
flutter analyze
flutter test
flutter test --update-goldens
~~~

看 390×844 和 1024×768 截图，不只看代码。

---

## 11. 一句话

Flutter 的 AI 味不是“暗色”造成的，是**半透明 + 渐变 + 大圆角 + 大阴影 + 小字 + 重复占位图**一起造成的。

保留暗色暖调和旧书店世界，把这六个模板手法拿掉，设计就会像一个人为笨笨做的 App，而不是一个 AI 生成的陪伴模板。
