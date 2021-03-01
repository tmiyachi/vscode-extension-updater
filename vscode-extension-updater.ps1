code --list-extensions | ForEach-Object {
    $extensionName = $_

    $arr = code --install-extension  $extensionName --force | ForEach-Object { $_ -split " " }
    if ($arr.Contains("Corrupt")) {
        try {
            $packageFullName = $arr[5].Trim("'")
            $package = $packageFullName.Split(".")[0]
            $extension = $packageFullName.Split(".")[1]
            $version = $arr[9].Trim("v")
            $uri = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$package/vsextensions/$extension/$version/vspackage"
            $vsixfile = "$packageFullName.$version.vsix"
            Write-Output "download extention $vsixfile"
            Invoke-WebRequest $uri -OutFile $vsixfile

            $res = code --install-extension .\$vsixfile | ForEach-Object { $_ -split " " }
            if ($res.Contains("successfully")) {
                Remove-Item $vsixfile
            }
        }
        catch [Exception] {
            Write-Output "fail to download extension $packageFullName"
            Write-Output "extension url is $uri"
        }
    }
}
