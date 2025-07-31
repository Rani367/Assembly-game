@echo off
echo Building 2D Platformer for Windows x64...

REM Check if NASM is installed
where nasm >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: NASM not found. Please install NASM and add it to PATH.
    echo Download from: https://www.nasm.us/
    exit /b 1
)

REM Assemble the code
echo Assembling platformer_win64.asm...
nasm -f win64 platformer_win64.asm -o platformer_win64.obj
if %errorlevel% neq 0 (
    echo ERROR: Assembly failed
    exit /b 1
)

REM Link with Windows libraries
echo Linking...

REM Try to use GoLink first (simpler)
where golink >nul 2>nul
if %errorlevel% equ 0 (
    echo Using GoLink...
    golink /entry:main platformer_win64.obj kernel32.dll user32.dll gdi32.dll /fo platformer.exe
    if %errorlevel% equ 0 (
        echo Build successful! Run platformer.exe to play.
        exit /b 0
    )
)

REM Try Visual Studio linker
where link >nul 2>nul
if %errorlevel% equ 0 (
    echo Using Microsoft Linker...
    link /subsystem:windows /entry:main platformer_win64.obj kernel32.lib user32.lib gdi32.lib /out:platformer.exe
    if %errorlevel% equ 0 (
        echo Build successful! Run platformer.exe to play.
        exit /b 0
    )
)

REM Try MinGW ld
where ld >nul 2>nul
if %errorlevel% equ 0 (
    echo Using MinGW ld...
    ld -m i386pep platformer_win64.obj -lkernel32 -luser32 -lgdi32 -o platformer.exe
    if %errorlevel% equ 0 (
        echo Build successful! Run platformer.exe to play.
        exit /b 0
    )
)

echo ERROR: No suitable linker found.
echo Please install one of the following:
echo   - GoLink: http://www.godevtool.com/
echo   - Visual Studio Build Tools
echo   - MinGW-w64
exit /b 1