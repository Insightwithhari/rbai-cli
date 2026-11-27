# RBAi CLI installer for Windows: the standalone rbai.exe, no Node.js needed.
#
#   irm https://cli.thedreamlabinnovations.com/install.ps1 | iex
#
# It picks the build for this PC: x64, the -baseline x64 build on CPUs without AVX2, or arm64. It
# downloads that build and the release's SHA256SUMS from https://cli.thedreamlabinnovations.com
# over HTTPS (TLS 1.2 or later), checks the SHA-256 with Get-FileHash, checks that the program
# starts and is the version asked for, and only then installs it as
# %LOCALAPPDATA%\Programs\rbai\rbai.exe. It adds that folder to your user Path (the registry's
# HKCU\Environment, keeping the value's type, then a broadcast so new windows see it). No
# administrator rights are needed. It runs in Windows PowerShell 5.1 and PowerShell 7.
#
# Options (environment variables, set before running):
#   $env:RBAI_VERSION = '1.0.0'            install this version (default: the newest, from latest.json)
#   $env:RBAI_INSTALL_DIR = 'D:\Tools\rbai' install there instead; it must be a new or empty
#                                          folder, or an earlier rbai install
#   $env:RBAI_NO_MODIFY_PATH = '1'         leave the user Path alone
#
# Uninstall: run `rbai logout` (it ends the browser sign-in), delete the folder
# %LOCALAPPDATA%\Programs\rbai, and remove it from your user Path (Settings > System > About >
# Advanced system settings > Environment Variables). Your settings stay in %APPDATA%\rbai and
# %LOCALAPPDATA%\rbai until you delete them.
#
# Everything runs in one script block: nothing is left in your PowerShell session, and a failure
# stops with a red error instead of closing the window.

