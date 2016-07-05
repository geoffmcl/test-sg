@setlocal
@set TMP_MSVC=_selectMSVC.x64.bat
@set WORKSPACE=%CD%
@set HAD_ERROR=0
@set LOGFIL=%WORKSPACE%\bldlog-3.txt

@REM Switch MSVC Version
@set _MSVS=0
@set _MSNUM=0
@set VS_BAT=
@set GENERATOR=
@call %TMP_MSVC%
@if "%GENERATOR%x" == "x" (
@set /A HAD_ERROR+=1
@echo.
@echo No GENERATOR set! %TMP_MSVC% FAILED! **FIX ME**
@echo.
@goto EXIT
)
@if "%VS_BAT%x" == "x" (
@set /A HAD_ERROR+=1
@echo.
@echo No ENV VS_BAT SET_BAT set! %TMP_MSVC% FAILED! **FIX ME**
@echo.
@goto EXIT
)

@REM MSVC has been setup, do NOT call this a 2nd time
@set VS_BAT=

@cd %WORKSPACE%

@set TMP3RD=3rdParty.x64

@set GET_EXE=wget
@set GET_OPT=-O
@set UZ_EXE=7z
@set UZ_OPT=x

@REM FreeGLUT 3.1 - http://freeglut.sourceforge.net/
@set TMP_URL=https://sourceforge.net/code-snapshots/svn/f/fr/freeglut/code/freeglut-code-1792-trunk.zip
@set TMP_ZIP=freeglut.zip
@set TMP_SRC=freeglut-source
@set TMP_DIR=freeglut-code-1792-trunk
@set TMP_BLD=freeglut-build
@set TMP_CMD=%TMP_SRC%\freeglut\freeglut

@if NOT EXIST %TMP_ZIP% (
@echo Doing: '%GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%'
@CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
@if ERRORLEVEL 1 goto GET_FAILED
@if NOT EXIST %TMP_ZIP% goto GET_FAILED
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
@REM Seems NEED a delay after the UNZIP, else get access denied on the renaming???
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul goto NO_SRC

@cd %WORKSPACE%
@if NOT EXIST %TMP_CMD%\CMakeLists.txt goto NO_CMT

@if NOT EXIST %TMP_BLD%\nul (
@md %TMP_BLD%
)

@CD %TMP_BLD%
@if ERRORLEVEL 1 goto NO_BLD
@REM IN BUILD directory

@echo Doing: 'cmake ..\%TMP_CMD% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH="%WORKSPACE%\%TMP_BLD%\build"'
@cmake ..\%TMP_CMD% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH="%WORKSPACE%\%TMP_BLD%\build"
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo Error exit config/gen %TMP_SRC%
@cd %WORKSPACE%
@goto EXIT
)

@echo Doing 'cmake --build . --config Debug --target INSTALL'
@cmake --build . --config Debug --target INSTALL
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo Build/install Debug FAILED %TMP_SRC%
@cd %WORKSPACE%
@goto EXIT
)

@echo Doing 'cmake --build . --config Release --target INSTALL'
@cmake --build . --config Release --target INSTALL
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo Build/install Release FAILED %TMP_SRC%
@cd %WORKSPACE%
@goto EXIT
)

@cd %WORKSPACE%
xcopy %WORKSPACE%\%TMP_BLD%\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\%TMP_BLD%\build\lib\* %WORKSPACE%\%TMP3RD%\lib /y /s /q
xcopy %WORKSPACE%\%TMP_BLD%\build\bin\* %WORKSPACE%\%TMP3RD%\bin /y /q

@if NOT EXIST %WORKSPACE%\%TMP3RD%\include\GL\glut.h goto NO_GLUT

@goto DN_GLUT
:GET_FAILED
@set /A HAD_ERROR+=1
@echo FreeGLUT Source fetch failed!
@goto DN_GLUT
:NO_SRC
@set /A HAD_ERROR+=1
@echo Failed to establish dir %TMP_SRC%
@goto DN_GLUT
:NO_BLD
@set /A HAD_ERROR+=1
@echo Failed to create dir %TMP_BLD%
@goto DN_GLUT
:NO_CMT
@set /A HAD_ERROR+=1
@echo Can NOT locate %TMP_CMD%\CMakeLists.txt!
@goto DN_GLUT
:NO_GLUT
@set /A HAD_ERROR+=1
@echo Error: Can NOT locate %WORKSPACE%\%TMP3RD%\include\GL\glut.h
@goto DN_GLUT

:DN_GLUT
@goto END

:SLEEP1
@timeout /t 1 >nul 2>&1
@goto :EOF

:END
:EXIT
@if %HAD_ERROR% EQU 0 (
@echo Appears a successful build and install of FreeGLUT
) else (
@echo Appears build and install of FreeGLUT FAILED!
)

@REM eof
