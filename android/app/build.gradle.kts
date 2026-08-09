plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.reduceco2now.co2diet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications 22.x requires core library desugaring
        // on Android (its plugin code uses java.time APIs backported via
        // desugar_jdk_libs) -- without this, release/debug builds fail with
        // "Dependency ':flutter_local_notifications' requires core library
        // desugaring to be enabled for :app."
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.reduceco2now.co2diet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // mobile_scanner 7.4.0 requires minSdk >= 21 (Android CameraX constraint)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // flutter_appauth requires this manifest placeholder to register the
        // OIDC redirect-URI scheme's intent-filter (07-RESEARCH.md Pitfall 2 --
        // lowercase scheme). Must match KeycloakConfig.redirectUrl's scheme
        // exactly ("com.reduceco2now.co2diet.auth://callback").
        manifestPlaceholders["appAuthRedirectScheme"] = "com.reduceco2now.co2diet.auth"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required by isCoreLibraryDesugaringEnabled above -- version pinned to
    // latest as of this fix (2026-07-28); see
    // https://dl.google.com/android/maven2/com/android/tools/desugar_jdk_libs/maven-metadata.xml
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
