REM call ../../env_var.bat 

XCOPY x64\Release\fistr_main.lib %WELSIM_LIBPACK%\lib\FemSolver2 /F /C /S /Y /I

XCOPY x64\Release\*.mod include /F /C /S /Y /I