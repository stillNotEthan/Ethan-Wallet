# 📱 Ethan Wallet - Apple-Style Web3 Wallet

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![WalletCore](https://img.shields.io/badge/WalletCore-TrustWallet-blue.svg)](https://github.com/trustwallet/wallet-core)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Ethan Wallet** 是一款追求极致用户体验的以太坊钱包。它融合了 **Apple 原生设计语言** 与 **硬核 Web3 技术**，旨在为用户提供一个安全、丝滑且功能完备的数字资产管理平台。

---

## ✨ 核心功能 (Core Features)

| 功能模块 | 描述 | 技术亮点 |
| :--- | :--- | :--- |
| **🔐 安全防护** | 金融级安全保障 | FaceID 生物识别, Keychain 加密存储, 助记词备份 |
| **💰 资产管理** | 实时多资产看板 | ETH & ERC-20 代币列表, 实时余额查询 (Ankr RPC) |
| **💸 极速转账** | 丝滑的发送体验 | 实时 Gas 费预估, 扫码发送 (AVFoundation), 触感反馈 |
| **📈 交易历史** | 真实的链上流水 | 对接 Etherscan API, 详细的交易状态展示 |
| **🔄 代币兑换** | 内置 DEX 聚合器 | 集成 0x Protocol, 实时报价与一键 Swap |
| **🎨 极致体验** | 纯正苹果味 UI | 深色模式适配, 多语言支持 (i18n), 渐变色卡片设计 |

---

## 🛠️ 技术栈 (Tech Stack)

*   **UI 框架**: SwiftUI (声明式布局, 响应式状态管理)
*   **加密引擎**: [TrustWallet Core](https://github.com/trustwallet/wallet-core) (助记词生成, 交易签名)
*   **大数运算**: [BigInt](https://github.com/attaswift/BigInt) (处理 18 位精度的 Wei 单位)
*   **网络层**: URLSession (JSON-RPC 交互, Etherscan API)
*   **持久化**: Keychain (硬件级私钥存储)
*   **路由**: NavigationStack (iOS 16+ 现代导航架构)

---

## 🚀 快速开始 (Quick Start)

### 1. 环境要求
*   Xcode 15.0+
*   iOS 16.0+ (真机或模拟器)
*   CocoaPods 或 Swift Package Manager (SPM)

### 2. 配置敏感信息
为了安全起见，本项目使用 `.xcconfig` 管理 API Key。请在根目录创建 `Secrets.xcconfig`：
```text
RPC_URL = https:/$()/eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY
ETHERSCAN_API_KEY = YOUR_ETHERSCAN_KEY
```
*注意：请确保 `Secrets.xcconfig` 已加入 `.gitignore`。*

### 3. 运行项目
1. 克隆仓库: `git clone https://github.com/yourname/EthanWallet.git`
2. 打开 `EthanWallet.xcodeproj`
3. 选择运行目标 (iPhone Simulator 或真机)
4. 点击 **Run (Cmd + R)**

---

## 📸 界面预览 (Screenshots)

*(建议在此处插入你的 App 截图，如首页、发送页、扫码页等)*

---

## 🛡️ 安全声明 (Security)

本项目仅用于学习与演示。在生产环境中使用前，请务必：
1. 进行完整的安全审计。
2. 确保私钥永远不会离开 Keychain。
3. 妥善保管你的助记词。

---

## 🤝 贡献与支持

如果你喜欢这个项目，欢迎给一个 **Star** ⭐️！
如果有任何问题或建议，请提交 **Issue** 或 **Pull Request**。

**Developed with ❤️ by Ethan**

