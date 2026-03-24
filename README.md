# FitCheck App

## Contributers
up2212828 - Sean
up2268420 - Maheer
up2240530 - Ben
up2266467 - Leo
up2270789 - Amaliia
up2246575 - rume]

FitCheck is a Flutter application designed to help users manage and organise outfits digitally. The project follows a clean architecture with Presentation, Domain, and Data layers. Authentication uses Supabase, and state management is handled with Riverpod. The app allows users to register, sign in, manage their wardrobe (add clothes, create outfits), and is set up for future outfit sharing features.

## Current Implementation Status

## Authentication & User Management
- User registration (sign-up) and login (sign-in) with Supabase Auth
- Email/password authentication
- Custom registration UI with dark theme and gold accents
- Sign-in buttons and password field components with visibility toggle

## Wardrobe Management (CRUD backend implemented, UI display pending)
- Backend CRUD methods fully implemented:
  - Add clothing items with detailed metadata (wear type, fabric, warmth rating, water resistance, layer category, photo URL)
  - Create outfits by linking multiple clothing items
  - Full CRUD operations: create, read, update, delete for both items and outfits
- UI Status:
  - Create item and create outfit modals are functional
  - Wardrobe items display not yet implemented— WardrobePage doesn't fetch/display items from database yet
  - Photo upload is a placeholder (shows mock button), not connected to Supabase Storage
- Outfit properties: name, description, isOwned flag, linked clothing items

## UI & Design
- Custom reusable components with glass morphism effect (GlassFrame with BackdropFilter blur)
- Floating navigation bar
- Search bar and filter buttons in wardrobe UI
- Dark theme with gold accents 
- Responsive layout for different screen sizes
- Custom password field with toggle visibility

## Architecture & State
- Clean architecture: Presentation / Domain / Data layers
- Riverpod for reactive state management
- Repository pattern with Supabase implementations
- Table fallback mechanism for flexible database structure (tries multiple table names)

## Testing
- Widget tests for Login and Register pages
- Test utilities for mobile screen size setup
- Fake repository implementations for unit testing

## Prerequisites

- Flutter SDK — https://flutter.dev/docs/get-started/install
- Dart SDK (bundled with Flutter)
- A development device:
  - iOS Simulator (requires Xcode on macOS)
  - Android Emulator (requires Android Studio)
  - Physical device (iOS or Android) with USB debugging enabled
- Code editor: VS Code, Android Studio, or Xcode
- Git (for cloning the repository)

## Installation & Setup

Clone the repository and navigate to the Flutter project:

git clone https://github.com/SETAP-Group-6E/FitCheck_App.git
cd "FitCheck_App/fitcheck frontend"


Install dependencies:

flutter pub get


## Required Supabase Setup

1. Authentication Tables — Supabase Auth automatically manages "auth.users" table
2. Profiles Table (optional) — For storing user metadata beyond auth
3. Clothing Items Table — Any of these names:
   - "item", "items", "clothing_item", or "clothing_items"
   - Columns: "id", "user_id", "title", "wear_type", "fabric_material", "warmth_rating", "water_resistant", "layer_category", "photo_url"
4. Outfits Table — Any of these names:
   - "outfit" or "outfits"
   - Columns: "id", "name", "description", "is_owned", "clothing_item_ids" (array type)



## Architecture Overview

## Clean Architecture Layers

Presentation Layer ("lib/Presentation/")
- Contains all UI widgets and pages
- Uses "ConsumerWidget" / "ConsumerStatefulWidget" for Riverpod integration
- Never directly calls Supabase; only uses repository interfaces
- Includes reusable styled components (buttons, inputs, containers)
- Organizes by feature: "auth/", "App/"

Domain Layer ("lib/Domain/")
- Contains abstract repository interfaces (contracts)
- Pure Dart, no external dependencies (except "flutter" for platform-agnostic types)
- Defines data models and business logic contracts
- Examples: AuthRepository, WardrobeRepository

Data Layer (lib/Data/)
- Implements domain repositories using Supabase
- Handles API calls, database queries, storage
- Handles errors and retries (table fallback mechanism for wardrobe)
- Examples: SupabaseAuthRepository, SupabaseWardrobeRepository


## Data Flow Example (Adding a Clothing Item)


UI (create_item.dart)
  ↓
calls repository.addClothingItem()
  ↓
WardrobeRepository (domain interface)
  ↓
SupabaseWardrobeRepository (data layer)
  ↓
_supabase.from(table).insert(data)   tries: item → items → clothing_item → clothing_items
  ↓
Supabase API → Database


## Tech stack

- Flutter (UI framework)
- Dart (programming language)
- Riverpod (state management and dependency injection)
- Supabase (backend, authentication, database, storage)
- Google Fonts 
- Google Sign-In 



## Key files & their roles

Core App Entry:
    - lib/main.dart — Initializes Supabase, sets up Riverpod ProviderScope, configures routes for HomePage, RegisterPage, LoginPage, WardrobePage.

