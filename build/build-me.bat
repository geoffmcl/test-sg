@setlocal
@REM 20161106 - Using msvc140
@REM 20160416 - 22/01/2016
@set VCVERS=14
@set DOINST=0
@set BLDDBG=1
@set TMPPRJ=test-sg
@set TMPSRC=..
@set TMPBGN=%TIME%
@set TMPLOG=bldlog-1.txt
@set BLDDIR=%CD%
@REM Local relative
@REM set TMPSG=..\..\install\msvc100\simgear
@REM set TMPBOOST=..\..\Boost
@REM On D: drive - fresh build
@REM set TMPINS=D:\FG\d-and-c\3rdParty.x64
@REM set TMPSG=D:\FG\d-and-c\install\simgear
@REM set TMPBOOST=D:\FG\d-and-c\Boost
@REM On X: drive
@set TMPINS=X:\3rdParty.x64
@REM set TMPBOOST=X:\boost_1_60_0
@set TMPBOOST=C:\local\boost_1_62_0
@set TMPSG=X:\install\msvc140-64\simgear
@if NOT EXIST %TMPSG%\nul goto NOSG
@set SET_BAT=%ProgramFiles(x86)%\Microsoft Visual Studio %VCVERS%.0\VC\vcvarsall.bat
@if NOT EXIST "%SET_BAT%" goto NOBAT
@REM Note: BOOST_ROOT set later
@if NOT EXIST %TMPBOOST%\nul goto NOBOOST

@set TMPOPTS=-DCMAKE_INSTALL_PREFIX=%TMPINS%
@set TMPOPTS=%TMPOPTS% -G "Visual Studio %VCVERS% Win64"
@REM set TMPOPTS=%TMPOPTS% -DBUILD_SHARED_LIB=ON

:RPT
@if "%~1x" == "x" goto GOTCMD
@set TMPOPTS=%TMPOPTS% %1
@shift
@goto RPT
:GOTCMD

@call chkmsvc %TMPPRJ%
@REM call chkbranch master

@echo Build %DATE% %TIME% > %TMPLOG%

@if NOT EXIST %TMPSRC%\nul goto NOSRC

@echo Build source %TMPSRC%... all output to build log %TMPLOG%
@echo Build source %TMPSRC%... all output to build log %TMPLOG% >> %TMPLOG%

@if EXIST build-cmake.bat (
@call build-cmake >> %TMPLOG%
)

@set SIMGEAR_DIR=%TMPSG%
@echo Set ENV SIMGEAR_DIR=%SIMGEAR_DIR%
@echo Set ENV SIMGEAR_DIR=%SIMGEAR_DIR% >> %TMPLOG%

@if NOT EXIST %TMPBOOST%\nul goto NOBOOST
@REM pushd %TMPBOOST%
@REM set BOOST_ROOT=%CD%
@REM popd
@set BOOST_ROOT=%TMPBOOST%
@echo Set ENV BOOST_ROOT=%BOOST_ROOT%
@echo Set ENV BOOST_ROOT=%BOOST_ROOT% >> %TMPLOG%

@if NOT EXIST %TMPSRC%\CMakeLists.txt goto NOCM

@echo Doing: 'call "%SET_BAT%" %PROCESSOR_ARCHITECTURE%'
@echo Doing: 'call "%SET_BAT%" %PROCESSOR_ARCHITECTURE%' >> %TMPLOG%
@call "%SET_BAT%" %PROCESSOR_ARCHITECTURE% >> %TMPLOG% 2>&1
@if ERRORLEVEL 1 goto ERR0

@cd %BLDDIR%

@echo Doing 'cmake %TMPSRC% %TMPOPTS%'
@echo Doing 'cmake %TMPSRC% %TMPOPTS%' >> %TMPLOG% 2>&1
@cmake %TMPSRC% %TMPOPTS% >> %TMPLOG% 2>&1
@if ERRORLEVEL 1 goto ERR1

@if NOT %BLDDBG% EQU 1 goto DNDBG1
@echo Doing: 'cmake --build . --config Debug'
@echo Doing: 'cmake --build . --config Debug'  >> %TMPLOG% 2>&1
@cmake --build . --config Debug  >> %TMPLOG% 2>&1
@if ERRORLEVEL 1 goto ERR2
:DNDBG1


@echo Doing 'cmake --build . --config Release'
@echo Doing 'cmake --build . --config Release'  >> %TMPLOG% 2>&1
@cmake --build . --config Release  >> %TMPLOG% 2>&1
@if ERRORLEVEL 1 goto ERR3

@fa4 "***" %TMPLOG%
@call elapsed %TMPBGN%
@echo Appears a successful build... see %TMPLOG%

@echo.
@if "%DOINST%x" == "1x" goto CHKINST
@echo No install at this time. Set DOINST=1
@REM echo But there is a updexe.bat to copy the EXE to c:\MDOS...
@goto END

:CHKINST
@echo Continue with install? Only Ctrl+c aborts...

@pause

@if NOT %BLDDBG% EQU 1 goto DNDBG2
cmake --build . --config Debug  --target INSTALL >> %TMPLOG% 2>&1
@if ERRORLEVEL 1 goto ERR4
:DNDBG2

cmake --build . --config Release  --target INSTALL >> %TMPLOG% 2>&1
@if ERRORLEVEL 1 goto ERR5

@fa4 " -- " %TMPLOG%

@call elapsed %TMPBGN%
@echo All done... see %TMPLOG%

@goto END

:NOBOOST
@echo NOT EXIST %TMPBOOST%\nul! *** FIX ME ***
@goto ISERR

:NOBAT
@echo Can NOT locate MSVC setup batch "%SET_BAT%"! *** FIX ME ***
@goto ISERR

:NOSG
@echo Can NOT locate %TMPSG%! *** FIX ME ***
@goto ISERR

:NOSRC
@echo Can NOT locate source %TMPSRC%! *** FIX ME ***
@echo Can NOT locate source %TMPSRC%! *** FIX ME *** >> %TMPLOG%
@goto ISERR

:NOCM
@echo Can NOT locate %TMPSRC%\CMakeLists.txt!
@echo Can NOT locate %TMPSRC%\CMakeLists.txt! >> %TMPLOG%
@goto ISERR

:ERR0
@echo MSVC 10 setup error
@goto ISERR

:ERR1
@echo cmake configuration or generations ERROR
@echo cmake configuration or generations ERROR >> %TMPLOG%
@goto ISERR

:ERR2
@echo ERROR: Cmake build Debug FAILED!
@echo ERROR: Cmake build Debug FAILED! >> %TMPLOG%
@goto ISERR

:ERR3
@echo ERROR: Cmake build Release FAILED!
@echo ERROR: Cmake build Release FAILED! >> %TMPLOG%
@goto ISERR

:ERR4
@echo ERROR: Install Debug FAILED!
@echo ERROR: Install Debug  FAILED! >> %TMPLOG%
@goto ISERR

:ERR5
@echo ERROR: Install Release FAILED!
@echo ERROR: Install Release  FAILED! >> %TMPLOG%
@goto ISERR

:ISERR
@echo See %TMPLOG% for details...
@endlocal
@exit /b 1

:END
@endlocal
@exit /b 0

@REM eof
