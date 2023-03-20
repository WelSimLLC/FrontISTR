REM call ../../env_var.bat 

XCOPY x64\Release\hecmw1.lib  %WELSIM_LIBPACK%\lib\FemSolver2 /F /C /S /D /Y /I

XCOPY src\common\*.h include /C /S /D /Y /I
XCOPY src\hecmw\*.h include /C /S /D /Y /I
XCOPY src\operations\dynamic_load_balancing\*.h include /C /S /D /Y /I
XCOPY src\visualizer\*.h include /C /S /D /Y /I