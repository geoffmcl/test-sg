@setlocal
@set TMPEXE=Release\metar.exe
@if NOT EXIST %TMPEXE% goto NOEXE
@set TMPBIN=X:\3rdParty.x64\bin
@REM set TMPBIN=D:\FG\d-and-c\3rdParty.x64\bin
@if NOT EXIST %TMPBIN%\nul goto NOBIN

@set PATH=%TMPBIN%;%PATH%

%TMPEXE% %*

@goto END

:NOEXE
@echo Can NOT locate exe %TMPEXE%! *** FIX ME ***
@goto END

:NOBIN
@echo Can NOT locate bin %TMPBIN%! *** FIX ME ***
@goto END

:END
