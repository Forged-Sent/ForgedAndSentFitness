# 07 · Nutrition and health

Status: **Accepted (ADR-0011)**. Provider choice is OD-07; point caps are OD-04.

## Nutrition

### Provider abstraction

```dart
abstract interface class NutritionProvider {
  Future<List<FoodHit>> search(String query, {Locale? locale, int limit = 20});
  Future<FoodHit?> byBarcode(String gtin);
  Future<FoodDetail> detail(String providerFoodId);
  ProviderAttribution get attribution; // shown in UI where the license requires it
}
```

- The client calls the callable `nutritionSearch` / `nutritionBarcode`. A Function holds the API keys, caches results in `nutritionCache/{provider}_{id}` (TTL per provider terms) and normalizes to `FoodDetail` with per-serving macros.
- Every `foodEntries` document stores `source` (`fatsecret | usda_fdc | off | manual`), `sourceId`, serving and grams, so totals are reproducible. A provider swap never rewrites history.

### Candidate providers: food *lookup*, not diary import

| Provider | What was verified (2026-10-26) | Notes |
|---|---|---|
| FatSecret Platform | Basic: free, US data, 5,000 calls/day, attribution required. Premier Free: unlimited, verification required, adds UPC barcode and autocomplete. Premier: priced on request ([editions](https://platform.fatsecret.com/api-editions)) | Strongest barcode coverage for a free tier, pending eligibility |
| USDA FoodData Central | Public-domain US data (from earlier review research) | Generic foods; weaker for branded products |
| Open Food Facts | ODbL database license (attribution and share-alike obligations) | Barcode coverage varies by country |
| Nutritionix, Edamam | **Not verified** in this pass | Evaluate pricing and terms before choosing |

### Importing a user's existing food diary

This is **not claimed**:

- MyFitnessPal and similar apps do not offer a verified public diary API for this use.
- Some apps write dietary energy and nutrients to Apple Health or Health Connect. For example, MyFitnessPal was reported writing dietary calories and carbohydrates to HealthKit in 2014. Current behavior is **unverified**.
- Reading HealthKit/Health Connect nutrition records via the `health` plugin (NUTRITION type, verified supported) may therefore surface other apps' entries. It must be tested per source app before the UI promises it.

### Points and safety (FS-NUT-002, OD-04)

- **Points:** participation only. A logged day (≥ 2 meals) and a hydration target met earn points, capped per week.
- **Never scored:** calorie deficit, being under target, weight change, body measurements.
- **Safety floor:** a day logged below a floor (proposed 1,200 kcal, clinician to confirm) earns **no complete-day credit**, and the app shows a private, supportive check-in. The floor is never a target.
- **Fasting:** opt-in, private, unscored, with a safety screen. Calorie boxes are not auto-checked (the prototype's L2017 behavior is retired).
- **AI meal-photo estimation:** deferred. If added, it is labelled as an estimate with a range, and never drives points.

## Health integrations

| Item | Design |
|---|---|
| Platforms | Apple HealthKit, Android Health Connect via the `health` plugin (13.3.2 verified: steps, workouts, weight, water, nutrition; Google Fit support removed) |
| Consent | Per type, recorded in `users/{uid}/healthSources/{type}` with grantedAt and revokedAt. Revoking stops reads and offers deletion of imported data |
| Storage | Daily aggregates `users/{uid}/healthDays/{localDate}_{type}`: value, unit, chosen source, `platformIds` (capped, else hashed), `importedAt` |
| Dedupe | By platform record UUID; one preferred source per type per day (watch > phone > manual); manual and imported values are never summed |
| Provenance | Every derived fact carries `source`; scoring may weigh sources differently (steps: health-sourced only) |
| Store requirements | Google Play Health apps declaration and Data safety; Apple HealthKit entitlement, usage strings, no advertising use. Re-verify when implementing |
| Privacy | Owner-only; never visible to leaders; included in export and deletion |

Delivery can be staged (Phase 7), but these collections and consent records are part of the Phase 1 schema contract.
