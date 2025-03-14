import Flutter
import UIKit

//flutter_local_notifications の利用のためのフレームワーク追加
import UserNotifications 

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // iOS 10.0以上の場合、UNUserNotificationCenterのデリゲートを設定
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self 
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
