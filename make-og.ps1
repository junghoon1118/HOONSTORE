# 링크 미리 보기용 대표 이미지(1200x630, assets/og.png)를 그린다.
Add-Type -AssemblyName System.Drawing
$root = $PSScriptRoot
$W = 1200; $H = 630
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'
$g.Clear([System.Drawing.ColorTranslator]::FromHtml('#14161b'))
$white = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#f2f3f5'))
$gray  = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#9aa0ab'))
$yellow = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#ffd43b'))

# 로고: HOON(형광펜 밑줄) + STORE
$fBig = New-Object System.Drawing.Font 'Arial Black', 88, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$sz = $g.MeasureString('HOON', $fBig)
$g.FillRectangle($yellow, 74, 228, [float]($sz.Width - 26), 34)
$g.DrawString('HOON', $fBig, $white, 70, 150)
$fStore = New-Object System.Drawing.Font 'Arial', 34, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString('S T O R E', $fStore, $gray, [float](70 + $sz.Width - 6), 196)

$fKo = New-Object System.Drawing.Font 'Malgun Gothic', 36, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
$fKo2 = New-Object System.Drawing.Font 'Malgun Gothic', 26, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString('설치비 없이 홈 화면에', $fKo, $white, 74, 312)
$g.DrawString('추가하는 웹앱 스토어', $fKo, $white, 74, 362)
$g.DrawString('junghoon1118.github.io/HOONSTORE', $fKo2, $gray, 76, 432)

# 오른쪽: 첫 앱 화면 두 장을 폰 모양으로
function Phone($path, $x, $y, $w, $angle) {
  $img = [System.Drawing.Image]::FromFile($path)
  $h = [int]($w * 812 / 375)
  $state = $g.Save()
  $g.TranslateTransform([float]($x + $w/2), [float]($y + $h/2)); $g.RotateTransform([float]$angle); $g.TranslateTransform([float](-$w/2), [float](-$h/2))
  $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#0b0d10'))), -8, -8, [float]($w + 16), [float]($h + 16))
  $src = New-Object System.Drawing.Rectangle 0, 0, $img.Width, ([int]($img.Width * 812 / 375))
  $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $w, $h), $src, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Restore($state); $img.Dispose()
}
Phone (Join-Path $root 'assets\apps\sqld\screen-3.jpg') 780 120 210 -6
Phone (Join-Path $root 'assets\apps\sqld\screen-2.jpg') 950 70 210 5

$bmp.Save((Join-Path $root 'assets\og.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output 'og.png done'
