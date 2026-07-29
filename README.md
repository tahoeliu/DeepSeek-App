# DeepSeek Desktop App - Native macOS Wrapper

<div align="center">

**Turn DeepSeek AI into a native macOS application** - Clean, fast, and lightweight wrapper for the best AI chat experience.

[![Swift Version](https://img.shields.io/badge/swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)]()
[![Size](https://img.shields.io/badge/size-~400KB-brightgreen.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**⭐ Star this repo to support native macOS AI apps!**

</div>

## 🎯 The Best Way to Use DeepSeek AI on macOS

**Stop opening DeepSeek AI in your browser!** Experience DeepSeek's powerful AI chat as a real, native macOS application.

Whether you're a **developer**, **researcher**, **student**, or **AI enthusiast** - this app transforms your DeepSeek experience into something that feels truly native to your Mac.

### Why DeepSeek Desktop App?

- **🚀 Native macOS Experience** - Proper window management, dock integration, and system menus
- **⚡ Blazing Fast** - Only 264KB, not the heavy Electron bloat of other AI apps
- **🎯 Smart Browsing** - DeepSeek links stay in-app, everything else opens in your browser
- **🔐 Persistent Login** - Stay logged in across sessions, no repeated authentication
- **🎨 Minimal Design** - Clean, borderless interface focused on pure AI conversation
- **🆓 Completely Free** - Open source, no ads, no tracking, no hidden costs

### Perfect For

- 💬 **Daily AI conversations** with DeepSeek's advanced language model
- 📚 **Research and learning** with instant AI assistance
- 💻 **Development work** with code generation and debugging help
- ✍️ **Content creation** with AI-powered writing assistance
- 🧠 **Brainstorming** and creative thinking sessions

## 📥 Download & Install

**Get DeepSeek Desktop in 3 simple steps:**

[📥 **Download DeepSeek.dmg**](DeepSeek-1.0.0.dmg) *(264KB)*

1. Click the download button above
2. Open the downloaded `.dmg` file
3. Drag **DeepSeek** to your **Applications** folder

**First time launching?** Right-click the app and select "Open" (macOS security requirement).

That's it! Now you have DeepSeek AI as a proper native app in your dock.

---

<div align="center">

**For the curious minds who refuse to accept the default.**

</div>

---

## ✨ Features

- **🚀 Native Performance** - Built with AppKit + WKWebView (no Electron, just ~400KB)
- **🎨 Minimalist Design** - Borderless window with no title text or toolbar buttons
- **🖱️ Draggable Title Area** - Hidden 48px drag band at window top
- **🔐 Login Persistence** - Maintains login state across sessions
- **🌐 Smart Navigation** - DeepSeek links stay in-app, external links open in browser
- **🇨🇳 Region Support** - Switch between Chinese/International versions via menu
- **🍎 Native Menus** - Standard macOS menus with keyboard shortcuts
- **🐳 Dock Integration** - App stays in Dock, click to reopen window

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘ + R` | Refresh page |
| `⌘ + [` | Go back |
| `⌘ + ]` | Go forward |
| `⌘ + ⇧ + H` | Go to home |
| `⌘ + B` | Open in browser |
| `⌘ + ⇧ + L` | Copy URL |
| `⌘ + M` | Minimize window |
| `⌃ + ⌘ + F` | Fullscreen |
| `⌘ + Q` | Quit app |

## 🌏 Region Switching

DeepSeek uses the same URL (`https://chat.deepseek.com/`) for both Chinese and International versions. The login options are determined by your network region:

- **Chinese Network** → Shows phone number/WeChat login
- **International Network** → Shows email/Google login

### Switching Regions

Use the **Region** menu to switch:
- **国内版** - Chinese version
- **International** - English version

> **Pro Tip**: If you have an international email account, connect to a VPN/HK/TW node first, then select "International". Once logged in, your session persists even on mainland networks!

## 🛠️ Tech Stack

- **Swift 5.9+** - Core application logic
- **AppKit** - Native macOS UI framework
- **WebKit** - Web rendering engine
- **WKWebView** - Persistent data store for login state
- **No external dependencies** - Just Swift stdlib + system frameworks

## 🔧 Development

### Build from Source

```bash
# Clone the repository
git clone https://github.com/tahoeliu/DeepSeek-App.git
cd DeepSeek-App

# Build the app
./build.sh

# The built app will be in ./DeepSeek.app
```

### Prerequisites

- macOS 10.15 or later
- Xcode Command Line Tools (`xcode-select --install`)
- Swift 5.9+ (included with macOS)

### Customization

**Change URL:** Edit `Sources/main.swift`:
```swift
static let homeURL = URL(string: "https://chat.deepseek.com/")!
```

**Change Icon:** Replace `Resources/icon_master.png` and regenerate icons.

**Change Name:** Edit `Resources/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>YourAppName</string>
```

## 📁 Project Structure

```
DeepSeekApp/
├── Sources/
│   └── main.swift         # Complete source code (single file!)
├── Resources/
│   ├── Info.plist        # App metadata
│   ├── AppIcon.icns      # Multi-resolution icons
│   ├── icon_master.png   # 1024x1024 source icon
│   ├── icon-black.png    # Dark theme icon
│   └── icon-white.png    # Light theme icon
├── DeepSeek.app/         # Built application
├── Build/                # Build artifacts
└── build.sh             # Build script
```

## 🌟 Why Choose DeepSeek Desktop App?

**Compared to browser-based access:**

| Feature | Native App | Browser |
|---------|------------|---------|
| Native Window Management | ✅ | ❌ |
| Dock Integration | ✅ | ❌ |
| System Menus | ✅ | ❌ |
| Keyboard Shortcuts | ✅ | ⚠️ Limited |
| Persistent Login | ✅ | ⚠️ Cookie-dependent |
| Distraction-Free | ✅ | ❌ |
| App Badge Notifications | ✅ | ❌ |

## 🎯 Key Implementation Details

### Drag Band
The top 48px of the window acts as a hidden title bar. This is implemented in `DragWebView` class in `main.swift`:

```swift
var dragBandHeight: CGFloat = 48
```

### Logo Hiding
The DeepSeek logo is hidden using CSS injection with `!important` to override React inline styles:

```swift
webView.evaluateJavaScript("""
    (function() {
        const style = document.createElement('style');
        style.textContent = '.site_logo_* { display: none !important; }';
        document.head.appendChild(style);
    })();
""")
```

### Navigation Logic
- Internal `*deepseek.com` links open in the app
- External links open in default browser
- Smart URL detection prevents broken navigation

## 🚧 Known Limitations

- Region switching depends on network IP (server-side)
- Requires manual exception for Gatekeeper on first run
- Single sign-on between Chinese/International accounts not supported

## 🤝 Contributing

Contributions are welcome! This is a simple, well-structured project perfect for learning Swift + AppKit.

Feel free to:

- 🐛 Report bugs via [GitHub Issues](https://github.com/tahoeliu/DeepSeek-App/issues)
- 💡 Suggest new features
- 🔧 Submit pull requests
- 📖 Improve documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [DeepSeek](https://deepseek.com/) - The underlying AI chat service
- [Apple](https://developer.apple.com/) - AppKit and WebKit frameworks

## 📢 Share DeepSeek Desktop App

If you find this app useful, please consider:

- ⭐ **Star this repository** on GitHub
- 🔗 **Share it** with friends and colleagues
- 🐦 **Tweet** about it on social media
- 📝 **Write a review** if you publish about it

## 🔗 Related Projects

- [ChatGPT Desktop](https://github.com/luyuhuang/chatgpt-desktop) - Native ChatGPT app
- [Claude Desktop](https://github.com/pionxzh/claude-desktop) - Native Claude app
- [BingGPT](https://github.com/d2ki3o4/BingGPT) - Bing Chat app

## 📞 Support

- 📧 **Issues**: [GitHub Issues](https://github.com/tahoeliu/DeepSeek-App/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/tahoeliu/DeepSeek-App/discussions)

## ⚠️ Disclaimer

**This application is a web browser wrapper** that provides a native macOS interface for DeepSeek AI's official web service at chat.deepseek.com.

**Important Notes:**
- This app **does not provide** AI models, AI services, or any computational resources
- All AI processing, content generation, and services are provided exclusively by DeepSeek (deepseek.com)
- This application simply renders DeepSeek's official website in a native macOS window
- Users must have their own DeepSeek account and comply with DeepSeek's terms of service
- The developer assumes no responsibility for the AI content, accuracy, or availability of DeepSeek's services
- Any issues with AI functionality, content policies, or service availability should be directed to DeepSeek support

**Technical Details:**
- This is a standalone client application using Apple's WebKit framework
- No data is collected, stored, or processed by this application
- All communications go directly to DeepSeek's official servers
- The application maintains no user data, AI responses, or conversation history locally

By using this application, you acknowledge that you understand and agree that this is merely a user interface wrapper for DeepSeek's official web service and not an AI service provider.
---

<div align="center">

**For a world worth debugging.**

**Built with Swift for macOS ❤️**

[⬆ Back to Top](#deepseek-desktop-app---native-macos-wrapper)

</div>

---

**Keywords:** DeepSeek AI, macOS app, DeepSeek desktop, native macOS, AI chat, artificial intelligence, DeepSeek wrapper, Swift app, macOS application, free AI app, open source AI, lightweight AI app
