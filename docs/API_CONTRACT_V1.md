# App API Contract v1

> 状态：冻结提案  
> 适用：Flutter App ↔ business-api  
> 不适用：admin-api（后台单独契约）  
> 版本头：X-Contract-Version: 1  
> 原则：App 不直接依赖 agent_core 原始字段

---

## 1. 先定边界

agent_core 返回的是内部数据，包含：

- snake_case
- 原始 life/world 结构
- 内部事件字段
- 不稳定的 tool 细节

这些**不能直接给 App**。

数据链路必须是：

~~~text
agent_core 原始 JSON
      ↓
business-api adapter / mapper
      ↓
App API Contract v1（camelCase、稳定字段）
      ↓
Flutter DTO
~~~

兼容责任在 business-api，不在 App。

---

## 2. 通用规则

### 2.1 命名

- 对外字段统一 camelCase
- 枚举统一小写 snake_case 字符串
- 不把核心 snake_case 字段名直接透出

### 2.2 时间

- 时间戳统一 RFC3339，带时区
- 示例：2026-11-04T15:32:00+08:00
- 由后端接受并返回 Asia/Shanghai
- 只用于展示的 timeLabel 可以是 15:32，但业务判断用 occurredAt

### 2.3 空值

- 没有值：null
- 空列表：[]
- 不返回 undefined
- 新增字段必须可缺省，App 必须忽略未知字段

### 2.4 ID

- 所有 id 都是字符串
- 不保证是 UUID 以外格式，App 不得解析 id
- 游标 cursor 是不透明字符串，App 不得拆解

### 2.5 响应

单资源直接返回对象：

~~~json
{
  "id": "cmp_123",
  "displayName": "笨笨"
}
~~~

列表：

~~~json
{
  "items": [],
  "nextCursor": null
}
~~~

错误：

~~~json
{
  "code": "INSUFFICIENT_CREDITS",
  "message": "积分不足，无法开始这一轮",
  "requestId": "req_xxx",
  "details": {}
}
~~~

所有响应带：

~~~text
X-Request-Id
X-Contract-Version: 1
~~~

### 2.6 兼容策略

v1 内只允许**加字段**，不允许改名/改类型/改语义。

需要破坏性修改时：

- 新路径 /api/v2
- 或 X-Contract-Version: 2
- 旧版本保留至少一个客户端版本周期

App 遇到未知字段必须忽略，不得报错。

---

## 3. 认证

### POST /api/v1/auth/login

请求：

~~~json
{
  "email": "demo@benben.local",
  "password": "demo1234"
}
~~~

响应：

~~~json
{
  "accessToken": "jwt...",
  "expiresIn": 604800,
  "account": {
    "id": "acc_123",
    "email": "demo@benben.local"
  },
  "companion": {
    "id": "cmp_123",
    "displayName": "笨笨"
  }
}
~~~

说明：

- expiresIn 单位秒
- refreshToken 暂不启用；未来新增字段
- companion 必须在登录时返回，App 不另外猜名字

### POST /api/v1/auth/register

请求同上。

### GET /api/v1/auth/me

响应：

~~~json
{
  "account": {
    "id": "acc_123",
    "email": "demo@benben.local",
    "status": "active"
  },
  "companion": {
    "id": "cmp_123",
    "displayName": "笨笨",
    "version": 3,
    "profile": {},
    "syncStatus": "pending"
  }
}
~~~

---

## 4. 陪伴对象状态

### GET /api/v1/companion/state

替代当前直接透传的 /api/v1/core/life。

响应：

