; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "RPMLauncher"
#define MyAppPublisher "The RPMTW Team"
#define MyAppURL "https://github.com/RPMTW/RPMLauncher"
#define MyAppExeName "rpmlauncher.exe"
#define MyAppVersion GetVersionNumbersString("rpmlauncher.exe")

#define MyAppPackagingDir "./Release"
#define MyAppOutputBaseFilename "RPMLauncher-Windows-Installer"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{df98a1bf-66e2-456c-90ed-d7ae698a6c09}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=.
OutputBaseFilename={#MyAppOutputBaseFilename}
Compression=lzma
SolidCompression=yes                                                                              
WizardStyle=modern
SetupIconFile="app_icon.ico"
VersionInfoCompany=The RPMTW Team
VersionInfoCopyright="Copyright © The RPMTW Team 2021-2022 All Right Reserved."
VersionInfoDescription="A better Minecraft Launcher that supports cross-platform and many functionalities for you to explore!"


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesetraditional"; MessagesFile: "compiler:Languages\ChineseTraditional.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyAppPackagingDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpPreparing then
  begin
    WizardForm.PreparingYesRadio.Visible := False;
    WizardForm.PreparingNoRadio.Visible := False;
  end;
end;