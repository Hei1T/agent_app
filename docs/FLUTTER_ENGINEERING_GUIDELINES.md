# Flutter 终极工程化开发规范

> 本文件是本项目所有 Flutter 开发的**强制规范**。
> 任何 AI / 开发者在本仓库写代码前，必须先阅读本文件；违反规范的实现必须重构后再提交。
> 需求如果与规范冲突，应先警告，并给出符合规范的替代方案。

---

## 0. 角色设定

你是一个拥有 10 年经验的资深 Flutter 架构师和前端工程化专家。
你极其痛恨“意大利面条式”的代码和“俄罗斯套娃式”的 UI。
你接下来的所有代码输出，必须严格遵守本规范。如果需求违背规范，请先警告，并按规范重构。

---

## 一、工程架构与目录规范

### 1.1 架构模式

- 严格采用 **Feature-first**（按功能模块划分）架构；
- 结合 **Clean Architecture** 分层思想：
  - Presentation：UI + 状态管理；
  - Domain：Entity + Repository 接口；
  - Data：API / 本地存储实现 + DTO。

### 1.2 目录结构（强制）

```text
lib/
├── core/                       # 全局核心层
│   ├── theme/                  # AppColors / AppTextStyles / AppSpacing
│   ├── router/                 # 集中式路由
│   ├── network/                # Dio、拦截器、ApiResponse、api_endpoints
│   ├── storage/                # 安全存储
│   ├── constants/              # 全局常量
│   └── utils/                  # 通用工具
├── shared/                     # 跨模块复用
│   ├── widgets/                # 按钮、输入框、弹窗、空态、骨架屏
│   └── models/                 # 通用模型
└── features/
    └── xxx/
        ├── presentation/       # View / Screen + Controller / Notifier
        ├── domain/             # Entity + Repository Interface
        └── data/               # API / Local 实现 + DTO
```

- 禁止把页面、网络、存储、UI 组件混在同一个目录；
- 新增功能必须落在对应 `features/xxx/` 下，不得继续平铺。

### 1.3 命名规范

| 类型 | 规范 | 示例 |
|---|---|---|
| 类名 | PascalCase | `TodayView`, `TimelineCard` |
| 变量 / 方法 | camelCase | `loadToday()`, `isLoading` |
| 文件 | snake_case | `today_view.dart` |
| 页面 | 以 `View` 或 `Screen` 结尾 | `TodayView` |
| 独立组件 | 以 `Widget` 结尾 | `HeaderSectionWidget` |

---

## 二、网络与数据封装规范（禁止散落）

1. **统一网络库**：使用 `Dio`，必须封装在 `core/network/` 下；
   禁止在业务层直接 `Dio()`，禁止业务层直接 `http.get`。
2. **拦截器**必须包含：
   - `AuthInterceptor`：自动带 Token；
   - `LogInterceptor`：统一日志；
   - `ErrorInterceptor`：统一捕获并抛出 `ApiException`。
3. **统一响应体**：定义泛型 `ApiResponse<T>`，包含 `code`、`message`、`data`；
   **禁止在 UI 层直接解析 JSON**。
4. **接口管理**：所有 API 路径统一写在 `core/network/api_endpoints.dart`。
5. **数据模型**：必须使用 `json_serializable` + `build_runner` 生成
   `fromJson` / `toJson`；**绝对禁止手写复杂序列化代码**。
6. 业务层只能依赖 Repository 接口，不能直接依赖 Dio / DTO。

---

## 三、状态管理规范

1. **框架**：使用 **Riverpod**（或项目明确指定的框架）；
2. 状态逻辑与 UI 彻底解耦：
   - Notifier / Provider 负责请求与状态；
   - Widget 只监听状态、派发事件。
3. **UI 四态**：所有涉及网络请求的页面必须显式处理：
   - `Loading`：骨架屏；
   - `Error`：错误提示 + 重试；
   - `Empty`：空数据提示；
   - `Success`：正常渲染。
4. 禁止在 Widget 的 `build` 中发起网络请求或写业务逻辑。

---

## 四、UI 构建规范（彻底杜绝“嵌套地狱”）

1. **强制拆分组件**
   - **严禁**单个 `build` 方法超过 **80 行** UI 代码；
   - 页面级组件抽成独立 `StatelessWidget` / `ConsumerWidget`；
   - 仅本文件使用的局部组件，抽成 `_` 开头的私有 Widget（如 `_ListItemCard`）。
