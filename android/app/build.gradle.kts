import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}
val mapsKeyFromProperty = project.findProperty("GOOGLE_MAPS_API_KEY") as String?
val mapsKeyFromLocal = localProperties.getProperty("GOOGLE_MAPS_API_KEY")
val mapsKeyFromEnv = System.getenv("GOOGLE_MAPS_ANDROID_API_KEY")
val googleMapsApiKey = (mapsKeyFromProperty
    ?: mapsKeyFromLocal
    ?: mapsKeyFromEnv
    ?: "")
    .trim()

require(googleMapsApiKey.isNotEmpty()) {
    """
    GOOGLE_MAPS_API_KEY is missing or empty.
    Add it to android/local.properties (gitignored), e.g.:
      GOOGLE_MAPS_API_KEY=your_android_maps_sdk_key
    Or set environment variable GOOGLE_MAPS_ANDROID_API_KEY.
    Do not put the real key in AndroidManifest.xml.
    """.trimIndent()
}

android {
    namespace = "com.rydu.user"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rydu.user"
        // Auth0 Android SDK: tenant domain + custom URL scheme for OAuth callback handling.
        // Must match Auth0 Allowed Callback URLs and lib/config/auth0_config.dart.
        // Google Maps: injected into main AndroidManifest meta-data via ${GOOGLE_MAPS_API_KEY}.
        manifestPlaceholders += mapOf(
            "auth0Domain" to "dev-5pz66h48u0jnn4sg.us.auth0.com",
            "auth0Scheme" to "com.rydu.user",
            "GOOGLE_MAPS_API_KEY" to googleMapsApiKey,
        )
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Apply only when the Firebase Android app config is present.
// Do not fabricate google-services.json; debug builds must still succeed without it.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
}
