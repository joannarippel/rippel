# C:\Snort\alert_popup.ps1
# Watches Snort alert file and shows a Windows popup you can screenshot.
# Mode: MessageBox (blocks until you click OK)

$path = "C:\Snort\log\alert.ids"

# Ensure the file exists
if (-not (Test-Path $path)) {
    New-Item -Path $path -ItemType File -Force | Out-Null
}

# Needed for MessageBox
Add-Type -AssemblyName PresentationFramework

function Show-Popup([string]$msg) {
    $safe = ($msg -replace '\s+', ' ').Trim()
    if ($safe.Length -gt 800) { $safe = $safe.Substring(0, 800) + "..." }

    # Blocking popup (easy to screenshot)
    [System.Windows.MessageBox]::Show($safe, "Snort Alert") | Out-Null
}

# Start tailing from end of file (so you only get NEW alerts)
$lastLen = (Get-Item $path).Length

while ($true) {
    Start-Sleep -Milliseconds 400

    $item = Get-Item $path

    # Handle truncation / rotation
    if ($item.Length -lt $lastLen) { $lastLen = 0 }

    # If file grew, read only new bytes
    if ($item.Length -gt $lastLen) {
        $fs = [System.IO.File]::Open($path, 'Open', 'Read', 'ReadWrite')
        $fs.Seek($lastLen, [System.IO.SeekOrigin]::Begin) | Out-Null
        $sr = New-Object System.IO.StreamReader($fs)
        $newText = $sr.ReadToEnd()
        $sr.Close(); $fs.Close()

        $lastLen = $item.Length

        foreach ($line in ($newText -split "`r?`n")) {
            $l = $line.Trim()
            if ($l) {
                Show-Popup ("Snort: " + $l)
            }
        }
    }
}
