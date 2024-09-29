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

    fun setSystemEnv(key: String, value: String) {
        val processEnvironmentClass = Class.forName("java.lang.ProcessEnvironment")
        processEnvironmentClass.getDeclaredField("theEnvironment").apply {
            isAccessible = true
            @Suppress("UNCHECKED_CAST")
            val env = get(null) as MutableMap<Any, Any>
            env[key] = value
        }
        processEnvironmentClass.getDeclaredField("theCaseInsensitiveEnvironment").apply {
            isAccessible = true
            @Suppress("UNCHECKED_CAST")
            val env = get(null) as MutableMap<Any, Any>
            env[key] = value
        }
    }

    setSystemEnv("GRADLE_LIBS_REPO_OVERRIDE", "$sourceFile\\.gradle\\m2")
}
