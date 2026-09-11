import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // Scene-based launch can register Flutter plugins before
    // application(_:didFinishLaunchingWithOptions:) returns. Provide the
    // Maps key first so GMSMapView never starts uninitialized.
    AppDelegate.provideGoogleMapsAPIKey()
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}
