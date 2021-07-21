#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

;;Create /data folder if missing
IfNotExist, data
	FileCreateDir, data


;;Read Settings on startup
IniRead, iniAllowNSFW, settings.ini, Settings, AllowNSFW, 0
if (iniAllowNSFW) {
DeoPackVersions := "DeoPack-1.16.5|DeoPack-1.17|DeoPack-1.17-NSFW"
} else {
DeoPackVersions := "DeoPack-1.16.5|DeoPack-1.17"
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
Gui, Settings:Add, Button, Default x160 y135 w100 gSaveSettings, Save Settings
Gui, Settings:Add, Button, x15 y135 w100 gDiscardSettings, Cancel
;;End of settings Gui

;;Update Gui
Gui, Update:New
Gui, Update:+AlwaysOnTop
Gui, Update:Color, FFFFFF
statusTxt := "Downloading current version list.." ;;Default Status text
Gui, Update:Add, text, w240 h40 vstatus, % statusTxt
Gui, Update:Add, Progress, x10 y35 w235 h20 cGreen vCurrentProgress, 1

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
Gui, Settings:Show, w275 h165, DeoPack Updater
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

run https://deocraft.serv.nu/resources/DeoPack-Updater-Help.html

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

if (DeoPackDirectory == "") {
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
	
	UrlDownloadToFile,https://deocraft.serv.nu/resources/%Choice%.zip, %DeoPackLocation%

	statusTxt := "Done!"
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, 100
	
	sleep 2500
	
	Gui, Update:Hide
	Gui, Main:Show,, DeoPack Updater
return
}

statusTxt := "Downloading current version list.."
GuiControl, Update:, status, %statusTxt%
GuiControl, Update:, CurrentProgress, 1

Gui, Main:Hide
Gui, Update:Show, w255 h65, DeoPack Updater

UrlDownloadToFile, https://deocraft.serv.nu/resources/%Choice%-infoCurrent.ini, %A_ScriptDir%\data\%Choice%-infoCurrent.ini

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
	UrlDownloadToFile,https://deocraft.serv.nu/resources/%Choice%.zip, %DeoPackLocation%
	
	
} Else if (localVersion == "ERROR") {
	statusTxt := "Coudn't find local version`nCurrent version: " currentVersion ", Local version: " localVersion
	
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, +5
	sleep 2500
	statusTxt := "Downloading new version.."
	GuiControl, Update:, status, %statusTxt%
	GuiControl, Update:, CurrentProgress, +15
	UrlDownloadToFile,https://deocraft.serv.nu/resources/%Choice%.zip, %DeoPackLocation%


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

sleep 2500
Gui, Update:Hide
Gui, Main:Show,, DeoPack Updater

}

if ErrorLevel
	MsgBox, 4400, Warning, Something went wrong!, read the documentary for help

return
