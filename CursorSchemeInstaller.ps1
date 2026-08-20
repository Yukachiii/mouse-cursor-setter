$ErrorActionPreference = 'Stop'

try {
    $dir = $env:CURSOR_DIR
    $schemeName = $env:SCHEME_NAME

    if ([string]::IsNullOrWhiteSpace($dir) -or -not (Test-Path -LiteralPath $dir -PathType Container)) {
        throw 'Cursor folder was not found.'
    }

    if ([string]::IsNullOrWhiteSpace($schemeName)) {
        throw 'Scheme name is empty.'
    }

    $cursorKey = 'HKCU:\Control Panel\Cursors'
    $schemesKey = 'HKCU:\Control Panel\Cursors\Schemes'

    $roles = @(
        'Arrow','Help','AppStarting','Wait','Crosshair','IBeam','NWPen','No',
        'SizeNS','SizeWE','SizeNWSE','SizeNESW','SizeAll','UpArrow','Hand','Pin','Person'
    )

    $aliases = @{
        Arrow       = @('Arrow','Normal','Default','Pointer','通常の選択','通常選択','通常','矢印')
        Help        = @('Help','ヘルプの選択','ヘルプ選択','ヘルプ')
        AppStarting = @('AppStarting','Working','Work','BusyBackground','バックグラウンドで作業中','バックグラウンド作業中','作業中')
        Wait        = @('Wait','Busy','待ち状態','待機','待ち')
        Crosshair   = @('Crosshair','Precision','領域選択','精密選択','十字')
        IBeam       = @('IBeam','Text','TextSelect','テキスト選択','テキスト')
        NWPen       = @('NWPen','Pen','Handwriting','手書き','ペン')
        No          = @('No','Unavailable','Forbidden','利用不可','使用不可','禁止')
        SizeNS      = @('SizeNS','VerticalResize','上下に拡大縮小','上下拡大縮小','上下')
        SizeWE      = @('SizeWE','HorizontalResize','左右に拡大縮小','左右拡大縮小','左右')
        SizeNWSE    = @('SizeNWSE','Diagonal1','ResizeNWSE','斜めに拡大縮小1','斜め拡大縮小1','斜め1')
        SizeNESW    = @('SizeNESW','Diagonal2','ResizeNESW','斜めに拡大縮小2','斜め拡大縮小2','斜め2')
        SizeAll     = @('SizeAll','Move','移動')
        UpArrow     = @('UpArrow','Alternate','代替選択','代替')
        Hand        = @('Hand','Link','LinkSelect','リンクの選択','リンク選択','リンク')
        Pin         = @('Pin','Location','場所の選択','場所選択','場所')
        Person      = @('Person','People','人の選択','人選択','人')
    }

    if (-not (Test-Path -LiteralPath $schemesKey)) {
        New-Item -Path $schemesKey -Force | Out-Null
    }

    $files = @(
        Get-ChildItem -LiteralPath $dir -File -ErrorAction Stop |
        Where-Object { $_.Extension -ieq '.ani' -or $_.Extension -ieq '.cur' }
    )

    function Normalize([string]$text) {
        if ($null -eq $text) { return '' }
        $text = $text.Normalize([Text.NormalizationForm]::FormKC)
        $text = $text -replace '[\s　_\-\(\)\[\]【】/／\\]+',''
        return $text.ToLowerInvariant()
    }

    function Find-CursorFile([string[]]$names) {
        foreach ($name in $names) {
            $normalized = Normalize $name
            $hit = $files | Where-Object { (Normalize $_.BaseName) -eq $normalized } | Select-Object -First 1
            if ($hit) { return $hit.FullName }
        }

        foreach ($name in $names) {
            $normalized = Normalize $name
            if ($normalized.Length -lt 2) { continue }
            $hit = $files | Where-Object { (Normalize $_.BaseName).EndsWith($normalized) } | Select-Object -First 1
            if ($hit) { return $hit.FullName }
        }

        return $null
    }

    $found = 0

    foreach ($role in $roles) {
        $path = Find-CursorFile $aliases[$role]
        if ($path) {
            Set-ItemProperty -LiteralPath $cursorKey -Name $role -Value $path
            $found++
        }
    }

    if ($found -eq 0) {
        throw 'No supported cursor filenames were found.'
    }

    $schemePaths = foreach ($role in $roles) {
        try {
            $value = (Get-ItemProperty -LiteralPath $cursorKey -Name $role -ErrorAction Stop).$role
            if ($null -eq $value) { '' } else { [string]$value }
        }
        catch {
            ''
        }
    }

    $schemeData = [string]::Join(',', $schemePaths)

    New-ItemProperty -LiteralPath $schemesKey -Name $schemeName -Value $schemeData -PropertyType ExpandString -Force | Out-Null

    $reg = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Control Panel\Cursors', $true)
    if ($null -eq $reg) {
        throw 'Could not open the cursor registry key.'
    }

    try {
        $reg.SetValue('', $schemeName, [Microsoft.Win32.RegistryValueKind]::String)
        $reg.SetValue('Scheme Source', 1, [Microsoft.Win32.RegistryValueKind]::DWord)
    }
    finally {
        $reg.Close()
    }

    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class CursorReload {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
    [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, string lParam, uint flags, uint timeout, out IntPtr result);
}
'@

    if (-not [CursorReload]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)) {
        throw 'Windows could not reload the cursor scheme.'
    }

    $result = [IntPtr]::Zero
    [void][CursorReload]::SendMessageTimeout(
        [IntPtr]0xffff,
        0x001A,
        [IntPtr]::Zero,
        'Control Panel\Cursors',
        0x0002,
        2000,
        [ref]$result
    )

    exit 0
}
catch {
    Write-Host ''
    Write-Host 'Cursor installation failed:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
