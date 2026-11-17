#define AppName "Wholesale Manager"
#define AppVersion "1.0.0"
#define ReleaseDir AddBackslash(SourcePath) + "..\build\windows\x64\runner\Release"
#define VCRedistPath AddBackslash(SourcePath) + "..\build\installer\vc_redist.x64.exe"

[Setup]
AppId={{A8D9A886-25A1-4B57-B41A-9F9F78B6CB91}
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={autopf}\Wholesale Manager
UsePreviousAppDir=yes
DefaultGroupName={#AppName}
UninstallDisplayIcon={app}\wholesale_manager.exe
OutputBaseFilename=Wholesale-Manager-Setup
OutputDir=..\build\installer
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
DisableProgramGroupPage=yes
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#VCRedistPath}"; DestDir: "{tmp}"; Flags: dontcopy

[InstallDelete]
Type: files; Name: "{app}\owner_desktop.exe"
Type: files; Name: "{autoprograms}\Wholesale Manager Owner.lnk"
Type: files; Name: "{autodesktop}\Wholesale Manager Owner.lnk"

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\wholesale_manager.exe"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\wholesale_manager.exe"

[Code]
function IsRequiredVCRedistInstalled: Boolean;
var
  Installed, Major, Minor: Cardinal;
begin
  Result :=
    RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) and
    (Installed = 1) and
    RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Major', Major) and
    RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Minor', Minor) and
    ((Major > 14) or ((Major = 14) and (Minor >= 20)));
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
begin
  Result := '';
  if IsRequiredVCRedistInstalled then
    Exit;

  ExtractTemporaryFile('vc_redist.x64.exe');
  if not Exec(
    ExpandConstant('{tmp}\vc_redist.x64.exe'),
    '/install /quiet /norestart',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    Result := 'The Microsoft Visual C++ x64 Redistributable could not be started. ' +
      'Close other installers and choose Retry, or cancel setup.';
    Exit;
  end;

  if (ResultCode = 3010) or (ResultCode = 1641) then
  begin
    NeedsRestart := True;
    Exit;
  end;

  if IsRequiredVCRedistInstalled then
    Exit;

  if ResultCode = 0 then
    Result := 'The Microsoft Visual C++ x64 Redistributable reported success, ' +
      'but its required runtime was not detected. Close other installers and ' +
      'choose Retry, or cancel setup.'
  else
    Result := 'The Microsoft Visual C++ x64 Redistributable installation failed ' +
      '(code ' + IntToStr(ResultCode) + '). Close other installers and choose ' +
      'Retry, or cancel setup.';
end;
