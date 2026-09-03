allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// storage_space 1.2.0 (Plan 09-02, no newer pub.dev release exists as of
// 2026-09-03) hardcodes compileSdkVersion 33 in its own android/build.gradle.
// AGP's AAR-metadata check now fails the build because several of its
// transitive androidx deps (fragment:1.7.1, window:1.2.0, exifinterface:1.4.1,
// annotation-experimental:1.4.0, lifecycle-process:2.7.0) require compiling
// against API >=34. This can't be fixed from app/build.gradle.kts -- that
// only controls the app module's own compileSdk, not a third-party
// subproject's -- so raise it here for every Android library subproject that
// declares a compileSdk below the floor these deps need. Only ever raises,
// never lowers (flutter_secure_storage already self-declares 37 and must
// stay there).
subprojects {
    // Guarded against the ":app" subprojects block above, which calls
    // evaluationDependsOn(":app") for every subproject -- for :app itself
    // that eagerly finishes :app's evaluation before this block's own
    // afterEvaluate registration runs, and Gradle refuses afterEvaluate on
    // an already-evaluated project. Run immediately in that case instead.
    val raiseCompileSdkFloor: () -> Unit = {
        val libraryExtension =
            extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        if (libraryExtension != null && (libraryExtension.compileSdk ?: 0) < 36) {
            libraryExtension.compileSdk = 36
        }
    }
    if (state.executed) raiseCompileSdkFloor() else afterEvaluate { raiseCompileSdkFloor() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
