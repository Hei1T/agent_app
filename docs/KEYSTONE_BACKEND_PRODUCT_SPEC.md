# keystone 后端能力清单与笨笨 App 对接规格

> 观察对象：<code>E:\agent_core</code>  
> 观察方式：只读源码、配置与文档；未修改后端。  
> 文档目的：说明后端真实做到了什么、App 该如何使用、哪些地方需要为了产品设计反向改后端。  
> 重要原则：本文不把 README 的宣传当成产品契约；接口字段以 <code>crates/keystone-bridge/src/http.rs</code> 与各插件实际序列化代码为准。

---

## 0. 先给结论

keystone 不是一个普通的聊天后端，而是一个**长期驻留的自主 agent 运行时**：

- 对 App 来说，它同时提供两套东西：
  1. **对话服务**：SSE 流式回复、工具执行状态、中断、附件、多轮历史；
  2. **角色生活数据**：他今天做了什么、在哪、心情/体力、朋友圈、日记、关系、承诺、家当、世界事件。
- 后端已经实现的东西，远多于当前 App 页面使用到的。
- 但后端目前更像“observatory API + agent API”，不是“App BFF”。很多接口是给观测台/调试用的，字段偏原始，App 设计需要的聚合、分页、图片上传、搜索、通知，后端还没有完全补齐。
- **当前最关键的契约问题**：后端要求所有业务请求带 <code>X-Session-Id</code>，且会话 id 必须由 <code>POST /api/sessions</code> 服务端铸造；当前 Flutter App 固定用 <code>default</code>，请求体里还传了后端不读的 <code>session_id</code>。这是 P0。
- 建议不要把 App 直接绑死在 <code>/api/life</code> 这些原始接口上，而是在后端补一层 **App BFF**（见 §10），把“角色一天”的多个数据源聚合成页面需要的形状。

---

## 1. 运行形态

### 1.1 进程

- Rust workspace，微内核 + 插件架构。
- 一个可执行文件同时承载：
  - HTTP 协议面；
  - WS 事件流；
  - 内嵌 React 观测台（构建产物嵌入二进制）；
  - 能力插件运行时；
  - 本地 SQLite / 向量库 / 文件资产。
- 运行期不依赖 Node。前端构建产物是编译期嵌入的。

### 1.2 当前本机配置中的实例

来自 <code>config.toml</code>：

| 实例 | 端口 | 角色 |
|---|---:|---|
| CEO / 主实例 | 8600 | 全量能力，主对话，世界/生活/注意力/组织 |
| 外部 webhook 面 | 8601 | <code>POST /webhook</code>，HMAC 签名，IM 桥用 |
| 小美员工实例 | 8602 | 客服型员工，白名单能力面 |
| 霸总员工实例 | 8603 | 角色扮演型员工 |

> App 默认连接 8600 即可；8601 是外部渠道入口，不是 App 主 API。

### 1.3 配置里已经开启的能力

<code>config.toml</code> 当前开启/配置了：

- LLM：<code>deepseek-flash</code>，100 万上下文窗口；
- <code>life_sim</code>：人生模拟器；
- <code>life_world</code>：栖湾世界引擎；
- <code>attention</code>：注意力/主动开口；
- <code>reality</code>：真实天气接入；
- <code>image</code> / <code>video</code>：生图/生视频；
- <code>web</code>：联网搜索/抓取；
- <code>im</code>：飞书通道；
- <code>org</code>：员工名单；
- <code>world</code>：项目/文件/端口/产物只读世界模型。

---

## 2. 认证、会话、错误模型

### 2.1 Base URL

- 本机/开发：<code>http://127.0.0.1:8600</code>
- Android 模拟器访问宿主机：<code>http://10.0.2.2:8600</code> 或 <code>adb reverse</code>
- 局域网设备：宿主机局域网 IP + 8600，并确认监听地址与防火墙
- Web 预览由同一 HTTP 服务提供静态 SPA 或代理

### 2.2 鉴权

来自 <code>crates/keystone-bridge/src/auth.rs</code>：

| 来源 | 规则 |
|---|---|
| loopback（127.0.0.1 / ::1） | 免 token |
| 非 loopback | 必须 <code>Authorization: Bearer &lt;device_token&gt;</code> |
| WebSocket | 浏览器不能自定义 header，用 <code>?token=&lt;device_token&gt;</code> |
| 未配置 token 的非 loopback | fail-closed，一律拒绝 |
| 浏览器 Origin | 必须是本机源，否则 403 |
| Host | loopback 免 token 路径校验，防 DNS rebinding |

> 这是“设备 token”，不是用户账号系统。后端没有登录、注册、用户表、密码、JWT 刷新。

### 2.3 会话是租户边界

- <code>POST /api/sessions</code> 由**服务端铸造** UUID，返回 <code>{ id, name }</code>。
- 之后所有内容接口必须带：
  
  <code>X-Session-Id: &lt;id&gt;</code>
  
