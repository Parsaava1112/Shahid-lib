android {
    namespace = "com.example.shahid_suleimani_library"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.shahid_suleimani_library"
        minSdk = 21
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }
}