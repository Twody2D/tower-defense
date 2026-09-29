# Builds the slim Godot web template for this game from custom.build (~15 min).
# Result: C:\PROGRAMS\godot-templates\towerdefence_web_release.zip (path used in export_presets.cfg).
# The template of other projects in godot-src\bin is backed up and restored.
$ErrorActionPreference = "Stop"
$src = "C:\PROGRAMS\godot-src"
$out = "C:\PROGRAMS\godot-templates"
$zip = "$src\bin\godot.web.template_release.wasm32.nothreads.zip"
$profile = Join-Path (Split-Path $PSScriptRoot -Parent) "custom.build"

New-Item -ItemType Directory -Force $out | Out-Null
$backup = "$out\previous_bin_template.zip"
if (Test-Path $zip) { Copy-Item $zip $backup -Force }

& C:\PROGRAMS\emsdk\emsdk_env.ps1
Push-Location $src
try {
	py -3.14 -m SCons platform=web target=template_release optimize=size lto=full threads=no "build_profile=$profile" -j12
	if ($LASTEXITCODE -ne 0) { throw "SCons failed: $LASTEXITCODE" }
	Copy-Item $zip "$out\towerdefence_web_release.zip" -Force
} finally {
	Pop-Location
	if (Test-Path $backup) { Copy-Item $backup $zip -Force }
}
Write-Output "OK: $out\towerdefence_web_release.zip"
