# 笨笨 Flutter

一个新的 Flutter 展示层，按 `docs/FLUTTER_ENGINEERING_GUIDELINES.md` 重建。

## 当前状态

- 新工程在 `benben_flutter/`
- 旧的 `benben_app/` 暂未删除（目录被进程占用，无法改名/删除）
- 当前是 **UI 展示层**，数据来自 demo fixture
- 后端接口、通知、语音/通话按 `docs/BENBEN_PLAYABILITY_PLAN.md` 后续接入

## 结构

```text
lib/
├── core/
│   ├── theme/          # AppColors / AppTextStyles / AppSpacing / AppRadius
│   ├── responsive/     # context.r / context.sp / 断点
│   ├── router/         # go_router
│   └── ...
├── shared/
│   ├── widgets/        # GlassPanel / Dock / FadeMask / ScreenHeader
│   └── models/
├── features/
│   ├── today/
│   ├── moments/
│   ├── diary/
│   ├── profile/
│   ├── chat/
│   ├── shell/
│   └── tablet/         # 电影感平板界面
```

## 运行

```bash
flutter pub get
flutter run
```

## 校验

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## 设计原则

- 手机：单列 + 底部 dock
- 平板：电影感全屏 + 顶部导航 + 右侧聊天浮层
- 单一笨笨、单一人生，没有角色/实例切换
- 视觉对齐 `web_preview/react_preview`
- 不在 UI 内写业务逻辑