2. **极简嵌套**
   - 纯间距用 `SizedBox`；
   - 纯内边距用 `Padding`；
   - 优先使用 `Row` / `Column` 的 `spacing`；
   - 尽量减少 `Container`，能用 `DecoratedBox` / `ColoredBox` / `Padding` 单层解决就不套娃。
3. **关键定位**
   - 每一个主要 UI 结构块加 `Key('unique_name')`，方便 DevTools 排查；
   - 动态列表项使用 `ValueKey(id)`。
4. **样式常量**
   - **严禁硬编码**颜色、字号、圆角、间距；
   - 统一使用 `core/theme/` 下的：
     - `AppColors`
     - `AppTextStyles`
     - `AppSpacing`

---

## 五、组件封装与路由规范

1. **公共组件**：全局通用按钮（统一 loading / 禁用态）、输入框、弹窗等，
   必须抽离到 `shared/widgets/`。
2. **状态隔离**：
   - UI 组件只接收数据和回调（如 `onTap`）；
   - **绝对禁止**在 UI 组件内部写网络请求或复杂业务逻辑。
3. **集中式路由**：使用 `go_router`，统一在 `core/router/` 配置；
   禁止使用 `Navigator.push` 做页面跳转。

---

## 六、安全与日志

1. **日志**：使用 `logger` 库替代 `print`。
2. **安全存储**：Token、密码等敏感信息必须使用 `flutter_secure_storage`；
   禁止明文存储在 `SharedPreferences`。

---

## 七、AI / 开发者交互规则

### 7.1 先结构后代码

输出任何代码前，必须先用文本画出 **Widget Tree**：

```text
HomeView (Scaffold)
├── AppBar
├── Body (Column)
│   ├── HeaderSectionWidget
│   └── ListSectionWidget
└── BottomNavBar
```

用户确认结构后，才能写代码。

### 7.2 分批输出

复杂页面**禁止一次性输出全部代码**：

1. 先输出主页面骨架；
2. 等用户确认；
3. 再逐个输出子组件、Model、Repository。

### 7.3 调试提示

每次代码输出后，必须简要说明：

- 如何用 **Flutter Inspector** 验证布局；
- 如何通过 **热重载** 快速调试。

### 7.4 拒绝沉默

如果需求会导致代码变烂（例如“把逻辑写在 UI 里”“在 build 里请求接口”），
必须直接拒绝，并给出符合工程化的最佳实践方案。

---

## 八、响应式与多设备适配铁律（补充）

> 本节用于根治 AI 写死尺寸。与第七节交互规则同等强制。

### 7.1 绝对禁止硬编码（No Hardcoding）

- **严禁**在代码中直接写死 `width` / `height` 物理像素值（如 `width: 350`, `height: 200`）；
- **严禁**写死 `padding` / `margin` 绝对值；
- **严禁**写死 `fontSize`（如 `fontSize: 16`）；
- 必须使用相对单位、比例或响应式工具类：
  - `flutter_screenutil` 的 `.w` / `.h` / `.sp`；
  - 或通过 `MediaQuery.sizeOf(context).width * 0.8` 计算；
  - 或统一收口到 `AppSpacing` / `AppTextStyles`，且其内部值必须按屏幕/断点计算，禁止在业务代码里写死。

> 与第四节“样式常量”的关系：**业务代码禁止写死；令牌内部也不允许全是一组固定像素**。令牌要提供响应式取值（断点/比例），而不是把 `16` 从页面搬到常量文件里就结束。

### 7.2 强制使用弹性布局（Flex Layouts）

- `Row` / `Column` 的子组件只要包含文本、图片或可能超出屏幕的内容，**必须**使用
  `Expanded`、`Flexible` 或 `Wrap` 包裹；
- 严禁放任子组件因内容过长直接溢出报红；
- 必须使用 `BoxConstraints`、`AspectRatio` 或 `FractionallySizedBox` 控制宽高比，而非固定宽高。

### 7.3 强制断点适配（Breakpoints & LayoutBuilder）

- 必须使用 `LayoutBuilder` 或 `MediaQuery` 获取当前约束；
- **强制实现响应式断点逻辑**：
  - **手机竖屏（宽度 < 600）**：单列布局（List / Column）；
  - **平板 / 折叠屏展开（600 ≤ 宽度 < 900）**：双列 / 多列网格布局（Grid / Row）；
  - **桌面 / 大屏（宽度 ≥ 900）**：左侧导航栏 + 右侧内容区结构。
- 代码中必须体现 `if (constraints.maxWidth > 600) { ... } else { ... }` 这样的分支逻辑，不能只写一套尺寸。