- 未知会话：<code>404</code>；缺少会话：<code>400</code>；同会话并发输入：<code>409</code>。
- <code>name</code> 只是显示标签，不参与存储键。
- 会话 id 会用于：
  - 对话历史；
  - 记忆/知识库隔离；
  - 人生模拟器“哪个窗口的那个他”；
  - 媒体目录隔离；
  - WS 事件过滤。

**当前 App 的问题**：

- <code>DioClient</code> 默认 <code>sessionId = 'default'</code>；
- <code>/api/history</code> 和 <code>/chat</code> 在 body/query 里传 <code>session_id</code>，后端不读 body 的 session_id，只读 header；
- 因此 App 实际一直在写 <code>default</code> 会话，而不是每个用户/设备自己的会话。

**建议 App 启动流程**：

~~~text
GET /health
  -> 校验 baseUrl/token，读取 display_name
POST /api/sessions { "name": "我的设备" }
  -> 保存 session.id
之后所有请求：
  X-Session-Id: session.id
~~~

如果后端已有 <code>default</code> 数据，可以先兼容读取，但新会话必须走铸造。

### 2.4 错误语义

常见状态码：

| 状态 | 含义 |
|---:|---|
| 400 | 缺少/非法 X-Session-Id，或参数非法 |
| 401 | 非 loopback 但 token 缺失/错误 |
| 403 | Origin/Host 不合法 |
| 404 | 会话不存在，或媒体/审批目标不存在 |
| 409 | 同会话正在处理上一条输入 |
| 503 | 对应服务缺席（SessionStore、roleplay、审批信箱等） |

前端必须把 <code>503</code> 和 <code>available:false</code> 当作“能力未启用/降级”，不要显示成普通网络错误。

---

## 3. API 总表

> 所有标记“需要会话”的接口都要求 <code>X-Session-Id</code>。  
> 返回字段是源码里的真实顶层结构；“—”表示源码未固定或当前只用于观测台。

### 3.1 健康与会话

| 方法 | 路径 | 会话 | 作用 | 主要返回 |
|---|---|---|---|---|
| GET | /health | 否 | 存活、插件清单、模型、显示名 | status, capabilities[], llm{model,context_window}, display_name |
| GET | /api/sessions | 否 | 会话清单（按最近活动倒序） | sessions[{id,name,created_at,last_active}] |
| POST | /api/sessions | 否 | 铸造会话 | id, name |
| PATCH | /api/sessions/:id | 否 | 改显示标签 | ok |
| DELETE | /api/sessions/:id | 否 | 删除会话持久化历史 | ok |
| GET | /api/history | 是 | 持久化历史，尾部 1000 条 | messages[{role,content,...}] |

### 3.2 对话与事件

| 方法 | 路径 | 会话 | 作用 | 主要返回/事件 |
|---|---|---|---|---|
| POST | /chat | 是 | 发起一轮对话，SSE | delta / tool_start / tool / done / error |
| POST | /api/interrupt | 是 | 中断在途轮次 | ok |
| GET | /api/events | 是 | 事件增量轮询（WS 降级） | next, events[{seq,ts,event}] |
| GET | /ws | 是（query session/token） | WS 事件流 | hello + {seq,ts,event} |
| GET | /api/permissions | 否 | 工具权限三态 | default, overrides, tools[] |
| POST | /api/permissions | 否 | 热切换权限 | ok |
| POST | /api/approve | 是 | 审批 allow/deny/always | ok |
| POST | /api/hooks/:topic | 否 | 外部事件广播 | ok |

### 3.3 人生模拟器 / 生活

| 方法 | 路径 | 会话 | 作用 | 主要返回 |
|---|---|---|---|---|
| GET | /api/life | 是 | 他当前状态、今天事件、物品、日记、世界 | available, awake, place, world, energy, mood, events[], items[], diary, people[], threads[], latest_post |
| GET | /api/life/today | 是 | 今天一张日报 | highlights[], diary, met[], promises{open,top[]} |
| GET | /api/life/feed | 是 | 他的朋友圈，最多 30 条 | posts[{id,ts,place,text,note,mood,photo_url,comments[],likes[]}] |
| GET | /api/life/diary | 是 | 日记，最多 30 天 | diaries[{day,text}] |
| GET | /api/life/relations | 是 | 他记得的人 | people[{name,role,note,bond,interactions,last_seen_day,days_since_seen,place}] |
| GET | /api/life/traits | 是 | 他长出来的性格 | durable, traits[{text,status,hits,first_seen_day,last_seen_day}] |
| GET | /api/life/promises | 是 | 承诺账本 | open, done, kept_rate, promises[] |
| POST | /api/life/like | 是 | 给朋友圈点赞，幂等 | ok |
| POST | /api/life/comment | 是 | 给朋友圈留言 | ok |

