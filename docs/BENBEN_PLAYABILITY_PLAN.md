# 笨笨 App：可玩性改造与后端接口方案

> 日期：2026-11-03  
> 架构前提：**前端只负责展示，后端负责全部游戏逻辑。**  
> 本文不是视觉稿，而是前后端必须共同遵守的产品/接口契约。  
> 现有参考：<code>benben_app/docs/KEYSTONE_BACKEND_PRODUCT_SPEC.md</code>

---

## 0. 结论

现在的 App 有氛围、有角色、有生活细节，但还不算“好玩”。

原因不是 UI 不够，而是：

> **他发来消息之后，世界没有继续。**

真正的可玩闭环必须由后端完成：

~~~text
后端：他自己遇到事
  ↓
后端：他自己形成打算
  ↓
后端：他主动找用户
  ↓
前端：展示通知，用户进入聊天
  ↓
用户：自由回复
  ↓
后端：他理解、权衡、决定
  ↓
后端：状态/关系/日记/世界发生变化
  ↓
后端：第二天出现新的局面
  ↓
前端：只负责把结果展示出来
~~~

前端不能决定：

- 他什么时候找用户
- 他遇到什么事
- 他听不听
- 他第二天怎么样
- 日记写什么
- 通知什么时候出现

这些全部属于后端。

---

## 1. 可玩性判断

### 1.1 现在成立的部分

- 单一笨笨、单一人生的设定成立
- 角色生活细节有可信度
- 主动找用户比“每日任务”高级
- 日记 / 朋友圈 / 今天有观察价值
- 平板电影感界面已经足够

### 1.2 现在缺失的部分

| 缺失 | 后果 |
|---|---|
| 后端没有产品级通知 | 用户不知道他找过自己 |
| 主动消息没有持久化/未读 | 刷新即丢，无法形成期待 |
| 用户回复后没有后续 | 对话是死胡同 |
| 他的决定没有状态依据 | 听起来像固定台词 |
| 没有第二天的后果 | 世界不连续 |
| 关系/记忆不可见 | 用户不知道自己的话有没有用 |
| 没有等待/悬念 | 没有任何理由第二天回来 |

### 1.3 目标体验

不是“替笨笨做选择”，也不是“刷内容”。

而是：

> **他在那边生活，遇到事会来找我；我说的话可能影响他，但他自己做决定；第二天我能看见结果。**

核心情绪：

- 被想起
- 好奇
- 牵挂
- 影响了一个人
- 想知道后来怎么样了

---

## 2. 游戏循环（后端拥有）

### 2.1 主循环

~~~text
事件生成
  ↓
他形成自己的打算
  ↓
他决定是否找用户
  ↓
通知 / 消息
  ↓
用户自由回复
  ↓
他理解并权衡
  ↓
他做决定（可能听，也可能不听）
  ↓
世界状态 / 关系 / 记忆 / 日记变化
  ↓
时间推进
  ↓
新事件
~~~

### 2.2 禁止的前端逻辑

- 前端定时器决定通知出现
- 前端本地注入“他发来的消息”
- 前端根据关键词伪造他的回复
- 前端提供三选一让用户替他决定
- 前端计算关系、健康、后果
- 前端本地写日记
- 前端把静态 mock 当成真实流程

### 2.3 允许的前端逻辑

- 打开哪个 tab / sheet
- 输入框草稿
- 滚动位置
- loading / empty / error / offline
- 用户消息的本地乐观显示 + 失败回滚
- 服务端事件的展示顺序

---

## 3. 职责边界

| 能力 | 后端 | 前端 |
|---|---|---|
| 时间/世界推进 | 拥有 | 只展示 |
| 他遇到什么事 | 拥有 | 只展示 |
| 他的打算 | 拥有 | 只展示 |
| 是否主动找用户 | 拥有 | 只展示通知 |
| 通知创建/未读 | 拥有 | 展示、回传已读 |
| 对话生成 | 拥有 | 发送输入、渲染流 |
| 他听不听 | 拥有 | 只展示结果 |
| 关系/记忆 | 拥有 | 展示变化 |
| 日记生成 | 拥有 | 展示 |
| 朋友圈生成 | 拥有 | 展示、点赞、留言 |
| 第二天状态 | 拥有 | 重新拉快照 |
| 登录/session | 拥有 | 保存 id |
| 设备推送 token | 接收 | 注册/上报 |

