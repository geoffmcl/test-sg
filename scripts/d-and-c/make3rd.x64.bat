@setlocal
@REM ================================================================================
@REM Build 3rdParty components prior to building flightgear
@REM ================================================================================
@REM ################################################################################
@REM 20180710 - v1.0.7 - General update, external call
@REM 20160521 - v1.0.6 - Use external _setupBoost.x64.bat, which uses build-boost.x64.bat 
@REM 20160513 - v1.0.5 - Use external _selectMSVC.x64 to set some variables for us
@REM 20160511 - v1.0.4 - Add PLIB build, and install, through special PLIB-1.8.5.zip with a CMakeLists.txt
@REM 20160510 - v1.0.3 - Add OpenAL build, and install, through openal-build.bat
@REM 20160509 - v1.0.2 - Massive updates build3rd.x64.bat, including doing Boost
@REM 20140811 - v1.0.1 - Renamed build3rd.x64.bat
@REM ################################################################################
@REM started with from : http://wiki.flightgear.org/Howto:Build_3rdParty_library_for_Windows
@REM ################################################################################
@set TMP_MSVC=_selectMSVC.x64.bat
@set "WORKSPACE=%CD%"
@REM if EXIST ..\..\.git\nul goto NOT_IN_SRC
@REM if NOT EXIST %TMP_MSVC% goto NO_MSVC_SEL 
@set TMPDN3RD=make3rd.x64.txt
@if EXIST %TMPDN3RD% (
@echo.
@type %TMPDN3RD%
@echo File %TMPDN3RD% already exists, so this has been run before...
@echo Delete this file to run this batch again
@echo.
@goto EXIT
)
@set HAD_ERROR=0
@set HAD_WARN=0
@set _TMP_LIBS=

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

@set GET_EXE=wget
@set GET_OPT=-O
@set UZ_EXE=7z
@set UZ_OPT=x
@set MOV_CMD=move
@set MOV_OPT=

@set TMP3RD=3rdParty.x64
@REM set PERL_FIL=%WORKSPACE%\rep32w64.pl
@set LOGFIL=%WORKSPACE%\bldlog-2.txt
@set BLDLOG=
@REM Uncomment this, and add to config/build line, if you can output to a LOG
@set BLDLOG= ^>^> %LOGFIL% 2^>^&1
@set ERRLOG=%WORKSPACE%\error-2.txt
@set ADD_GDAL=1
@set HAVELOG=1

@REM call setupqt64

@echo %0: Begin %DATE% %TIME% in %CD% > %LOGFIL%
@echo # Error log %DATE% %TIME% > %ERRLOG%

@REM #############################################################################
@REM #############################################################################
@REM #### CGAL SETUP - THIS MAY NEED TO BE CHANGED TO WHERE YOU INSTALL CGAL #####
@REM #############################################################################
@REM #### DO NOT USE PATH NAMES WITH SPACES - USE DIR /X TO GET SHORT DIR    #####
@REM #############################################################################
@if "%CGAL_DIR%x" == "x" (
@REM 20160509 - Update to CGAL-4.8
@set CGAL_PATH=D:\FG\CGAL-4.8
@REM set CGAL_PATH=C:\PROGRA~2\CGAL-4.1
) else (
@set "CGAL_PATH=%CGAL_DIR%"
)

@set "GMP_HDR=%CGAL_PATH%\auxiliary\gmp\include\gmp.h"
@set "GMP_DLL=%CGAL_PATH%\auxiliary\gmp\lib\libgmp-10.dll"
@set "GMP_LIB=%CGAL_PATH%\auxiliary\gmp\lib\libgmp-10.lib"
@if NOT EXIST %CGAL_PATH%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Can NOT locate %CGAL_PATH%! *** FIX ME ***
@echo %HAD_ERROR%: Can NOT locate %CGAL_PATH%! *** FIX ME *** >> %ERRLOG%
)
@if NOT EXIST %GMP_DLL% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Can NOT locate %GMP_DLL%! *** FIX ME ***
@echo %HAD_ERROR%: Can NOT locate %GMP_DLL%! *** FIX ME *** >> %ERRLOG%
)
@if NOT EXIST %GMP_LIB% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Can NOT locate %GMP_LIB%! *** FIX ME ***
@echo %HAD_ERROR%: Can NOT locate %GMP_LIB%! *** FIX ME *** >> %ERRLOG%
)

@if NOT %HAD_ERROR% EQU 0 goto END

@REM ######################################################################
@REM ######################################################################
@REM ########### SHOULD NOT NEED TO ALTER ANYTHING BELOW HERE ############# 
@REM ######################################################################

@if NOT EXIST  %WORKSPACE%\%TMP3RD%\nul (
md %WORKSPACE%\%TMP3RD%
)
@if NOT EXIST %WORKSPACE%\%TMP3RD%\bin\nul (
md %WORKSPACE%\%TMP3RD%\bin
)
@if NOT EXIST %WORKSPACE%\%TMP3RD%\lib\nul (
md %WORKSPACE%\%TMP3RD%\lib
)
@if NOT EXIST %WORKSPACE%\%TMP3RD%\include\nul (
md %WORKSPACE%\%TMP3RD%\include
)

@REM Already done... do not repeat... anyway should be VS_BAT BUILD_BITS
@REM CALL %SET_BAT% amd64

@REM TEST JUMP - REMOVE AFTER TESTING
@REM GOTO DO_CGAL
@REM GOTO DO_GDAL
@REM GOTO DO_BOOST
@REM goto DO_JPEG
@REM goto DO_CURL
@REM goto DO_FLTK
@REM goto DO_GEOS

:DO_ZLIB
@echo %0: ############################# Download ^& compile ZLIB %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile ZLIB
)

