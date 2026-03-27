# Adaptive Commerce (Happy Paws)

AI-powered Flutter app for pet care and shopping workflows:
- Pet profile onboarding
- Food guidance and product recommendations
- Veterinary guidance and nearby clinic discovery
- Toys recommendations from Firestore with checkout mock

The app uses GenUI + Firebase AI to render structured widget surfaces per turn.

## Tech Stack

- Flutter + Dart
- Riverpod (state management)
- GoRouter (navigation)
- Firebase Core + Firestore + Storage
- `firebase_ai` + `genui` + `genui_firebase_ai`

## App Modules

### Onboarding (`lib/features/onboarding`)
- `onboarding_page.dart`: GenUI conversation for profile collection.
- `catalog/onboarding_catalog.dart`: custom onboarding widgets:
  - `PetTypeDropdown`
  - `PetNameInput`
  - `PetDobCalendar`
  - `PetBreedDropdown`
  - `PetGenderRadio`
  - `PetProfileCard` (summary + Continue)
- `pet_profile.dart` / `pet_profile_provider.dart`: pet profile model + state.

### Food (`lib/features/food`)
- `food_page.dart`: Food assistant surface flow.
- `catalog/food_catalog.dart`: custom widgets such as:
  - `FoodProductResults`
  - `ProductComparisonTable`
  - `FeedingQuantityGuide`
  - `PetFoodSafetyAnswer`
  - `PetHabitTips`
  - `PetTopicAdvice`
- Tools:
  - `tools/pet_food_search_tool.dart`
  - `tools/pet_food_web_search_tool.dart`

### Veterinary (`lib/features/vet`)
- `vet_page.dart`: Veterinary assistant surface flow.
- `catalog/vet_catalog.dart`: custom widgets:
  - `VetVaccinationSchedule`
  - `VetRemediesAnswer`
  - `VetNearestVetFinder`
  - `VetTopicAdvice`
- Tool:
  - `tools/vet_places_tool.dart` (Google Places lookup)

### Toys (`lib/features/toys`)
- `toys_page.dart`: Toys assistant with Firestore tool + GenUI catalog surfaces.
- `catalog/toys_catalog.dart`: custom widgets:
  - `ToySuggestionResults` (includes Buy now CTA)
  - `ToyTopicAdvice`
- `tools/toys_firestore_tool.dart`: reads `toys` collection from Firestore.
- `checkout_page.dart`: mock order placed screen.

## Navigation

Routes live in:
- `lib/core/router/app_routes.dart`
- `lib/core/router/app_router.dart`

Main paths:
- `/onboarding`
- `/food`
- `/vet`
- `/toys`
- `/checkout` (full-screen mock checkout)

Shell tabs are `Food`, `Veterinary`, and `Toys`.

## Data and AI

- Firebase bootstrapping is in `lib/main.dart` and `firebase_options.dart`.
- Firestore path constants are in `lib/core/firebase/firebase_paths.dart`.
- `toys` Firestore collection is used by `fetch_toys_from_firestore`.

Expected toy document fields:
- `name` (string)
- `price` (string)
- `seller` (string)
- `url` (string)

## Run Locally

Install dependencies:

```bash
flutter pub get
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run as web server (use your own browser profile/extensions):

```bash
flutter run -d web-server --web-port=7357
```

Then open `http://localhost:7357` in Chrome.

## Configuration Notes

- Gemini model selection comes from `FirebaseAiConfig.generativeModel`.
- Vet places tool expects Google Places support; review `lib/features/vet/tools/vet_places_tool.dart`.
- Environment variables are loaded via `flutter_dotenv` from root `.env`.
- Add this key for veterinary places:
  - `GOOGLE_PLACES_API_KEY=your_api_key_here`
- App-wide UI labels are centralized in `lib/core/resources/app_strings.dart`.

## Project Structure (High-level)

```text
lib/
  core/
    firebase/
    resources/
    router/
    widgets/
  features/
    onboarding/
    food/
    vet/
    toys/
  layout/
  services/
  theme/
```