---

## 4. 后端改造总览

### 4.1 可复用的现有能力

- 会话/记忆/知识库
- 人生模拟器 <code>life_sim</code>
- 栖湾世界 <code>life_world</code>
- 注意力/主动行为 <code>attention</code>
- WS 事件流 / SSE 对话
- 日记/朋友圈/关系/承诺/家当
- 权限/审批/多模态
- 角色状态/多实例（仅后端，不暴露给 App）

### 4.2 需要新增的产品层

后端目前更像“观测台 API + agent API”，需要增加 **App BFF / 产品事件层**。

建议新增：

~~~text
GET  /api/app/bootstrap
GET  /api/app/snapshot
GET  /api/app/notifications
POST /api/app/notifications/read
GET  /api/app/events          （WS 或 SSE）
GET  /api/app/chat/messages
POST /api/app/chat
GET  /api/app/moments
GET  /api/app/moments/:id
POST /api/app/moments/:id/like
POST /api/app/moments/:id/comments
GET  /api/app/diary
GET  /api/app/profile
POST /api/app/push-token
POST /api/app/voice/transcribe
GET  /api/app/voice/messages/:id
POST /api/app/calls
POST /api/app/calls/:id/accept
POST /api/app/calls/:id/decline
POST /api/app/calls/:id/end
GET  /api/app/calls/:id
WS   /api/app/calls/:id/signal
~~~

> 也可以保留现有 <code>/api/life</code>、<code>/chat</code> 作为底层，由 BFF 聚合成 App 契约。  
> App 不直接消费观测台原始事件。

---

## 5. 后端领域模型

### 5.1 CompanionState

~~~json
{
  "id": "benben",
  "display_name": "笨笨",
  "day": 5,
  "phase": "evening",
  "awake": true,
  "place": "旧书店",
  "action": "收书",
  "health": 0.62,
  "energy": 0.55,
  "mood": "quiet",
  "condition": "slight_fever",
  "money_cents": 145250,
  "current_intention": "撑到关门，明天再去诊所"
}
~~~

### 5.2 Relationship

~~~json
{
  "trust": 0.64,
  "closeness": 0.58,
  "respect": 0.71,
  "last_interaction_at": "2026-11-02T18:40:00+08:00",
  "unresolved": true
}
~~~

### 5.3 Event / Dilemma

~~~json
{
  "id": "evt_20261102_fever",
  "type": "health",
  "status": "awaiting_reply",
  "title": "他今天没去开门",
  "summary": "早上淋了雨，下午一直趴在柜台上。",
  "his_intention": "撑到关门，明天再去诊所",
  "created_at": "2026-11-02T18:40:00+08:00",
  "due_at": "2026-11-02T21:00:00+08:00",
  "notification_id": "ntf_..."
}
~~~

### 5.4 Notification

~~~json
{
  "id": "ntf_20261102_1840",
  "kind": "proactive_message",
  "title": "笨笨",
  "body": "今天有点不舒服，店里刚进的书还没理完。要不我撑到关门？",
  "created_at": "2026-11-02T18:40:00+08:00",
  "read": false,
  "conversation_id": "default",
  "event_id": "evt_20261102_fever",
  "deep_link": "/chat"
}
~~~

规则：

- 只有后端可以创建通知
- 用户在聊天中时，可以只入聊天不弹通知
- 用户不在时，创建通知并计入未读
- 用户已读后回传服务端
- 通知和消息必须可追溯

### 5.5 Memory / Advice

~~~json
{
  "id": "mem_...",
  "kind": "advice",
  "text": "她那天让我先去看病",
  "source_event_id": "evt_...",
  "created_at": "...",
  "weight": 0.8
}
~~~

用于：

- 他之后的日记
- 他聊天时提起
- 他下次是否更愿意听
- 不是用户可见的“好感度数字”

