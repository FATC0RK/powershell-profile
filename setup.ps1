# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Function to install Nerd Fonts
function Install-NerdFonts {
    param (
        [string]$FontName = "CascadiaCode",
        [string]$FontDisplayName = "CaskaydiaCove NF",
        [string]$Version = "3.2.1"
    )

    try {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        if ($fontFamilies -notcontains "${FontDisplayName}") {
            $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
            $zipFilePath = "$env:TEMP\${FontName}.zip"
            $extractPath = "$env:TEMP\${FontName}"

            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($fontZipUrl)), $zipFilePath)

            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2
            }

            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
                If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                    $destination.CopyHere($_.FullName, 0x10)
                }
            }

            Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
        } else {
            Write-Host "Font ${FontDisplayName} already installed"
        }
    }
    catch {
        Write-Error "Failed to download or install ${FontDisplayName} font. Error: $_"
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}

# Profile creation or update
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of PowerShell & Create Profile directories if they do not exist.
        $profilePath = ""
        if ($PSVersionTable.PSEdition -eq "Core") {
            $profilePath = "$env:userprofile\Documents\Powershell"
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            $profilePath = "$env:userprofile\Documents\WindowsPowerShell"
        }

        if (!(Test-Path -Path $profilePath)) {
            New-Item -Path $profilePath -ItemType "directory"
        }

        Invoke-RestMethod https://raw.githubusercontent.com/FATC0RK/powershell-profile/refs/heads/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
        Write-Host "If you want to make any personal changes or customizations, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "Failed to create or update the profile. Error: $_"
    }
}
else {
    try {
        Get-Item -Path $PROFILE | Move-Item -Destination "oldprofile.ps1" -Force
        Invoke-RestMethod https://raw.githubusercontent.com/FATC0RK/powershell-profile/refs/heads/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
        Write-Host "Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "Failed to backup and update the profile. Error: $_"
    }
}

# OMP Install
try {
    winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh
}
catch {
    Write-Error "Failed to install Oh My Posh. Error: $_"
}

# Font Install
Install-NerdFonts -FontName "CascadiaCode" -FontDisplayName "CaskaydiaCove NF"

# Final check and message to the user
if ((Test-Path -Path $PROFILE) -and (winget list --name "OhMyPosh" -e) -and ($fontFamilies -contains "CaskaydiaCove NF")) {
    Write-Host "Setup completed successfully. Please restart your PowerShell session to apply changes."
} else {
    Write-Warning "Setup completed with errors. Please check the error messages above."
}

# Choco install
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
catch {
    Write-Error "Failed to install Chocolatey. Error: $_"
}

# Terminal Icons Install
try {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
}
catch {
    Write-Error "Failed to install Terminal Icons module. Error: $_"
}
# zoxide Install
try {
    winget install -e --id ajeetdsouza.zoxide
    Write-Host "zoxide installed successfully."
}
catch {
    Write-Error "Failed to install zoxide. Error: $_"
}

# SIG # Begin signature block
# MIIF+AYJKoZIhvcNAQcCoIIF6TCCBeUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCHNy6E/pm631DN
# 3pphU/vKlrdk8670YLZuSCNJSIOnNKCCA0wwggNIMIICMKADAgECAhB2Ar1EhQO1
# kkcuujT3xlgOMA0GCSqGSIb3DQEBCwUAMDwxDjAMBgNVBAMMBUFobWVkMSowKAYJ
# KoZIhvcNAQkBFhthaHVzc2FpbmFobWVkNDFAb3V0bG9vay5jb20wHhcNMjQxMTA5
# MDU1MzUyWhcNMjkxMjMxMjEwMDAwWjA8MQ4wDAYDVQQDDAVBaG1lZDEqMCgGCSqG
# SIb3DQEJARYbYWh1c3NhaW5haG1lZDQxQG91dGxvb2suY29tMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvAV0jLpa+TcosgVTtrCd94eU1t3s8xxATLaW
# Pkd4I7UaRYUOBaHAHuodt4eBUWh/5bMeXkuCNHZAfmR4kPgRImt/EF0S5S5ldQ11
# V+6qz5juKCY5xGbPajGvcDNsq5FhaogU6OVJPBBPnK9Y0hwRnN8lrXU/V6cLIaee
# p80Wi4xZRMTPL5K8xtaBUtxdjRiBsw103QqW8VzDvS6XmjYjfHMqNS8k3ciGc567
# XUkF9fqSDCMvP76ELgT2pMtwg5677MD0dYBBzrOAR7KFRZ14318JYYG8cbewKiLO
# 7czKBOxhMwJxlbqWUvAZNJTnRORcyntQi1A/91PG26HStaqkyQIDAQABo0YwRDAO
# BgNVHQ8BAf8EBAMCBaAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFM9d
# 7mryYcIPtUjNflHm9IzGhXKgMA0GCSqGSIb3DQEBCwUAA4IBAQBqu2EvpkdT66UY
# C3h6HlKPteJ/cDBKa+TGd7z4mIpmYahdY8476kZXRwPVehANuD+4D+11TixWdKK1
# NNmO+pfsgq0aeBO11ILJ5h9ILaWOSSlV/rMi/rY4LZEzeSjQq5uS6wMzfFa1bpy9
# U40ORo5fwS9vcTuyWa5Da+rN0mJVf9KhA1AbZPgIbUX6yIH17nCmxcvyOmpcS6gW
# ttbWRAGOYwhrES61Ky+AHSuvk0zM+L+N9qSjhR7L9PiI9t1+2fcdRGBXpTTkrX+a
# gAAkZdNJyxf/XdTVgnyRgxZDJxqYi1gcp4m6Ccxs19AftryV7G7UDewdw5aHYwsl
# GlgpT30uMYICAjCCAf4CAQEwUDA8MQ4wDAYDVQQDDAVBaG1lZDEqMCgGCSqGSIb3
# DQEJARYbYWh1c3NhaW5haG1lZDQxQG91dGxvb2suY29tAhB2Ar1EhQO1kkcuujT3
# xlgOMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAw
# GQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisG
# AQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIH9gJTWyT3svquThGu+XwzomFRBKJzci
# JBnjKglQM58WMA0GCSqGSIb3DQEBAQUABIIBAIrWzq9+EuPiPvaK/vKYiUUF1pTl
# Ga7Z7Sq1fd7jRC8ffddUSCGqeQ9XGP87hmiTUd63UFUcifyJWjBfiGDGYjIigrdQ
# mBuyp9ToyNtZ7cJSVKRnrRzjYuN1nywRVzC/sWpMtH30KDviWMC5FTJ9AZ2iepOv
# XXvE9K5w0KIxZKVR6U/9+F+oo4jqq8/qqFrfWkY8M6XahvlY/jAYKlMei0ALZK8P
# bjdnYnifnHTfzJd3WmQsmPuwcQTZfbxPVqRi6xtaSyF5oFYSFzFsTwXr37XIBNQx
# rLA1KhxfTm5hy3/xHrKkjq3zxpPb/1VPDKK5rjKQiA59JpfHCy9n/DkAi/M=
# SIG # End signature block
