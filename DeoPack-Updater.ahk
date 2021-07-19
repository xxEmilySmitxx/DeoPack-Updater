#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force


Gui, Main:New
Gui, Main:+AlwaysOnTop
Gui, Main:Color, FFFFFF
Gui, Main:Add, GroupBox, w235 h50, Select a DeoPack version to update
;Gui, Main:Add, text,, 
Gui, Main:Add, DropDownList, x25 y25 vChoice, DeoPack-1.16.5|DeoPack-1.17
Gui, Main:Add, Button, Default x150 y25 w80 gUpdate, Update!
Gui, Main:Add, GroupBox, x10 y60 w235 h45, Need help?
Gui, Main:Add, Button, x20 y75 w215 gHelp, Documentary on The DeoCraft Website

Gui, Main:Show, w255 h115, DeoPack Updater

Gui, Update:New
Gui, Update:+AlwaysOnTop

Actxt := "Downloading current version list.."

Gui, Update:Add, text, w240 h40 vAct, % Actxt
Gui, Update:Add, Progress, x10 y35 w235 h20 cGreen vCurrentProgress, 1
Gui, Update:Color, FFFFFF

return

;;Help info
Help:

run https://deocraft.serv.nu/resources/DeoPack-Updater-Help.html

return

;;Exit when close Gui
GuiClose:
MainGuiClose:
UpdateGuiClose:

MsgBox, 4388, Confirmation, Are you sure you want to exit the DeoPack Updater?
IfMsgBox No
    return
else
ExitApp

return


;;Update
Update:
{

Gui, Main:Submit, NoHide

if (Choice == "") {
	MsgBox, 4400, Warning, Select a version to update!
	return
}

;;Check if DeoPaack exists
DeoPackLocation := A_AppData "\.minecraft\resourcepacks\" Choice ".zip"

if !FileExist(DeoPackLocation) {
	MsgBox, 4388, Confirmation, You do not have %Choice%.zip, Do you want to download it?
IfMsgBox No
    return
else
	Gui, Main:Hide
	Gui, Update:Show, w255 h65, DeoPack Updater
	Actxt := "Downloading newest version.."
	GuiControl, Update:, Act, %Actxt%
	GuiControl, Update:, CurrentProgress, 10
	
	UrlDownloadToFile,https://deocraft.serv.nu/resources/%Choice%.zip, %A_AppData%\.minecraft\resourcepacks\%Choice%.zip

	Actxt := "Done!"
	GuiControl, Update:, Act, %Actxt%
	GuiControl, Update:, CurrentProgress, 100
	
	sleep 2500
	
	Gui, Update:Hide
	Gui, Main:Show,, DeoPack Updater
return
}

Actxt := "Downloading current version list.."
GuiControl, Update:, Act, %Actxt%
GuiControl, Update:, CurrentProgress, 1

Gui, Main:Hide
Gui, Update:Show, w255 h65, DeoPack Updater

UrlDownloadToFile, https://deocraft.serv.nu/resources/%Choice%-currentVersion.json, %A_ScriptDir%\data\%Choice%-currentVersion.json

GuiControl, Update:, CurrentProgress, +15

DeoPack := A_AppData "\.minecraft\resourcepacks\" Choice ".zip"
data := A_ScriptDir "\data\"

Run PowerShell.exe -NoExit -Command Expand-Archive -LiteralPath '%DeoPack%' -DestinationPath '%data%',, Hide

sleep, 500
Actxt := "Getting local version.."
GuiControl, Update:, Act, %Actxt%
GuiControl, Update:, CurrentProgress, +10
sleep, 500

;;Get Current Version
currentV_JSON_FilePath := A_ScriptDir "\data\" Choice "-currentVersion.json"

FileRead, currentVersionJSON, % currentV_JSON_FilePath

FoundPosCV := InStr(currentVersionJSON, "currentVersion")


currentVersion := SubStr(currentVersionJSON, FoundPosCV+18 , 3)

GuiControl, Update:, CurrentProgress, +15

sleep 2500

;;Get Local Version

localV_JSON_FilePath := A_ScriptDir "\Data\" Choice "-version.json"

FileRead, localVersionJSON, % localV_JSON_FilePath

FoundPosLV := InStr(localVersionJSON, "version")

localVersion := SubStr(localVersionJSON, FoundPosLV+11 , 3)



if (!localVersion) {
	localVersion := "NaN"
}

GuiControl, Update:, CurrentProgress, +15


if (currentVersion > localVersion) {
	Actxt := "A new version is avalible!`nCurrent version: " currentVersion " Local version: " localVersion
	
	GuiControl, Update:, Act, %Actxt%
	GuiControl, Update:, CurrentProgress, +5
	sleep 2500
	Actxt := "Downloading new version.."
	GuiControl, Update:, Act, %Actxt%
	GuiControl, Update:, CurrentProgress, +15
	UrlDownloadToFile,https://deocraft.serv.nu/resources/%Choice%.zip, %A_AppData%\.minecraft\resourcepacks\%Choice%.zip
	
	
} Else if (localVersion == "NaN") {
	Actxt := "Coudn't find local version`nCurrent version: " currentVersion ", Local version: " localVersion
	
	GuiControl, Update:, Act, %Actxt%
	GuiControl, Update:, CurrentProgress, +5
	sleep 2500
	Actxt := "Downloading new version.."
	GuiControl, Update:, Act, %Actxt%
	GuiControl, Update:, CurrentProgress, +15
	UrlDownloadToFile,https://deocraft.serv.nu/resources/%Choice%.zip, %A_AppData%\.minecraft\resourcepacks\%Choice%.zip


} Else {
Actxt := "Up-to-date!"
GuiControl, Update:, Act, %Actxt%
GuiControl, Update:, CurrentProgress, +30
sleep 250
}

FileRemoveDir, %data%, 1
FileCreateDir, %data%


Actxt := "Done!"
GuiControl, Update:, Act, %Actxt%
GuiControl, Update:, CurrentProgress, 100

sleep 2500
Gui, Update:Hide
Gui, Main:Show,, DeoPack Updater

}

if ErrorLevel
	MsgBox, 4400, Warning, Something went wrong!, read the documentary for help

return
