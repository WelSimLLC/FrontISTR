REM call ../../env_var.bat 

XCOPY x64\Debug\fistr_maind.lib %WELSIM_LIBPACK%\lib\FemSolver2 /F /C /S /Y /I

XCOPY x64\Debug\*.mod include /F /C /S /Y /I