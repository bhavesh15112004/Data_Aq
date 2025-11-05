@echo off
setlocal

:: Check if a file was provided
if "%~1"=="" (
    echo Please drag and drop a CSV file onto this script.
    pause
    exit /b
)

set FILE=%~1
echo Processing "%FILE%" ...

:: ✅ Correct MATLAB path (change only if your version differs)
set MATLAB_PATH="C:\Program Files\MATLAB\R2025b\bin\matlab.exe"

:: ✅ Run MATLAB silently
%MATLAB_PATH% -nosplash -nodesktop -minimize -wait -r "try, run_fft_file('%FILE%'); catch e, disp(getReport(e)); end; exit"

echo Done!
pause
