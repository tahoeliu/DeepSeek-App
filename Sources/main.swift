//
//  DeepSeek - a minimalist native macOS wrapper for chat.deepseek.com
//

import AppKit
import WebKit

/// A web view that also acts like a transparent title bar: grabbing the very top
/// edge of the window drags it. The top `dragBandHeight` points form the drag zone;
/// everywhere else behaves like a normal web view.
final class DragWebView: WKWebView {
    var dragBandHeight: CGFloat = 48

    override func mouseDown(with event: NSEvent) {
        let top = window?.frame.height ?? 0
        if event.locationInWindow.y >= top - dragBandHeight {
            window?.performDrag(with: event)
        } else {
            super.mouseDown(with: event)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    static let homeURL = URL(string: "https://chat.deepseek.com/")!
    private static let observedKeys = ["title", "url"]

    private var window:    NSWindow!
    private var webView:   DragWebView!
    private var container: NSView!

    // MARK: App lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        applyLocaleOverride()   // must run before the web view is created
        buildWebView()
        buildWindow()
        buildMenu()
        loadHome()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !window.isVisible { window.makeKeyAndOrderFront(nil) }
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // stay alive; user can quit via menu or Cmd+Q
    }

    // MARK: Home URL / locale

    private func currentHomeURL() -> URL {
        if let raw = UserDefaults.standard.string(forKey: "homeURLString"),
           let u = URL(string: raw.trimmingCharacters(in: .whitespaces)),
           u.scheme?.hasPrefix("http") == true {
            return u
        }
        return Self.homeURL
    }

    private func loadHome() {
        webView.load(URLRequest(url: currentHomeURL()))
    }

    /// WebKit reads the system language at web-view creation time, so to switch
    /// between the domestic (zh-CN) and international (en-US) login page we set
    /// AppleLanguages and recreate the web view.
    private func applyLocaleOverride() {
        if let loc = UserDefaults.standard.string(forKey: "localeOverride") {
            UserDefaults.standard.set([loc], forKey: "AppleLanguages")
        }
    }

    private func recreateWebView() {
        for kp in AppDelegate.observedKeys { webView.removeObserver(self, forKeyPath: kp) }
        webView.removeFromSuperview()
        buildWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        loadHome()
    }

    @objc func useDomestic() {
        UserDefaults.standard.set("zh-CN", forKey: "localeOverride")
        UserDefaults.standard.set(Self.homeURL.absoluteString, forKey: "homeURLString")
        recreateWebView()
    }

    @objc func useInternational() {
        UserDefaults.standard.set("en-US", forKey: "localeOverride")
        UserDefaults.standard.set(Self.homeURL.absoluteString, forKey: "homeURLString")
        recreateWebView()
    }

    @objc func setCustomURL() {
        let alert = NSAlert()
        alert.messageText = "设置首页地址"
        alert.informativeText = "输入 DeepSeek 网页版地址(例如 https://chat.deepseek.com/)"
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 24))
        field.stringValue = currentHomeURL().absoluteString
        field.placeholderString = Self.homeURL.absoluteString
        alert.accessoryView = field
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")
        if alert.runModal() == .alertFirstButtonReturn {
            let v = field.stringValue.trimmingCharacters(in: .whitespaces)
            if let u = URL(string: v), u.scheme?.hasPrefix("http") == true {
                UserDefaults.standard.set(u.absoluteString, forKey: "homeURLString")
                loadHome()
            }
        }
    }

    // MARK: Web

    private func buildWebView() {
        let cfg = WKWebViewConfiguration()
        cfg.applicationNameForUserAgent = "Version/18.0 Safari/605.1.15"
        cfg.defaultWebpagePreferences = WKWebpagePreferences()

        let controller = WKUserContentController()
        controller.addUserScript(makeLogoHiderScript())
        cfg.userContentController = controller

        let wv = DragWebView(frame: .zero, configuration: cfg)
        wv.allowsBackForwardNavigationGestures = true
        wv.allowsMagnification = true

        for kp in AppDelegate.observedKeys {
            wv.addObserver(self, forKeyPath: kp, options: .new, context: nil)
        }
        wv.navigationDelegate = NavigationDelegate.shared
        NavigationDelegate.shared.onOpenExternal = { url in
            NSWorkspace.shared.open(url)
        }
        self.webView = wv
    }

    /// Injects a <style> rule that hides the DeepSeek sidebar logo. We use `!important`
    /// on purpose: the logo <img> carries a React-controlled inline `style.display`, which
    /// would otherwise overwrite a plain `el.style.display = 'none'`. A stylesheet rule with
    /// `!important` wins over inline styles, so the logo stays hidden even after React
    /// re-renders. The style is re-applied as the SPA mounts/updates.
    private func makeLogoHiderScript() -> WKUserScript {
        let js = """
        (function(){
          function addStyle(){
            if (document.getElementById('ds-hide-logo')) return;
            var s = document.createElement('style');
            s.id = 'ds-hide-logo';
            s.textContent =
              '[class*="site_logo"]{display:none !important;}' +
              'img.site_logo_img{display:none !important;}';
            (document.head || document.documentElement).appendChild(s);
          }
          addStyle();
          var scheduled = false;
          function schedule(){ if (scheduled) return; scheduled = true;
            setTimeout(function(){ scheduled = false; addStyle(); }, 300); }
          try { new MutationObserver(schedule).observe(document.documentElement,
                  {childList:true, subtree:true}); } catch(e){}
          window.addEventListener('load', addStyle);
          setTimeout(addStyle, 500); setTimeout(addStyle, 1500); setTimeout(addStyle, 3000);
        })();
        """
        return WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    // MARK: Window & Toolbar

    private func buildWindow() {
        // Full-size content view: the web page renders all the way to the top, with no
        // custom strip. The (still-visible) traffic lights float over the page's own
        // chrome; the DeepSeek logo is hidden inside the page via injected CSS, so there
        // is no clash at the top-left.
        let style: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1100, height: 740),
                          styleMask: style, backing: .buffered, defer: false)
        window.title = "DeepSeek"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 720, height: 520)

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = .white
        window.center()

        setupContent()
    }

    /// Builds the content: a full-size web view whose page renders to the very top. The
    /// DeepSeek logo is hidden inside the page via injected CSS, and the top edge of the
    /// web view itself acts as a transparent title bar (see `DragWebView`), so the window
    /// is both clean and movable.
    private func setupContent() {
        container = NSView(frame: .zero)
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.white.cgColor

        webView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        window.contentView = container
    }

    // MARK: Menu

    private func buildMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About DeepSeek", action: nil, keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Hide DeepSeek",  action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let hideOthers = NSMenuItem(title: "Hide Others",
                                    action: #selector(NSApplication.hideOtherApplications(_:)),
                                    keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(hideOthers)
        appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        let quit = NSMenuItem(title: "Quit DeepSeek",
                              action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quit)
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)

        // File menu
        mainMenu.addItem(buildMenu("File", [
            ("Open in Browser", #selector(openInBrowser), "b", [.command]),
            ("Reload Page",     #selector(reload),        "r", [.command]),
            ("Go Back",         #selector(goBack),        "[", [.command]),
            ("Go Forward",      #selector(goForward),     "]", [.command]),
            ("Home",            #selector(goHome),        "h", [.command, .shift]),
        ]))

        // Edit menu (standard cut/copy/paste, routed via web view's responder chain)
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(NSMenuItem(title: "Cut",   action: #selector(NSText.cut(_:)),   keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy",  action: #selector(NSText.copy(_:)),  keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        let editItem = NSMenuItem(); editItem.submenu = editMenu; mainMenu.addItem(editItem)

        // View menu
        mainMenu.addItem(buildMenu("View", [
            ("Reload Page",     #selector(reload),        "r", [.command]),
            ("Back",            #selector(goBack),        "[", [.command]),
            ("Forward",         #selector(goForward),     "]", [.command]),
            ("Home",            #selector(goHome),        "h", [.command, .shift]),
            ("Open in Browser", #selector(openInBrowser), "b", [.command]),
            ("Copy URL",        #selector(copyURL),       "l", [.command, .shift]),
        ]))

        // Region menu (domestic / international / custom URL)
        let regionMenu = NSMenu(title: "Region")
        regionMenu.addItem(withTitle: "国内版 (中文)", action: #selector(useDomestic),     keyEquivalent: "")
        regionMenu.addItem(withTitle: "国际版 (English)", action: #selector(useInternational), keyEquivalent: "")
        regionMenu.addItem(NSMenuItem.separator())
        regionMenu.addItem(withTitle: "设置首页地址…", action: #selector(setCustomURL), keyEquivalent: "")
        let regionItem = NSMenuItem(); regionItem.submenu = regionMenu; mainMenu.addItem(regionItem)

        // Window menu
        let winMenu = NSMenu(title: "Window")
        winMenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        winMenu.addItem(NSMenuItem.separator())
        winMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        winMenu.addItem(withTitle: "Zoom",     action: #selector(NSWindow.performZoom(_:)),     keyEquivalent: "")
        let wItem = NSMenuItem(); wItem.submenu = winMenu; mainMenu.addItem(wItem)
        NSApp.windowsMenu = winMenu

        // Help menu
        mainMenu.addItem(buildMenu("Help", [
            ("DeepSeek Website", #selector(openWeb), "", []),
        ], last: true))

        NSApp.mainMenu = mainMenu
    }

    private func buildMenu(_ title: String,
                           _ entries: [(String, Selector, String, NSEvent.ModifierFlags)],
                           last: Bool = false) -> NSMenuItem {
        let parent = NSMenuItem()
        let menu = NSMenu(title: title)
        for (label, action, key, mods) in entries {
            let item = NSMenuItem(title: label, action: action, keyEquivalent: key)
            item.keyEquivalentModifierMask = mods
            menu.addItem(item)
        }
        if !last { menu.addItem(NSMenuItem.separator()) }
        parent.submenu = menu
        return parent
    }

    // MARK: Actions

    @objc func goBack()       { webView.goBack() }
    @objc func goForward()    { webView.goForward() }
    @objc func reload()       { webView.reload() }
    @objc func goHome()       { loadHome() }

    @objc func openInBrowser() {
        if let u = webView.url { NSWorkspace.shared.open(u) }
    }
    @objc func openWeb() { NSWorkspace.shared.open(URL(string: "https://www.deepseek.com")!) }

    @objc func copyURL() {
        guard let u = webView.url else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(u.absoluteString, forType: .string)
    }

    // MARK: KVO

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let keyPath else { return }
        switch keyPath {
        case "title", "url":
            // Keep the (hidden) window title in sync for the Dock / Window menu,
            // but it is never drawn over the page.
            if let t = webView.title, !t.isEmpty {
                window.title = t
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - Navigation policy: keep things inside deepseek.com; send outsiders to the browser.

final class NavigationDelegate: NSObject, WKNavigationDelegate {
    static let shared = NavigationDelegate()
    var onOpenExternal: ((URL) -> Void)?

    func isDeepSeek(_ u: URL) -> Bool {
        guard let host = u.host else { return false }
        return host == "deepseek.com" || host.hasSuffix(".deepseek.com")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // page loaded
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            decisionHandler(.allow); return
        }
        if let url = navigationAction.request.url {
            if isDeepSeek(url) || url.scheme == "about" {
                decisionHandler(.allow)
            } else {
                onOpenExternal?(url)
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let u = navigationAction.request.url {
            onOpenExternal?(u)
        }
        return nil
    }
}

// MARK: - Entry point

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
