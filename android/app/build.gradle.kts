plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.agribot"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.agribot"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ✅ Add this block to fix META-INF/DEPENDENCIES conflict
    packaging {
        resources {
            excludes += "META-INF/DEPENDENCIES"
        }
    }
}


dependencies {
    // Already added
    implementation("joda-time:joda-time:2.12.7")

    // Modern, Android-safe HTTP client
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    // ✅ NEW: Add Joda-Convert (needed for Joda-Time)
    implementation("org.joda:joda-convert:2.2.3")

    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    implementation("com.google.code.gson:gson:2.10.1")


    // ✅ NEW: Add Javax.naming API (needed for Apache HTTP SSL stuff)
    implementation("com.sun.activation:javax.activation:1.2.0") // For javax.* (optional workaround)
    implementation("com.sun.jndi:cosnaming:1.2.1") // Best effort workaround for javax.naming

    
}


flutter {
    source = "../.."
}
