REM call ../../env_var.bat 

XCOPY x64\Release\fhecmw1.lib %WELSIM_LIBPACK%\lib\FemSolver2 /F /C /S /D /Y /I

XCOPY src\common\fstr_ctrl_util_f.inc include\fstr_ctrl_util_f.inc /C /S /D /Y /I
XCOPY x64\Release\*.f90 include\*.f90 /C /S /D /Y /I
XCOPY x64\Release\*.mod include\*.mod /C /S /D /Y /I