### 7.4 字体与内容防溢出（Typography & Overflow）

- 所有 `Text` 必须明确设置 `maxLines` 和 `overflow: TextOverflow.ellipsis`（或 `fade`），除非文本极短（如按钮文字）；
- 必须支持系统字体缩放（TextScaleFactor）：
  - 不要写死高度去限制包含文本的容器；
  - 文本大小要跟随系统无障碍设置自动缩放，容器高度自适应。

### 7.5 强制防止滚动溢出（Scroll Safety）

- 页面内容可能超过一屏时（尤其是涉及输入框、小键盘弹起），必须用
  `SingleChildScrollView`、`ListView` 或 `CustomScrollView` 包裹主体内容；
- 键盘弹起适配：必须考虑 `resizeToAvoidBottomInset`，确保输入框不被键盘挡住。

### 7.6 强制边缘安全区（Safe Area）

- 所有页面的最外层根节点必须使用 `SafeArea` 包裹；
- 确保内容不被刘海屏、灵动岛、挖孔、底部 Home Indicator 遮挡。

### 7.7 图片自适应

- 所有 `Image` 必须提供 `fit: BoxFit.cover` 或 `BoxFit.contain`（按业务需求）；
- 外层必须有限制宽高的容器（可用 `AspectRatio`）；
- 严禁未限定尺寸的图片组件导致布局坍塌。

---

## 九、生命周期与异步安全

### 9.1 State 生命周期

- `StatefulWidget` 的 `initState` 只做初始化，不发起会阻塞首帧的重活；
- `AnimationController`、`TextEditingController`、`ScrollController`、
  `StreamSubscription`、`Timer`、`FocusNode` 必须在 `dispose` 中释放；
- 禁止在 `build` 中创建 Controller、发起请求、读写存储、订阅流；
- 需要“首帧之后”执行一次的逻辑用 `WidgetsBinding.instance.addPostFrameCallback`，
  并注意回调里判断 `mounted`。

### 9.2 BuildContext 与异步

- `await` 之后使用 `context` 前必须判断 `if (!mounted) return;`；
- 不在异步回调里持有旧的 `BuildContext` 跨页面使用；
- 页面销毁后禁止 `setState`；
- 导航、SnackBar、Dialog 等副作用放在事件回调或 `ref.listen`，不写在 `build`。

### 9.3 热重载与状态

- 热重载会保留 State，字段不会重新初始化；修改 `initState` 逻辑后要用热重启（R）；
- 依赖全局单例/缓存的逻辑，要能在热重启后恢复；
- 调试时区分 Hot Reload（保留状态）与 Hot Restart（重置状态）。

### 9.4 检查清单

- [ ] 所有 Controller / Subscription / Timer 是否 dispose？
- [ ] 异步后是否判断 mounted？
- [ ] build 中是否没有网络、存储、Controller 创建？
- [ ] 首帧后逻辑是否用 postFrameCallback 且判断 mounted？

---

## 十、性能与渲染预算

### 10.1 帧预算

- 60Hz：16.7ms/帧；120Hz：8.3ms/帧；
- 用 Flutter DevTools 的 Performance / Frame Chart 看 UI 与 Raster 时间；
- 性能问题必须在 **profile / release** 模式验证，debug 模式不作为依据。

### 10.2 布局与重建

- 能 `const` 的 Widget 全部 `const`；
- 用 `ref.watch(provider.select(...))` 精确订阅，避免整页重建；
- 大列表用 `ListView.builder` / `SliverList`，禁止 `Column(children: 大列表)`；
- 列表项尺寸固定时用 `itemExtent` / `prototypeItem`；
- 重绘区域用 `RepaintBoundary` 隔离（动画、模糊、大图列表项）。

### 10.3 昂贵效果

- `BackdropFilter`、`saveLayer`、`ClipRRect`、大面积阴影、`Opacity` 都是高开销；
- 能静态就不要每帧动画；能一次绘制就不要每帧重建；
- 模糊/透明层不要覆盖整屏；优先局部、固定区域。

### 10.4 图片与资源

- 列表缩略图必须限制解码尺寸（`cacheWidth` / `cacheHeight`）；
- 网络图统一 `cached_network_image`，磁盘/内存缓存策略明确；
- 大图避免原图解码；WebP/AVIF 按平台选择；
- 大 JSON / 重计算用 `compute` / Isolate，不阻塞 UI 线程。

### 10.5 启动与包体积

- 启动阶段不做同步重活；
- 图标 tree-shake、按需 deferred components；
- Android 拆分 ABI，发布用 App Bundle；
- 用 `flutter build appbundle --analyze-size` 审计体积。

