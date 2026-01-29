@echo off
setlocal enabledelayedexpansion

:: Check if a folder was provided
if "%~1"=="" (
    echo Usage: %~0 "path\to\folder\with\nef\files" [png|jpg]
    echo Default output format is PNG.
    exit /b 1
)

set FOLDER=%~1
set FORMAT=png
if not "%~2"=="" (
    set FORMAT=%~2
)

:: Check if the folder exists
if not exist "%FOLDER%" (
    echo Error: The provided directory does not exist!
    exit /b 1
)

:: Check if ImageMagick is installed
magick --version > nul 2>&1
if errorlevel 1 (
    echo Error: ImageMagick is not installed or not in PATH!
    exit /b 1
)

:: Check if ExifTool is installed
exiftool -ver > nul 2>&1
if errorlevel 1 (
    echo Error: ExifTool is not installed or not in PATH!
    exit /b 1
)

:: Create subfolder for output if it doesn't exist
if not exist "%FOLDER%\%FORMAT%" (
    mkdir "%FOLDER%\%FORMAT%"
)

:: Convert each NEF file in the folder to specified format
for %%f in ("%FOLDER%\*.NEF") do (
    set "base_name=%%~nf"
    set "output_file=%FOLDER%\%FORMAT%\!base_name!.!FORMAT!"

    :: Convert NEF to specified format using ImageMagick
    magick "%%f" "!output_file!"
    echo Converted "%%f" to "!output_file!"

    :: Copy metadata from NEF to the converted file using ExifTool
    if /i "%FORMAT%"=="jpg" (
        exiftool -overwrite_original -TagsFromFile "%%f" -all:all "!output_file!"
        echo Copied metadata from "%%f" to "!output_file!"
    ) else (
        echo Metadata cannot be copied to PNG format. Skipping metadata copy for "!output_file!".
    )
)

echo Conversion completed!
endlocal
