REM call ../../env_var.bat 

XCOPY x64\Release\libfistr.lib %WELSIM_LIBPACK%\lib\FemSolver2 /F /C /S /Y /I

XCOPY src\common\*.h include /C /S /Y /I