@echo off
REM Change to the directory where this script is located
cd /d "%~dp0"

echo Docker Compose Deployment Script
echo ================================
echo.
REM Get the current directory name for display
for %%I in (.) do set CURRENT_DIR=%%~nxI
echo Working in directory: %CURRENT_DIR%
echo Script location: %~dp0
echo.
REM Check if Docker is running
echo Checking Docker status...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not running or not installed.
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo ✓ Docker is running
REM Check if Docker Compose YAML file exists
if not exist "docker-compose.yml" (
    if not exist "docker-compose.yaml" (
        if not exist "compose.yml" (
            if not exist "compose.yaml" (
                echo Error: No Docker Compose YAML file found in current directory.
                echo Looking for: docker-compose.yml, docker-compose.yaml, compose.yml, or compose.yaml
                echo Please make sure you're in the correct directory.
                pause
                exit /b 1
            )
        )
    )
)
echo ✓ Docker Compose file found
echo.
echo Starting deployment process...
echo ================================
REM Step 1: Build
echo.
echo [1/3] Building Docker images...
echo Command: docker compose build
echo.
docker compose build
if %errorlevel% neq 0 (
    echo.
    echo ✗ Build failed!
    echo Check the error messages above and fix any issues.
    pause
    exit /b 1
)
echo ✓ Build completed successfully
REM Step 2: Stop existing containers
echo.
echo [2/3] Stopping existing containers...
echo Command: docker compose down
echo.
docker compose down
if %errorlevel% neq 0 (
    echo.
    echo ✗ Failed to stop containers!
    echo This might not be critical if no containers were running.
    echo Continuing anyway...
)
echo ✓ Containers stopped
REM Step 3: Start containers in detached mode
echo.
echo [3/3] Starting containers in background...
echo Command: docker compose up -d
echo.
docker compose up -d
if %errorlevel% neq 0 (
    echo.
    echo ✗ Failed to start containers!
    echo Check the error messages above.
    echo You can try running 'docker compose logs' to see detailed logs.
    pause
    exit /b 1
)
echo.
echo ================================
echo ✓ Deployment completed successfully!
echo ================================
echo.
REM Show running containers
echo Current running containers:
docker compose ps
echo.
echo Useful commands:
echo   View logs:        docker compose logs -f
echo   Stop services:    docker compose down
echo   Restart:          docker compose restart
echo   Check status:     docker compose ps
echo.
REM Ask if user wants to view logs
choice /C YN /M "Do you want to view the logs now"
if errorlevel 1 if not errorlevel 2 (
    echo.
    echo Showing logs (Press Ctrl+C to exit)...
    timeout /t 2 /nobreak >nul
    docker compose logs -f
)
echo.
echo Deployment script finished.
pause