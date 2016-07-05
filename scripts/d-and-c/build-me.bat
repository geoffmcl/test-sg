@if "%Qt5_DIR%x" == "x" goto WARN
@echo Have environment Qt5_DIR=%Qt5_DIR%
@goto DOIT
:WARN
@echo NOTE: Qt5_DIR **NOT** set in environment...
@pause
:DOIT
@set TMPTBGN=%TIME%
call d-and-c.x64 %* simgear flightgear
@call elapsed %TMPTBGN%
@set TMPTBGN=
