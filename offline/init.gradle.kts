@file:Suppress("UnstableApiUsage")

initscript {
    gradle.beforeSettings {
        val localMavenDir = File(checkNotNull(sourceFile?.parent) + "/.gradle/m2")
        if (!localMavenDir.exists()) {
            logger.log(LogLevel.ERROR, "Not found local maven directory [$localMavenDir]")
        }

        val localMavenUri = localMavenDir.toURI()
        pluginManagement {
            repositories {
                maven(localMavenUri)
            }
        }

        dependencyResolutionManagement {
            repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
            repositories {
                maven(localMavenUri)
            }
        }
    }
}
