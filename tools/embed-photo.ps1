# Usage : placer photo.jpg (ou .png) a la racine du depot, puis lancer  .\tools\embed-photo.ps1
# Peut etre relance autant de fois que tu veux (change de photo = relance).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$photo = Get-ChildItem -Path $root -File | Where-Object { $_.Name -match '^photo\.(jpg|jpeg|png)$' } | Select-Object -First 1
if (-not $photo) { Write-Host "ERREUR : aucune photo trouvee. Place photo.jpg a la racine du depot ($root)."; exit 1 }

Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($photo.FullName)
$w = 400; $h = 500; $ratio = $w / $h
if (($img.Width / $img.Height) -gt $ratio) { $ch = $img.Height; $cw = [int]($ch * $ratio); $cx = [int](($img.Width - $cw) / 2); $cy = 0 }
else { $cw = $img.Width; $ch = [int]($cw / $ratio); $cx = 0; $cy = [int](($img.Height - $ch) / 4) }
$bmp = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $w, $h), $cx, $cy, $cw, $ch, [System.Drawing.GraphicsUnit]::Pixel)
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$b64 = [Convert]::ToBase64String($ms.ToArray())
$g.Dispose(); $bmp.Dispose(); $img.Dispose()

$utf8 = New-Object System.Text.UTF8Encoding $false
foreach ($n in "hero", "about") {
  $tpl = [System.IO.File]::ReadAllText("$root\tools\$n.template.svg", $utf8)
  [System.IO.File]::WriteAllText("$root\src\$n.svg", $tpl.Replace("PHOTO_BASE64", $b64), $utf8)
}
Write-Host "OK : photo integree dans src\hero.svg et src\about.svg ($($photo.Name))."