@set TMP_URL=http://zlib.net/zlib1211.zip
@set TMP_ZIP=zlib.zip
@set TMP_SRC=zlib-source
@set TMP_DIR=zlib-1.2.11
@set TMP_BLD=zlib-build

@if NOT EXIST zlib.zip ( 
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
@REM Seems NEED a delay after the UNZIP, else get access denied on the renaming???
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to set up %TMP_SRC%
@echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
@goto DN_ZLIB
)

cd %WORKSPACE%

@if NOT EXIST %TMP_BLD%\nul (
md %TMP_BLD%
)

CD %TMP_BLD%

ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\zlib-build\build %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\zlib-build\build
)
cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\zlib-build\build %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC% >> %ERRLOG%
)

ECHO Doing 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing 'cmake --build . --config Release --target INSTALL'
)
cmake --build . --config Release --target INSTALL >> %ERRLOG% 2>&1
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)
 
xcopy %WORKSPACE%\zlib-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\zlib-build\build\lib\zlib.lib %WORKSPACE%\%TMP3RD%\lib /y /q
xcopy %WORKSPACE%\zlib-build\build\bin\zlib.dll %WORKSPACE%\%TMP3RD%\bin /y /q
@if EXIST %WORKSPACE%\%TMP3RD%\include\zlib.h (
@set _TMP_LIBS=%_TMP_LIBS% ZLIB
)
:DN_ZLIB
cd %WORKSPACE%

:DO_TIFF
@set TMP_PRJ=libtiff
@echo %0: ############################# Download ^& compile LIBTIFF %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBTIFF to %LOGFIL%
)

@set TMP_URL=http://download.osgeo.org/libtiff/tiff-4.0.9.zip
@set TMP_ZIP=libtiff.zip
@set TMP_SRC=libtiff-source
@set TMP_DIR=tiff-4.0.9
@set TMP_BLD=libtiff-build

@if NOT EXIST %TMP_ZIP% ( 
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)
@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to set up %TMP_SRC%
@echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
@goto DN_TIFF
)

@if NOT EXIST %TMP_BLD%\nul (
md %TMP_BLD%
)

CD %TMP_BLD%

ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libtiff-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD% %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libtiff-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD%
)
cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libtiff-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD% %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC% >> %ERRLOG%
)

ECHO Doing 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing 'cmake --build . --config Release --target INSTALL'
)
cmake --build . --config Release --target INSTALL >> %ERRLOG% 2>&1
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)
 
cd %WORKSPACE%

xcopy %WORKSPACE%\libtiff-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\libtiff-build\build\lib\* %WORKSPACE%\%TMP3RD%\lib /y /q
xcopy %WORKSPACE%\libtiff-build\build\bin\* %WORKSPACE%\%TMP3RD%\bin /y /q


@if EXIST %WORKSPACE%\%TMP3RD%\include\tiff.h (
@set _TMP_LIBS=%_TMP_LIBS% TIFF
)
:DN_TIFF
cd %WORKSPACE%

:DO_PNG
@echo %0: ############################# Download ^& compile LIBPNG %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBPNG to %LOGFIL%
)

@set TMP_URL=http://download.sourceforge.net/libpng/lpng1610.zip
@set TMP_ZIP=libpng.zip
@set TMP_SRC=libpng-source
@set TMP_DIR=lpng1610
@set TMP_BLD=libpng-build

@if NOT EXIST %TMP_ZIP% (
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to set up %TMP_SRC%
@echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
@goto DN_PNG
)

cd %WORKSPACE%

@if NOT EXIST %TMP_BLD%\nul (
MD %TMP_BLD%
)

CD %TMP_BLD%
ECHO Doing 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libpng-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD%' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libpng-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD%' to %LOGFIL%
)

cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libpng-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit cmake config/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit cmake config/gen %TMP_SRC% >> %ERRLOG%
)
ECHO Doing 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing 'cmake --build . --config Release --target INSTALL' to %LOGFIL%
)

cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)

cd %WORKSPACE%

xcopy %WORKSPACE%\libpng-build\build\include\*.h %WORKSPACE%\%TMP3RD%\include /y
xcopy %WORKSPACE%\libpng-build\build\lib\libpng16.lib %WORKSPACE%\%TMP3RD%\lib /y
xcopy %WORKSPACE%\libpng-build\build\bin\libpng16.dll %WORKSPACE%\%TMP3RD%\bin /y
@if EXIST %WORKSPACE%\%TMP3RD%\include\png.h (
@set _TMP_LIBS=%_TMP_LIBS% PNG
)
:DN_PNG
cd %WORKSPACE%
:DO_JPEG
@REM https://github.com/mozilla/mozjpeg - git@github.com:mozilla/mozjpeg.git
@set _TMP_LIBS=%_TMP_LIBS% JPEG
@echo %0: ############################# Download ^& compile LIBJPEG %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBJPEG to %LOGFIL%
)

@set TMP_REPO=git@github.com:mozilla/mozjpeg.git
@set TMP_SRC=libjpeg-source
@set TMP_BLD=libjpeg-build
@set TMP_OPT=-DWITH_SIMD:BOOL=FALSE
@set TMP_INS=%WORKSPACE%\libjpeg-build\build

@if NOT EXIST %TMP_SRC%\nul (
@call git clone %TMP_REPO% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to CLONE from %TMP_REPO% to %TMP_SRV%
@echo %HAD_ERROR%: Failed to CLONE from %TMP_REPO% to %TMP_SRV% >> %ERRLOG%
@goto DN_JPEG
)

@if NOT EXIST %TMP_BLD%\nul @(mkdir %TMP_BLD%)
 
@if NOT EXIST %TMP_BLD%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to setup %TMP_BLD%!
@echo %HAD_ERROR%: Failed to setup %TMP_BLD%! >> %ERRLOG%
@goto DN_JPEG
)