---

## 6. 后端事件契约

建议 App 只消费稳定的产品事件：

### 6.1 WS 事件

~~~json
{
  "seq": 123,
  "ts": 1760000000000,
  "type": "notification.created",
  "data": { "notification": { } }
}
~~~

事件类型：

| type | 用途 |
|---|---|
| notification.created | 他主动找用户 |
| chat.message | 新消息 / 主动消息写入历史 |
| chat.typing | 他正在输入 |
| chat.done | 本轮结束 |
| companion.updated | 位置/身体/心情/打算变化 |
| relationship.updated | 关系变化 |
| diary.created | 新日记 |
| moment.created | 新朋友圈 |
| event.resolved | 某件事有了结果 |
| voice.message.created | 他发来一条语音 |
| call.incoming | 他打来语音/视频电话 |
| call.accepted | 通话接通 |
| call.ended | 通话结束 |
| call.missed | 未接来电 |
| call.transcript | 通话转写更新 |

前端按 seq 断线重连，按 session 过滤。

### 6.2 SSE 对话

用户主动发送消息时仍用 SSE：

| event | data |
|---|---|
| delta | 增量文本 |
| tool_start | 工具开始（普通用户可隐藏） |
| tool | 工具预览 |
| done | 完整回复 |
| error | 可重试错误 |

后端生成他的回应；前端只渲染。

---

## 7. 后端接口草案

### 7.1 GET /api/app/bootstrap

一次返回首屏：

~~~json
{
  "session": { "id": "...", "display_name": "笨笨" },
  "companion": { },
  "relationship": { },
  "today": { "events": [], "diary": null },
  "notifications": { "unread": 1, "items": [] },
  "last_seen_at": "..."
}
~~~

### 7.2 GET /api/app/notifications

~~~text
GET /api/app/notifications?after=<seq>&limit=30
~~~

~~~json
{
  "items": [ ],
  "next": 124,
  "unread": 1
}
~~~

### 7.3 POST /api/app/notifications/read

~~~json
{ "ids": ["ntf_..."] }
~~~

### 7.4 GET /api/app/chat/messages

~~~text
GET /api/app/chat/messages?before=<id>&limit=50
~~~

返回历史，包括他主动发的消息。  
现有 <code>/api/history</code> 可复用，但需要补齐主动消息来源、时间和未读。

### 7.5 POST /api/app/chat

~~~json
{ "text": "先去看病，书明天再理。" }
~~~

返回 SSE。  
后端负责：

- 读记忆/关系/事件
- 理解用户的话
- 决定他的回应
- 决定他的行动
- 更新状态
- 写日记
- 安排第二天

### 7.6 GET /api/app/events

WS：

~~~text
/api/app/events?session=<id>&since=<seq>&token=<token>
~~~

### 7.7 朋友圈

~~~text
GET  /api/app/moments?cursor=
GET  /api/app/moments/:id
POST /api/app/moments/:id/like
POST /api/app/moments/:id/comments
~~~

### 7.8 日记 / 资料

~~~text
GET /api/app/diary?cursor=
GET /api/app/diary/:id
GET /api/app/profile
~~~

---

## 8. 后端如何决定“他听不听”

这不是前端逻辑，而是后端 agent 的一部分。

建议他的决策输入：

- 当前身体/心情
- 当前打算
- 对用户的信任
- 他的自主性
- 用户这句话的方式（关心/命令/说教/陪伴）
- 过去类似建议的结果
- 当前事件压力

输出：

- 他听到什么
- 他怎么理解
- 他决定做什么
- 他怎么说
- 他记住什么

要求：

- 不能永远顺从
- 不能随机反着来
- 不能脱离他的人设和当天状态
- 听不听都要有原因
- 不听也要继续生活，而不是游戏失败

---

## 9. 时间、通知与“第二天”

### 9.1 时间

后端拥有世界时钟和生活 tick。

- 事件按世界时间触发
- 用户离开后，世界继续
- 第二天由后端推进
- 前端只展示快照

### 9.2 通知

