# Local-only Firebase developer configuration

Firebase CLI starts the Local Emulator Suite under \`demo-forgedandsent\`.
No Firebase login or cloud project is required.

From the repository root:

\`firebase emulators:start --project demo-forgedandsent --only auth,firestore,storage\`

From the mobile folder, after \`flutter pub get\`:

\`flutter run -d chrome --dart-define=FNS_ENV=emulator\`

The app initializes SDKs with explicit demo-only FirebaseOptions, binds Auth
port 9099, Firestore 8080, and Storage 9199 before any SDK operation, then
signs in anonymously against the Auth emulator. Failure presents a visible
error instead of falling back to cloud.

For Android Emulator, the host default is \`10.0.2.2\`; browser and desktop use
\`127.0.0.1\`. A physical Android device requires an explicit reachable LAN IP
via \`--dart-define=FNS_EMULATOR_HOST=YOUR-LAN-IP\`, plus network/firewall and
host binding changes that should be reviewed before opening emulator ports.

**Never run \`flutterfire configure\` in automated setup.** It can register
real cloud apps. DEV/PROD modes are intentionally disabled until reviewed.

The \`developer_smoke\` collection and storage prefix are available only to
authenticated emulator users. Other documents/objects are denied by the
checked-in rules.

Integration acceptance requires a real emulator response, not only compilation.
