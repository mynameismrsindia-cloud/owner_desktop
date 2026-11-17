# Wholesale Manager

Flutter desktop app for managing wholesale products and sales. It connects to
the NestJS + PostgreSQL API; Firebase Auth, Firestore, and Google Sign-In are
not required.

## Development

```powershell
flutter pub get
flutter run -d windows
flutter analyze
flutter test
```

For Windows desktop development, enable Windows desktop support in Flutter
and install Visual Studio with the **Desktop development with C++** workload.
The app uses the production API URL by default.

If `API_BASE_URL` is omitted, the app uses the production API:
`https://wholesellerbackend-production.up.railway.app/api/v1`.

For local development, set `API_BASE_URL` to your local API URL. For a release
build, the production URL is used by default; to override it:

```powershell
flutter build windows --release --dart-define=API_BASE_URL=https://wholesellerbackend-production.up.railway.app/api/v1
```

Owner accounts are provisioned by the API administrator.

## Windows installer

Build the Windows installer on a Windows machine with Flutter's Windows
desktop prerequisites and Inno Setup 6 installed. From the project directory,
run:

```powershell
flutter pub get
flutter build windows --release
New-Item -ItemType Directory -Force build/installer
Invoke-WebRequest https://aka.ms/vs/17/release/vc_redist.x64.exe `
  -OutFile build/installer/vc_redist.x64.exe
& "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" installer/owner_desktop.iss
```

The setup is created at `build/installer/Wholesale-Manager-Setup.exe`. It
installs the desktop app and creates Start menu and desktop shortcuts. The
installer's AppId and install directory are intentionally retained so an
upgrade can target an existing installation. The setup is unsigned; Windows
may show a publisher warning.

## Portable ZIP

On Windows, run this from PowerShell in the project directory:

```powershell
flutter pub get
.\installer\build-windows-zip.ps1
```

The script builds the Windows release and creates
`build/installer/Wholesale-Manager-Windows-x64.zip`. Extract it and double-click
`wholesale_manager.exe` inside the extracted folder. Keep the other files from
the ZIP beside the EXE. The ZIP does not install the Microsoft Visual C++
runtime; install the x64 Redistributable if Windows reports that a `VCRUNTIME`
DLL is missing.

## Updates

Product, stock, and sales changes are stored by the API and load in the app;
those data changes do not require reinstalling the desktop program. Changes to
the app itself (for example, new screens or logic) require a new Windows build
and installation for the Windows desktop version.

The web version deploys automatically to
`https://mynameismrsindia-cloud.github.io/owner_desktop/` when changes are
pushed to the `main` branch. Web users open that link in a browser and do not
reinstall the Windows app; they may need to refresh the page to load the latest
version. To enable deployment the first time, open the repository's **Settings
→ Pages** and set the build and deployment source to **GitHub Actions**.
GitHub Pages hosts only the web app, not the Windows EXE.

Every push to `main` also builds a Windows release ZIP. Download it from the
repository's **Actions → Build Wholesale Manager for Windows → latest
successful run → Artifacts → Wholesale-Manager-Windows-x64**. Extract the ZIP
and run `wholesale_manager.exe`; keep the adjacent files together. Each
successful Windows build artifact is available for 30 days.

The browser app still needs access to the configured HTTPS API. If the API is
private or restricted to an office network, users need that network or VPN,
and the API must allow browser requests from the GitHub Pages origin.

The optional Microsoft Store package configuration keeps its existing package
identity (`PushpenduDas.WholeSalerOwner`) to avoid breaking existing Store
updates. Its Store display name is still reserved as `WholeSalerOwner`; changing
that listing name requires a Partner Center change as well.

See [FUNCTIONS_AND_LOGIC.md](./FUNCTIONS_AND_LOGIC.md) for a one-page list of
app features and business logic.
