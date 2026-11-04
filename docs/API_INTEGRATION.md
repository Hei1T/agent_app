# App API 接入

## API 地址

默认：

- Android 模拟器：http://10.0.2.2:3000/api/v1
- Windows/iOS 模拟器：http://127.0.0.1:3000/api/v1

真机或自建服务器：

```bash
flutter run --dart-define=API_BASE_URL=http://<电脑局域网IP>:3000/api/v1
```

## 登录

- 演示账号：demo@benben.local / demo1234
- 登录 token 存 flutter_secure_storage
- 登录后路由进入 /today
- 注册接口已接入，登录页有“注册新账号”

## 网络层

- Dio + Bearer 拦截器
- flutter_secure_storage 存 token
- 业务页面通过 Riverpod provider 获取状态

## 已接入

- GET /core/life -> Today 状态
- GET /core/life/feed -> 朋友圈
- POST /chat -> SSE 聊天
- GET /credits/balance -> 积分（提供 provider）
- core session 由后端自动创建并持久化

## 未接入

- 朋友圈发照片仍只在本机操作
- 日记页仍使用 demo 数据
- 积分余额尚未在界面展示
- 没有聊天历史加载（core history API 未代理）