@CD %TMP_BLD%

ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%TMP_INS% %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%TMP_INS%
)
cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%TMP_INS% %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC% >> %ERRLOG%
)

ECHO Doing 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing 'cmake --build . --config Release --target INSTALL'
)
cmake --build . --config Release --target INSTALL >> %ERRLOG% 2>&1
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)
 
xcopy %WORKSPACE%\libjpeg-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\libjpeg-build\build\lib\*.lib %WORKSPACE%\%TMP3RD%\lib /y /q
xcopy %WORKSPACE%\libjpeg-build\build\bin\*.dll %WORKSPACE%\%TMP3RD%\bin /y /q

@if EXIST %WORKSPACE%\%TMP3RD%\include\jpeglib.h (
@set _TMP_LIBS=%_TMP_LIBS% JPEG
)

:DN_JPEG
cd %WORKSPACE%
@REM TEST EXIT - REMOVE AFTER TESTING
@REM goto EXIT

:DO_CURL
@echo %0: ############################# Download ^& compile LIBCURL %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBCURL to %LOGFIL%
)
@set TMP_URL=http://curl.haxx.se/download/curl-7.35.0.zip
@set TMP_ZIP=libcurl.zip
@set TMP_SRC=libcurl-source
@set TMP_DIR=curl-7.35.0
@set TMP_BLD=libcurl-build

@if NOT EXIST %TMP_ZIP% (
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)
@if NOT EXIST %TMP_ZIP% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error failed download from %TMP_URL% to %TMP_ZIP%
@echo %HAD_ERROR%: Error failed download from %TMP_URL% to %TMP_ZIP% >> %ERRLOG%
@goto DN_CURL
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error failed set up of %TMP_SRC%
@echo %HAD_ERROR%: Error failed set up of %TMP_SRC% >> %ERRLOG%
@goto DN_CURL
) 

cd %WORKSPACE%

if NOT EXIST %TMP_BLD%\nul (
MD %TMP_BLD%
)

CD %TMP_BLD%
@REM This option causes problems with simgear linkage -- wants the __imp_xxx version
@REM -DCURL_STATICLIB:BOOL=ON
@set _TMPOPTS=-G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libcurl-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD%
@REM Reduce load - not not delete cmake cache
@REM if EXIST CMakeCache.txt @del CMakeCache.txt
ECHO Doing: 'cmake ..\%TMP_SRC% %_TMPOPTS%' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake ..\%TMP_SRC% %_TMPOPTS%' to %LOGFIL%
)
cmake ..\%TMP_SRC% %_TMPOPTS% %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC% >> %ERRLOG%
)
ECHO Doing: 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake --build . --config Release --target INSTALL' to %LOGFIL%
)
cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)

cd %WORKSPACE%
 
xcopy %WORKSPACE%\libcurl-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\libcurl-build\build\lib\libcurl_imp.lib %WORKSPACE%\%TMP3RD%\lib /y /q
xcopy %WORKSPACE%\libcurl-build\build\lib\libcurl.lib %WORKSPACE%\%TMP3RD%\lib /y /q
xcopy %WORKSPACE%\libcurl-build\build\lib\libcurl.dll %WORKSPACE%\%TMP3RD%\bin /y /q
xcopy %WORKSPACE%\libcurl-build\build\bin\curl.exe %WORKSPACE%\%TMP3RD%\bin /y /q
@set _TMP_LIBS=%_TMP_LIBS% CURL
:DN_CURL
cd %WORKSPACE%
@REM TEST EXIT - REMOVE AFTER TESTING
@REM goto END

:DO_GDAL 
@if %ADD_GDAL% EQU 0 goto DN_GDAL

@echo %0: ############################# Download ^& compile GDAL %CD% %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile GDAL %CD% to %LOGFIL%
)
@REM # NOTE: update the version and checksum for new GDAL release
@set  GDAL_VERSION_STR=2.3.0
@set  GDAL_VERSION_PKG=230
@set  GDAL_VERSION_LIB=203
@set  GDAL_PACKAGE_SUM=f3f790b7ecb28916d6d0628b15ddc6b396a25a8f1f374589ea5e95b5a50addc99e05e363113f907b6c96faa69870b5dc9fdf3d771f9c8937b4aa8819bd78b190

@REM http://download.osgeo.org/gdal/2.3.1/
@REM set TMP_URL=https://svn.osgeo.org/gdal/trunk/gdal
@REM This SVN source FAILED to link with CGAL
@set TMP_SRC=libgdal-source
@set TMP_URL=http://download.osgeo.org/gdal/%GDAL_VERSION_STR%/gdal%GDAL_VERSION_PKG%.zip
@REM set TMP_URL=http://download.osgeo.org/gdal/2.0.0/gdal200.zip
@rem set TMP_URL=http://download.osgeo.org/gdal/2.3.1/gdal231.zip
@set TMP_DIR=gdal-%GDAL_VERSION_STR%
@REM set TMP_DIR=gdal-2.0.0
@REM set TMP_URL=http://download.osgeo.org/gdal/2.1.0/gdal210.zip
@REM set TMP_URL=http://download.osgeo.org/gdal/1.11.0/gdal1110.zip
@set TMP_ZIP=libgdal.zip