- 后端创建 notification
- App 在前台：WS 推送
- App 在后台：APNs / FCM / PWA Push
- 前端只负责注册 token 和展示
- 通知点击 → deep link 到聊天/事件

### 9.3 未读

- 后端维护 read/unread
- 前端进入聊天后回传已读
- 刷新/换设备后未读仍正确

### 9.4 忽略

用户不点通知、不回复：

- 事件不能永远挂起
- 到 due_at 后后端自行推进
- 他按自己的性格处理
- 产生后果、日记、第二天状态
- 不要求用户“必须在线”

---

## 10. 前端改造方案

### 10.1 原则

前端只做三件事：

1. 拉取服务端快照
2. 订阅服务端事件
3. 发送用户动作

### 10.2 要删除的前端逻辑

- <code>useProactiveChat</code> 的本地注入
- 1.6 秒通知计时器
- <code>proactiveChat</code> 本地开关
- 本地点赞/留言直接改 UI 真相
- 静态 <code>data.ts</code> 作为真实数据源
- 任何“替他决定”的 UI

### 10.3 新前端结构

~~~text
src/
  data/
    apiClient.ts        // HTTP
    eventStream.ts      // WS/SSE
    snapshotStore.ts    // 服务端状态缓存
    types.ts            // 契约类型
  hooks/
    useBootstrap.ts
    useAppEvents.ts
    useChat.ts
    useNotifications.ts
  screens/
    ...
~~~

状态原则：

- 服务端是唯一真相源
- 前端 store 只是缓存
- 用户消息可以乐观显示，失败回滚
- 所有世界状态以后端返回为准

### 10.4 通知

- 由 <code>notification.created</code> 驱动
- 前台显示顶部横幅
- 未读显示角标
- 点击 → 聊天
- 已读 → POST
- 不自己 setTimeout

### 10.5 聊天

- 历史从后端拉
- 用户输入 → POST
- 回复 → SSE
- typing 状态由后端事件驱动
- 没有选项按钮
- 没有前端伪造回复
- 发送失败可重试

### 10.6 今天 / 平板场景

保留现有电影感布局，只换数据源：

- companion 状态
- 今天事件
- 关系/未读
- 日记/朋友圈

平板只是另一种渲染，不跑另一套逻辑。

### 10.7 设计预览模式

现有静态数据保留，但只放在：

~~~text
?preview=1
~~~

或独立的 design fixture。

不能把 fixture 当生产数据。

---

## 11. 前端“可玩性”具体改什么

前端不产生玩法，但可以决定玩法是否被感知。

### 11.1 通知

- 从顶部进入，不抢焦点
- 显示“他找过你”的时间
- 未读保留，不点不消失
- 点开进入聊天

### 11.2 聊天

- 正常输入，不提供选项
- 他说话时有 typing
- 用户消息发送中/失败/重试
- 历史从服务端恢复

### 11.3 今天

- 展示“你不在时发生的变化”
- 新日记/新朋友圈有标记
- 他的身体/心情变化可见
- 不展示“任务进度”

### 11.4 日记

- 新日记到达时提示
- 打开后能看到他当天的真实想法
- 不前端拼故事

### 11.5 平板

- 保留电影感
- 右侧聊天浮层
- 通知从顶部进入
- 数据与手机同源

---

## 12. 改造优先级

### P0：跑通闭环

1. 后端 notification 表 + 主动消息持久化
2. 后端在 proactive 轮次创建通知
3. 后端事件契约 + WS
4. 前端删掉本地通知/本地消息注入
5. 前端接 bootstrap + chat history + SSE
6. 用户自由回复后，后端生成回应并落状态
7. 后端生成当天日记 / 第二天状态

### P1：体验完整

8. 未读/已读
9. 忽略通知后的后端自行推进
10. 关系/记忆在聊天和日记中体现
11. 日记/朋友圈分页
12. 手机/平板统一数据层

### P2：增强

13. 原生推送
14. 多设备已读同步
15. 更丰富的事件类型
16. 更长期的关系变化
17. 语音消息
18. 语音通话
19. 视频通话

---

## 13. 验收标准

