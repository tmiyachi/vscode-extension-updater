code --list-extensions | ForEach-Object {
    $extensionName = $_
    Write-Output "check for update of $extensionName"
    $arr = code --install-extension  $extensionName --force 2>&1 | ForEach-Object { $_ -split " " }
    if ($arr.Contains("Corrupt")) {
        try {
            $packageFullName = $arr[5].Trim("'")
            $package = $packageFullName.Split(".")[0]
            $extension = $packageFullName.Split(".")[1]
            $version = $arr[9].Trim("v")
            $uri = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$package/vsextensions/$extension/$version/vspackage"
            $vsixfile = "$packageFullName.$version.vsix"
            Write-Output "Invoke-WebRequest $uri -OutFile $vsixfile"
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
