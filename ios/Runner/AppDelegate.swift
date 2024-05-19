import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    weak var registrar = self.registrar(forPlugin: "TestViewPlugin")

    let factory = TestViewFactory(messenger: registrar!.messenger())
    registrar!.register(factory, withId: "TestView")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class TestViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return TestView(frame: frame, viewIdentifier: viewId, arguments: args as? [String: Any] ?? [:], binaryMessenger: messenger)
  }
}

class TestView: NSObject, FlutterPlatformView {
  let frame: CGRect
  var viewId: Int64
  var messenger: FlutterBinaryMessenger
  var _view: UIView
  var channel: FlutterMethodChannel?
  let buffer = [UInt8](repeating: 0, count: 100*1024*1024)

  init(frame: CGRect, viewIdentifier viewId: Int64, arguments: [String: Any], binaryMessenger messenger: FlutterBinaryMessenger) {
    self.frame = frame
    self.viewId = viewId
    self.messenger = messenger

    _view = UIView()
    _view.backgroundColor = UIColor.blue
    super.init()

    let value = (arguments["value"] as? Int) ?? -1

    let label = UILabel()
    label.text = "Value: \(value)"
    label.textColor = UIColor.white
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
  
    _view.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: _view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: _view.centerYAnchor)
    ])
  }

  func view() -> UIView {
    return _view
  }
}