### 后端

- 能在他主动说话时创建 notification
- 通知可持久化、可未读、可已读
- 用户不在时，事件仍能按 due_at 推进
- 用户自由回复后，他生成自己的回应
- 他的决定能改变状态/日记/第二天
- 所有 App 数据都有 session 隔离
- WS 断线可补发

### 前端

- 通知出现不依赖前端计时器
- 刷新后未读仍正确
- 聊天历史来自后端
- 没有选项按钮
- 发送失败可重试
- 后端不可用时显示 unavailable，不伪造数据
- 手机/平板看到的是同一份状态

### 体验

- 用户第二天有理由回来
- 用户能说出“我昨天说的话改变了他什么”
- 他能听，也能不听
- 不听时故事继续，而不是失败

---

## 14. 语音消息（异步）

### 14.1 定位

语音消息是“他发来一段话”，不是实时通话。

后端负责：

- 决定发不发语音
- 写什么
- 用什么语气
- 合成音频
- 存储媒体
- 创建消息/通知

前端只负责：

- 展示语音气泡
- 播放/暂停
- 显示时长
- 可选显示转写文字

### 14.2 消息模型

~~~json
{
  "id": "msg_voice_...",
  "kind": "voice",
  "conversation_id": "default",
  "sender": "companion",
  "media": {
    "url": "/media/voice/....m4a",
    "format": "m4a",
    "duration_ms": 8400,
    "waveform": [0.1, 0.4, 0.7, 0.3]
  },
  "transcript": "今天有点不舒服，店里刚进的书还没理完……",
  "created_at": "2026-11-02T18:40:00+08:00",
  "event_id": "evt_..."
}
~~~

### 14.3 API

~~~text
POST /api/app/voice/transcribe
  multipart audio
  -> { text, confidence }

GET /api/app/voice/messages/:id
  -> voice message

GET /api/app/media/:id
  -> 带鉴权的媒体
~~~

后端内部还应有：

~~~text
POST /internal/voice/synthesize
  text + persona + emotion
  -> audio asset
~~~

这个接口不暴露给 App。

### 14.4 生成流程

~~~text
事件/日记/聊天上下文
  ↓
后端决定：发文字，还是发语音
  ↓
后端 TTS（人格、情绪、语速）
  ↓
媒体存储
  ↓
消息写入会话
  ↓
通知 / WS 事件
  ↓
前端播放
~~~

### 14.5 规则

- 前端绝不做 TTS
- 语音失败必须降级为文字
- 语音消息也必须可追溯、可已读
- 所有媒体按 session 隔离
- 用户语音输入由后端转写，前端不猜文字
- 语音可以带情感，但不能改变事实

---

## 15. 语音通话与视频通话

### 15.1 定位

通话是后端能力的延伸，不是前端计时器：

> **后端判断“他现在想给你打电话”，前端只负责显示来电和媒体。**

### 15.2 两种模式

| 模式 | 内容 |
|---|---|
| 语音通话 | 实时音频，像电话 |
| 视频通话 | 实时音频 + 他的角色形象画面 |

**边界说明：**

视频通话不是“真人摄像头”。

他的画面可以来自：

- Live2D / 3D 角色渲染
- 预生成的视频片段
- 静态立绘 + 口型/表情

后端负责画面状态；前端只接收视频轨。

### 15.3 通话状态机

~~~text
idle
  ↓
ringing
  ├── accepted → active → ended
  ├── declined → ended
  └── timeout → missed
~~~

状态全部在后端维护。

### 15.4 API

~~~text
POST /api/app/calls
{ "mode": "audio" | "video" }
-> {
  "call_id": "...",
  "mode": "audio",
  "state": "ringing",
  "signaling_url": "wss://.../api/app/calls/.../signal",
  "ice_servers": [],
  "expires_at": "..."
}

POST /api/app/calls/:id/accept
POST /api/app/calls/:id/decline
POST /api/app/calls/:id/end
GET  /api/app/calls/:id

WS /api/app/calls/:id/signal
  -> offer / answer / ice / mute / camera / end
~~~

### 15.5 后端职责