@if NOT EXIST %TMP_ZIP% ( 
    @echo Doing: 'CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%'
    @CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP% %BLDLOG%
    @if ERRORLEVEL 1 (
        @set /A HAD_ERROR+=1
        @echo HAD_ERROR: Failed 'CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%'
        @echo HAD_ERROR: Failed 'CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%' %BLDLOG%
        @goto DN_GDAL
    )
)
@if NOT EXIST %TMP_SRC%\nul (
    @if NOT EXIST %TMP_DIR%\nul (
        @CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
        @if ERRORLEVEL 1 (
            @set /A HAD_ERROR+=1
            @echo HAD_ERROR: Failed 'CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%'
            @echo HAD_ERROR: Failed 'CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%' %BLDLOG%
            @goto DN_GDAL
        )
    )
    CALL :SLEEP1
    REN %TMP_DIR% %TMP_SRC%
    @if ERRORLEVEL 1 (
        @set /A HAD_ERROR+=1
        @echo HAD_ERROR: Failed 'REN %TMP_DIR% %TMP_SRC%'
        @echo HAD_ERROR: Failed 'REN %TMP_DIR% %TMP_SRC%' %BLDLOG%
        @goto DN_GDAL
    )
)

if NOT EXIST %TMP_SRC%\nul (
    @set /A HAD_ERROR+=1
    @echo %HAD_ERROR%: Failed to set up %TMP_SRC%
    @echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
    @goto DN_GDAL
)

@CD %TMP_SRC%
@ECHO Doing: 'nmake -f makefile.vc MSVC_VER=%_MSNUM% GDAL_HOME=%WORKSPACE%/libgdal-source BINDIR=%WORKSPACE%\%TMP3RD%\bin LIBDIR=%WORKSPACE%\%TMP3RD%\lib INCDIR=%WORKSPACE%\%TMP3RD%\include WIN64=YES' %BLDLOG%
@IF %HAVELOG% EQU 1 (
@ECHO Doing: 'nmake -f makefile.vc MSVC_VER=%_MSNUM% GDAL_HOME=%WORKSPACE%/libgdal-source BINDIR=%WORKSPACE%\%TMP3RD%\bin LIBDIR=%WORKSPACE%\%TMP3RD%\lib INCDIR=%WORKSPACE%\%TMP3RD%\include WIN64=YES' to %LOGFIL%
)
@nmake -f makefile.vc MSVC_VER=%_MSNUM% GDAL_HOME=%WORKSPACE%/libgdal-source BINDIR=%WORKSPACE%\%TMP3RD%\bin LIBDIR=%WORKSPACE%\%TMP3RD%\lib INCDIR=%WORKSPACE%\%TMP3RD%\include WIN64=YES %BLDLOG%
@if ERRORLEVEL 1 (
    @set /A HAD_ERROR+=1
    @echo %HAD_ERROR%: Error exit nmake building source %TMP_SRC% in %CD%
    @echo %HAD_ERROR%: Error exit nmake building source %TMP_SRC% in %CD% >> %ERRLOG%
    @goto DN_GDAL
)

cd %WORKSPACE%
 
xcopy %WORKSPACE%\libgdal-source\gcore\gdal.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\gcore\gdal_frmts.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\gcore\gdal_proxy.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\gcore\gdal_priv.h %WORKSPACE%\%TMP3RD%\include\ /y /f 
xcopy %WORKSPACE%\libgdal-source\gcore\gdal_version.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\alg\gdal_alg.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\alg\gdalwarper.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\frmts\vrt\gdal_vrt.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\ogr\ogr*.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\ogr\ogrsf_frmts\ogrsf_frmts.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\port\cpl*.h %WORKSPACE%\%TMP3RD%\include\ /y /f
xcopy %WORKSPACE%\libgdal-source\gdal_i.lib %WORKSPACE%\%TMP3RD%\lib\ /y /f
@REM seem not built
@REM xcopy %WORKSPACE%\libgdal-source\gdal.lib %WORKSPACE%\%TMP3RD%\lib\ /y /f
xcopy %WORKSPACE%\libgdal-source\gdal*.dll %WORKSPACE%\%TMP3RD%\bin\ /y /f

@set _TMP_LIBS=%_TMP_LIBS% GDAL

:DN_GDAL
cd %WORKSPACE%
@REM TEST EXIT
@REM GOTO END
@REM goto ISERR

:DO_FLTK
@REM http://fltk.org/pub/fltk/
@set _TMP_LIBS=%_TMP_LIBS% FLTK
@echo %0: ############################# Download ^& compile LIBFLTK %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBFLTK to %LOGFIL%
)
@set TMP_URL=http://fltk.org/pub/fltk/1.3.2/fltk-1.3.2-source.tar.gz
@set TMP_ZIP=libfltk.tar.gz
@set TMP_TAR=libfltk.tar
@set TMP_SRC=libfltk-source
@set TMP_BLD=libfltk-build
@set TMP_DIR=fltk-1.3.2
@set TMP_OPT=-DOPTION_BUILD_EXAMPLES:BOOL=OFF

@if NOT EXIST %TMP_TAR% (
@if NOT EXIST %TMP_ZIP% (
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)

@if NOT EXIST %TMP_TAR% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to fetch %TMP_URL% to %TMP_ZIP%
@echo %HAD_ERROR%: Failed to fetch %TMP_URL% to %TMP_ZIP% >> %ERRLOG%
@goto DN_FLTK
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_TAR%
)
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to set up %TMP_SRC%
@echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
@goto DN_FLTK
)

cd %WORKSPACE%

@if NOT EXIST %TMP_BLD%\nul (
md %TMP_BLD%
)

cd %TMP_BLD%
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libfltk-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD%' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libfltk-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD%' to %LOGFIL%
)
cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libfltk-build\build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%\%TMP3RD% %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC% >> %ERRLOG%
)

ECHO Doing: 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake --build . --config Release --target INSTALL' to %LOGFIL%
)
cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)

cd %WORKSPACE%
 
xcopy %WORKSPACE%\libfltk-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\libfltk-build\build\bin\* %WORKSPACE%\%TMP3RD%\bin /y /s /q
xcopy %WORKSPACE%\libfltk-build\build\lib\fltk*.lib %WORKSPACE%\%TMP3RD%\lib /y /s /q

