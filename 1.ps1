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

# 如果没传参数，则默认处理当前目录下的 *.html
if (-not $Paths) {
    $Paths = Get-ChildItem -Path . -Filter *.html | ForEach-Object { $_.FullName }
}

foreach ($path in $Paths) {
    if (Test-Path $path) {
        # 如果是文件夹，则递归找 html 文件
        if ((Get-Item $path).PSIsContainer) {
            $files = Get-ChildItem -Path $path -Filter *.html -Recurse | ForEach-Object { $_.FullName }
        } else {
            $files = @($path)
        }

        foreach ($file in $files) {
            Write-Host "Processing $file ..."
            $content = Get-Content $file -Raw

            if ($content -match "(<link\s+href='https://madmaxchow\.github\.io/openfonts/css/vlook-[^>]+>)") {
                $link = $matches[1]

                # 只有当 </style> 后没有该 link 时才处理
                if ($content -notmatch "</style>\s*$([regex]::Escape($link))") {
                    # 删除原位置
                    $content = $content -replace [regex]::Escape($link), ""

                    # 插入到 </style> 后
                    $content = $content -replace "(</style>)", "`$1`r`n$link"
                }
            }

            # 写回文件
            Set-Content $file $content -Encoding UTF8
        }
    }
}

Write-Host "Done."