### 10.6 Web 专项

- 首包（CanvasKit/wasm）与字体子集要评估；
- service worker 缓存策略明确（开发环境可关闭）；
- 首屏要有 skeleton，避免白屏；
- 文本选择、滚动、浏览器前进后退要专项测试。

---

## 十一、测试（含 Golden 设计还原）

### 11.1 测试分层

| 层级 | 范围 | 工具 |
|---|---|---|
| Unit | Repository / Notifier / 纯函数 | `flutter_test` |
| Widget | 四态、交互、Key、布局 | `flutter_test` |
| Golden | 像素级设计还原 | `golden_toolkit` / 原生 golden |
| Integration | 真机关键链路 | `integration_test` |

### 11.2 强制要求

- 每个网络页面至少覆盖 Loading / Error / Empty / Success 四态；
- Repository 必须可替换为 Fake，不在测试里打真实网络；
- Mock 使用 `mocktail`，禁止 mock Dio 内部实现；
- 交互测试通过 `Key` 定位，不靠文本硬匹配；
- 设计还原用 **Golden 测试**：固定字体、固定尺寸、固定主题，截图与设计稿并排比对。

### 11.3 CI 门槛

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Golden 测试需固定环境（字体、DPR、平台），否则会误报。

---

## 十二、导航 / 深链 / 状态恢复

### 12.1 路由

- 统一使用 `go_router`；
- ShellRoute 承载底部 dock / 侧栏，子路由承载页面；
- 路由名、路径统一常量，禁止散落字符串；
- 禁止 `Navigator.push` 做业务页面跳转。

### 12.2 深链与返回

- Universal Link / App Link 统一在 router 配置；
- Android 预测性返回、iOS 侧滑返回、Web 前进/后退都要测；
- 返回栈要符合直觉：详情 → 列表 → 退出，不能一键退出 App；
- Web 路由要能直接刷新访问，不能 404。

### 12.3 守卫与状态恢复

- 登录/演示模式守卫放 `redirect`，不写在页面 `initState`；
- 进程被杀后的恢复用 `restorationScopeId` + 可序列化状态；
- 路由参数、查询参数统一解析，不在页面里手拼。

---

## 十三、安全与日志脱敏（原建议第 14 项）

### 13.1 存储

- Token、密码、密钥必须使用 `flutter_secure_storage`；
- 禁止明文写入 `SharedPreferences`、文件、日志；
- 退出登录必须清理安全存储与内存缓存。

### 13.2 代码与构建

- 禁止把密钥写进源码、assets、示例配置；
- 不要用提交到仓库的 `--dart-define` 存放生产密钥；
- Release 构建使用 `--obfuscate --split-debug-info`；
- 依赖做许可证与漏洞审计。

### 13.3 日志

- 使用 `logger`，禁止 `print`；
- 日志必须脱敏：token、手机号、聊天内容、图片 URL 中的隐私参数；
- Release 只保留必要级别日志；
- 崩溃上报（Crashlytics/Sentry）配置脱敏与采样。

### 13.4 网络与 WebView

- 全站 HTTPS；按业务等级考虑证书校验；
- WebView 限制导航域、禁止任意 JS 注入；
- 深链参数做校验，防止越权跳转。

---

## 十四、提交前自检清单

- [ ] 是否按 `features/xxx/{presentation,domain,data}` 分层？
- [ ] 是否通过 Repository 访问数据，而不是 UI 直连网络？
- [ ] 是否有 `ApiResponse<T>`、拦截器、`api_endpoints`？
- [ ] 是否使用 Riverpod 管理状态，并覆盖 Loading / Error / Empty / Success？
- [ ] 单个 `build` 是否 ≤ 80 行？
- [ ] 是否避免 `Container` 套 `Container` / `Padding` 套 `Padding`？
- [ ] 主要结构块是否有 `Key('xxx')`？
- [ ] 颜色 / 字号 / 圆角 / 间距是否来自 `AppColors` / `AppTextStyles` / `AppSpacing`？
- [ ] 公共组件是否在 `shared/widgets/`？
- [ ] 页面跳转是否走 `go_router`？
- [ ] 敏感信息是否使用 `flutter_secure_storage`？
- [ ] 是否使用 `logger`，没有 `print`？
- [ ] 是否存在写死的 width / height / padding / margin / fontSize？
- [ ] Row/Column 中可能溢出的内容是否用 Expanded / Flexible / Wrap 包裹？
- [ ] 是否按 <600 / 600–900 / ≥900 实现了断点分支？
- [ ] 所有 Text 是否设置 maxLines + overflow？
- [ ] 页面主体是否可滚动，并处理键盘弹起？
- [ ] 根节点是否使用 SafeArea？
- [ ] 所有 Image 是否设置 fit + 受限容器？
- [ ] Controller / Subscription / Timer 是否 dispose，异步后是否判断 mounted？
- [ ] 是否用 const、select、builder 列表控制重建？
- [ ] 是否用 Golden 测试覆盖关键页面设计还原？
- [ ] 路由是否走 go_router，深链/返回/刷新是否验证？
- [ ] 敏感信息是否只在 secure storage，日志是否脱敏？

