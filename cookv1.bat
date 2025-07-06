@ECHO OFF
:: secret_schemer homebrew helper batch script 03/07/25
ECHO Welcome to Cook - A process for setting up homebrew files for Blood On The Clocktower!
set /p author=Please enter your homebrew colelction name:
set author=%author: =_%
::replace spaces with _
ECHO Let's get making!
CALL :newchar
EXIT /B 0

::Ask user a bunch of questions then generate the character JSON
:newchar
setlocal 
set /p name=Character Name:
set name=%name: =_%
::replace spaces with _
set id=%name%_%author%

ECHO Character Type
ECHO 1) Townsfolk
ECHO 2) Outsider
ECHO 3) Minion
ECHO 4) Demon
ECHO 5) Traveller
ECHO 6) Fabled
CHOICE /n /c 123456
IF %ERRORLEVEL% ==6 set team=fabled
IF %ERRORLEVEL% ==5 set team=traveller
IF %ERRORLEVEL% ==4 set team=demon
IF %ERRORLEVEL% ==3 set team=minion
IF %ERRORLEVEL% ==2 set team=outsider
IF %ERRORLEVEL% ==1 set team=townsfolk

CHOICE /c NY /m "Need the global night order sheet (requires firefox)"
IF ERRORLEVEL ==2 start firefox https://script.bloodontheclocktower.com/data/nightsheet.json

set /p firstNight=Enter first ngiht Night Order value (0 for does not wake): 
set firstNightReminder=
if /I "%firstNight%" NEQ "0" set /p firstNightReminder=Enter the reminder for the first night: 

set /p otherNight=Enter other ngiht Night Order value (0 for does not wake): 
set otherNightReminder=
if /I "%otherNight%" NEQ "0" set /p otherNightReminder=Enter the reminder for the other nights: 

set /p r_count=How many reminders?
set /a count=0
set /a r_count=%r_count%
:loopstart1
if /I "%count%" EQU "%r_count%" GOTO :loopend1
set /a count=%count%+1
set /p input=Enter reminder %count%: 
set reminders=%reminders%"%input%", 
GOTO :loopstart1
:loopend1
set reminders=[%reminders:~0,-2%]
IF /I "%r_count%" EQU "0" set reminders=[]
ECHO reminders string created: %reminders%

set /p rg_count=How many remindersGlobal: 
set /a count=0
set /a rg_count=%rg_count%
:loopstart2
if /I "%count%" EQU "%rg_count%" GOTO :loopend2
set /a count=%count%+1
set /p input=Enter reminder %count%: 
set remindersGlobal=%remindersGlobal%"%input%", 
GOTO :loopstart2
:loopend2
set remindersGlobal=[%remindersGlobal:~0,-2%]
IF /I "%rg_count%" EQU "0" set remindersGlobal=[]
ECHO remindersGlobal string created: %remindersGlobal%

CHOICE /c NY /m "Does your character affect setup?"
set /a setup=ERRORLEVEL-1

set /p ability=Enter the ability text: 

CHOICE /c NY /m "Does your character see the grimoire?"
set /a sees_grimoire=ERRORLEVEL-1

set /p flavour=Enter the flavour text, if any: 
ECHO OK here we go!
CALL :makecharfile "%id%" , "%name%" , %team% , "%firstNight%" , "%firstNightReminder%" "%otherNight%", "%otherNightReminder%" , "%reminders%" , "%remindersGlobal%" , %setup% , "%ability%" , %sees_grimoire% , "%flavour%"
endlocal
EXIT /B 0

:test
set reminders= ["Poisoned"]
set remindersGlobal= ["Knows"]
set fnreminder=Show the Grimoire for as long as the Widow needs. The Widow chooses a player. :reminder:
set ability=On your 1st night, look at the Grimoire and choose a player: they are poisoned. 1 good player knows a Widow is in play.
set empty=
set flavour=wahoo flavour
CALL :makecharfile widow , Widow , minion , 22 , "%fnreminder%" , 0 , "%empty%" , "%reminders%" , "%remindersGlobal%" , 0 , "%ability%" , 1, "%flavour%"
EXIT /B 0

::Take variables provided and produce JSON
:makecharfile
setlocal
set id=%~1
set name=%~2
set team=%~3
set firstNight=%~4
set firstNightReminder=%~5
set otherNight=%~6
set otherNightReminder=%~7
set reminders=%~8
set remindersGlobal=%~9
::MUST SHIFT TO ACCESS
SHIFT
SHIFT
SHIFT
SHIFT
SHIFT
SHIFT
SHIFT
SHIFT
SHIFT
set setup=%~1
set ability=%~2
set sees_grimoire=%~3
set flavour=%~4

ECHO Variables set

set foldertag=#
if %team%==townsfolk set foldertag="T"
if %team%==outsider set foldertag="O"
if %team%==minion set foldertag="M"
if %team%==demon set foldertag="D"
set foldername=%foldertag%-%name%
mkdir "./%foldername%"
ECHO Folder created

(
	ECHO {
	ECHO "id": "%id%",
	ECHO "name": "%name:_= %",
	ECHO "team": "%team%",
	ECHO "image": [],
	IF /I "%firstNight%" NEQ "0" (
		ECHO "firstNight": %firstNight%,
		ECHO "firstNightReminder": "%firstNightReminder%",
	)
	IF /I "%otherNight%" NEQ "0" (
		ECHO "otherNight": %otherNight%,
		ECHO "otherNightReminder": "%otherNightReminder%",
	)
	ECHO "reminders": %reminders%,
	ECHO "remindersGlobal": %remindersGlobal%,
	if /I "%setup%" EQU "1" ECHO "setup": true,
	ECHO "ability": "%ability%",
	if /I "%sees_grimoire%" EQU "1" (
		ECHO "special": [
		ECHO {
		ECHO "name": "grimoire",
		ECHO "type": "signal",
		ECHO "time": "night"
		ECHO }
		ECHO ],
	) 
	ECHO "flavor": "%flavour%",
	ECHO "jinxes": []
	ECHO }
) >./%foldername%/%name%.json

ECHO JSON created - You will need to fill in icons and jinxes yourself
endlocal
EXIT /B 0