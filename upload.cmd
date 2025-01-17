@echo off
setlocal enabledelayedexpansion

:: Debug Mode (set to 1 to enable)
set "DEBUG=0"

:: Check if curl is installed
where curl >nul 2>&1
if errorlevel 1 (
    echo ERROR: curl is not installed or not in PATH.
    pause
    exit /b 1
)

:: Check if jq is installed
where jq >nul 2>&1
if errorlevel 1 (
    echo ERROR: jq is not installed or not in PATH.
    pause
    exit /b 1
)

:: Check if a file argument is provided
if "%~1"=="" (
    echo ERROR: No file specified!
    echo Usage: %~nx0 file_to_upload
    pause
    exit /b 1
)

:: Check if the file exists
set "FILE=%~1"
if not exist "%FILE%" (
    echo ERROR: File "%FILE%" not found!
    pause
    exit /b 1
)

:: Query GoFile API for the best server
for /f "delims=" %%i in ('curl -s https://api.gofile.io/servers') do (
    set "SERVER_RESPONSE=%%i"
)

:: Debug: Show API response
if "%DEBUG%"=="1" (
    echo Server Response: !SERVER_RESPONSE!
)

:: Extract the correct server name
for /f "delims=" %%i in ('echo !SERVER_RESPONSE! ^| jq -r ".data.servers[0].name"') do (
    set "SERVER=%%i"
)

:: Debug: Show selected server
if "%DEBUG%"=="1" (
    echo Selected Server: !SERVER!
)

:: Check if server was retrieved
if "!SERVER!"=="" (
    echo ERROR: Failed to retrieve a server from GoFile API.
    pause
    exit /b 1
)

:: Upload the file with a progress bar
echo Uploading file, please wait...
for /f "delims=" %%i in ('curl --progress-bar -F "file=@%FILE%" https://!SERVER!.gofile.io/uploadFile') do (
    set "UPLOAD_RESPONSE=%%i"
)

:: Debug: Show upload response
if "%DEBUG%"=="1" (
    echo Upload Response: !UPLOAD_RESPONSE!
)

:: Extract the download link
for /f "delims=" %%i in ('echo !UPLOAD_RESPONSE! ^| jq -r ".data.downloadPage"') do (
    set "LINK=%%i"
)

:: Check if upload was successful
if "!LINK!"=="" (
    echo ERROR: Upload failed or download link not retrieved.
    pause
    exit /b 1
)

:: Show the download link
echo.
echo Upload successful! Download link:
echo !LINK!
pause
