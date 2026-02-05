# fitcheck

## Architecture overview

To achieve a clean architecture the system has 3 different layers

-Presentation layer: handles UI widgets and state management, managed by Riverpod
-Data layer: implementation of repositories and it handles fetching data from Supabase 
-Domain layer: handles the rules and logic of the application and is independent of database or UI 

## Tech stack

-Framework: Flutter
-State management: Riverpod
-Backend: Supabase