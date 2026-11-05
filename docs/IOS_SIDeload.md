# 只有 iPhone、没有 Mac：原生 iOS 安装路线

这条路不需要 Mac，也不需要 99 美元开发者账号：

    Windows 写代码
      → GitHub Actions macOS runner 编译未签名 IPA
      → Windows 安装 Sideloadly
      → 用免费 Apple ID 签名
      → 装到 iPhone
      → 7 天后重签

## 1. 准备 GitHub

当前仓库 origin 是 Gitee。GitHub Actions 需要 GitHub 仓库：

    git remote add github https://github.com/<你的账号>/benben-flutter.git
    git push github main

公开仓库的 macOS Actions 免费；私有仓库消耗免费分钟。

## 2. 改后端地址

找到 Windows 的局域网 IP：

    ipconfig

确保 iPhone 和 Windows 在同一个 Wi-Fi，Windows 防火墙放行 3000。

编辑：

    .github/workflows/ios-unsigned.yml

把：

    API_BASE_URL: http://192.168.1.2:3000/api/v1

改成你的实际 IP。

后端要保持运行：

    PostgreSQL   55434
    agent_core   8600
    business-api 0.0.0.0:3000

## 3. 编译

GitHub 仓库 → Actions → iOS unsigned build → Run workflow。

完成后下载 artifact：

    Runner-unsigned.zip
    → 解压得到 Runner-unsigned.ipa

IPA 是未签名包，下一步由 Sideloadly 用你的 Apple ID 签名。

## 4. Windows 安装 Sideloadly

1. 安装 iTunes 或 Apple Devices（Windows 版）。
2. 安装 Sideloadly。
3. iPhone 用 USB 连接 Windows，信任电脑。
4. 打开 Sideloadly，把 Runner-unsigned.ipa 拖进去。
5. 输入你的 Apple ID。
6. Start，等待签名和安装。
7. iPhone：设置 → 通用 → VPN与设备管理 → 信任你的开发者证书。
8. iOS 16 以上：设置 → 隐私与安全性 → 开发者模式 → 打开并重启。

## 5. 限制

- 免费 Apple ID 签名 7 天有效，到期重新用 Sideloadly 签一次。
- 没有 TestFlight，没有 App Store。
- App 被系统杀掉后收不到 WS/本地通知；这是 iOS 后台限制。
- 更换 Windows IP 后需要重新编译 IPA。
- 正式长期使用建议 Apple Developer + TestFlight，但先看效果这条路够了。

## 备选

- 借一台 Mac：Xcode 直接 flutter run，最快。
- MacinCloud：云 Mac + Sideloadly/TestFlight。
- Codemagic：云 Mac + Apple Developer + TestFlight。
