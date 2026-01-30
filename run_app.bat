@echo off
setlocal enabledelayedexpansion

cd /d D:\flutterwork\fashion_critic

echo.
echo ========================================
echo  Fashion Critic App Build ^& Run Script
echo ========================================
echo.

echo [STEP 1] Cleaning previous build...
echo.
C:\flutter\bin\flutter.bat clean
echo.

echo [STEP 2] Getting dependencies...
echo.
C:\flutter\bin\flutter.bat pub get
echo.

echo [STEP 3] Running app on Android device...
echo.
C:\flutter\bin\flutter.bat run -d R5CT326T5EZ

echo.
echo ========================================
echo  Build and Run Complete!
echo ========================================
echo.
pause
