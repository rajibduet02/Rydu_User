import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static var didProvideMapsAPIKey = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    Self.provideGoogleMapsAPIKey()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // GMSServices must be initialized before the Google Maps plugin creates a map view.
    Self.provideGoogleMapsAPIKey()
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// Resolves the iOS Maps SDK key from Info.plist (`GMSApiKey` / xcconfig) then env.
  /// Must run before any `GMSMapView` / `GMSServices.sharedServices()` use.
  static func provideGoogleMapsAPIKey() {
    if didProvideMapsAPIKey {
      return
    }

    guard let apiKey = resolvedGoogleMapsAPIKey() else {
      let message = """
      Google Maps SDK for iOS is not initialized.
      GMSApiKey is missing or still a placeholder ($(GOOGLE_MAPS_IOS_API_KEY)).
      Set a real iOS Maps SDK key (bundle-id restricted), then rebuild:
        1. ios/Flutter/MapsSecrets.xcconfig (see MapsSecrets.xcconfig.example)
        2. export GOOGLE_MAPS_IOS_API_KEY=your_ios_maps_key
      Do not hardcode the key in AppDelegate.
      """
      #if DEBUG
      fatalError(message)
      #else
      NSLog("%@", message)
      #endif
      return
    }

    GMSServices.provideAPIKey(apiKey)
    didProvideMapsAPIKey = true
  }

  private static func resolvedGoogleMapsAPIKey() -> String? {
    let candidates: [String?] = [
      Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
      ProcessInfo.processInfo.environment["GOOGLE_MAPS_IOS_API_KEY"],
    ]
    return candidates
      .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
      .first { key in
        !key.isEmpty
          && !key.contains("$(")
          && !key.contains("GOOGLE_MAPS_IOS_API_KEY")
          && !key.localizedCaseInsensitiveContains("YOUR_")
          && key != "YOUR KEY HERE"
      }
  }
}