~~~json
{
  "contractVersion": 1,
  "companion": {
    "id": "cmp_123",
    "displayName": "笨笨",
    "day": 1,
    "place": {
      "id": "bookstore",
      "name": "旧书店"
    },
    "status": "awake",
    "condition": "",
    "awake": true,
    "energy": 0.8,
    "mood": 0.6,
    "satiety": 0.39,
    "social": 0.7,
    "transit": null,
    "lastActiveAt": "2026-11-04T15:32:00+08:00"
  },
  "world": {
    "available": true,
    "clockLabel": "15:32",
    "weather": "小雪",
    "temperatureC": 1.7,
    "season": "autumn",
    "dayOfWeek": 3
  },
  "events": [
    {
      "id": "evt_1",
      "occurredAt": "2026-11-04T15:32:00+08:00",
      "timeLabel": "15:32",
      "title": "收书",
      "detail": "把晒了一下午的旧书收回来。",
      "feeling": "安静",
      "sourceEventId": "core_evt_1"
    }
  ],
  "people": [
    {
      "id": "npc_lin",
      "name": "林叔",
      "role": "旧书店掌柜",
      "note": "今天见过",
      "place": "旧书店",
      "lastSeenDay": "2026-11-04"
    }
  ],
  "items": [
    {
      "id": "item_1",
      "kind": "clothing",
      "name": "厚毛衣",
      "note": "",
      "place": "home"
    }
  ],
  "diary": null
}
~~~

字段约定：

- energy / mood / satiety / social：0 到 1 的浮点数
- status：awake / asleep / transiting / busy / quiet
- place.id 可为空，但 place.name 必须有
- transit：null 或 { from, to, etaMinutes }
- events 按时间倒序或正序必须固定；建议从新到旧，并在契约中固定
- diary：null 或 { day, text }

**兼容旧路径**：

~~~text
GET /api/v1/core/life
~~~

保留一年，内部映射到同一个 DTO；App 新版本改用 /companion/state。

---

## 5. 朋友圈

### GET /api/v1/companion/moments?limit=20&cursor=xxx

响应：

~~~json
{
  "items": [
    {
      "id": "post_1",
      "author": {
        "type": "companion",
        "id": "cmp_123",
        "name": "笨笨"
      },
      "createdAt": "2026-11-04T15:32:00+08:00",
      "timeLabel": "15:32",
      "place": "旧书店",
      "text": "今天把后院的旧书搬出来晒，风一吹，纸页哗啦响。",
      "photos": [
        {
          "url": "https://api.example.com/media/post_1/1.jpg",
          "width": 1080,
          "height": 1440,
          "alt": "旧书"
        }
      ],
      "likes": [
        {
          "actorType": "npc",
          "name": "林叔"
        }
      ],
      "comments": [
        {
          "id": "comment_1",
          "author": {
            "type": "npc",
            "name": "林叔"
          },
          "text": "晒书记得翻面。",
          "createdAt": "2026-11-04T15:40:00+08:00",
          "timeLabel": "15:40"
        }
      ],
      "visibility": "public",
      "sourceEventId": "evt_1"
    }
  ],
  "nextCursor": null
}
~~~

字段约定：

- photos 0–9；没有就是 []
- author.type：companion / player / npc
- visibility：public / player_only / self_only
- sourceEventId 可空，但能追时必须给
- 图片 URL 必须由后端可访问，不能直接暴露 core 内网地址

**兼容旧路径**：

~~~text
GET /api/v1/core/life/feed
~~~

旧路径暂时保留。

---

## 6. 聊天 SSE

### POST /api/v1/chat

请求：

~~~json
{
  "message": "今天店里有什么小事？",
  "clientMessageId": "local_123"
}
~~~

Header：

~~~text
Authorization: Bearer <token>
Idempotency-Key: optional
Accept: text/event-stream
~~~

成功：

~~~text
HTTP 200
Content-Type: text/event-stream; charset=utf-8
~~~

### SSE 事件格式

所有 data 必须是 JSON，不能是裸字符串。

#### meta

~~~text
event: meta
data: {"requestId":"req_1","sessionId":"sess_1","turnId":"turn_1"}
~~~

#### delta

~~~text
event: delta
data: {"text":"嗯"}
~~~

#### tool

~~~text
event: tool
data: {"callId":"call_1","tool":"life","preview":"..."}
~~~

#### done

~~~text
event: done
data: {"text":"完整回复","requestId":"req_1","usage":{"promptTokens":0,"completionTokens":0,"totalTokens":0}}
~~~

usage 现在可以为 null 或零值；未来按 token 计费时再启用。

#### error

~~~text
event: error
data: {"code":"INSUFFICIENT_CREDITS","message":"积分不足","requestId":"req_1"}
~~~

### HTTP 错误

开流前：

~~~text
HTTP 402
{"code":"INSUFFICIENT_CREDITS","message":"积分不足","requestId":"req_1"}
~~~

