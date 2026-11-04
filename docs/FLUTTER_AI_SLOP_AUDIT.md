> 本轮范围调整：数据 WIP，不算设计问题；设计去味以 FLUTTER_DESIGN_DESLOP.md 为准。

# Flutter App AI 味审查

> 范围：只审 Flutter App，不含 admin-web  
> 日期：2026-11-04  
> 方法：kill-ai-slop 扫描 + design-taste-frontend app-screen 规则 + humanizer-zh 中文文案检查  
> 本文件只出报告，不改代码

## 0. 结论

App 的暗色暖调、旧书店细节、具体生活文案是个性，应该保留。

真正要去掉的是：

1. 假数据：12,145 条消息、94 张照片、第 5 天、在店 3 小时、固定日期天气。
2. 硬编码状态：聊天页写死“有点不舒服”、朋友圈写死“第 5 天”、通知写死“今天有点不舒服”。
3. 硬编码名字：App 里 35 处“笨笨”，没有用后端 displayName。
4. 44 次重复使用 3 张 book 图，把同一张图当人物、事件、朋友圈、相册。
5. 玻璃拟态 + 渐变 + 极小字号，典型的生成式 App UI 外观。
6. 占有式空泛文案：你的笨笨、只属于你的一条生活、这一条生活只在这里发生。

## 1. 扫描摘要

kill-ai-slop 的 web scanner 对 Flutter 基本无效，只扫到文档里的一个箭头，因此以下按 Flutter 源码手工统计：

| 项 | 命中 |
|---|---:|
| 硬编码“笨笨” | 35 处 |
| GlassPanel / surfaceGlass / warmGlow / photoOverlay | 16 处 |
| 字号 7.5–10sp 的微小文字 | 18 处 |
| 重复 book1/book2/book3 图片 | 44 处 |
| 硬编码假数字 / 假日期 / 假状态 | 17 处以上 |

## 2. P0：假数据与假状态

### P0-1 ProfileHero 的假数字

文件：lib/features/profile/presentation/widgets/profile_hero.dart

- 第 141 行：消息 12,145
- 第 143 行：照片 94
- 第 145 行：相处 5 天
- 第 37 行：栖湾 · 旧书店 · 18 岁
- 第 105 行：第 N 天 · 只属于你的一条生活
- 第 128 行：现在在旧书店，收书

问题：后端没有这些数字，全部写死；用户改名 / 改年龄不会变。

改法：只用真实字段；没有就显示“—”；第 N 天从真实相处时间计算；18 岁从 profile 读；没有就不显示。

### P0-2 ProfileView 的假统计

文件：lib/features/profile/presentation/profile_view.dart

- 第 92 行：全部 94 张
- 第 96 行：4 个街坊
- 第 102 行：6 件
- 第 108 行：10月25日 — 10月29日
- 第 270-274 行：他最近说 / 「书不会跑，人会跑。」 / 今天 15:32 · 旧书店

改法：照片数来自 media；街坊数来自 life.people；家当数来自 life.items；“最近说”来自真实最新对话或删除；日期范围来自真实日记/事件。

### P0-3 NowCard 写死引语、日期、天气、在店时长

文件：lib/features/today/presentation/widgets/now_card.dart

- 第 67 行：把晒了一下午的旧书一本本收回来，码回后院
- 第 159 行：11月2日 周日 · 雨 1.7°C
- 第 182 行：在店 3 小时
- 第 79 行：这一条生活，只在这里发生

问题：TodayView 已接真实 lifeProvider，但 NowCard 仍显示写死的句子和日期，界面与真实事件会打架。

改法：NowCard 接收完整 LifeSnapshot；引语用最新真实事件 detail；日期/天气用 world.clockLabel / weather / temperature；在店时长从事件计算；没有就删；删除空泛收束句。

### P0-4 聊天标题写死身体状态

文件：lib/features/chat/presentation/chat_view.dart，第 52 行：

~~~text
旧书店 · 有点不舒服 · 醒着
~~~

改法：从 lifeProvider 当前状态拼；“有点不舒服”来自 condition；位置来自真实 place；没有就不显示。

### P0-5 朋友圈标题写死第 5 天

文件：lib/features/moments/presentation/moments_view.dart，第 42 行：

~~~text
他的生活 · 第 5 天
~~~

改法：改成“他的生活”或真实日期范围；第 N 天统一从真实账号/companion 数据来。

### P0-6 后端失败时回退 demoProfile

文件：lib/features/profile/presentation/profile_view.dart，第 63 行：

~~~dart
final people = life == null ? demoProfile.people : ...
~~~

改法：life == null 显示 Error/Empty，不显示 demoProfile；删除 demoProfile 生产依赖。

### P0-7 Diary 仍是 demo 数据

文件：lib/features/diary/data/demo_diary.dart

问题：日记页当前不是真实日记；写得像人，但它是假记录。

改法：接真实 diary；没有就显示“还没写”；demo_diary 只用于 Golden，不进生产。

### P0-8 Tablet / ProactiveNotice 是整块假状态

文件：

- lib/features/tablet/presentation/widgets/cinema_scene.dart
- lib/features/tablet/presentation/widgets/cinema_panels.dart
- lib/shared/widgets/proactive_notice.dart

命中：