### 3.4 世界只读面

| 方法 | 路径 | 会话 | 作用 | 主要返回 |
|---|---|---|---|---|
| GET | /api/world | 是 | 栖湾当前快照 | tick, clock, weather, place_name, player, household, npcs, places, items, disaster, closures, chronicle, gossip, season… |
| GET | /api/world/map | 是 | 全量地点与边 | places, edges, closures |
| GET | /api/world/people | 是 | 全量人口 | persons[] |
| GET | /api/world/ledger?person=&limit= | 是 | 个人账本 | person, entries[] |
| GET | /api/world/events?since=&limit= | 是 | 世界事件流 | events[] |
| GET | /api/world/audit | 是 | 世界巡检 | frozen, violations[] |
| GET | /api/world/report | 是 | 今日镇报 | chronicle, romances, township, disaster, closures, gossip |
| GET | /api/world/items | 是 | 他的家当履历 | items[{name,kind,wear,warm,warm_effective,value_cents,…}] |

### 3.5 媒体、角色、组织

| 方法 | 路径 | 会话 | 作用 |
|---|---|---|---|
| GET | /api/media | 是 | 本会话媒体库清单 |
| GET | /media/*path | 否（受鉴权中间件约束） | 媒体/附件只读文件 |
| GET | /api/roles | 否 | 角色库 |
| POST | /api/roles | 否 | 建角色 |
| DELETE | /api/roles/:id | 否 | 删角色 |
| POST | /api/sessions/:id/bind | 否 | 会话绑定角色 |
| DELETE | /api/sessions/:id/bind | 否 | 解绑 |
| GET | /api/sessions/:id/state | 否 | 角色状态快照 |
| GET | /api/org/agents | 否 | 员工名单 + 健康面 |
| POST | /api/org/agents | 否 | 注册员工（热加载） |
| DELETE | /api/org/agents/:name | 否 | 辞退员工 |

### 3.6 其他

| 方法 | 路径 | 作用 |
|---|---|---|
| GET | / | 内嵌观测台 SPA |
| POST | /webhook（8601 外部面） | IM 桥消息入口，HMAC 签名 |

---

## 4. 对话接口：App 真正要用的部分

### 4.1 请求

~~~http
POST /chat
X-Session-Id: <session>
Authorization: Bearer <device_token>   # 非 loopback 才需要
Content-Type: application/json
~~~

~~~json
{
  "message": "今天累不累",
  "source": "user",
  "images": ["data:image/jpeg;base64,..."],
  "files": [
    { "name": "report.pdf", "data": "base64..." }
  ]
}
~~~

- <code>images</code>：最多 4 张，单张解码前 ≤8MB；
- <code>files</code>：最多 4 个，单个 ≤8MB；落盘 inbox，模型用 read 工具读取；
- <code>source=external</code> 时走外部通道权限模型（黄挂审批、红硬拒）；
- 缺省 source=user。

### 4.2 SSE 事件

| event | data | 用途 |
|---|---|---|
| delta | 增量文本 | 打字机 |
| tool_start | {tool,call_id} | 工具开始，显示状态行 |
| tool | {tool,call_id,preview} | 工具预览（≤300 字） |
| done | 完整回复 | 结束、落历史 |
| error | 自解释错误 | 结束、可重试 |

内容面不推送 delta 到 WS；工具全文在通知面/观测台。

### 4.3 中断与并发

- 同会话正在处理时再次 <code>POST /chat</code> 返回 <code>409</code>。
- <code>POST /api/interrupt</code> 立刻中断在途 LLM 流和工具。
- SSE 结束后才会解除占用；前端要以 done/error 收尾。
- 历史加载：<code>GET /api/history</code>，按会话返回，尾部最多 1000 条。

### 4.4 审批

若工具是黄/红权限，会挂起等待审批。观测台的挂起证据在事件流里表现为：

<code>ToolCallResult</code> 且 <code>outcome</code> 以 <code>[调用挂起等待审批]</code> 开头。

批准：

~~~json
POST /api/approve
{ "call_id": "...", "decision": "allow" }
~~~

<code>decision</code> 可选 <code>allow / deny / always</code>；<code>always</code> = 本会话该工具免审。

App 如果只做聊天，可以先不暴露审批；一旦展示工具/自动任务，必须做审批闭环，否则高危调用会 300 秒后自动拒绝。

---

## 5. 人生数据：今日 / 朋友圈 / 日记 / 关系

### 5.1 GET /api/life

这是他“当前生活”的主接口。顶层字段：

| 字段 | 类型 | 说明 |
|---|---|---|
| available | bool | life_sim 是否可用 |
| awake | bool | 是否醒着 |
| place | string | 当前地点名 |
| transit | object/null | {from,to,eta_min} 在途 |
| energy / health / satiety / mood / social / security | number | 身体与主观状态 |
| condition | string | 身体状况（病/累等） |
| day | string | YYYY-MM-DD |
| world | object | 世界快照（见 §6） |
| events | array | 今天的事件 |
| items | array | 家当摘要 |
| diary | string/null | 最近一篇日记 |
| latest_post | object/null | 最近朋友圈 |
| last_proactive | object/null | 最近主动找你 |
| threads | array | 开着的心事 |
| people | array | 今天/最近见过的人 |

**<code>events</code> 的真实字段**来自 <code>view.rs</code>：

~~~json
{ "clock_min": 932, "place": "旧书店", "detail": "把晒了一下午的旧书收回来，码回后院", "feeling": "手上都是纸味儿" }
~~~

注意：**没有 <code>ts</code> 字段**。当前 App 的 <code>TodayEventDto</code> 读取 <code>ts</code> 或 <code>clock_min</code>；如果只用后端真实返回，时间要由 <code>clock_min</code> 换算成 HH:mm，否则 App 会显示空时间。

### 5.2 GET /api/life/today

一天四张面合成一张日报：

~~~json
{
  "available": true,
  "day": "2026-11-02",
  "highlights": [
    { "clock_min": 932, "place": "旧书店", "detail": "把晒了一下午的旧书收回来，码回后院", "feeling": "手上都是纸味儿" }
  ],
  "diary": { "day": "2026-11-02", "text": "..." },
  "met": [
    { "name": "林叔", "role": "旧书店掌柜", "note": "...", "bond": 0.7, "interactions": 12 }
  ],
  "promises": {
    "open": 2,
    "top": [ { "id": 1, "text": "去旧货市场问洗衣机", "day": "2026-11-01" } ]
  }
}
~~~

- highlights 会过滤纯位移/流水，最多 6 条；
- met 只包含今天见过的人；
- promises 是当天仍开着的承诺。

### 5.3 GET /api/life/feed

~~~json
{
  "available": true,
  "posts": [
    {
      "id": 1,
      "ts": "2026-11-02T15:32:00+08:00",
      "place": "旧书店",
      "text": "把晒了一下午的旧书收回来，码回后院。",
      "note": "...",
      "mood": "...",
      "photo_url": "/media/....jpg",
      "comments": [
        { "ts": "...", "author": "林叔", "text": "别累着" }
      ],
      "likes": ["林叔", "老赵"]
    }
  ]
}
~~~

真实限制：

- 只有 **一个 <code>photo_url</code>**，不是多图数组；
- comments 只返回每个 post 最近 5 条；
- 没有单条 post 详情接口；
- likes 是名字数组，不是用户 id；
- **没有用户创建朋友圈的 API**：当前 post 由 life_sim 的 agent 自己产生。

### 5.4 点赞与留言

~~~json
POST /api/life/like
{ "post_id": 1 }
~~~

- 幂等：同一人重复点赞不会重复加；
- 成功返回 <code>{ "ok": true }</code>；
- 失败/未启用 <code>{ "ok": false, "error": "life_sim 未启用" }</code>；
- 点赞/留言会广播 <code>life.like</code> / <code>life.comment</code> 给注意力引擎，可能触发他主动回应。

~~~json
POST /api/life/comment
{ "post_id": 1, "text": "今天早点休息" }
~~~

- 文本非空、≤500 字、post 必须存在；
- 写入作者是 **“小白”**（也就是 App 里的用户“你”）；
- 没有返回新评论对象，只返回 <code>{ "ok": true }</code>。

### 5.5 GET /api/life/diary

~~~json
{
  "available": true,
  "diaries": [
    { "day": "2026-11-01", "text": "十一月的头一天。他发烧，39.2……" }
  ]
}
~~~

真实字段只有 <code>day</code> 和 <code>text</code>。当前设计里的天气、心情、照片、摘句，需要前端从 <code>/api/life</code> 的 world/mood 派生，或后端补字段。

### 5.6 GET /api/life/relations

~~~json
{
  "available": true,
  "people": [
    {
      "name": "林叔",
      "role": "旧书店掌柜",
      "note": "老同事，嘴硬心软",
      "bond": 0.7,
      "interactions": 12,
      "last_seen_day": "2026-11-02",
      "days_since_seen": 0,
      "place": "旧书店"
    }
  ]
}
~~~

### 5.7 GET /api/life/traits

~~~json
{
  "available": true,
  "durable": 2,
  "traits": [
    { "text": "会自己生火了", "status": "durable", "hits": 3, "first_seen_day": "...", "last_seen_day": "..." }
  ]
}
~~~

<code>durable</code> = 已经长成性格；<code>tentative</code> = 正在长。

### 5.8 GET /api/life/promises

~~~json
{
  "available": true,
  "open": 2,
  "done": 5,
  "kept_rate": 0.71,
  "promises": [
    { "id": 1, "text": "去旧货市场问洗衣机的价", "status": "open", "day": "2026-11-01", "closed_ms": 0 }
  ]
}
~~~

---

## 6. 栖湾世界：后端真正“活着”的部分

### 6.1 世界是什么

<code>keystone-life-world</code> 是一个零 LLM 的确定性世界引擎：

- 时间、天气、季节、节日；
- 地图、地点、道路、封路；
- 人口、NPC 行动、工作、消费、健康；
- 账本、工资、租金、物品磨损、穿着、保暖；
- 婚恋、出生、死亡、离乡；
- 灾害、风闻、镇志；
- 玩家（笨笨）的位置、动作、体力、饱食、健康、金钱、家当；
- 以 1 分钟 tick 持续运行，产生世界事件。

### 6.2 GET /api/world 顶层字段

| 字段 | 说明 |
|---|---|
| tick / clock_min / clock_label | 世界时刻 |
| day_index / day_of_week | 世界日 |
| weather | 天气对象 |
| place_name | 当前地点名 |
| player | 玩家完整状态（energy/health/satiety/money/action/job/transit…） |
| household | 穿着、干净衣服、厨具、食材、伞、乱度、理发间隔 |
| npcs | 同地点/邻地点的 NPC |
| places | 地点清单 |
| items | 家当摘要 |
| romances | 姻缘簿 |
| township | 镇务：基金、情谊、人口 |
| disaster | 当前灾害或 null |
| closures | 封路/关店 |
| season / season_name / festival | 时令 |
| chronicle | 近三天镇志 |
| gossip | 街谈巷议 |
| fate_status | 天意/导演面 |
| seed | 世界种子 |

### 6.3 其他世界接口

- <code>/api/world/map</code>：places, edges, closures；
- <code>/api/world/people</code>：全量人口；
- <code>/api/world/ledger</code>：个人账本，支持 <code>person</code>、<code>limit</code>；
- <code>/api/world/events</code>：世界事件，支持 <code>since</code>、<code>limit</code>；
- <code>/api/world/audit</code>：frozen + violations；
- <code>/api/world/report</code>：镇志、婚恋、灾害、关店、风闻、人丁、流水；
- <code>/api/world/items</code>：物品履历（磨损、穿着、保暖、价值）。

### 6.4 世界事件与生活事件

WS 中与 App 最相关的 opaque topic：

| topic | payload 关键字段 | 用途 |
|---|---|---|
| life.event | session,id,what,value,reason | 他做了一件事，可能触发主动找你 |
| life_world.state | session,action,place,condition,clock,satiety,energy,money_cents | 他状态变化，App 可实时更新 |
| life_world.act_done | session,what,clock,sev | 动作完成 |
| life_world.met | session,who,name,bond,place,clock | 路上偶遇 |
| life.comment | session,id,what,value,reason | 用户在朋友圈留言，触发注意力 |
| life.like | session,id,what,value,reason | 用户点赞 |

这些事件适合驱动：

- 状态胶囊实时更新；
- 新朋友圈/新日记红点；
- 主动消息提示；
- 无需轮询。

---

## 7. 其他已实现能力

### 7.1 Agent 编排

- <code>think</code>：一次高思考预算的 LLM 调用；
- <code>agent</code>：派生干净上下文的子 agent，工具白名单、禁递归；
- <code>spawn_goal</code>：持久后台员工（goals 文件夹）；
- 同轮工具并发；
- 后台员工双闸：≤20 在册、≤30 唤醒/小时。

### 7.2 记忆与知识

- 三层记忆：
  - 10 轮滞回历史窗口；
  - episode 永久向量沉降；
  - fact 蒸馏 + supersede 链；
- <code>memo_write</code>：remember / update / forget；
- 双通道召回：被动 top-5 + 主动 memory search；
- 本地 ONNX 嵌入（bge-small-zh，512 维），sqlite-vec；
- 知识库 RAG：文件夹即真相源，增量同步，双路召回；
- 技能系统：skills.index 索引 + skill 按名加载；
- <code>web</code>：search / fetch。

### 7.3 主动性与注意力

- 世界变化 × 关切度 → 候选；
- 候选积分累积、自适应阈值、不应期、可用性；
- 主 agent 组织语言，注意力只决定“要不要开口”；
- 陪伴通道：长时间无互动时低价值种子；
- <code>GET /api/attention</code>：当前 s/tau/次数/最近决策（只读）。

### 7.4 多模态

- 对话图片内联（≤4 张，≤8MB），视觉路由；
- 文件附件落 inbox；
- read 工具可读 pdf/docx/xlsx/图片；
- 生图/生视频（DashScope / 火山）；
- 媒体统一从 <code>/media/*path</code> 输出；
- <code>GET /api/media</code> 列本会话媒体库。

### 7.5 权限与审批

- 工具风险级：green / yellow / red / critical；
- 用户策略：allow / ask / deny，热切换 + 持久化；
- 输入来源：user / proactive / autonomous / external；
- 三道硬防线：失控、危急、外部通道；
- 审批 300 秒超时自动拒绝；
- <code>/api/permissions</code>、<code>/api/approve</code>。

### 7.6 多实例组织 / IM

- 同一 exe 多实例；
- 能力白名单裁剪员工；
- CEO 观测员工事件，零污染上下文；
- 员工呼叫 <code>agent(action=call)</code>；
- 外部 webhook HMAC；
- IM 出站模板引擎；
- 员工名单热加载。

### 7.7 角色扮演与生命周期

- <code>/api/roles</code> 角色库；
- 会话绑定角色、状态快照；
- 角色 API 是哑数据口，权限/计费/审核不在后端；
- 生命周期：VACUUM INTO 备份、30 天保留、manifest 指纹校验、恢复。

### 7.8 观测台

- 内嵌 React；
- SSE 打字机 + 工具状态；
- 审批待办；
- token/上下文折线；
- 完整提示词透视；
- 权限三态；
- 事件流；
- 桌面通知。

---

## 8. App 页面与后端数据的映射

| App 页面 | 主要后端 | 已能支持 | 缺口 |
|---|---|---|---|
| 登录/连接 | /health | 显示名、能力、模型 | 没有账号登录；只有设备 token |
| 聊天 | /chat, /api/history, /api/interrupt | 流式、工具状态、图片/文件、历史 | App 会话固定 default；body 传 session_id 无效 |
| 今天 | /api/life, /api/life/today, /api/world/report | 事件、状态、世界、日报、镇报 | life.events 无 ts；today DTO 字段需要适配 |
| 朋友圈 | /api/life/feed, /like, /comment | 帖子、点赞、留言 | 单图、无详情、无分页、无用户发帖、评论只回 5 条 |
| 日记 | /api/life/diary | 日期 + 正文 | 无天气/心情/照片/摘句；无详情 |
| 他/资料 | /api/life/relations, /traits, /promises, /api/world/items, /api/life/feed | 关系、成长、承诺、家当、照片 | 无 profile 聚合；统计散落 |
| 顶部搜索 | 无 | — | 没有生活/朋友圈搜索接口 |
| 顶部相机 | /chat images | 聊天发图 | 没有独立的媒体上传接口给朋友圈/日记 |
| 设置 | /api/permissions | 权限三态 | 无用户偏好/通知设置 API |
| 通知 | /ws 事件 | 实时事件 | 没有“未读通知”持久化接口 |
| 平板 | 同上 | 响应式 | 同手机缺口 |

---

## 9. 当前后端 vs App 设计的真实差距

### P0：不修就会错

1. **会话契约**
   - App 必须 <code>POST /api/sessions</code> 并保存 id；
   - 所有请求用 <code>X-Session-Id</code>；
   - 删除 body/query 的 <code>session_id</code> 依赖；
   - 否则所有用户共享 <code>default</code> 数据。

2. **/api/life 的 events 时间**
   - 后端只有 <code>clock_min</code>，没有 <code>ts</code>；
   - App 必须用 <code>clock_min</code> 生成 HH:mm，不能依赖 <code>ts</code>；
   - 现在 demo 数据有 <code>ts</code>，真实后端没有，联调会空时间。

