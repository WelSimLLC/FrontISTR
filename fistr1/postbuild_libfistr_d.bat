REM call ../../env_var.bat 

XCOPY x64\Debug\libfistrd.lib %WELSIM_LIBPACK%\lib\FemSolver2 /F /C /S /Y /I

XCOPY src\common\*.h include /F /C /S /Y /I