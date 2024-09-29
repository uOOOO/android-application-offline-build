function checkWorkspace([string]$path) {
    return Test-Path $path -PathType Leaf
}

function createWorkspace {
    $xmlSettings = New-Object System.Xml.XmlWriterSettings
    $xmlSettings.Indent = $true
    $xmlWriter = [System.XML.XmlWriter]::Create("$pwd\.idea\a.xml", $xmlSettings)
    $xmlWriter.WriteStartElement("project") 
    $xmlWriter.WriteAttributeString("version", "4")

    $xmlWriter.WriteStartElement("component")
    $xmlWriter.WriteAttributeString("name", "AndroidGradleBuildConfiguration")

    $xmlWriter.WriteStartElement("option")
    $xmlWriter.WriteAttributeString("name", "COMMAND_LINE_OPTIONS")
    $xmlWriter.WriteAttributeString("value", "--init-script init.gradle.kts")

    $xmlWriter.WriteEndElement()
    $xmlWriter.WriteEndElement()
    $xmlWriter.WriteEndElement()
    $xmlWriter.Flush()
    $xmlWriter.Close()
}

function openWorkspace($path) {
    return [xml](Get-Content $path)
}

function selectXmlNode($xmlOrNode, $xpath) {
    return $xmlOrNode.SelectSingleNode($xpath)
}

function createComponentNode($xml) {
    $node = $xml.CreateElement("component")
    $node.SetAttribute("name", "AndroidGradleBuildConfiguration")
    return $node
}

function createOptionNode($xml) {
    $node = $xml.CreateElement("option")
    $node.SetAttribute("name", "COMMAND_LINE_OPTIONS")
    $node.SetAttribute("value", "--init-script init.gradle.kts")
    return $node
}

function setOptionNodeAttribute($node) {
    $node.SetAttribute("name", "COMMAND_LINE_OPTIONS")
    unsetOptionNodeAttribute($node)
    $value = $node.GetAttribute("value")
    $value = "$value".trim() + " --init-script init.gradle.kts"
    $node.SetAttribute("value", $value)
}

function unsetOptionNodeAttribute($node) {
    $options = $node.value -split '-?(?=\s-)'
    $concatOptions = ""
    foreach ($option in $options) {
        $option = $option.trim()
        if ($option.startsWith("--init-script")) {
            continue
        }
        if ($concatOptions) {
            $concatOptions += " "
        }
        $concatOptions += $option
    }
    $node.value = $concatOptions
}

function insert($xml) {
    $componentNode = $workspace.SelectSingleNode("project/component[@name='AndroidGradleBuildConfiguration']")
    if (!$componentNode) {
        $componentNode = createComponentNode($xml)
        $optionNode = createOptionNode($xml)
        $componentNode.AppendChild($optionNode)
        $xml.project.AppendChild($componentNode)
    } else {
        $optionNode = $componentNode.SelectSingleNode("option")
        if ($optionNode) {
            setOptionNodeAttribute($optionNode)
        } else {
            $optionNode = createOptionNode($xml)
            $componentNode.AppendChild($optionNode)
        }
    }
}

function delete($node) {
    unsetOptionNodeAttribute($node)
}

function save($xml, $path) {
    $xml.Save("$pwd" + "$path")
}

function changeGradleDistributionUrl([bool]$isOffline) {
    $path = "gradle\wrapper\gradle-wrapper.properties"
    $content = Get-Content $path
    $content = $content | ForEach-Object {
        if ($_.startsWith("distributionUrl")) {
            if ($isOffline) {
                $_ -replace "https\\://services.gradle.org/distributions", "dists"
            } else {
                $_ -replace "dists",  "https\://services.gradle.org/distributions"
            }
        } else {
            $_
        }
    }
    Set-Content $path $content
}

$workspacePath = ".\.idea\workspace.xml"

function on() {
    changeGradleDistributionUrl($true)
    if (checkWorkspace $workspacePath) {
        $workspace = openWorkspace $workspacePath
        insert($workspace)
        save $workspace $workspacePath
    } else {
        createWorkspace
    }
}

function off() {
    changeGradleDistributionUrl($false)
    if (checkWorkspace $workspacePath) {
        $workspace = openWorkspace $workspacePath
        $optionNode = selectXmlNode $workspace "project/component[@name='AndroidGradleBuildConfiguration']/option[@name='COMMAND_LINE_OPTIONS']"
        if ($optionNode) {
            delete($optionNode)
            save $workspace $workspacePath
        }
    }
}

function gradleOffline([bool]$on) {
    if ($on) {
        on
    } else {
        off
    }
}

function createMavenLocal {
    .\gradlew -b local.maven.gradle.kts createMavenLocal
}

function archiveMavenLocal {
    .\gradlew -b local.maven.gradle.kts archiveMavenLocal
}

# if (!$args) {
#     echo "No argument. Please enter argument 'on' or 'off'."
#     return
# }
#
# $arg = $args[0]
#
# if ($arg -ne "on" -and $arg -ne "off") {
#     echo "Wrong argument. Please enter argument 'on' or 'off'."
#     return
# }
#
# if ($arg -eq "on") {
#     on
# } elseif ($arg -eq "off") {
#     off
# }