3. **/api/history 的会话**
   - 后端从 header 取会话，query 的 <code>session_id</code> 不生效；
   - 当前 App 历史可能一直读 default。

### P1：影响产品完整度

4. **朋友圈单图**
   - 后端 <code>photo_url</code> 单值；设计里的三图网格无法直接支持；
   - 需要 <code>photos: string[]</code> 或 <code>media: [{url,kind}]</code>。

5. **朋友圈详情 / 分页**
   - 后端只返回最近 30 条，comments 每帖 5 条；
   - 没有 <code>GET /api/life/feed/:id</code>；
   - 设计里的查看全部留言无法实现。

6. **用户发朋友圈**
   - 后端没有用户创建 post 的写口；
   - 目前只有 life_sim 的 agent 会发；
   - App 的“相机→发布”只能本地假数据，无法同步。

7. **媒体上传**
   - /chat 可以直接传 base64 图片，但朋友圈/日记没有上传接口；
   - 需要 <code>POST /api/media/upload</code> 或 <code>POST /api/moments</code> 支持 multipart/base64。

8. **日记增强**
   - 后端只有 day/text；
   - 设计里的天气、心情、照片、摘句需要字段或由前端从 world 派生。

9. **资料页聚合**
   - 后端数据散在 relations/traits/promises/items/feed/history；
   - App 需要并发 5–6 个请求；
   - 建议 <code>GET /api/app/profile</code> 聚合。

