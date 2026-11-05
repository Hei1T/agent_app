# 原生 iPhone 运行指南

Windows 不能编译或签名 iOS App。原生 iPhone 必须经过 macOS + Xcode（本机 Mac、云 Mac，或 CI 的 macOS runner）。

## 方案 A：借一台 Mac（最快看到真机效果）

1. Mac 安装 Xcode、Flutter、CocoaPods。
2. 把仓库放到 Mac（Git 或压缩包）。
3. 在 Windows 上启动后端，并让 iPhone 和 Windows 在同一 Wi-Fi：
   - PostgreSQL: 55434
   - agent_core: 8600
   - business-api: 3000，监听 0.0.0.0
   - Windows 防火墙放行 3000
4. 查 Windows 局域网 IP：

    powershell
    ipconfig
    

5. Mac 上：

    bash
    cd benben_flutter
    flutter pub get
    cd ios && pod install && cd ..
    flutter run -d <iPhone> --dart-define=API_BASE_URL=http://<Windows局域网IP>:3000/api/v1
    

iPhone 首次运行需要在 设置 → 通用 → VPN与设备管理 信任开发者证书。

免费 Apple ID 只能装 7 天，到期重签；付费开发者账号可用 TestFlight。

## 方案 B：没有 Mac，用云 Mac + TestFlight

推荐：Codemagic / MacinCloud / AWS EC2 Mac。

1. 准备 Apple Developer 账号（$99/年，TestFlight 必须）。
2. 把仓库推到 GitHub/GitLab/Bitbucket（Codemagic 不识 Gitee 时可镜像）。
3. Codemagic 创建 iOS 应用，配置：
   - App Store Connect API Key
   - Distribution Certificate + Provisioning Profile
   - Bundle ID：com.benben.benbenApp
4. Build 命令：

    bash
    flutter pub get
    flutter build ipa --release --dart-define=API_BASE_URL=https://<公网后端域名>/api/v1
    

5. 上传 App Store Connect → TestFlight → 内部测试 → iPhone 安装。

云 Mac 上不能访问你 Windows 的 127.0.0.1。真机/TestFlight 的后端必须公网可达，建议：

    Cloudflare Tunnel / ngrok / 一台有公网 IP 的服务器
    https://xxx.example.com/api/v1
    wss://xxx.example.com/api/v1/ws

本地局域网调试用 http；TestFlight 用 https，避免 App Store 的 ATS 问题。

## 方案 C：Mac 上只跑 iOS 模拟器

也要 Mac + Xcode。适合先看布局，不需要 Apple Developer 账号。

    bash
    open -a Simulator
    flutter run -d "iPhone 16 Pro" --dart-define=API_BASE_URL=http://<Windows局域网IP>:3000/api/v1
    

模拟器里的 localhost 是 Mac，不是 Windows，所以必须用 Windows 局域网 IP。

## iOS 项目已准备的配置

- Bundle ID：com.benben.benbenApp
- Deployment Target：13.0
- Info.plist：
  - 通知/相机/相册/麦克风描述
  - 本地网络描述
  - 开发期 ATS 允许 HTTP
- ios/Podfile
- 本地通知、video_player、image_picker、secure_storage 均有 iOS 实现

正式上架前应把 ATS 的 NSAllowsArbitraryLoads 改成只允许你的 HTTPS 域名。

## 主动消息在 iOS 的边界

- App 活着：本地通知
- App 被系统杀掉：没有 WS，需要 APNs 服务端推送
- 真要做锁屏推送，需要 Apple Developer + APNs Key + 后端 device token 注册
