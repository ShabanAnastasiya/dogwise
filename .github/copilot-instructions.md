# DogWise Project Coding Guidelines

## General Principles:
- Adhere strictly to **Clean Architecture** principles: Separation of Concerns, Dependency Rule.
- Ensure high **readability**, **maintainability**, and **testability** of the code.
- Prioritize **null-safety** in all code.
- Focus on creating **performant and scalable** Flutter applications.
- Avoid unnecessary abstractions or redundant classes/enums if not clearly justified by the architecture or future scalability needs.
- Maximize **code reuse** within the existing architecture.
- Always consider **edge cases** and **robust error handling** (e.g., empty states, network errors, null data).

## File Structure & Naming:
- **Be highly attentive to file paths and naming conventions.**
- All generated files must adhere to the specified directory structure:
    - `lib/core/` (models, notifiers, utils, errors)
    - `lib/data/` (datasources, repositories)
    - `lib/bloc/` (BLoC events, states, blocs per feature)
    - `lib/presentation/` (screens, widgets, styling, routing)
    - `lib/l10n/` (localization `.arb` files)
    - `lib/generated/l10n/` (for generated localization files)
- Use `snake_case` for file names (e.g., `dog_breed.dart`).
- Use `PascalCase` for class names (e.g., `DogBreed`).

## Flutter Specific:
- **State Management (BLoC):**
    - Use **BLoC** for all major state management.
    - Each screen or complex feature must have its dedicated BLoC (e.g., `BreedsListBloc`, `BreedDetailsBloc`, `FiltersBloc`).
    - BLoCs must handle business logic, data fetching, caching, and state transitions.
    - **BLoC implementation details:**
        - Define **clear and granular Events and States** for each BLoC, placed in separate files (e.g., `breeds_list_event.dart`, `breeds_list_state.dart`).
        - **Avoid excessive reactivity in the UI layer; BLoCs must abstract complexity.**
        - Handle asynchronous events using `on<Event>` handlers, `async/await`, and `try-catch` blocks.
        - **Ensure states are immutable.** For state updates, create new state instances with modified data.
        - Use `StateNotifier` or `Cubit` where appropriate for simpler, isolated state management within a BLoC's scope, but the primary state management for screens should be BLoC.
        - **Avoid `freezed` for BLoC states; prefer `equatable` for value equality comparisons.**
    - **Handling different application states:**
        - **Loading:** Use specific loading states (`LoadingState`, `BreedsListLoading`) and display **Skeleton loading** (shimmer effect).
        - **Loaded/Success:** Display the actual data.
        - **Empty:** If data is successfully fetched but the list is empty, display a clear "no data" message or appropriate placeholder.
        - **Error:** Catch all errors (network, parsing, etc.) and emit specific `ErrorState`s. Display user-friendly error messages (e.g., `SnackBar`, `Toast`, or dedicated error UI).
        - **Offline:** The Data Layer handles this (see below), and BLoC should react by emitting `Loaded` state with cached data or `Error` if no cache and no network.
- **Dependency Injection:** Prefer **explicit constructor injection** for all dependencies (Repositories, Data Sources, Notifiers, BLoCs).
- **Routing:** Use **`go_router`** for all navigation. Implement custom page transitions as specified:
    - **Hero animation** for images during `/breeds` to `/breed/:id` transitions.
    - **`fade` + `scale` transition** for general UI elements on screen transitions.
    - **`slide` animation** for modal screens (e.g., `/filters`).
- **HTTP Client:** Use **`dio`** for all network requests. Implement interceptors for logging and robust error handling.
- **Local Storage/Caching:** Use **`Hive`** for persistent data storage (caching breed lists, details, app settings). `SharedPreferences` for simple key-value pairs if specifically needed for non-complex settings.
- **Offline Mode:**
    - Implement robust offline detection using **`connectivity_plus`**.
    - The **Repository** (`DogRepositoryImpl`) is responsible for "cache-first, then network" strategy.
    - When offline: prioritize serving cached data (`Hive`) instantly.
    - When refreshing offline: show error message but keep cached data displayed.
- **UI:**
    - Keep UI widgets lean, declarative, and focused on presentation.
    - Use `BlocBuilder`, `BlocConsumer`, and `BlocListener` for efficient UI updates based on BLoC states.
    - Ensure **responsive UI** that adapts well to different screen sizes and orientations.
- **Animations:** Utilize `flutter_animate` for general UI animations, and `Hero` widgets and custom `PageTransition`s for navigation.
- **Theme Management:** Implement dark/light theme support. Manage theme state globally using a `ChangeNotifier` (`ThemeNotifier`). Persist theme preference using `Hive`.

## Dart Specific:
- Use `camelCase` for variables and function names.
- Use `PascalCase` for class names.
- Prefer `const` constructors where possible.
- **Data Models:**
    - **DO NOT USE `freezed` or `.freezed.dart` files for generating data models.**
    - For data models (`DogBreed`, `DogBreedDetails`, `DogImage`), use **`json_annotation` (`@JsonSerializable`)** for JSON serialization/deserialization.
    - **Manually implement `copyWith` methods** where necessary for immutable updates to model instances.
    - Use **`equatable`** (extend `Equatable` and override `props`) for value equality comparisons in models and BLoC states.
- **Asynchronous Code:** Use `Streams` for continuous data flow (e.g., connectivity status). Use `Future` and `async/await` for one-time operations. Avoid creating excessive reactivity or unnecessary stream listeners in the UI layer.

## Error Handling:
- Implement **custom exception classes** (e.g., `NetworkException`, `CacheException`) in `lib/core/errors/exceptions.dart`.
- Always use `try-catch` blocks for operations that can fail (network, disk I/O, parsing).
- Provide **meaningful fallback UIs**, `Toast` messages, or `SnackBar` notifications for errors.

## Styling and Assets:
- **Colors:** All colors must be centralized in `lib/presentation/style/color.dart` (or similar path if you use a different naming, e.g., `AppColors`). When new colors are introduced or used in UI code, they must be defined in this central file. Do not use hardcoded color values (`Color(0xFF...)`) directly in widgets. Refer to colors as `GTColor.yourColorName` (assuming `GTColor` is your class name).
- **Text Styles:** All custom or application-specific text styles must be defined and centralized in `lib/presentation/style/text_style.dart` (e.g., `AppTextStyles`). When text styles are applied to widgets, they should refer to these predefined styles (e.g., `GTTextStyle.heading5base.medium` as you already have). If new styles emerge, define them there.

## Localization:
- Use `flutter_localizations` and `intl` packages.
- All user-facing text strings must be externalized into `.arb` files (`lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`).
- When generating new UI components or adding text, **always use localized strings via `context.l10n.yourStringKey`**.
- If a new text string appears, add it to the `.arb` files and generate the corresponding `AppLocalizations` key. Do not hardcode strings directly in the UI.

## Testing:
- Write unit tests for BLoCs, Repositories, and Data Sources.
- Write widget tests for critical UI components.