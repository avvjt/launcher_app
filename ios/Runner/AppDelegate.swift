import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var blurEffectView: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    // Add a blur effect when the app moves to the background (optional)
    addBlurEffect()
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Remove the blur effect or show the lock screen when the app comes to the foreground
    removeBlurEffect()
    showLockScreenIfNeeded()
  }

  // Add a blur effect to hide sensitive content
  func addBlurEffect() {
    let blurEffect = UIBlurEffect(style: .dark)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView?.frame = window?.frame ?? UIScreen.main.bounds
    if let blurView = blurEffectView {
      window?.addSubview(blurView)
    }
  }

  // Remove the blur effect when the app becomes active again
  func removeBlurEffect() {
    blurEffectView?.removeFromSuperview()
    blurEffectView = nil
  }

  // Show lock screen if the app is locked
  func showLockScreenIfNeeded() {
    let isLocked = true // Replace with actual logic to check if the app is locked
    if isLocked {
      // Present the lock screen view controller
      let lockScreenViewController = UIViewController()
      lockScreenViewController.view.backgroundColor = .white
      lockScreenViewController.modalPresentationStyle = .fullScreen
      window?.rootViewController?.present(lockScreenViewController, animated: false, completion: nil)
    }
  }
}