10. **搜索**
    - 后端没有生活/朋友圈/日记搜索；
    - App 顶部搜索只能本地过滤，无法搜全量。

### P2：体验增强

11. **通知/未读**
    - WS 有实时事件，但没有持久化未读；
    - 需要 <code>GET /api/notifications</code> 或事件游标 + 已读水位。

12. **审批**
    - 如果 App 展示工具/自动任务，需要审批 UI；
    - 需要把 <code>ToolCallResult.outcome</code> 的挂起帧映射成审批卡片。

13. **角色扮演**
    - roleplay 已有 API，但 App 当前没有选角/绑定流程。

---

## 10. 建议：在后端补一层 App BFF

不要把 App 直接绑在观测台原始接口上。建议保留现有插件 API，对外增加一层“产品 API”：

### 10.1 页面聚合

~~~text
GET /api/app/home
  -> { health, life, today, worldReport, unread }

GET /api/app/moments?cursor=&limit=
  -> { posts, nextCursor }

GET /api/app/moments/:id
  -> { post, comments, nextCursor }

GET /api/app/diary?cursor=&limit=
  -> { entries, nextCursor }

GET /api/app/profile
  -> { hero, stats, relations, traits, promises, items, photos }

GET /api/app/search?q=
  -> { events, posts, diaries, people }
