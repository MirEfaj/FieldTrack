# FieldTrack

The app implements secure authentication, location management, geofence entry detection, offline-first todo synchronization, and local notifications using Clean Architecture and Bloc.
## 1. Setup

### Flutter SDK Management

This project uses [FVM](https://fvm.app) (Flutter Version Management) so every developer and CI runner uses the same Flutter SDK. That keeps analyzer output, builds, and dependency resolution consistent across machines.

**Pinned SDK:** Flutter **3.44.4**

```bash
fvm install
Flutter 3.44.4 (via FVM)
```
### Prerequisites

- [FVM](https://fvm.app) installed locally
- Flutter **3.44.4** via FVM (`fvm install` from project root)
- Android Studio and/or Xcode for device builds

## 2. Run locally

```bash
git clone <your-repo-url>
cd FieldTrack
fvm install
fvm flutter pub get
dart run build_runner build --delete-conflicting-outputs
fvm flutter run
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---


## 3. Architecture

I use feature-first Clean Architecture because the task has five distinct areas (auth, locations, todos/sync, geofence, notifications) that evolve independently. Each feature owns its layers. Shared infrastructure lives in `core/` and `config/`.

The goal: UI never talks to Dio or Hive directly. Business rules live in repositories and use cases. Blocs only coordinate.

### Folder layout

```
lib/
├── main.dart / app.dart
├── config/          # DI, env, GoRouter
├── core/            # network, storage, theme, connectivity, Result<T>
├── features/
│   ├── authentication/
│   ├── locations/
│   ├── todos/       # includes sync presentation
│   ├── geofence/
│   └── notifications/
└── shared/widgets/
```

Per-feature structure:

```
features/<feature>/
├── data/       datasources, models, repository impl
├── domain/     entities, repository interface, use cases
└── presentation/  bloc, pages, widgets
```
## 4. Offline Sync
### Offline sync flow

See [Offline Sync](#offline-sync) for the full breakdown. Short version:

```
Toggle offline → Hive + sync_queue
    ↓
SyncBloc hears reconnect (debounced 500ms)
    ↓
SyncTodosUseCase → POST /api/v1/todos/sync
    ↓
Clear queue entries, set lastSyncedAt, mark todos synced
```


How implemented in the codebase.

```
User checks a todo
        ↓
TodoListBloc.add(TodoToggleRequested)
        ↓
ToggleTodoUseCase → TodoRepositoryImpl.toggleTodo
        ↓
TodoLocalDataSource.updateTodoLocally (immediate Hive write)
        ↓
ConnectivityService.isConnected?
     ┌──── Yes ────→ PATCH /api/v1/todos/:id
     │                    ↓
     │              success → clearSyncItem(todoId), status = synced
     │              failure → fall through to queue (same as offline)
     └──── No ─────→ enqueueSync in sync_queue box
                           ↓
                     UI shows pending badge
                           ↓
              (later) ConnectivityService fires online
                           ↓
              SyncBloc (500ms debounce) → SyncNowRequested
                           ↓
              SyncTodosUseCase → TodoRepositoryImpl.syncPendingChanges
                           ↓
              _isSyncing lock acquired
                           ↓
              POST /api/v1/todos/sync  { changes: [...] }
                           ↓
              For each item: update todo, clearSyncItem
                           ↓
              setLastSyncedAt, reset backoff counters
                           ↓
              SyncBloc emits synced / pending state
```


### Sync screen

`SyncPage` reads from `SyncBloc`, which pulls pending items via `GetPendingSyncChangesUseCase`. Shows offline banner, pending count, last synced time, and a force-sync button.

---
## 5. Geofence flow

```
ShellRoute loads → fetch/cache locations → GeofenceService.startMonitoring
    ↓
Position stream update
    ↓
distance ≤ radius_m AND was outside → inside?
    ↓
Yes + not in cooldown → NotificationService.showGeofenceEntry
    ↓
Write last_notified to geofence_state box (5 min cooldown)
```

| Topic | Implementation |
|-------|----------------|
| **Permissions** | `GeofenceService.requestPermission()` — requests if denied, accepts while-in-use or always. |
| **Monitoring** | `getPositionStream` with `LocationAccuracy.high`, `distanceFilter: 10` metres. |
| **Entry detection** | Compare `Geolocator.distanceBetween` to `radius_m`. Fire only on outside → inside transition. |
| **Notification** | `onEntry` callback set in `initializeApp()` → `NotificationService.showGeofenceEntry(name)`. |
| **No repeat alerts** | In-memory `_insideState` map tracks current inside/outside per location. |
| **Cooldown** | `geofence_state` box stores `last_notified` per location. 5-minute window (`AppConfig.geofenceCooldownMinutes`). |

Monitoring starts in `AppRouter._startGeofenceMonitoring()` when the authenticated shell mounts.

---
## Known Limitations

1. **No map widget** — coordinates entered manually per task spec.
2. **Geofence when app is killed** — position stream stops; no native region APIs used.
3. **Profile placeholders** — edit profile and notification settings menus have no backend.
4. **Forgot password** — UI link only; no recovery endpoint wired.

---



