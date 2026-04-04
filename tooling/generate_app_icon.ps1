Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $root 'assets\branding'
$outputPath = Join-Path $outputDir 'hanbit-app-icon-1024.png'

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$size = 1024
$bitmap = New-Object System.Drawing.Bitmap $size, $size
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.Clear([System.Drawing.Color]::Transparent)

function New-RoundedRectanglePath {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [float]$Radius
    )

    $diameter = $Radius * 2
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

$bgRect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $bgRect,
    [System.Drawing.ColorTranslator]::FromHtml('#20322D'),
    [System.Drawing.ColorTranslator]::FromHtml('#314A43'),
    65
)
$bgPath = New-RoundedRectanglePath -X 48 -Y 48 -Width 928 -Height 928 -Radius 220
$graphics.FillPath($bgBrush, $bgPath)

$haloBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(28, 247, 240, 224))
$graphics.FillEllipse($haloBrush, 122, 136, 780, 780)

$orbBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(34, 250, 244, 230))
$graphics.FillEllipse($orbBrush, 214, 188, 596, 596)

$jarShadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(34, 0, 0, 0))
$jarShadowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$jarShadowPath.AddEllipse(294, 262, 436, 478)
$graphics.FillPath($jarShadowBrush, $jarShadowPath)

$jarBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#F6F0E4'))
$jarPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$jarPath.AddBezier(404, 244, 304, 244, 270, 318, 286, 404)
$jarPath.AddBezier(286, 404, 298, 528, 314, 672, 424, 744)
$jarPath.AddBezier(424, 744, 478, 778, 546, 778, 600, 744)
$jarPath.AddBezier(600, 744, 710, 672, 726, 528, 738, 404)
$jarPath.AddBezier(738, 404, 754, 318, 720, 244, 620, 244)
$jarPath.AddBezier(620, 244, 574, 236, 450, 236, 404, 244)
$jarPath.CloseFigure()
$graphics.FillPath($jarBrush, $jarPath)

$jarRimPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(84, 207, 191, 165)), 7
$jarRimPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$graphics.DrawPath($jarRimPen, $jarPath)

$highlightBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(72, 255, 255, 255))
$highlightPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$highlightPath.AddBezier(384, 312, 334, 350, 334, 474, 374, 612)
$highlightPath.AddBezier(374, 612, 394, 676, 428, 706, 458, 704)
$highlightPath.AddBezier(458, 704, 404, 664, 384, 548, 384, 312)
$highlightPath.CloseFigure()
$graphics.FillPath($highlightBrush, $highlightPath)

$baseShadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(30, 145, 123, 96))
$graphics.FillEllipse($baseShadowBrush, 388, 672, 248, 42)

$elementColors = @(
    '#5E8E59',
    '#C35433',
    '#D7B277',
    '#AEB7C5',
    '#4C7498'
)
$elementDots = @(
    @{ X = 446; Y = 332 },
    @{ X = 560; Y = 394 },
    @{ X = 584; Y = 528 },
    @{ X = 506; Y = 632 },
    @{ X = 388; Y = 560 }
)

for ($i = 0; $i -lt $elementColors.Count; $i++) {
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($elementColors[$i]))
    $graphics.FillEllipse($brush, $elementDots[$i].X, $elementDots[$i].Y, 58, 58)
    $brush.Dispose()
}

$centerBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#E9DDC4'))
$graphics.FillEllipse($centerBrush, 474, 466, 76, 76)

$sealBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#A33E2F'))
$graphics.FillEllipse($sealBrush, 716, 726, 74, 74)

$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$androidTargets = @(
    @{ Path = Join-Path $root 'android\app\src\main\res\mipmap-mdpi\ic_launcher.png'; Size = 48 },
    @{ Path = Join-Path $root 'android\app\src\main\res\mipmap-hdpi\ic_launcher.png'; Size = 72 },
    @{ Path = Join-Path $root 'android\app\src\main\res\mipmap-xhdpi\ic_launcher.png'; Size = 96 },
    @{ Path = Join-Path $root 'android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png'; Size = 144 },
    @{ Path = Join-Path $root 'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png'; Size = 192 }
)

foreach ($target in $androidTargets) {
    $resized = New-Object System.Drawing.Bitmap $target.Size, $target.Size
    $resizedGraphics = [System.Drawing.Graphics]::FromImage($resized)
    $resizedGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $resizedGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $resizedGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $resizedGraphics.DrawImage($bitmap, 0, 0, $target.Size, $target.Size)
    $resized.Save($target.Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $resizedGraphics.Dispose()
    $resized.Dispose()
}

$sealBrush.Dispose()
$centerBrush.Dispose()
$baseShadowBrush.Dispose()
$highlightPath.Dispose()
$highlightBrush.Dispose()
$jarRimPen.Dispose()
$jarPath.Dispose()
$jarBrush.Dispose()
$jarShadowPath.Dispose()
$jarShadowBrush.Dispose()
$orbBrush.Dispose()
$haloBrush.Dispose()
$bgBrush.Dispose()
$bgPath.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Output $outputPath