HTTP 409：

~~~text
{"code":"DUPLICATE_REQUEST","message":"该请求已处理"}
~~~

### 兼容策略

旧版 core 事件：

~~~text
event: delta
data: 嗯
~~~

后端必须适配为 JSON：

~~~text
event: delta
data: {"text":"嗯"}
~~~

App 在迁移期可以同时兼容裸字符串和 JSON；新版本只认 JSON。

---

## 7. 积分

### GET /api/v1/credits/balance

响应：

~~~json
{
  "balance": 3,
  "reserved": 0,
  "available": 3,
  "updatedAt": "2026-11-04T15:32:00+08:00"
}
~~~

规则：

- App 用 available 判断能否聊天
- 不存在返回 0 也是合法状态
- 402 时 App 展示购买/补发入口

---

## 8. 错误码

| HTTP | code | 场景 |
|---|---|---|
| 400 | VALIDATION_ERROR | 参数不合法 |
| 400 | CONTRACT_VERSION_UNSUPPORTED | 客户端契约版本不支持 |
| 401 | AUTH_REQUIRED | 未登录 / token 过期 |
| 402 | INSUFFICIENT_CREDITS | 积分不足 |
| 403 | FORBIDDEN | 无权限 |
| 404 | COMPANION_NOT_FOUND | 账号没有角色 |
| 409 | DUPLICATE_REQUEST | 幂等键重复 |
| 409 | VERSION_CONFLICT | 角色编辑版本冲突 |
| 502 | CORE_UNAVAILABLE | agent_core 不可用 |
| 503 | CORE_TIMEOUT | agent_core 超时 |
| 500 | INTERNAL_ERROR | 未分类错误 |

错误响应的 message 必须可展示；内部堆栈不返回。

---

## 9. 旧实现 → 新契约的映射

| 旧 core / 当前字段 | 新 App 字段 | 说明 |
|---|---|---|
| place | companion.place.name | 结构化 |
| energy | companion.energy | 0..1 |
| mood | companion.mood | 0..1 |
| world.clock_label | world.clockLabel | camelCase |
| world.weather | world.weather | 原样 |
| events[].clock_min | events[].timeLabel | 后端格式化 |
| events[].detail | events[].detail | 原样 |
| people[].name | people[].name | 原样 |
| life_posts.photo_url | moments[].photos[].url | 必须后端代理 |
| next_before | nextCursor | 不透明 |
| SSE data 裸文本 | SSE data JSON | 后端适配 |
| core 原始 snake_case | camelCase DTO | 全部映射 |

---

## 10. 后端胶水层职责

business-api 必须新增/明确：

1. CompanionStateMapper
   - core /api/life -> CompanionStateDto
2. MomentMapper
   - core /api/life/feed -> MomentDto
3. ChatSseAdapter
   - core 裸 SSE -> 契约 JSON SSE
4. ErrorMapper
   - Dio/Nest/core 错误 -> ApiError
5. PaginationMapper
   - next_before -> nextCursor
6. MediaUrlMapper
   - core /media -> 业务可访问 CDN/代理 URL
7. ContractVersionInterceptor
   - 校验 X-Contract-Version，写响应头

App 不负责 core 字段兼容。

---

## 11. 迁移顺序

1. 冻结本契约
2. 后端先输出新 DTO，同时保留旧路径/旧 SSE 兼容
3. App 先兼容双格式（裸文本 + JSON data）
4. App 切 /companion/state 与 /companion/moments
5. 观察一个版本周期
6. 下线旧 /core 透传

---

## 12. 待确认

以下需要产品和后端一起拍板：

1. accessToken 是否要 refreshToken
2. media 是走业务代理还是对象存储 CDN
3. usage 何时由 core 提供
4. 游标格式用 opaque base64 还是时间戳
5. 朋友圈图片 0–9 的布局是否由 App 纯推断
6. 玩家发动态、visibility 是否本期就进契约
7. 角色编辑 API 的字段是否放进 /companion/state 或单独 /companion/edit

---

## 13. 一句话

**App 只认 v1 DTO；agent_core 原始数据只存在于后端内部。**  
以后 core 改字段，改 mapper，不改 App。
