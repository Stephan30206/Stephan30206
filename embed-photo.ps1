# Usage : placer photo.jpg a la racine du depot, puis lancer .\embed-photo.ps1
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Image]::FromFile((Resolve-Path "photo.jpg"))
$w = 400; $h = [int]($src.Height * $w / $src.Width)
$bmp = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($src, 0, 0, $w, $h)
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$b64 = [Convert]::ToBase64String($ms.ToArray())
foreach ($f in "src\hero.svg", "src\about.svg") {
  (Get-Content $f -Raw -Encoding UTF8).Replace("PHOTO_BASE64", $b64) | Set-Content $f -Encoding UTF8 -NoNewline
}
Write-Host "Photo integree."
