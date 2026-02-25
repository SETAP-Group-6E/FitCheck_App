# fitcheck
 FitCheck is a mobile application currently in development using Flutter, helps users manage and organise their outfits digitally. The app is being developed using a clean architecture approach with separate presentation, domain, and data layers. So far, the focus of the project has been on implementing the core structure of the app and user authentication using Supabase. The aim of the app is to allow users to register, manage their wardrobe, and share outfit styles in the future.


At this stage, the project mainly focuses on setting up the app structure, authentication system, and registration user interface.

# Current Progress
The application is still in development. The following features have been implemented so far:

- Flutter project setup
- Clean Architecture structure (Presentation, Domain, Data layers)
- Supabase backend integration
- User registration system (Sign Up)
- User Login system (Sign in)
- Custom registration page UI (dark theme with gold accents)
- Riverpod state management setup
- Basic widget testing file


## Prerequisites

Before running the FitCheck app, make sure you have the following installed:

- Flutter SDK – https://flutter.dev/docs/get-started/install
- Dart SDK (comes with Flutter)
- VS Code 
- A device or emulator (Android, iOS, or Web)

## Installation

1. Clone the repository:
   Type ("cd fitcheck" + tab, + enter) in the terminal

2. Install project dependencies:
   Type ("flutter pub get" + enter) in the terminal


## Architecture overview
To achieve a clean architecture the system has 3 different layers

-Presentation layer: handles user interface widgets, handles pages such as the register page and performs state management, managed by Riverpod

-Data layer: implementation of repositories and it handles fetching data from Supabase (handles database operations)

-Domain layer: handles the rules and logic of the application and is independent of database or UI 

## Tech stack. 
- UI Framework: Flutter

- Dart (Programming Language)

-State management: Riverpod

-Backend, Authentication & Database: Supabase


## How Authentication Works
User authentication has been set up using Supabase:

   1. User can enter name, email, and password on the registration page  
   2. Supabase Auth creates the user account  
   3. A profile record is inserted into the 'profiles' table with:
       - profile_id
       - full_name
       - email  

This logic is implemented using a repository pattern. The authentication logic is handled through an AuthRepository which keeps the domain layer independent from the backend.

## Supabase intergration
Supabase is used as the backend service for authentication and future database storage.
Currently, it is connected to handle:
   -User sign up
   -User sign in
   -Secure authentication handling

This allows the app to manage real user accounts instead of using mock data.


## Wardrobe Feature (Initial Setup)
The wardrobe section is currently being structured to allow users to manage clothing items in the future.
At this stage:
   Basic project structure for wardrobe functionality is in place. Future support will include adding, viewing, and organising outfits.



## Project Structure
lib/
├── main.dart
├── Presentation/
│ └── auth/pages/
│ ├── register_page.dart
│ └── login_page.dart
├── Data/
│ └── repositories/
│ └── supabase_auth_repository.dart
├── Domain/
│ └── repositories/
│ └── auth_repository.dart

