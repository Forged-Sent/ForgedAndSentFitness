# Sign-in design (approved 2026-11-01)

Approved by Curtis for the Firebase version of the app. The current claude.ai prototype gets identity from claude.ai, so none of this is live yet. Mockup: `sign-in-mockup.png` (source `sign-in-mockup.html`).

## Decisions

- Sign in with **Apple**, **Google**, or **email and password**. All three sit behind the 18+ terms checkbox (shipped as the agreement screen in v220).
- **No Face ID / app lock.** Once signed in, a brother stays signed in on that device until he signs out.
- **Email is the user ID** for password accounts, so password reset works without owner help. Display name is separate.
- Apple is offered alongside Google per App Store login-services rules.

## Security baseline

- Firebase Authentication providers only (Apple, Google, Email/Password). No custom authentication.
- Email accounts: verification link on sign-up, minimum 8 characters and a common-password check, Firebase's built-in throttling after repeated wrong attempts, "Forgot password" via email.
- Firebase refresh tokens keep users signed in; ID tokens refresh hourly in the background.
- "Sign out everywhere" and owner removal revoke refresh tokens.
- Recent sign-in required before account deletion or password change.
- Agreement recorded server-side with version and timestamp; a new version re-prompts.

## Screens

1. Sign in: terms checkbox, Continue with Apple, Continue with Google, "Sign up or sign in with email".
2. Create account: name, email (user ID), password with rules, confirmation email.
3. Email sign-in: email, password, Forgot password, throttle note.
4. Settings › Sign-in & security: sign-in method, Change password (email only), devices with per-device sign-out, agreement accepted, Sign out of this phone, Sign out everywhere.
