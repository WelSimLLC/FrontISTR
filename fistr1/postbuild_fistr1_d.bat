REM call ../../env_var.bat 

XCOPY x64\Debug\ffistr1d.lib %WELSIM_LIBPACK%\lib\FemSolver2 /F /C /S /Y /I

XCOPY x64\Debug\*.mod include /F /C /S /Y /I