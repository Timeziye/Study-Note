<#
    move_link.ps1
    功能：
      - 在 HTML 中查找以 https://madmaxchow.github.io/openfonts/css/vlook- 开头的 <link> 标签
      - 删除它在原来的位置
      - 将它插入到 </style> 后面
      - 如果已经存在正确位置则不重复插入
    用法：
      1. 直接运行：处理当前目录下所有 HTML 文件
         .\move_link.ps1
      2. 拖拽文件或文件夹到脚本上：只处理这些文件
#>

param (
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Paths
)

# 统计变量
$totalFiles = 0
$processedFiles = 0
$modifiedFiles = 0
$skippedFiles = 0

Write-Host "HTML Link标签移动工具" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""

# 如果没传参数，则默认处理当前目录下的 *.html
if (-not $Paths) {
    $Paths = Get-ChildItem -Path . -Filter *.html | ForEach-Object { $_.FullName }
}

# 收集所有需要处理的文件
$allFiles = @()
foreach ($path in $Paths) {
    if (Test-Path $path) {
        # 如果是文件夹，则递归找 html 文件
        if ((Get-Item $path).PSIsContainer) {
            $files = Get-ChildItem -Path $path -Filter *.html -Recurse | ForEach-Object { $_.FullName }
        } else {
            $files = @($path)
        }
        $allFiles += $files
    }
}

if ($allFiles.Count -eq 0) {
    Write-Host "没有找到HTML文件！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请确保："
    Write-Host "  1. 当前目录或指定路径中存在 .html 文件"
    Write-Host "  2. 文件路径正确"
    Write-Host ""
    exit
}

Write-Host "找到 $($allFiles.Count) 个HTML文件：" -ForegroundColor Yellow
foreach ($file in $allFiles) {
    Write-Host "  - $([System.IO.Path]::GetFileName($file))" -ForegroundColor Cyan
}
Write-Host ""

foreach ($file in $allFiles) {
    $totalFiles++
    $fileName = [System.IO.Path]::GetFileName($file)
    Write-Host "处理中: $fileName" -ForegroundColor Yellow
    
    try {
        $content = Get-Content $file -Raw -Encoding UTF8
        $originalContent = $content

        if ($content -match "(<link\s+href='https://madmaxchow\.github\.io/openfonts/css/vlook-[^>]+>)") {
            $link = $matches[1]

            # 只有当 </style> 后没有该 link 时才处理
            if ($content -notmatch "</style>\s*$([regex]::Escape($link))") {
                # 删除原位置
                $content = $content -replace [regex]::Escape($link), ""

                # 插入到 </style> 后
                $content = $content -replace "(</style>)", "`$1`r`n$link"

                # 写回文件
                Set-Content $file $content -Encoding UTF8
                
                Write-Host "  成功: $fileName - 已移动link标签" -ForegroundColor Green
                $modifiedFiles++
            } else {
                Write-Host "  跳过: $fileName - link标签已在正确位置" -ForegroundColor Gray
                $skippedFiles++
            }
        } else {
            Write-Host "  跳过: $fileName - 未找到目标link标签" -ForegroundColor Gray
            $skippedFiles++
        }
        
        $processedFiles++
    } catch {
        Write-Host "  错误: $fileName - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "======================================" -ForegroundColor Green
Write-Host "处理完成！" -ForegroundColor Green
Write-Host "总文件数: $totalFiles" -ForegroundColor Cyan
Write-Host "成功处理: $processedFiles" -ForegroundColor Cyan
Write-Host "已修改: $modifiedFiles" -ForegroundColor Green
Write-Host "已跳过: $skippedFiles" -ForegroundColor Gray
Write-Host "======================================" -ForegroundColor Green 