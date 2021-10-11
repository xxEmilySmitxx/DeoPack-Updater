#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force ;;Only 1 instance of program open, open again and first one closes.

;; Internal "Settinges"
DeoPackUpdaterVersion := 1171.5
DeoPackVersionList := "DeoPack-1.16.5|DeoPack-1.17"
DeoPackVersionListFull := "DeoPack-1.16.5|DeoPack-1.17|DeoPack-1.17-NSFW"

DeoCraftURL := "https://deocraft.serv.nu"
;; End of internal Settings

;; clean and create /data folder
sleep, 500
FileRemoveDir, %A_ScriptDir%\data\, 1
FileCreateDir, %A_ScriptDir%\data\

;;Create settings.ini file if missing
if !FileExist("settings.ini") {
	FileAppend, [Settings], settings.ini
}
;;Read Settings on startup
IniRead, iniAllowNSFW, settings.ini, Settings, AllowNSFW, 0
if (iniAllowNSFW) {
DeoPackVersions := DeoPackVersionListFull
} else {
DeoPackVersions := DeoPackVersionList
}

IniRead, iniCustomDirectory, settings.ini, Settings, CustomDirectory
IniRead, iniUseDefaultDir, settings.ini, Settings, UseDefaultDir, 1
;;End of reading settings on startup


;;Main Gui
Gui, Main:New
Gui, Main:+AlwaysOnTop
Gui, Main:Color, FFFFFF
Gui, Main:Add, GroupBox, w235 h99, Select a DeoPack version to update
Gui, Main:Add, DropDownList, x20 y26 w130 vChoice, %DeoPackVersions%
Gui, Main:Add, Button, Default x155 y25 w80 gUpdate, Update!
Gui, Main:Add, GroupBox, x10 y60 w235 h45,
Gui, Main:Add, Button, x20 y74 w215 gSettings, Open settings
Gui, Main:Add, GroupBox, x10 y110 w235 h45, Need help?
Gui, Main:Add, Button, x20 y125 w215 gHelp, Documentary on The DeoCraft Website

Gui, Main:Show, w255 h165, DeoPack Updater
;;End of main Gui

;;Settings Gui
Gui, Settings:New
Gui, Settings:+AlwaysOnTop
Gui, Settings:Color, FFFFFF
Gui, Settings:Add, GroupBox, w255 h125, Settings
Gui, Settings:Add, Checkbox, Checked%iniAllowNSFW% x20 y25 vAllowNSFW, Show NSFW DeoPack versions in dropdown?
Gui, Settings:Add, Edit, x20 y50 w235 h20 ReadOnly vCustomDirectory, %iniCustomDirectory%
Gui, Settings:Add, Button, x20 y75 w235 gChangeDirectory, Change Minecraft save directory
Gui, Settings:Add, Checkbox, Checked%iniUseDefaultDir% x20 y105 vUseDefaultDir gUseDefaultDir, Use Default Minecraft save directory?
Gui, Settings:Add, GroupBox, x10 y123 w255 h42,
Gui, Settings:Add, Button, x20 y135 w235 gUpdateDeoPackUpdater, Check for Updates
Gui, Settings:Add, Button, Default x160 y170 w100 gSaveSettings, Save Settings
Gui, Settings:Add, Text, x118 y175, v%DeoPackUpdaterVersion%
Gui, Settings:Add, Button, x15 y170 w100 gDiscardSettings, Cancel
;;End of settings Gui

;;Update Gui
Gui, Update:New
Gui, Update:+AlwaysOnTop
Gui, Update:Color, FFFFFF
statusTxt := "Downloading current version list.." ;;Default Status text
Gui, Update:Add, text, w240 h40 vstatus, % statusTxt
Gui, Update:Add, Progress, x10 y35 w235 h20 cGreen vCurrentProgress, 1
Gui, Update:Add, Button, x10 y35 w235 h20 vCloseUpdate gCloseUpdate, Close

GuiControl, Update:Show, CurrentProgress
GuiControl, Update:Hide, CloseUpdate

;;End of update Gui
return

;;Settings
Settings:

;;Read Settings
IniRead, iniAllowNSFW, settings.ini, Settings, AllowNSFW, 0
if (iniAllowNSFW) {
DeoPackVersions := "DeoPack-1.16.5|DeoPack-1.17|DeoPack-1.17-NSFW"
} else {
DeoPackVersions := "DeoPack-1.16.5|DeoPack-1.17"
}

IniRead, iniCustomDirectory, settings.ini, Settings, CustomDirectory

GuiControl, Settings:, AllowNSFW, %iniAllowNSFW%

