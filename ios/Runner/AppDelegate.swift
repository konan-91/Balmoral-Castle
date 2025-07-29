import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "video_path_channel", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { call, result in
      if call.method == "getVideoPath",
         let args = call.arguments as? [String: Any],
         let name = args["name"] as? String,
         let path = Bundle.main.path(forResource: name, ofType: "mp4") {
          result(path)
      } else {
          result(FlutterError(code: "UNAVAILABLE", message: "Video path not available", details: nil))
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
