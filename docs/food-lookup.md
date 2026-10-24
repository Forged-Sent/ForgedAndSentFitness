# Food lookup

**Now (v21):** "Estimate with Claude" in the add-food form. `B.lookupFood(text)` calls the artifact `sample` capability and returns `{name, kcal, p, f, c}`. Values are estimates, flagged as such in the UI.

**Why no direct USDA / Open Food Facts calls:** a published artifact page's network is blocked, so third-party APIs cannot be called from the page.

**Next:** a small serverless function (Cloudflare Worker or Cloud Function) that holds the API key and proxies:
- USDA FoodData Central `/fdc/v1/foods/search` (free; US foods, branded foods include UPC)
- Open Food Facts `/api/v2/product/<barcode>` (free; ODbL license, review before commercial release)

Then replace `B.lookupFood` with a fetch to that endpoint and add a search-results list and barcode scan to the form. Paid providers (Edamam, FatSecret, Nutritionix) can sit behind the same endpoint later.