IniRead, iniUseDefaultDir, settings.ini, Settings, UseDefaultDir, 1
if (iniUseDefaultDir) {
	GuiControl, Settings:, CustomDirectory, %A_AppData%\.minecraft\resourcepacks 
} else {
	GuiControl, Settings:, CustomDirectory, %iniCustomDirectory%
}

GuiControl, Settings:, UseDefaultDir, %iniUseDefaultDir%
;;End of reading settings

Gui, Main:Hide
Gui, Settings:Show, w275 h200, DeoPack Updater
return

ChangeDirectory:
Gui, Settings:Submit, NoHide
Gui, Settings:+Owndialogs

GuiControl, Settings:, UseDefaultDir, 0
GuiControl, Settings:, CustomDirectory, %iniCustomDirectory%

FileSelectFolder, CustomDirectory,, 4, Select minecraft's 'resourcepacks' folder`nOnly do this if you changed Minecraft's save directory
GuiControl, Settings:, CustomDirectory, %CustomDirectory%
return

UseDefaultDir:
Gui, Settings:Submit, NoHide
if (UseDefaultDir) {
	GuiControl, Settings:, CustomDirectory, %A_AppData%\.minecraft\resourcepacks 
} else {
	GuiControl, Settings:, CustomDirectory, %iniCustomDirectory%
}

return

;; Update DeoPack Updater
UpdateDeoPackUpdater:

statusTxt := "Downloading current version list.."
GuiControl, Update:, status, %statusTxt%
GuiControl, Update:, CurrentProgress, 10

Gui, Main:+Owndialogs

Gui, Main:Hide
Gui, Settings:Hide
Gui, Update:Show, w255 h65, DeoPack Updater


UrlDownloadToFile, %DeoCraftURL%/resources/DeoPackUpdater-CurrentVersion.ini, %A_ScriptDir%\data\DeoPackUpdater-CurrentVersion.ini
sleep, 500
IniRead, CurrentDeoPackUpdaterVersion, %A_ScriptDir%\data\DeoPackUpdater-CurrentVersion.ini, Info, Version

statusTxt := "Checking current version"
GuiControl, Update:, status, %statusTxt%
GuiControl, Update:, CurrentProgress, 25

if (CurrentDeoPackUpdaterVersion > DeoPackUpdaterVersion) {
	
	statusTxt := "A new DeoPack-Updater version is avalible!`nCurrent version: " CurrentDeoPackUpdaterVersion " Local version: " DeoPackUpdaterVersion
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 35
	
	sleep, 2500
	
	statusTxt := "Downloading newest version.."
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 45
	
	UrlDownloadToFile, %DeoCraftURL%/resources/DeoPack-Updater.zip, %A_ScriptDir%\data\DeoPack-Updater.zip
	
	statusTxt := "Installing current version"
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 55
	
	RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%A_ScriptDir%\data\DeoPack-Updater.zip' -DestinationPath '%A_ScriptDir%\data\',, Hide
	ScriptLocation := A_ScriptDir
	
	GuiControl, Update:, CurrentProgress, 70
	
	sleep, 500
	FileMove, %A_ScriptDir%\DeoPack-Updater.exe, %A_ScriptDir%\data\DeoPack Updater\data
	GuiControl, Update:, CurrentProgress, 85
	sleep, 250
	FileMove, %A_ScriptDir%\data\DeoPack Updater\DeoPack-Updater.exe, %A_ScriptDir%\
	sleep, 500
	statusTxt := "Done!`nRestarting.."
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 100
	sleep, 1500
	Run, %ScriptLocation%\DeoPack-Updater.exe
} else {
	sleep, 250
	statusTxt := "Up-to-date!`n" CurrentDeoPackUpdaterVersion " is the latest version of DeoPack Updater"
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 100
	FileRemoveDir, %A_ScriptDir%\data\, 1
	FileCreateDir, %A_ScriptDir%\data\
	
	GuiControl, Update:Hide, CurrentProgress
	GuiControl, Update:Show, CloseUpdate
	
Return
}
;; End of updating DeoPack Updater


CloseUpdate: ;; Closes the Update Window and hides the button again
	GuiControl, Update:Hide, CloseUpdate
	GuiControl, Update:Show, CurrentProgress
	Gui, Update:Hide
	Gui, Main:Show,, DeoPack Updater
return


SaveSettings:
Gui, Settings:Submit

IniWrite, %AllowNSFW%, settings.ini, Settings, AllowNSFW
if (AllowNSFW) {
DeoPackVersions := "DeoPack-1.16.5|DeoPack-1.17|DeoPack-1.17-NSFW"
} else {
DeoPackVersions := "DeoPack-1.16.5|DeoPack-1.17"
}