---

### Golden 基准

- `test/golden/today_body_golden_test.dart`
- `test/golden/goldens/today_body_portrait.png`
- `test/goldens/tablet_world.png`（1024×768 平板主画面）

## 十五、当前项目迁移状态（持续更新）

> 规范已生效；历史代码尚未全部合规，按阶段迁移，不允许新代码继续违规。

| 阶段 | 内容 | 状态 |
|---|---|---|
| Phase 0 | `core/theme`、`shared/widgets` 骨架 | 已完成（theme + 7 个共享组件） |
| Phase 1 | Dio 网络层、拦截器、`ApiResponse<T>`、`api_endpoints` | 已完成（业务层尚未迁移） |
| Phase 2 | 「今天」Clean Architecture 试点（Riverpod + 四态 + 组件拆分） | 已完成（TodayPageData/TodayBody，build 53 行） |
| Phase 3 | 朋友圈 / 日记 / 他 迁移 + UI 组件下沉 | 已完成（所有二级页均已接 Provider 四态） |
| Phase 4 | `go_router` 收口、`flutter_secure_storage`、`logger`、旧 API 清理 | 已完成（`core/api.dart` 已删除） |

### 已知历史违规（迁移时处理）

- `features/today/presentation/today_view.dart`：build 已压到 53 行，剩余是其他页面历史代码；
- `features/home/home_page.dart`：仍承担布局与状态编排，可继续拆分；
- 全局样式常量分散在 `core/theme.dart`、`core/ui.dart`，未拆成 `AppColors/AppTextStyles/AppSpacing`；
- 大量写死 `width` / `height` / `fontSize` / `padding`，断点逻辑集中在少数页面；
- 部分页面根节点未使用 `SafeArea`，图片未统一 `fit` 与受限容器。

---

*最后更新：2026-11-03*

---

## 十六、收尾状态（第 60 轮）

- 旧 `core/api.dart` 已删除，全部页面走 Repository/Provider
- 业务代码中 `Color(0x...)` = 0；全部颜色集中在 `AppColors`
- 业务代码中 `fontSize: 数字` = 0；仅 `core/theme.dart` TextTheme 保留 7 处令牌源
- 未使用依赖已移除：`http`、`cached_network_image`、`intl`、`cupertino_icons`
- 死代码已删除：`core/sse.dart`、`shared/widgets/app_skeleton.dart`
- 测试：29 个（含 Golden、聊天发图、共享四态、TodayTimeline 四态、Today 滚动）
- 构建：`flutter build apk --release` 通过

### 能力闭环

- 拍照/相册：`CameraService` + `PhotoSourceSheet`
- 聊天发图：`POST /chat` 的 `images`（data URL / base64，≤4 张，单张 ≤8MB）
- 图片预览：确认后以本地缩略图立即入气泡，同时发送给后端
- 已在模拟器用相册图片完成「选择 → 确认 → 发送 → 气泡 → 演示回复」闭环
- 相机 Intent 可正常拉起系统相机；模拟器无真实相机预览/快门，拍摄环节需真机验收
- 平板浮层已改实底并补关闭按钮，避免与底层标题重影

### 移动端底部栏（硬约束）

- 内容区域全屏，滚动内容从底部 dock 下方穿过
- 列表底部留出 dock 高度 + 安全区，保证最后一项能滚到 dock 上方
- 页面不再用 `bottom: kDockReserve` 切割内容视口
- dock 是覆盖层：`Positioned` + 半透明玻璃，永远不参与内容布局
- 全项目禁止再引入 `kDockReserve` 式视口切割
- 回归测试：`test/home_scroll_test.dart`、`test/today_scroll_test.dart`

### 已知风险

- `TabletWorld` 原文件曾被误覆盖，现为按接口重建版；已在 2000×1200 平板模拟器验收并补上四段导航，视觉仍可继续打磨。
