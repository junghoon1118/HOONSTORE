# Draws the HOONSTORE app icon (192 and 512 PNG): a bold "H" on ink with a yellow marker stripe.
Add-Type -AssemblyName System.Drawing
$dir = Join-Path $PSScriptRoot 'icons'
New-Item -ItemType Directory -Force $dir | Out-Null

foreach ($size in 192, 512) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.TextRenderingHint = 'AntiAliasGridFit'
  $k = $size / 512.0
  $g.Clear([System.Drawing.ColorTranslator]::FromHtml('#14161b'))

  # yellow marker stripe behind the lower part of the letter
  $yellow = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#ffd43b'))
  $g.FillRectangle($yellow, [float](140*$k), [float](300*$k), [float](232*$k), [float](70*$k))

  # bold H drawn as three bars so it does not depend on installed fonts
  $white = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#f2f3f5'))
  $g.FillRectangle($white, [float](160*$k), [float](140*$k), [float](58*$k), [float](232*$k))
  $g.FillRectangle($white, [float](294*$k), [float](140*$k), [float](58*$k), [float](232*$k))
  $g.FillRectangle($white, [float](160*$k), [float](228*$k), [float](192*$k), [float](52*$k))

  $bmp.Save((Join-Path $dir "icon-$size.png"), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}
Write-Output "icons done"
