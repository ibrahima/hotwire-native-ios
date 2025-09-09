import UIKit
import WebKit

/// A base controller to use or subclass that handles bridge lifecycle callbacks.
/// Use `Hotwire.registerBridgeComponents(_:)` to register bridge components.
open class HotwireWebViewController: VisitableViewController, BridgeDestination {
    public lazy var bridgeDelegate = BridgeDelegate(
        location: initialVisitableURL.absoluteString,
        destination: self,
        componentTypes: Hotwire.bridgeComponentTypes
    )

    // MARK: View lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonDisplayMode = Hotwire.config.backButtonDisplayMode
        view.backgroundColor = .systemBackground

        if Hotwire.config.showDoneButtonOnModals {
            addDoneButtonToModals()
        }

        bridgeDelegate.onViewDidLoad()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bridgeDelegate.onViewWillAppear()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bridgeDelegate.onViewDidAppear()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bridgeDelegate.onViewWillDisappear()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bridgeDelegate.onViewDidDisappear()

        // Defensive cleanup: ensure any right bar buttons added by bridge components
        // do not persist beyond this view controller's lifetime (e.g., after replace_root).
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
    }

    // MARK: Visitable

    override open func visitableDidActivateWebView(_ webView: WKWebView) {
        super.visitableDidActivateWebView(webView)
        bridgeDelegate.webViewDidBecomeActive(webView)
    }

    override open func visitableDidDeactivateWebView() {
        super.visitableDidDeactivateWebView()
        bridgeDelegate.webViewDidBecomeDeactivated()
    }

    // MARK: Private

    private func addDoneButtonToModals() {
        if presentingViewController != nil {
            let action = UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: action)
        }
    }
}
