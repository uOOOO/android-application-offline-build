# Android Application Offline Build Scripts for Windows

Sometimes we need to move existing projects to a private network environment.\
Of course, the best way is setting up an internal server.\
But if that's not possible, these scripts can help.

### Prerequisite

1. Copy the files in offline directory to your project root directory
2. Copy gradle distribution zip file to your project rootDir/gradle/wrapper/dists
    ```text
    // The distribution URL is in gradle/wrapper/gradle-wrapper.properties.
    // But download gradle-${version}-all.zip instead of gradle-${version}-bin.zip
    // and rename it to gradle-${version}-bin.zip
    distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
    ```

### Usage

1. Remove GRADLE_USER_HOME\caches\modules-2 directory\
   In most cases, GRADLE_USER_HOME is C:\Users\\${USER_NAME}\\.gradle
2. Open a project in Android Studio
3. Run gradle clean build task in Android Studio or run this command
   ```text
   PS > .\gradlew clean build [--refresh-dependencies]
   ```
4. Open terminal in Android Studio
5. Dot-source the script
   ```text
   PS > . .\gradle.offline.ps1
   ```
6. Copy dependencies to local maven directory rootDir/.gradle/m2
   ```text
   PS > createMavenLocal
   ```
7. Switch to offline build
   ```text
   PS > gradleOffline $true
   ```

### ETC

1. If you want to switch to online build, run this command.
   ```text
   PS > gradleOffline $false
   ```
2. If you want to create zip archive of local maven, run this command.
   Then, m2.zip file is created in rootDir/.gradle
   ```text
   PS > archiveMavenLocal
   ```