~~~

### 10.2 写入

~~~text
POST /api/app/moments
  body: { text, photos: [mediaId], place? }
  -> { post }

POST /api/app/moments/:id/like
POST /api/app/moments/:id/comments
  body: { text }
  -> { comment, commentCount, liked }

POST /api/app/media
  multipart 或 { dataUrl, name }
  -> { url, mediaId, kind, size }
~~~

### 10.3 通知

~~~text
GET /api/app/notifications?after=<seq>
  -> { items[{id,kind,text,ts,read}], next }
POST /api/app/notifications/read
  body: { ids: [...] }
~~~

### 10.4 建议字段

朋友圈 post 建议扩展为：

~~~json
{
  "id": 1,
  "author": "笨笨",
  "avatarUrl": "/media/...",
  "time": "15:32",
  "date": "2026-11-02",
  "place": "旧书店",
  "text": "...",
  "photos": ["/media/..."],
  "likes": [{ "name": "林叔" }],
  "likedByMe": false,
  "commentCount": 2,
  "comments": [
    { "id": 1, "author": "林叔", "text": "...", "time": "15:40" }
  ]
}
~~~

日记建议扩展为：

~~~json
{
  "day": "2026-11-01",
  "weather": "雨",
  "temperature": "1.7°C",
  "mood": "安静",
  "photos": ["/media/..."],
  "quote": "书不会跑，人会跑。",
  "text": "...",
  "writtenAt": "22:40"
}
~~~

