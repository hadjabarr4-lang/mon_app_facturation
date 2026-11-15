plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mon_app_facturation"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

   signingConfigs {
    create("release") {
        storeFile = file("upload-keystore.jks")
        storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
        keyAlias = System.getenv("CM_KEY_ALIAS")
        keyPassword = System.getenv("CM_KEY_PASSWORD")
    }
}

    defaultConfig {
        applicationId = "com.example.mon_app_facturation"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}