:DN_FLTK
cd %WORKSPACE%
@REM goto END

:DO_BOOST
@REM if NOT EXIST _setupBoost.x64.bat goto NOBOOST

@echo %0: ############################# Download ^& compile LIBBOOST %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBBOOST to %LOGFIL%
)

@call _setupBoost.x64 %BLDLOG%
@if ERRORLEVEL 1 goto NOBOOST2
@if "%Boost_DIR%x" == "x" goto NOBOOST3
@echo Established ENV Boost_DIR=%Boost_DIR% %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo Established ENV Boost_DIR=%Boost_DIR%
)

@set _TMP_LIBS=%_TMP_LIBS% BOOST
:DN_BOOST 
cd %WORKSPACE%

:DO_CGAL
@call :SET_BOOST

@echo %0: ############################# Download ^& compile CGAL %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile CGAL to %LOGFIL%
)
@REM set TMP_URL=https://gforge.inria.fr/frs/download.php/32996/CGAL-4.3.zip
@REM set TMP_URL=https://gforge.inria.fr/frs/download.php/file/33527/CGAL-4.4.zip
@REM set TMP_URL=http://github.com/CGAL/cgal/releases/download/releases%2FCGAL-4.8/CGAL-4.8.zip
@set TMP_URL=http://geoffair.org/tmp/CGAL-4.8.zip
@set TMP_ZIP=libcgal.zip
@set TMP_SRC=libcgal-source
@set TMP_BLD=libcgal-build
@set TMP_DIR=CGAL-4.8
@set TMP_PRE=%WORKSPACE%\cgal-source\auxiliary\gmp;%WORKSPACE%\Boost;%WORKSPACE%\install\Boost;%WORKSPACE%\%TMP3RD%

@if NOT EXIST %TMP_ZIP% (
@echo Moment, doing 'CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%'
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
@if ERRORLEVEL 1 goto NOCGALZIP
)

@if NOT EXIST %TMP_ZIP% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed download from %TMP_URL% to %TMP_ZIP%
@echo %HAD_ERROR%: Failed download from %TMP_URL% to %TMP_ZIP% >> %ERRLOG%
@goto DN_CGAL
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
@if ERRORLEVEL 1 goto NOCGALUZ
@echo Done UNZIP: CALL '%UZ_EXE% %UZ_OPT% %TMP_ZIP%'
)
CALL :SLEEP1
)

@if NOT EXIST %TMP_SRC%\nul (
@if EXIST %TMP_DIR%\nul (
CALL :SLEEP1
@REN %TMP_DIR% %TMP_SRC%
@if ERRORLEVEL 1 goto NOCGALREN
)
)

@set _TMP_GMP=%WORKSPACE%\libcgal-source\auxiliary\gmp
@if EXIST %_TMP_GMP%\include\gmp.h (
@echo Could avoided update of GMP headers...
)
@xcopy "%CGAL_PATH%"\auxiliary\gmp\include\* %_TMP_GMP%\include /s /y /i
@xcopy "%CGAL_PATH%"\auxiliary\gmp\lib64\* %_TMP_GMP%\lib /s /y /i
@xcopy "%CGAL_PATH%"\auxiliary\gmp\lib\* %_TMP_GMP%\lib /s /y /i
 
CD %WORKSPACE%

@if NOT EXIST %TMP_SRC%\nul (
@echo Creation of %TMP_SRC% FAILED!
@goto ISERR
)

@if NOT EXIST %TMP_BLD%\nul (
@MD %TMP_BLD%
@if ERRORLEVEL 1 goto NOCGALBLD
)

CD %TMP_BLD%
@if ERRORLEVEL 1 goto NOCGALBLD

@if NOT EXIST ..\%TMP_SRC%\CMakeLists.txt goto NOCGALCMAKE

@if EXIST CMakeCache.txt (
@REM This ia a BIG search - do NOT repeat it every time...
@REM del CMakeCache.txt >nul
)

@REM -DZLIB_LIBRARY=%WORKSPACE%\%TMP3RD%\lib\zlib.lib -DZLIB_INCLUDE_DIR=%WORKSPACE%\%TMP3RD%\include 
@set TMP_OPS=-G "%GENERATOR%" -DCMAKE_PREFIX_PATH=%TMP_PRE% -DCGAL_Boost_USE_STATIC_LIBS:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libcgal-build\build

@ECHO Doing: 'cmake ..\%TMP_SRC% %TMP_OPS% %BLDLOG%
IF %HAVELOG% EQU 1 (
@ECHO Doing: 'cmake ..\%TMP_SRC% %TMP_OPS% to %LOGFIL%
)

@REM Make a build-me.bat
@ECHO @REM Just to be able to repeat the individual build >build-me.bat
@ECHO cmake ..\%TMP_SRC% %TMP_OPS% >>build-me.bat

cmake ..\%TMP_SRC% %TMP_OPS% %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Config/Gen FAILED %TMP_SRC%
@echo %HAD_ERROR%: Config/Gen FAILED %TMP_SRC% >> %ERRLOG%
@goto NOCGAL1
@REM goto DN_CGAL
)
ECHO Doing: 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake --build . --config Release --target INSTALL' to %LOGFIL%
)
@ECHO cmake --build . --config Release --target INSTALL >>build-me.bat
cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Build FAILED %TMP_SRC%
@echo %HAD_ERROR%: Build FAILED %TMP_SRC% >> %ERRLOG%
@goto NOCGAL2
@REM goto DN_CGAL
)
 
cd %WORKSPACE%