- 第 88 行：今天第 4 件事
- 第 127 行：第 5 / 5 天
- 第 162 行：第 3 小时
- 第 168 行：今天还剩 2 件事
- 通知第 180 行：今天有点不舒服，店里刚进的书还没理完
- 通知第 199 行：他在等你说句话

改法：平板复用 Today/Moments/Profile 真实 provider；通知用真实 proactive 消息，没有就不弹；删除写死数字和写死病症。

## 3. P1：硬编码身份

App 里 35 处“笨笨”，包括：

- lib/app.dart
- lib/core/auth/login_view.dart
- lib/features/chat/presentation/chat_view.dart
- lib/features/profile/presentation/profile_view.dart
- lib/features/profile/presentation/widgets/profile_hero.dart
- lib/features/today/presentation/today_view.dart
- lib/features/today/presentation/widgets/today_header_actions.dart
- lib/shared/widgets/proactive_notice.dart
- tablet 多个文件

问题：角色改名后 App 仍显示“笨笨”；登录、聊天、个人页、通知不统一；这是“只改 UI 名字”的前置阻塞。

改法：从 authResponse.companion.displayName 或 /auth/me 取；建立 currentCompanionProvider；所有标题、通知、系统文案用 displayName；“你的笨笨”改成“你的 displayName”或直接“他”。

## 4. P2：AI 外观

### P2-1 玻璃拟态

文件：

- lib/shared/widgets/glass_panel.dart
- lib/core/theme/app_colors.dart
- lib/shared/widgets/dock.dart
- 多个卡片

问题：surfaceGlass = 0xCC1B1411；半透明面板 + 白色边框 + 多层圆角；glass_panel 的 blur 参数目前没用，但视觉已经是玻璃卡片。

建议：保留暗色暖调；主内容面板改实色 surface + 1px 分隔线；只保留一个真正需要浮起的层（dock/弹层）；不要每张卡都 glass。

### P2-2 渐变

文件：

- lib/features/today/presentation/widgets/now_card.dart
- lib/core/theme/app_colors.dart

问题：NowCard 外层 RadialGradient、内层 LinearGradient；warmGlow 径向渐变；photoOverlay 三段渐变。

建议：NowCard 改实色背景 + hairline；删除 warmGlow；photoOverlay 只在真实照片有可读性需求时保留，并且只保留一层 scrim。

### P2-3 极小字号与平层级

命中 18 处 7.5–10sp：

- now_card.dart
- timeline_card.dart
- chat_bubble.dart
- moment_card.dart
- app_sheet.dart
- screen_header.dart
- proactive_notice.dart

建议：正文最小 11–12sp；辅助信息最小 10sp；标题和正文至少 1.25× 差距；减少同时存在的字号档位。

### P2-4 重复占位图

44 次使用 book1/book2/book3。

问题：所有人物、事件、朋友圈、相册共用三张书店图；看起来像没素材的模板；照片档案、头像、NPC 全是假图。

建议：人物用稳定首字母 + 淡色，不用 book 图；事件没有图就不显示；朋友圈只显示真实 photos；相册只显示 media 真图；demo 图只留在 Golden。

## 5. P2：文案

### 应删 / 改写

1. “这一条生活，只在这里发生” —— 空泛收束，没有信息；改成真实状态或删除。
2. “只属于你的一条生活” —— 占有式宣传语；改成真实第 N 天，没有就删。
3. “你的笨笨” —— 硬编码占有式昵称；改成 displayName 或“他”。
4. “他最近说：书不会跑，人会跑” —— 不是真实最新消息；改成真实最新消息或删除。
5. “他在等你说句话” —— 假状态；用真实 proactive 通知，没有就不显示。
6. “这一条生活只在这里发生” —— 重复、无信息；删除。

### 应保留

- 旧书店、晒书、房租、林叔、旧车票这些具体细节
- 雨、纸味、门轴、咸菜这些生活细节
- 暗色暖调
- 一个暖琥珀 accent
- 日记里具体、不完美的句子

这些不是 AI 味，是产品自己的世界，不要一起删。

## 6. 修复顺序

### P0

1. NowCard 接 LifeSnapshot，删写死引语/日期/天气/时长
2. ProfileHero/ProfileView 删假统计，只显示真实或“—”
3. Chat/Moments 标题接真实状态
4. Profile API 失败不回退 demo
5. Diary/Tablet/ProactiveNotice 接真实数据或显示空态
6. 全 App 去掉硬编码“笨笨”，接 displayName

### P1

7. 删 demoProfile 生产依赖
8. 人物头像改首字母 + 稳定淡色
9. 事件无图不显示图
10. 删重复 book 占位

### P2

11. GlassPanel 改实色 surface + hairline，保留一个浮层
12. 删 NowCard 双层渐变、warmGlow
13. 提升最小字号，收敛层级
14. 删除占有式/空泛文案

## 7. 验证

~~~bash
flutter analyze
flutter test
flutter test --update-goldens
~~~

并看实际 390×844 / 1024×768 截图，不只看代码。

## 8. 最终判断

当前 Flutter 最重的 AI 味不是“颜色不够高级”，而是：

- 假数据
- 假状态
- 假图片
- 假身份
- 玻璃/渐变/小字堆出来的模板感

先把 P0 的假东西换成真实数据，再谈视觉收敛。否则越“设计”越假。
