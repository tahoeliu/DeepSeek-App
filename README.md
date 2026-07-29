# DeepSeek Desktop App - Native macOS Wrapper

<div align="center">

A **native macOS application** wrapper for DeepSeek AI chat. Lightweight (~400KB) with native window management and system integration.

[![Swift Version](https://img.shields.io/badge/swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)]()
[![Size](https://img.shields.io/badge/size-~400KB-brightgreen.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

## ✨ Features

- **🚀 Native Performance** - Built with AppKit + WKWebView (no Electron, just ~400KB)
- **🎨 Minimalist Design** - Borderless window with no title text or toolbar buttons
- **🖱️ Draggable Title Area** - Hidden 48px drag band at window top
- **🔐 Login Persistence** - Maintains login state across sessions
- **🌐 Smart Navigation** - DeepSeek links stay in-app, external links open in browser
- **🇨🇳 Region Support** - Switch between Chinese/International versions via menu
- **🍎 Native Menus** - Standard macOS menus with keyboard shortcuts
- **🐳 Dock Integration** - App stays in Dock, click to reopen window

## 📸 Screenshots

<div align="center">

*Clean, native macOS interface for DeepSeek AI*

</div>

## 🚀 Installation

### Quick Install

1. Download `DeepSeek.app` from [Releases](https://github.com/tahoeliu/DeepSeek-App/releases)
2. Drag `DeepSeek.app` to your **Applications** folder
3. Launch the app (may need to right-click → Open on first run)

### Security Note

Since this is built locally without a paid developer account, you might see a Gatekeeper warning:

```bash
# Option 1: Right-click → Open (recommended)
# Option 2: Remove quarantine via command line
xattr -dr com.apple.quarantine ~/Applications/DeepSeek.app
open ~/Applications/DeepSeek.app
```

The app is **ad-hoc signed** (`codesign --sign -`) and safe to use.

## 🌏 Region Switching

DeepSeek uses the same URL (`https://chat.deepseek.com/`) for both Chinese and International versions. The login options are determined by your network region:

- **Chinese Network** → Shows phone number/WeChat login
- **International Network** → Shows email/Google login

### Switching Regions

Use the **Region** menu to switch:
- **国内版** - Chinese version
- **International** - English version

> **Pro Tip**: If you have an international email account, connect to a VPN/HK/TW node first, then select "International". Once logged in, your session persists even on mainland networks!

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

## 🛠️ Tech Stack

- **Swift 5.9+** - Core application logic
- **AppKit** - Native macOS UI framework
- **WebKit** - Web rendering engine
- **WKWebView** - Persistent data store for login state
- **No external dependencies** - Just Swift stdlib + system frameworks

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

## 🔧 Development

### Prerequisites

- macOS 10.15 or later
- Xcode Command Line Tools (`xcode-select --install`)
- Swift 5.9+ (included with macOS)

### Building from Source

```bash
# Clone the repository
git clone https://github.com/tahoeliu/DeepSeek-App.git
cd DeepSeek-App

# Build the app
./build.sh

# The built app will be in ./DeepSeek.app
```

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

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [DeepSeek](https://deepseek.com/) - The underlying AI chat service
- [Apple](https://developer.apple.com/) - AppKit and WebKit frameworks

## 📞 Support

- 📧 Email: [GitHub Issues](https://github.com/tahoeliu/DeepSeek-App/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/tahoeliu/DeepSeek-App/discussions)

---

<div align="center">

**Built with Swift for macOS ❤️**

</div>