@echo Doing: xcopy %WORKSPACE%\libcgal-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\libcgal-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
@echo Doing: xcopy %WORKSPACE%\libcgal-build\build\bin\* %WORKSPACE%\%TMP3RD%\bin /y /s /q
xcopy %WORKSPACE%\libcgal-build\build\bin\* %WORKSPACE%\%TMP3RD%\bin /y /s /q
@echo Doing: xcopy %WORKSPACE%\libcgal-build\build\lib\* %WORKSPACE%\%TMP3RD%\lib /y /s /q
xcopy %WORKSPACE%\libcgal-build\build\lib\* %WORKSPACE%\%TMP3RD%\lib /y /s /q

@echo Doing: xcopy %WORKSPACE%\libcgal-source\auxiliary\gmp\lib\*.dll %WORKSPACE%\%TMP3RD%\bin /s /y /q
xcopy %WORKSPACE%\libcgal-source\auxiliary\gmp\lib\*.dll %WORKSPACE%\%TMP3RD%\bin /s /y /q
@echo Doing: xcopy %WORKSPACE%\libcgal-source\auxiliary\gmp\lib\*.lib %WORKSPACE%\%TMP3RD%\lib /s /y /q
xcopy %WORKSPACE%\libcgal-source\auxiliary\gmp\lib\*.lib %WORKSPACE%\%TMP3RD%\lib /s /y /q

@set _TMP_LIBS=%_TMP_LIBS% CGAL

:DN_CGAL
cd %WORKSPACE%
@REM TEST EXIT
@REM GOTO END

:DO_FREETYPE
@set _TMP_LIBS=%_TMP_LIBS% FREETYPE
@call :SET_BOOST
 
@echo %0: ############################# Download ^& compile FREETYPE %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile FREETYPE to %LOGFIL%
)

@set TMP_URL=http://sourceforge.net/projects/freetype/files/freetype2/2.5.3/ft253.zip/download
@set TMP_ZIP=freetype.zip
@set TMP_SRC=freetype-source
@set TMP_BLD=freetype-build
@set TMP_DIR=freetype-2.5.3

@if NOT EXIST %TMP_ZIP% (
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)
@if NOT EXIST %TMP_ZIP% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to download %TMP_URL% to %TMP_ZIP%
@echo %HAD_ERROR%: Failed to download %TMP_URL% to %TMP_ZIP% >> %ERRLOG%
@goto DN_FREETYPE
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to set up %TMP_SRC%
@echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
@goto DN_FREETYPE
)

CD %WORKSPACE%

@if NOT EXIST %TMP_BLD%\nul (
MD %TMP_BLD%
)

CD %TMP_BLD%
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%/freetype-build/build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%/%TMP3RD%' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%/freetype-build/build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%/%TMP3RD%' to %LOGFIL%
) 
cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%/freetype-build/build -DCMAKE_PREFIX_PATH:PATH=%WORKSPACE%/%TMP3RD%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC% >> %ERRLOG%
)

ECHO Doing: 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake --build . --config Release --target INSTALL' to %LOGFIL%
)
cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)

CD %WORKSPACE%
 
xcopy %WORKSPACE%\freetype-build\build\* %WORKSPACE%\%TMP3RD% /y /s /q

:DN_FREETYPE

cd %WORKSPACE%

:DO_PROJ
@set _TMP_LIBS=%_TMP_LIBS% Proj
@call :SET_BOOST
@echo %0: ############################# Download ^& compile LIBPROJ %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBPROJ to %LOGFIL%
)
@set TMP_URL=http://download.osgeo.org/proj/proj-4.8.0.zip
@set TMP_ZIP=libproj.zip
@set TMP_SRC=libproj-source
@set TMP_DIR=proj-4.8.0

@if NOT EXIST %TMP_ZIP% (
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
) 
@if NOT EXIST %TMP_ZIP% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed download %TMP_URL% to %TMP_ZIP%
@echo %HAD_ERROR%: Failed download %TMP_URL% to %TMP_ZIP% >> %ERRLOG%
@goto DN_PROJ
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to setup %TMP_SRC%
@echo %HAD_ERROR%: Failed to setup %TMP_SRC% >> %ERRLOG%
@goto DN_PROJ
)

CD %TMP_SRC%
@echo Doing:  'nmake -f makefile.vc' %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo Doing:  'nmake -f makefile.vc' to %LOGFIL%
)
nmake -f makefile.vc %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit nmake makefile.vc %TMP_SRC%
@echo %HAD_ERROR%: Error exit nmake maekfile.vc %TMP_SRC% >> %ERRLOG%
)

CD %WORKSPACE%
 
xcopy %WORKSPACE%\libproj-source\src\*.lib %WORKSPACE%\%TMP3RD%\lib /s /y /q
xcopy %WORKSPACE%\libproj-source\src\*.dll %WORKSPACE%\%TMP3RD%\bin /s /y /q
xcopy %WORKSPACE%\libproj-source\src\proj_api.h %WORKSPACE%\%TMP3RD%\include /s /y /q

:DN_PROJ
cd %WORKSPACE%
 
:DO_GEOS 
@call :SET_BOOST
@REM http://download.osgeo.org/geos/
@echo %0: ############################# Download ^& compile LIBGEOS %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBGEOS to %LOGFIL%
)

@REM 20180711 - switch to github repo - https://github.com/libgeos/geos - git@github.com:libgeos/geos.git
@set TMP_REPO=git@github.com:libgeos/geos.git
@set TMP_SRC=libgeos-source
@set TMP_BLD=libgeos-build

@REM set TMP_URL=http://download.osgeo.org/geos/geos-3.6.2.tar.bz2
@REm set TMP_URL=http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
@REM set TMP_ZIP=libgeos.tar.bz2
@REM set TMP_TAR=libgeos.tar
@REM set TMP_SRC=libgeos-source
@REM set TMP_BLD=libgeos-build
@REM set TMP_DIR=geos-3.6.2
@set TMP_OPT=-DGEOS_MSVC_ENABLE_MP:BOOL=OFF -DGEOS_ENABLE_TESTS:BOOL=OFF

