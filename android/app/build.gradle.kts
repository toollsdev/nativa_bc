plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// --> Corrigido para Kotlin:
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())

    println("==== KEY PROPERTIES DEBUG ====")
    println("keyAlias: ${keystoreProperties["keyAlias"]}")
    println("keyPassword: ${keystoreProperties["keyPassword"]}")
    println("storeFile: ${keystoreProperties["storeFile"]}")
    println("storePassword: ${keystoreProperties["storePassword"]}")
    println("===============================")
} else {
    println("Arquivo key.properties NÃO encontrado!")
}


android {
    namespace = "com.ez1.nativabc"
    compileSdk = flutter.compileSdkVersion

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.ez1.nativabc"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as? String ?: ""
        keyPassword = keystoreProperties["keyPassword"] as? String ?: ""
        storeFile = file(keystoreProperties["storeFile"] as? String ?: "")
        storePassword = keystoreProperties["storePassword"] as? String ?: ""
    }
}


    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
