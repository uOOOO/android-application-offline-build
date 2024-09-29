tasks.register<Sync>("createMavenLocal") {
    from(File(gradle.gradleUserHomeDir, "caches/modules-2/files-2.1"))

    val intoPath = "${rootDir}/.gradle/m2"
    into(intoPath)

    duplicatesStrategy = DuplicatesStrategy.INCLUDE
    includeEmptyDirs = false

    val notRealFilename = lazy { mutableListOf<Pair<String, String>>() }
    eachFile {
        val (packageName, artifactName, version, parentDirName, fileName) = path.split('/')
        path = packageName.replace('.', '/') +
                '/' + artifactName +
                '/' + version +
                '/' + fileName

        Util.getRealFileName(packageName, artifactName, version, fileName)?.run {
            val from = file.absolutePath
            val to = destinationDir.absolutePath + "/$this"
            notRealFilename.value.add(from to to)
        }
    }

    doLast {
        notRealFilename.value.forEach { (from, to) ->
            File(to).takeIf { !it.exists() }?.let { File(from).copyTo(it) }
        }
    }
}

object Util {
    fun getRealFileName(
        packageName: String,
        artifactName: String,
        version: String,
        fileName: String
    ): String? {
        if (!fileName.endsWith(".jar") && !fileName.endsWith(".aar")) {
            return null
        }
        val isSource =
            fileName.endsWith("-sources.jar") &&
                    !fileName.endsWith("-${version}-sources.jar")
        val isJavadoc =
            fileName.endsWith("-javadoc.jar") &&
                    !fileName.endsWith("-${version}-javadoc.jar")
        val isArtifact =
            !fileName.endsWith("-sources.jar") &&
                    !fileName.endsWith("-javadoc.jar") &&
                    (fileName.endsWith(".jar") && !fileName.endsWith("-${version}.jar")) ||
                    (fileName.endsWith(".aar") && !fileName.endsWith("-${version}.aar"))

        if (!isSource && !isJavadoc && !isArtifact) {
            return null
        }

        return packageName.replace('.', '/') +
                '/' + artifactName +
                '/' + version +
                '/' + artifactName + '-' + version +
                when {
                    isSource -> "-sources.jar"
                    isJavadoc -> "-javadoc.jar"
                    else -> ".${fileName.substringAfterLast('.')}"
                }
    }
}

tasks.register<Zip>("archiveMavenLocal") {
    dependsOn("createMavenLocal")
    from("${rootDir}/.gradle/m2")
    archiveFileName.set("m2.zip")
    destinationDirectory.set(file("$rootDir/.gradle"))
    includeEmptyDirs = false
}
