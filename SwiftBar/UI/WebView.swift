import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let request: URLRequest
    let zoomFactor: CGFloat

    init(request: URLRequest, zoomFactor: CGFloat = 1.0) {
        self.request = request
        self.zoomFactor = zoomFactor
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ webView: WKWebView, context _: Context) {
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            if parent.zoomFactor != 1.0 {
                applyZoom(to: webView, scale: parent.zoomFactor)
            }
        }

        private func applyZoom(to webView: WKWebView, scale: CGFloat) {
            let zoomScript = """
            (function() {
                document.body.style.transformOrigin = 'top left';
                document.body.style.transform = 'scale(\(scale))';
                document.body.style.width = '\(100 / scale)%';
                document.documentElement.style.overflow = 'auto';
            })();
            """
            webView.evaluateJavaScript(zoomScript, completionHandler: nil)
        }
    }
}
