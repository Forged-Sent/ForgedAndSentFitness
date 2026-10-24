# Connecting Apple Health and Health Connect

**Status:** groundwork is in the page (v14). Real connection needs the native app wrapper. A web page, including the claude.ai prototype, cannot reach HealthKit or Health Connect.

## What the page already does
- Reads `window.ForgedHealth`. When absent (web), the Settings > Health data section explains this and Steps, Weigh-In and Workout stay manual.
- When present, each man can switch on Steps, Weight and Workouts separately. The page then:
  - checks **Steps** at 10,000 steps (task kind `steps`),
  - checks **Weigh-In** when a weigh-in is recorded today (task kind `weigh`),
  - checks **Workout** when a workout is recorded (never unchecks it).
- Health numbers stay on the phone. Only the on/off choices (private settings) and the resulting checked boxes are stored. Raw numbers are never sent to the group.
- Refreshes on app open, when the app returns to the foreground, and every 5 minutes.

## Contract the wrapper must implement
```js
window.ForgedHealth = {
  platform: "ios" | "android",
  requestAccess(types),   // types: ["steps"] | ["weight"] | ["workouts"]; resolves {steps?: bool, weight?: bool, workouts?: bool}
  readToday()             // resolves {steps: number|null, weightLb: number|null, workouts: number}
};
```
`weightLb` must be null unless a weigh-in exists for today.

## Plugin options (Capacitor)
- `@capacitor/health-fitness` reads and writes steps, calories burned, distance, weight, height, body fat and more through HealthKit (iOS) and Health Connect (Android). Per its docs, workouts are iOS-only, water is iOS-only, and Android writes are limited to profile data. iOS needs `Info.plist` entries and HealthKit entitlements; Android needs a `healthfitness.config.json` declaring permissions and a privacy policy URL. Source: https://capacitorjs.com/docs/apis/health-fitness
- Community alternatives exist (e.g. `@capgo/capacitor-health`, Capawesome's health plugin). Re-check maintenance before choosing.
- Android workouts: confirm Health Connect exercise-session support in the chosen plugin before promising the Workout box on Android.

## Store requirements
- **Google Play:** complete the Data safety section and the Health apps declaration form (App content page). Request the minimum data types and justify each; the privacy policy must match what users see in Health Connect. Source: https://developer.android.com/health-and-fitness/health-connect/publish
- **Apple:** treat health data as sensitive (App Review 5.1.3): disclose what is collected, no advertising or data mining, usage descriptions in `Info.plist`. Source: https://developer.apple.com/app-store/review/guidelines/
- Privacy policy and in-app data deletion must cover health-derived data.

## Next steps
1. Native wrapper (Capacitor) around `index.html`.
2. Small bridge script that implements `window.ForgedHealth` on top of the chosen plugin.
3. Real backend (see README), then TestFlight and Play internal testing with a few men.