& {
  $ErrorActionPreference = 'Stop'
  # Invoke-WebRequest's progress bar makes downloads many times slower in Windows PowerShell 5.1.
  $ProgressPreference = 'SilentlyContinue'
  # Windows PowerShell 5.1 runs on .NET Framework, which may offer only TLS 1.0 by default.
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

  $base = 'https://cli.thedreamlabinnovations.com'
  $npmHint = 'With Node.js 22 or later you can install it from npm instead: npm install -g rbai-cli'

  # AVX2 (IsProcessorFeaturePresent 40 = PF_AVX2_INSTRUCTIONS_AVAILABLE) and the broadcast that
  # tells Explorer and new terminals the user Path changed (WM_SETTINGCHANGE "Environment").
  if (-not ('RbaiInstall.Win32' -as [type])) {
    Add-Type -Namespace RbaiInstall -Name Win32 -MemberDefinition @'
[DllImport("kernel32.dll")]
public static extern bool IsProcessorFeaturePresent(uint feature);
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, UIntPtr wParam, string lParam, uint flags, uint timeout, out UIntPtr result);
'@
  }

  # -- this PC ----------------------------------------------------------------
  # The machine's own CPU: an x64 PowerShell on an Arm PC sees AMD64 in its own environment.
  $arch = $null
  try { $arch = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PROCESSOR_ARCHITECTURE).PROCESSOR_ARCHITECTURE } catch { $arch = $null }
  if (-not $arch) { $arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE } }
  $note = $null
  switch ($arch) {
    'AMD64' {
      $target = 'windows-x64'
      if (-not [RbaiInstall.Win32]::IsProcessorFeaturePresent(40)) {
        $target = 'windows-x64-baseline'
        $note = 'This CPU has no AVX2, so the baseline build was installed.'
      }
    }
    'ARM64' { $target = 'windows-arm64' }
    default { throw "rbai install: there is no rbai build for a $arch CPU. $npmHint" }
  }
  $asset = "rbai-$target.exe"

  # -- which version ----------------------------------------------------------
  $version = $env:RBAI_VERSION
  if (-not $version) {
    try { $latest = Invoke-RestMethod -UseBasicParsing -Uri "$base/latest.json" }
    catch { throw "rbai install: could not read $base/latest.json ($($_.Exception.Message)). Check the connection and the proxy settings." }
    $version = [string]$latest.version
  }
  $version = $version.Trim()
  if ($version.StartsWith('v')) { $version = $version.Substring(1) }
  if ($version -notmatch '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$') { throw "rbai install: `"$version`" is not a version number (for example 1.0.0)." }

  # -- where: a new or empty folder, or an earlier rbai install ---------------
  if ($env:RBAI_INSTALL_DIR) {
    $dir = $env:RBAI_INSTALL_DIR
    if (-not [IO.Path]::IsPathRooted($dir)) { throw "rbai install: RBAI_INSTALL_DIR must be a full path (it is $dir)." }
  } else {
    if (-not $env:LOCALAPPDATA) { throw 'rbai install: LOCALAPPDATA is not set; set RBAI_INSTALL_DIR to the folder to install into.' }
    $dir = Join-Path $env:LOCALAPPDATA 'Programs\rbai'
  }
  $dir = [IO.Path]::GetFullPath($dir)
  if ($dir.Length -gt 3) { $dir = $dir.TrimEnd('\') }
  if (Test-Path -LiteralPath $dir -PathType Container) {
    $mine = @('rbai.exe', 'rbai.exe.old', '.rbai-install')
    $other = Get-ChildItem -LiteralPath $dir -Force | Where-Object { ($mine -notcontains $_.Name) -and ($_.Name -notlike '.rbai-download.*') } | Select-Object -First 1
    if ($other) { throw "rbai install: $dir is not empty and is not an rbai install (it holds $($other.Name)), so nothing was changed. Choose a new or empty folder with RBAI_INSTALL_DIR." }
  } elseif (Test-Path -LiteralPath $dir) {
    throw "rbai install: $dir exists and is not a folder."
  }
  try { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  catch { throw "rbai install: could not create $dir ($($_.Exception.Message)). Choose a folder you can write to with RBAI_INSTALL_DIR." }

  # -- download and check -----------------------------------------------------
  $release = "$base/cli/$version"
  try { $sums = (Invoke-WebRequest -UseBasicParsing -Uri "$release/SHA256SUMS").Content }
  catch { throw "rbai install: rbai $version is not on $base (could not read $release/SHA256SUMS: $($_.Exception.Message)). The newest version is in $base/latest.json." }
  if ($sums -is [byte[]]) { $sums = [Text.Encoding]::UTF8.GetString($sums) }
  $expected = $null
  foreach ($line in ($sums -split "`n")) {
    $parts = $line.Trim() -split '\s+', 2
    if ($parts.Count -eq 2 -and $parts[1].TrimStart('*') -eq $asset) { $expected = $parts[0].ToLowerInvariant(); break }
  }
  if (-not $expected) {
    if ($target -like '*-baseline') { throw "rbai install: rbai $version has no build for $target (for x64 CPUs without AVX2, like this one). $npmHint" }
    throw "rbai install: rbai $version has no build for $target. $npmHint"
  }
  if ($expected -notmatch '^[0-9a-f]{64}$') { throw "rbai install: SHA256SUMS has no valid SHA-256 for $asset." }

  # The download goes into the install folder itself, so it is checked where it will live.
  $partial = Join-Path $dir (".rbai-download." + [Guid]::NewGuid().ToString('N') + '.exe')
  $exe = Join-Path $dir 'rbai.exe'
  try {
    Write-Host "Downloading rbai $version for $target"
    Write-Host "  $release/$asset"
    try { Invoke-WebRequest -UseBasicParsing -Uri "$release/$asset" -OutFile $partial }
    catch { throw "rbai install: the download of $release/$asset failed ($($_.Exception.Message)). Nothing was installed." }
    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $partial).Hash.ToLowerInvariant()
    if ($actual -ne $expected) { throw "rbai install: the download's SHA-256 is $actual, but SHA256SUMS says $expected. Nothing was installed. Try again; if it repeats, tell hari@thedreamlabinnovations.com." }
    Write-Host "SHA-256 checked: $actual"

    # The program must start here and be the version asked for. RBAI_NO_UPDATE_CHECK only for this
    # run (it is put back after): the check must not reach the registry.
    $before = $env:RBAI_NO_UPDATE_CHECK
    $env:RBAI_NO_UPDATE_CHECK = '1'
    try { $got = (& $partial --version | Out-String).Trim(); $code = $LASTEXITCODE }
    catch { throw "rbai install: the downloaded rbai does not start on this PC ($($_.Exception.Message)). Nothing was installed. $npmHint" }
    finally { $env:RBAI_NO_UPDATE_CHECK = $before }
    if ($code -ne 0) { throw "rbai install: the downloaded rbai does not start on this PC (exit code $code). Nothing was installed. $npmHint" }
    if ($got -ne $version) { throw "rbai install: the downloaded program says it is version `"$got`", not $version. Nothing was installed." }

    # A running rbai.exe cannot be overwritten but can be renamed: the old copy becomes
    # rbai.exe.old, removed now or, if it still runs, by the next install.
    $old = "$exe.old"
    if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Force -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $exe) { Move-Item -LiteralPath $exe -Destination $old -Force }
    Move-Item -LiteralPath $partial -Destination $exe
    if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Force -ErrorAction SilentlyContinue }
  } finally {
    if (Test-Path -LiteralPath $partial) { Remove-Item -LiteralPath $partial -Force -ErrorAction SilentlyContinue }
  }
  Set-Content -LiteralPath (Join-Path $dir '.rbai-install') -Encoding Ascii -Value @(
    "# rbai was installed in this folder by $base/install.ps1; delete the folder to uninstall it.",
    "host=$base",
    "version=$version",
    "target=$target",
    "installed=$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
  )

  # -- the user Path ----------------------------------------------------------
  # Read and written raw (DoNotExpandEnvironmentNames) and with the value's own type, so entries
  # such as %USERPROFILE%\bin stay as they are; only this user's Path, so no administrator rights.
  $pathNote = $null
  $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
  try {
    $raw = [string]$key.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    $onPath = @($raw -split ';' | Where-Object { $_ -and ([Environment]::ExpandEnvironmentVariables($_).TrimEnd('\') -ieq $dir) }).Count -gt 0
    if ($onPath) {
      $pathNote = "$dir is on your user Path."
    } elseif ($env:RBAI_NO_MODIFY_PATH -eq '1') {
      $pathNote = "$dir is not on your user Path (RBAI_NO_MODIFY_PATH=1). Add it to run rbai from any folder."
    } else {
      $kind = if ($null -ne $key.GetValue('Path')) { $key.GetValueKind('Path') } else { [Microsoft.Win32.RegistryValueKind]::ExpandString }
      $new = if ($raw) { $raw.TrimEnd(';') + ';' + $dir } else { $dir }
      $key.SetValue('Path', $new, $kind)
      $result = [UIntPtr]::Zero
      [void][RbaiInstall.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x1a, [UIntPtr]::Zero, 'Environment', 2, 5000, [ref]$result)
      $pathNote = "Added $dir to your user Path: new terminals find rbai."
    }
  } finally {
    $key.Close()
  }
  # This window too.
  if (-not (@($env:Path -split ';') | Where-Object { $_.TrimEnd('\') -ieq $dir })) { $env:Path = "$($env:Path.TrimEnd(';'));$dir" }

  $first = Get-Command rbai -CommandType Application, ExternalScript -ErrorAction SilentlyContinue | Select-Object -First 1
  Write-Host ''
  Write-Host "rbai $version is installed: $exe" -ForegroundColor Green
  if ($note) { Write-Host $note }
  Write-Host $pathNote
  if ($first -and ($first.Source -ne $exe)) {
    Write-Host "Note: another rbai comes first on your Path: $($first.Source) (npm's rbai-cli, or an older copy)." -ForegroundColor Yellow
    Write-Host "      Remove it (npm: npm uninstall -g rbai-cli) or move $dir before it." -ForegroundColor Yellow
  }
  Write-Host 'Next:'
  Write-Host '  rbai login    sign in through your browser'
  Write-Host '  rbai          start the chat'
  Write-Host ''
  Write-Host "Uninstall: rbai logout, then delete $dir and remove it from your user Path (Settings > System > About > Advanced system settings > Environment Variables)."
}