@if NOT EXIST %TMP_SRC%\nul (
@echo Cloning %TMP_REPO%, to %TMP_SRC%
@call git clone %TMP_REPO% %TMP_SRC%
)
if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1 
@echo %HAD_ERROR%: Failed clone from %TMP_REPO% to %TMP_SRC%
@echo %HAD_ERROR%: Failed clone from %TMP_REPO% to %TMP_SRC% >> %ERRLOG%
@goto DN_GEOS
)

cd %WORKSPACE%
@if NOT EXIST %TMP_BLD%\nul (
@md %TMP_BLD%
)

cd %TMP_BLD%
@echo Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libgeos-build\build' %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libgeos-build\build' to %LOGFIL%
)
cmake ..\%TMP_SRC% -G "%GENERATOR%" %TMP_OPT% -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libgeos-build\build %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC% >> %ERRLOG%
@goto DN_GEOS
)

@ECHO Doing: 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
@ECHO Doing: 'cmake --build . --config Release --target INSTALL' to %LOGFIL%
)
cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
@goto DN_GEOS
)

cd %WORKSPACE%
 
xcopy %WORKSPACE%\libgeos-build\build\bin\*.dll %WORKSPACE%\%TMP3RD%\bin /s /y /q
xcopy %WORKSPACE%\libgeos-build\build\lib\*.lib %WORKSPACE%\%TMP3RD%\lib /s /y /q
xcopy %WORKSPACE%\libgeos-build\build\include\* %WORKSPACE%\%TMP3RD%\include /s /y /q

@set _TMP_LIBS=%_TMP_LIBS% GEOS

:DN_GEOS
cd %WORKSPACE%
@REM goto ISERR

:DO_EXPAT
@set _TMP_LIBS=%_TMP_LIBS% EXPAT
@call :SET_BOOST
@echo %0: ############################# Download ^& compile LIBEXPAT %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile LIBEXPAT to %LOGFIL%
)
@set TMP_URL=http://sourceforge.net/projects/expat/files/expat/2.1.0/expat-2.1.0.tar.gz/download
@set TMP_TAR=libexpat.tar
@set TMP_ZIP=libexpat.tar.gz
@set TMP_SRC=libexpat-source
@set TMP_BLD=libexpat-build
@set TMP_DIR=expat-2.1.0

@if NOT EXIST %TMP_TAR% (
@if NOT EXIST %TMP_ZIP% (
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)

@if NOT EXIST %TMP_ZIP% (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed download from %TMP_URL% to %TMP_ZIP%
@echo %HAD_ERROR%: Failed download from %TMP_URL% to %TMP_ZIP% >> %ERRLOG%
@goto DN_EXPAT
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_TAR% (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
CALL %UZ_EXE% %UZ_OPT% %TMP_TAR%
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to set up %TMP_SRC%
@echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
@goto DN_EXPAT
)
 
cd %WORKSPACE%

@if NOT EXIST %TMP_BLD%\nul (
md %TMP_BLD%
)

cd %TMP_BLD%
@echo Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libexpat-build\build' %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libexpat-build\build' to %LOGFIL%
)
cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\libexpat-build\build %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit cmake conf/gen %TMP_SRC% >> %ERRLOG%
)

@echo Doing: 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo Doing: 'cmake --build . --config Release --target INSTALL' to %LOGFIL%
)
cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)
 
xcopy %WORKSPACE%\libexpat-build\build\bin\expat.dll %WORKSPACE%\%TMP3RD%\bin /s /y /q
xcopy %WORKSPACE%\libexpat-build\build\lib\expat.lib %WORKSPACE%\%TMP3RD%\lib /s /y /q
xcopy %WORKSPACE%\libexpat-build\build\include\* %WORKSPACE%\%TMP3RD%\include /s /y /q
 
:DN_EXPAT
cd %WORKSPACE%

:DO_PLIB
@call :SET_BOOST
@echo %0: ############################# Download ^& compile PLIB %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo %0: ############################# Download ^& compile PLIB to %LOGFIL%
)

@set TMP_DIR=PLIB-1.8.5
@set TMP_ZIP=%TMP_DIR%.zip
@set TMP_URL=http://geoffair.org/tmp/%TMP_ZIP%
@set TMP_SRC=plib-source
@set TMP_BLD=plib-build

@if NOT EXIST %TMP_ZIP% ( 
CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP%
)

@if NOT EXIST %TMP_SRC%\nul (
@if NOT EXIST %TMP_DIR%\nul (
CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%
)
@REM Seems NEED a delay after the UNZIP, else get access denied on the renaming???
CALL :SLEEP1
REN %TMP_DIR% %TMP_SRC%
)

@if NOT EXIST %TMP_SRC%\nul (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Failed to set up %TMP_SRC%
@echo %HAD_ERROR%: Failed to set up %TMP_SRC% >> %ERRLOG%
@goto DN_PLIB
)

cd %WORKSPACE%

@if NOT EXIST %TMP_BLD%\nul (
md %TMP_BLD%
)

CD %TMP_BLD%

ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\plib-build\build %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing: 'cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\plib-build\build
)
cmake ..\%TMP_SRC% -G "%GENERATOR%" -DCMAKE_INSTALL_PREFIX:PATH=%WORKSPACE%\plib-build\build %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC%
@echo %HAD_ERROR%: Error exit config/gen %TMP_SRC% >> %ERRLOG%
)

ECHO Doing 'cmake --build . --config Debug --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing 'cmake --build . --config Debug --target INSTALL'
)
cmake --build . --config Debug --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit debug building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit debug building source %TMP_SRC% >> %ERRLOG%
)