- 决定是否发起通话
- 创建 call 记录
- 推 incoming call 通知
- 维护 ringing / accepted / active / ended / missed
- STT：把用户语音转成文字
- VAD：判断用户是否在说、何时说完
- LLM：生成他的实时回应
- TTS：把回应变成语音流
- 支持打断（barge-in）
- 把通话转写、情绪、关键句写入记忆
- 通话结束生成摘要/日记
- 未接来电生成通知或后续消息

### 15.6 视频通话

后端需要额外能力：

- 角色画面状态（表情、口型、动作）
- 视频轨生成或播放器
- 音频/视频同步
- 网络差时降级为静态画面 + 音频
- 最低可用：静态立绘 + 语音通话

前端不允许自己生成“他在说话”的画面。

### 15.7 媒体与延迟

目标：

- 语音回复首包延迟 < 1.5s
- 支持用户打断
- 弱网降级为语音，再降级为文字
- 通话中断可恢复/回拨

### 15.8 隐私与安全

- 麦克风/摄像头权限由用户授予
- 录制、转写、保存策略必须明确
- 通话内容和会话绑定
- 不允许跨 session
- 媒体访问需要鉴权
- 来电通知要能区分“他”和系统其他通知

---

## 16. 前端怎么展示语音与通话

### 16.1 语音消息

- 语音气泡：播放/暂停、时长、波形
- 可选展开转写
- 加载失败降级显示文字
- 通知可以显示“他发来一条语音”

### 16.2 来电

- 顶部/全屏来电 UI
- 接听 / 拒绝
- 显示是语音还是视频
- 未接来电进入通知中心
- 前端不判断是否该来电

### 16.3 通话中

- 语音模式：头像/名字/时长，静音、扬声器、挂断
- 视频模式：他的画面 + 小窗自己，麦克风、摄像头、挂断
- 通话状态、计时、网络状态都由后端事件驱动
- 前端不做语音识别、不做 TTS、不做对话生成

### 16.4 前端模块

~~~text
src/
  data/
    calls.ts        // 发起/接听/拒绝/结束
    voice.ts        // 语音消息、媒体播放
  hooks/
    useCall.ts      // 服务端通话状态
    useVoice.ts     // 服务端语音消息
  screens/
    IncomingCall.tsx
    ActiveCall.tsx
~~~

原则不变：

> 前端只展示和发送动作，通话业务全在后端。

---

## 17. 后端模块与分期

### 17.1 建议模块

| 模块 | 职责 |
|---|---|
| voice | TTS、STT、语音消息、媒体资产 |
| call | 通话状态机、WebRTC 信令、通话记录 |
| avatar | 角色画面/表情/口型/视频轨 |
| notification | 来电、语音消息、未接来电通知 |

可复用现有：

- LLM / 记忆 / 关系 / life_sim / life_world
- 媒体存储
- WS/SSE
- 权限/审批

### 17.2 分期

**P0：语音消息**

- 后端生成短语音
- 存媒体
- 写入聊天
- 前端播放

**P1：语音通话**

- 后端发起/接听/结束
- STT + LLM + TTS
- 通话转写、摘要、记忆
- 未接来电

**P2：视频通话**

- 角色画面
- 音视频同步
- 弱网降级
- 通话中的表情/口型

### 17.3 验收

- 语音消息刷新后仍在
- 前端不合成语音
- 来电由后端事件触发
- 拒绝/超时/挂断状态正确
- 通话内容进入记忆
- 通话结束有摘要/日记
- 弱网能降级
- 视频失败自动退回语音
- 手机/平板看到同一通话状态

## 18. 明确不做

- 前端游戏状态机
- 前端合成语音/视频
- 前端自建通话状态
- 前端模拟他的回复
- 前端决定通知时间
- 三选一 / 任务卡
- 替用户决定他的行动
- 用静态数据假装真实流程
- 把观测台原始事件直接暴露给 App
- 多角色/多实例切换

---

## 19. 一句话

**后端负责他为什么来、说什么、怎么决定、第二天怎样；前端负责让他被看见、被听见、被等待。**
