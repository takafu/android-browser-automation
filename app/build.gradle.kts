plugins {
    id("com.android.application") version "8.7.3"
    id("org.jetbrains.kotlin.android") version "2.2.21"
}

android {
    namespace = "io.github.takafu.webdroid"
    compileSdk = 34

    defaultConfig {
        applicationId = "io.github.takafu.webdroid"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.webkit:webkit:1.8.0")
    implementation("org.nanohttpd:nanohttpd:2.3.1")
    implementation("com.google.code.gson:gson:2.10.1")
}