ECHO Doing 'cmake --build . --config Release --target INSTALL' %BLDLOG%
IF %HAVELOG% EQU 1 (
ECHO Doing 'cmake --build . --config Release --target INSTALL'
)
cmake --build . --config Release --target INSTALL %BLDLOG%
@if ERRORLEVEL 1 (
@set /A HAD_ERROR+=1
@echo %HAD_ERROR%: Error exit building source %TMP_SRC%
@echo %HAD_ERROR%: Error exit building source %TMP_SRC% >> %ERRLOG%
)
 
xcopy %WORKSPACE%\plib-build\build\include\* %WORKSPACE%\%TMP3RD%\include /y /s /q
xcopy %WORKSPACE%\plib-build\build\lib\*.lib %WORKSPACE%\%TMP3RD%\lib /y /q
@REM xcopy %WORKSPACE%\plib-build\build\bin\zlib.dll %WORKSPACE%\%TMP3RD%\bin /y /q
@echo Done PLIB...
@set _TMP_LIBS=%_TMP_LIBS% PLIB
:DN_PLIB
cd %WORKSPACE%
@REM external builds
:DO_AL
@set _TMP_ALI=%WORKSPACE%\%TMP3RD%\include\AL\al.h
@REM Avoid re-doing OpenAL if it already appears installed
@if EXIST %_TMP_ALI% goto GOT_AL
@set _TMP_ALB=openal-build.x64.bat
@rem if EXIST %_TMP_ALB% (
    @echo Doing an OpenAL build and install...
    @call %_TMP_ALB%
    @if ERRORLEVEL 1 (
        @set /A HAD_ERROR+=1
        @set _TMP_BLD_FAIL=%_TMP_BLD_FAIL% OpenAL
        @goto ISERR
    )
    @set _TMP_LIBS=%_TMP_LIBS% OpenAL
@rem ) else (
@rem    @echo %_TMP_ALB% NOT FOUND in %CD%! ** FIX ME **
@rem    @goto ISERR
@rem )
@goto DN_AL
:GOT_AL
@echo Found %_TMP_ALI%... done AL
@set _TMP_LIBS=%_TMP_LIBS% OpenAL
:DN_AL

:END
cd %WORKSPACE%

@if NOT %HAD_ERROR% EQU 0 goto ISERR
@echo =================================== %BLDLOG%
@echo Appears a fully successful build... %BLDLOG%
@echo Add deps %_TMP_LIBS% to %TMP3RD% %BLDLOG%
IF %HAVELOG% EQU 1 (
@echo.
@echo Appears a fully successful build... to %LOGFIL%
@echo Add deps %_TMP_LIBS% to %TMP3RD%
)

@REM Create the already done file...
@echo Done 3rdParty build %DATE% %TIME% > %TMPDN3RD%
@echo End: Created file %DATE% %TIME% %CD%\%TMPDN3RD%
@echo.
:EXIT
@endlocal
@exit /b 0

:NOBOOST
@set /A HAD_ERROR+=1
@echo.
@echo Missing '_setupBoost.x64.bat' batch file to setup boost
@echo.
@goto ISERR
:NOBOOST2
@set /A HAD_ERROR+=1
@echo.
@echo batch '_setupBoost.x64.bat' FAILED to setup boost
@echo.
@goto ISERR
:NOBOOST3
@set /A HAD_ERROR+=1
@echo.
@echo batch '_setupBoost.x64.bat' FAILED to setup Boost_DIR in ENV
@echo.
@goto ISERR

:NOCGALZIP
@set /A HAD_ERROR+=1
@echo.
@echo CALL %GET_EXE% %TMP_URL% %GET_OPT% %TMP_ZIP% yielded error!
@if EXIST %TMP_ZIP% @del %TMP_ZIP%
@goto ISERR

:NOCGALCMAKE
@set /A HAD_ERROR+=1
@echo.
@echo Error: In %CD%: Can NOT locate ..\%TMP_SRC%\CMakeLists.txt
@goto ISERR

:NOCGAL1
@set /A HAD_ERROR+=1
@echo.
@echo CGAL CMake config, gen FAILED!
@goto ISERR

:NOCGAL2
@set /A HAD_ERROR+=1
@echo.
@echo CGAL build FAILED!
@goto ISERR

:NOCGALREN
@set /A HAD_ERROR+=1
@echo.
@echo FAILED to do REN %TMP_DIR% %TMP_SRC%
@goto ISERR

:NOCGALUZ
@set /A HAD_ERROR+=1
@echo.
@echo Failed 'CALL %UZ_EXE% %UZ_OPT% %TMP_ZIP%'
@goto ISERR

:NOCGALBLD
@set /A HAD_ERROR+=1
@echo.
@echo Error: from MD %TMP_BLD%!!!
@goto ISERR

:NOT_IN_SRC
@set /A HAD_ERROR+=1
@echo.
@echo Error: Do NOT do a build in the repo source! %CD%
@goto ISERR

:NO_MSVC_SEL
@set /A HAD_ERROR+=1
@echo.
@echo Error: Can NOT locate %TMP_MSVC% to setup MSVC environment
@goto ISERR

:ISERR
@REM echo.
@REM type %ERRLOG%
@echo.
@echo Note: Had %HAD_ERROR% ERRORS during the build...
@echo Perhaps above %ERRLOG% output may have details...
@endlocal
@exit /b %HAD_ERROR% 

:SLEEP1
@timeout /t 1 >nul 2>&1
@goto :EOF

:SET_BOOST
@REM set Boost_DIR=%WORKSPACE%\Boost
@echo Set ENV Boost_DIR=%Boost_DIR% %BLDLOG%
@REM could also use BOOST_ROOT and BOOSTROOT to find Boost.
@goto :EOF

REM eof