Authentication Layer
- lib/Domain/repositories/auth_repository.dart — Abstract interface defining "signUp()" and "signIn()" methods
- lib/Data/repositories/supabase_auth_repository.dart — Supabase implementation of auth with email/password
- lib/Presentation/auth/provider/auth_provider.dart — Riverpod providers: authRepositoryProvider and  authControllerProvider for managing auth state
- lib/Presentation/auth/pages/register_page.dart — Registration UI with validation, username/email/password fields, custom styling
- lib/Presentation/auth/pages/login_page.dart — Login UI with email/password, password visibility toggle

Wardrobe & Item Management
- lib/Domain/repositories/wardrobe_repository.dart — Abstract interface with CRUD (Create, Read, Update, Delete) methods for clothing items and outfits
- lib/Data/repositories/supabase_wardrobe_repository.dart — Supabase implementation with:
  - addClothingItem(), removeClothingItem(), updateClothingItem(), getClothingItems()
  - addOutfit(), removeOutfit(), updateOutfit(), getOutfits()
  - Table fallback mechanism (tries multiple table names for robustness)
- lib/Presentation/App/app_pages/wardrobe_page.dart — Main wardrobe screen with search, filter, back button, floating navbar
- lib/Presentation/App/app_pages/wardrobe/widgets/create_item.dart` — Modal dialog for adding clothing items with:
  - Wear type selection, fabric material, warmth rating, water resistance, layer category
  - Photo URL field (placeholder image picker — not connected to Supabase Storage)
  - Dark theme with custom input styling
- lib/Presentation/App/app_pages/wardrobe/widgets/create_outfit.dart — Modal dialog for creating outfits with name, description, ownership flag, and item linking

UI & Navigation
- lib/Presentation/App/app_pages/home_page.dart — Welcome page with gold buttons to navigate to wardrobe or sign in
- lib/Presentation/App/app_style/glass_frame.dart — Reusable glass morphism component (BackdropFilter blur effect)
- lib/Presentation/App/app_style/floating_navbar.dart — Positioned floating navigation bar with customizable items
- lib/Presentation/App/app_style/password_field.dart — Password input widget with visibility toggle (eye icon)
- lib/Presentation/App/app_style/search_bar.dart — Search input field
- lib/Presentation/App/app_style/signin_buttons.dart — Styled authentication buttons
- lib/Presentation/App/app_style/dashed_box.dart — Custom dashed border container
- lib/Presentation/App/app_style/backlight_gradient.dart — Gradient effect utilities

Testing
- test/register_page_test.dart — Widget tests for register page :
  - Name, email, password field visibility checks
  - Password visibility toggle functionality
  - Form validation and error handling
- test/login_page_test.dart — Widget tests for login page :
  - Email and password field presence tests
  - Password visibility toggle tests
  - Screen size utilities for iPhone SE (375x667)

## How the app works (detailed implementation)

## Authentication Flow

Registration (Sign Up)
1. User lands on RegisterPage and enters: username, email, password
2. Validation checks:
   - Non-empty fields
   - Email format validation
   - Password strength validation
3. On submit:
   - Presentation layer calls AuthRepository.signUp() (from Riverpod provider)
   - Data layer (SupabaseAuthRepository) calls "Supabase.auth.signUp(email, password, data: {username})"
   - User created in Supabase Auth with metadata attached
4. On success: navigate to HomePage or authenticated area
5. On error: display error message via SnackBar

Login (Sign In)
1. User enters email and password on LoginPage
2. Validation checks for non-empty fields
3. On submit:
   - Presentation calls "AuthRepository.signIn(email, password)"
   - Data layer calls "Supabase.auth.signInWithPassword()"
4. On success: Riverpod provider updates auth state, navigate to HomePage
5. On error: display error feedback

## State Management

- authRepositoryProvider (Riverpod Provider) — provides "SupabaseAuthRepository"
- authControllerProvider (StateNotifierProvider) — Manages boolean auth state (logged in / out)
- UI pages use "ConsumerWidget" to access providers via "WidgetRef"
- Widget rebuilds when provider state changes

## Navigation & Routing

Routes configured in "main.dart":
- /homepage → HomePage (welcome page)
- /register → RegisterPage (sign up)
- /login → LoginPage (sign in)
- /wardrobe → WardrobePage (main feature)

Default home is HomePage on app launch.

## Wardrobe Data Model & CRUD

Clothing Items stored with properties:
- "id" — unique identifier
- "user_id" — linked to authenticated user
- "title" — item name/description
- "wear_type" — category (Top, Bottom, Footwear, Outerwear, Accessory)
- "fabric_material" — material type (Cotton, Denim, Wool, etc.)
- "warmth_rating" — 1-5 scale for temperature suitability
- "water_resistant" — boolean flag
- "layer_category" — Base layer, Mid layer, Outer layer, or Single layer
- "photo_url" — optional image URL (stored in Supabase storage)

Outfits stored with:
- "id" — unique identifier
- "name" — outfit name
- "description" — outfit notes
- "is_owned" — boolean (owned vs. inspiration)
- "clothing_item_ids" — array of linked item IDs

CRUD Operations via SupabaseWardrobeRepository:

Create:
- addClothingItem() — inserts new clothing item
- addOutfit() — inserts new outfit with linked items

Read:
- getClothingItems() — fetches all items for current user
- getOutfits() — fetches all outfits

Update:
- updateClothingItem() — partial update (only specified fields)
- updateOutfit() — partial update

Delete:
- removeClothingItem() — deletes item by ID
- removeOutfit() — deletes outfit by ID

Table Fallback Mechanism:
The repository tries multiple possible table names ("item", "items", "clothing_item", "clothing_items" for items, "outfit", "outfits" for outfits) to handle flexible database schemas and migration states.

## UI Layers & Components

WardrobePage
- Black background with header row containing:
  - Back button (GlassFrame with blur effect)
  - SearchBarRow for filtering items
  - Filter icon button
  - Grid view toggle icon
- Scrollable content area displaying wardrobe items/outfits
- FloatingNavbar at bottom with action buttons (create item, create outfit)

Create Item Dialog ("create_item.dart")
- Modal overlay with semi-transparent black background
- Form inputs:
  - Title field
  - Wear type dropdown 
  - Fabric material dropdown
  - Layer category dropdown
  - Warmth rating slider 
  - Water resistance toggle
  - Photo URL field (placeholder image picker not connected to Supabase Storage)
- Save/Cancel buttons
- Themed styling: dark cards, gold accents, muted text colors

Create Outfit Dialog ( "create_outfit.dart" )
- Modal overlay
- Form inputs:
  - Name field
  - Description field (multi-line)
  - "Is Owned" toggle
  - Clothing items selector (future enhancement: checkbox list)
- Save/Cancel with error handling

Custom UI Components:
- GlassFrame — Container with BackdropFilter blur, semi-transparent background, and subtle border
- FloatingNavbar — Positioned at bottom with customizable icon buttons
- PasswordField — TextField with visibility toggle (eye/eye_off icons)
- SearchBarRow — Input field integrated into toolbar

## Design System

Color Palette:
- Background: Black 
- Accent: Gold 
- Cards: Dark gray 
- Borders: Lighter gray 
- Text: White (light) / Gold (accents)

Theme:
- Dark mode throughout
- Gold accents for highlights
- Glass morphism (BackdropFilter blur) for modern look
- Material Design 3 with "ColorScheme.fromSeed(seedColor: Colors.deepPurple)"

## Testing & Quality Assurance

Widget Tests (using "flutter_test"):
- Field visibility tests
- Password visibility toggle tests
- Form submission tests
- Navigation tests
- Fake repositories for isolating UI logic

Test Utilities:
- Mobile screen size setup ("setUpMobileScreenSize") — simulates iPhone SE (375×667)
- Fake "AuthRepository" implementation for deterministic testing



This README reflects the complete current state of the FitCheck app including:
- Full authentication system with Riverpod state management
- Complete wardrobe CRUD implementation (clothing items, outfits)
- Custom reusable UI components with glass morphism design
- Modal dialogs for creating items and outfits
- Widget tests for auth pages
- Clean architecture with proper separation of concerns


## Project Structure


lib/
├── main.dart                                 # App entry point, Supabase init, routes
├── Domain/                                   # Business logic & interfaces
│   └── repositories/
│       ├── auth_repository.dart              # Auth interface (signUp, signIn)
│       └── wardrobe_repository.dart          # Wardrobe CRUD interface
├── Data/                                     # Supabase implementations
│   └── repositories/
│       ├── supabase_auth_repository.dart     # Supabase auth implementation
│       └── supabase_wardrobe_repository.dart # Wardrobe CRUD with Supabase
├── Presentation/                             # UI Layer
│   ├── auth/
│   │   ├── pages/
│   │   │   ├── register_page.dart            # Sign-up screen (dark theme, gold accents)
│   │   │   └── login_page.dart               # Sign-in screen
│   │   └── provider/
│   │       └── auth_provider.dart            # Riverpod providers for auth state
│   └── App/
│       ├── app_pages/
│       │   ├── home_page.dart                # Welcome page with navigation buttons
│       │   ├── wardrobe_page.dart            # Wardrobe main UI (search, filter, grid)
│       │   └── wardrobe/
│       │       └── widgets/
│       │           ├── create_item.dart      # Modal dialog to add clothing items
│       │           └── create_outfit.dart    # Modal dialog to create outfits
│       └── app_style/                        # Reusable UI components & themes
│           ├── glass_frame.dart              # Glass morphism effect with blur
│           ├── floating_navbar.dart          # Bottom floating navigation bar
│           ├── password_field.dart           # Password input with visibility toggle
│           ├── dashed_box.dart               # Custom dashed border box
│           ├── search_bar.dart               # Search input field
│           ├── signin_buttons.dart           # Sign-in/Sign-up button styles
│           └── backlight_gradient.dart       # Gradient effects
test/
├── login_page_test.dart                      # Widget tests for login page
└── register_page_test.dart                   # Widget tests for register page
pubspec.yaml                                  # Dependencies and assets