if (!UseDefaultDir) {
	IniWrite, %CustomDirectory%, settings.ini, Settings, CustomDirectory
}

IniWrite, %UseDefaultDir%, settings.ini, Settings, UseDefaultDir


Gui, Settings:Hide
GuiControl, Main:, Choice, |%DeoPackVersions%
Gui, Main:Show,, DeoPack Updater
return

DiscardSettings:
SettingsGuiClose:
Gui, Settings:+Owndialogs
MsgBox, 4388, Confirmation, Are you sure you want to discard the changes to the settings?
IfMsgBox No
    return
else
Gui, Settings:Hide
Gui, Main:Show,, DeoPack Updater
return
;;End of Settings


;;Help info
Help:

run %DeoCraftURL%/resources/DeoPack-Updater-Help.html

return



;;Exit when close Gui
GuiClose:
MainGuiClose:
UpdateGuiClose:
Gui, +Owndialogs
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
Gui, Settings:Submit

Gui, Main:+Owndialogs

IniRead, iniCustomDirectory, settings.ini, Settings, CustomDirectory

if (UseDefaultDir) {
	DeoPackDirectory :=  A_AppData "\.minecraft\resourcepacks"
} else {
	DeoPackDirectory := iniCustomDirectory
}

if !FileExist(DeoPackDirectory) {
	MsgBox, 4400, Warning, Select a valid directory!
	return
}

if (Choice == "") {
	MsgBox, 4400, Warning, Select a version to update!
	return
}

;;Check if DeoPaack exists
DeoPackLocation := DeoPackDirectory "\" Choice ".zip"

if !FileExist(DeoPackLocation) {
	MsgBox, 4388, Confirmation, You do not have %Choice%.zip, Do you want to download it?
IfMsgBox No
    return
else
	Gui, Main:Hide
	Gui, Update:Show, w255 h65, DeoPack Updater
	statusTxt := "Downloading newest version.."
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 10
	
	UrlDownloadToFile,%DeoCraftURL%/resources/%Choice%.zip, %DeoPackLocation%

	statusTxt := "Done!"
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 100
	
	GuiControl, Update:Hide, CurrentProgress
	GuiControl, Update:Show, CloseUpdate
return
}

statusTxt := "Downloading current version list.."
GuiControl, Update:, status, %statusTxt%
GuiControl, Update:, CurrentProgress, 1

Gui, Main:Hide
Gui, Update:Show, w255 h65, DeoPack Updater

UrlDownloadToFile, %DeoCraftURL%/resources/%Choice%-infoCurrent.ini, %A_ScriptDir%\data\%Choice%-infoCurrent.ini

GuiControl, Update:, CurrentProgress, +15

data := A_ScriptDir "\data\"

RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%DeoPackLocation%' -DestinationPath '%data%',, Hide

sleep, 500
statusTxt := "Getting local version.."
GuiControl, Update:, status, %statusTxt%
GuiControl, Update:, CurrentProgress, +10
sleep, 500

;;Get Current Version
IniRead, currentVersion, %A_ScriptDir%\data\%Choice%-infoCurrent.ini, Info, Version

GuiControl, Update:, CurrentProgress, +15

sleep 2500

;;Get Local Version

IniRead, localVersion, %A_ScriptDir%\data\%Choice%-info.ini, Info, Version

GuiControl, Update:, CurrentProgress, +15

;;Update check
if (currentVersion > localVersion) {
	statusTxt := "A new version is avalible!`nCurrent version: " currentVersion " Local version: " localVersion
	
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, +5
	sleep 2500
	statusTxt := "Downloading new version.."
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, +15
	UrlDownloadToFile,%DeoCraftURL%/resources/%Choice%.zip, %DeoPackLocation%
	
	
} Else if (localVersion == "ERROR") {
	statusTxt := "Coudn't find local version`nCurrent version: " currentVersion ", Local version: " localVersion
	
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, +5
	sleep 2500
	statusTxt := "Downloading new version.."
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, +15
	UrlDownloadToFile,%DeoCraftURL%/resources/%Choice%.zip, %DeoPackLocation%


} Else {
statusTxt := "Up-to-date!"
GuiControl, Update:, status, %statusTxt%
GuiControl, Update:, CurrentProgress, +30
sleep 250
}

FileRemoveDir, %data%, 1
FileCreateDir, %data%


statusTxt := "Done!"
GuiControl, Update:, status, %statusTxt%
GuiControl, Update:, CurrentProgress, 100

GuiControl, Update:Hide, CurrentProgress
GuiControl, Update:Show, CloseUpdate

}

if ErrorLevel
	MsgBox, 4400, Warning, Something went wrong!, read the documentary for help

return