> 这些扩展不是让后端“迎合 UI”，而是把 App 需要的稳定字段显式化，避免前端靠拼接/猜测。

---

## 11. 前端接入规范建议

### 11.1 Session 启动

1. <code>GET /health</code>，校验 token/baseUrl；
2. <code>POST /api/sessions</code> 创建会话；
3. 持久化 session id；
4. Dio/HTTP 客户端统一注入 <code>X-Session-Id</code>；
5. WS 用 <code>?session=&lt;id&gt;&amp;token=&lt;token&gt;</code>；
6. 删除所有 body/query 的 session_id 依赖。

### 11.2 SSE

- 只解析 <code>delta/tool_start/tool/done/error</code>；
- 收到 done 才关闭本轮 loading；
- error 也要复位；
- 409 表示上一条未完成，应禁用输入并等待；
- 断线重连后 <code>GET /api/history</code> 对齐。

### 11.3 WS

~~~text
/ws?since=0&events=all&session=<id>&token=<token>
~~~

- 首帧 <code>hello</code>：记录 seq/boot；
- 每帧 <code>{seq,ts,event}</code>；
- 上行 <code>{"since": seq}</code> 对齐；
- boot 变化 = 服务重启，回 since 0 补发；
- 断线 3 秒重连。

### 11.4 降级

- <code>available:false</code>：显示能力未开启；
- <code>503</code>：能力缺席；
- 不要用假数据覆盖真实失败；
- 媒体 URL 需拼 baseUrl；
- 所有时间为本地时区。

### 11.5 缓存与刷新

- 聊天历史按 session；
- 今天/朋友圈/日记进入页面刷新；
- WS 事件到达时局部更新，不必全页重拉；
- 点赞/留言先乐观更新，失败回滚。

---

## 12. 后端已知边界

来自 README / 源码：

- 单机；没有 SaaS 多租户隔离；
- 没有跨机迁移/集群；
- 记忆中的旧事实 3 天后不会自动复核；
- shell 是内置子集，不是完整 bash；
- 世界探针有界（文件数量/深度），不是索引器；
- attention 质量依赖运行数据；
- 前端 attention/life 面板还不完整；
- 没有 CI，只有本机机械门禁；
- 没有用户账号体系。

---

## 13. 验收清单

### 后端联调

- [ ] App 能 <code>POST /api/sessions</code> 并拿到 id
- [ ] 所有请求带 <code>X-Session-Id</code>
- [ ] /health 在 loopback 与 token 两种模式都通过
- [ ] /chat SSE 打字机、done、error、409 都正确
- [ ] /api/history 返回本会话历史
- [ ] /api/life 的 events 时间正确显示
- [ ] /api/life/feed 点赞/留言后刷新可见
- [ ] /api/life/diary 能滚动加载
- [ ] /api/life/relations/traits/promises/items 渲染
- [ ] unavailable / 503 有降级 UI
- [ ] WS 断线重连、session 过滤正确

### 产品

- [ ] 今天页能看见他“今天真正发生的事”
- [ ] 朋友圈能看照片、点赞、留言、详情
- [ ] 日记能按时间向下滚
- [ ] 资料页能看见关系、性格、承诺、家当
- [ ] 搜索能搜今天/朋友圈/日记
- [ ] 相机图片能上传并出现在对应内容
- [ ] 聊天里能中断、重试、看工具状态
- [ ] 多端（手机/平板/横竖屏）数据一致

---

## 14. 代码索引

| 内容 | 路径 |
|---|---|
| HTTP 路由与 handler | crates/keystone-bridge/src/http.rs |
| WS 事件协议 | crates/keystone-bridge/src/ws.rs |
| 鉴权 | crates/keystone-bridge/src/auth.rs |
| 事件日志/媒体 URL | crates/keystone-bridge/src/eventlog.rs |
| 人生只读投影 | crates/keystone-life-sim/src/view.rs |
| 人生工具与事件 | crates/keystone-life-sim/src/life_tool.rs |
| 栖湾世界 JSON | crates/keystone-life-world/src/jsonview.rs |
| 世界事件广播 | crates/keystone-life-world/src/cap.rs |
| 契约 | crates/keystone-contract/src |
| 运行配置 | config.toml |
| 总览/边界 | README.md, TODO.md |
| App 会话/接口 | benben_app/lib/core/network/dio_client.dart, api_endpoints.dart |
| App 数据模型 | benben_app/lib/features/*/data/models/*.dart |

---

## 15. 一句话建议

先把 **会话 + 真实时间字段 + 朋友圈/日记详情与媒体** 这四件事补齐；  
再补 App BFF 聚合与搜索/通知；  
否则 UI 越精致，越容易在真实数据上露馅。


---

## 16. 前端产品红线：单角色、单人生

这一条高于所有页面设计：

> **一个 App 实例只对应一个笨笨，只对应一条不会重复的人生。**

### 16.1 不允许出现在前端的

- 角色切换
- 实例切换
- 员工 / CEO / 组织切换
- “选择你的笨笨”
- “其他笨笨”
- 多角色列表
- 多世界选择
- 公共朋友圈 / 全站广场
- 跨用户的笨笨对比
- 把 roleplay / org / 多实例能力暴露成用户功能

这些是后端的运行时能力，不是 App 的产品面。

### 16.2 前端应该表现的

- 首次连接只做一件事：连上属于你的那个实例；
- 服务端铸造一个 session，之后这个 session 就是“他的房间钥匙”；
- 所有页面固定使用同一个 session；
- 语言永远是“他 / 你的笨笨”，不是“当前角色”；
- 他的世界是“栖湾”，不是“世界选择器”；
- 他的朋友圈、日记、关系、家当，都是这一个他的；
- 他的生活由 session / 世界种子 / 长期记忆自然长出来，不是模板复制；
- 页面可以展示“第几天”“在旧书店”“今天见过谁”，让用户感到这条人生是唯一的。

### 16.3 对页面设计的影响

| 位置 | 不能做 | 应该做 |
|---|---|---|
| 登录/连接 | 角色选择、实例列表 | 只填连接信息，创建/恢复唯一 session |
| 设置 | 切换角色、切换员工 | 连接信息、通知、显示、关于 |
| 他页 | 角色库、其他 agent | 当前这一个他的关系/成长/家当 |
| 朋友圈 | 公共广场、其他用户动态 | 只显示他的生活 |
| 世界 | 多世界、多实例 | 只显示他所在的栖湾 |
| 聊天 | 选择对话对象 | 只和这一个他聊天 |
| 通知 | 多角色通知 | 只来自这一个他 |

### 16.4 异常处理

如果 session 丢失、被删除、连到了别的实例：

- 不要静默创建新会话假装还是他；
- 明确提示“联系断了 / 这不是他的生活”；
- 只有用户确认后，才允许建立新的唯一人生；
- 旧 session 的数据不合并到新 session。

### 16.5 设计原则

**不是“多 agent 产品”，是“一个人的生活窗口”。**

多实例、角色扮演、组织，是后端为了保证隔离、测试和部署而存在的机制；  
前端只呈现其中一个、唯一的、正在过日子的笨笨。
