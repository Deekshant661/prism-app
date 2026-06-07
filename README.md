# prism-app

> Flutter mobile app for [Prism](https://github.com/your-username/prism-backend) — a personal mutual fund analytics platform for Indian markets.

> **Status:** In development. Targets the same backend API as [prism-web](https://github.com/your-username/prism-web).

---

## Overview

Prism's mobile app brings the full fund research experience to iOS and Android from a single Flutter codebase. It connects to the Prism backend API — the same one powering the web dashboard — to deliver real NAV charts, composite fund rankings, portfolio analysis, and SIP projections on mobile.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Navigation | go_router |
| HTTP | Dio |
| Charts | fl_chart |
| Local Storage | shared_preferences |
| Formatting | intl |
| Environment | flutter_dotenv |
| Loading States | shimmer |

---

## Features

- **Category dashboard** — grid of fund categories with fund count, average score, and best 1Y return per category
- **Rankings screen** — scrollable fund list with horizontal category chip filter and sort controls; infinite scroll pagination
- **Fund detail screen** — NAV line chart with 1M/6M/1Y/3Y/5Y/Max range selector, performance metrics row, score breakdown, holdings list, sector pie chart, plan/option switcher (Direct/Regular, Growth/IDCW), and embedded SIP calculator
- **Fund comparison** — select up to 4 funds, compare metrics in a scrollable table, overlaid normalised NAV chart, holdings overlap panel
- **SIP calculator** — slider-based inputs, live corpus projection, growth area chart, multi-fund comparison mode
- **Global search** — full-screen search with live results, recent searches stored locally
- **Watchlist** — bookmark funds, persisted across sessions via SharedPreferences; swipe to remove

---

## Project Structure

```
lib/
├── api/                     # Dio HTTP client + per-resource API functions
│   ├── api_client.dart      # Dio instance, base URL, timeouts, error interceptor
│   ├── funds_api.dart
│   ├── rankings_api.dart
│   ├── nav_api.dart
│   └── schemes_api.dart
│
├── models/                  # Dart data classes with fromJson constructors
│   ├── fund.dart
│   ├── fund_metrics.dart
│   ├── ranking.dart
│   ├── nav_point.dart
│   ├── scheme.dart
│   ├── holding.dart
│   ├── sector_allocation.dart
│   └── sip_result.dart
│
├── providers/               # Riverpod providers — data fetching and state
│   ├── funds_provider.dart
│   ├── rankings_provider.dart
│   ├── nav_provider.dart
│   ├── watchlist_provider.dart
│   └── comparison_provider.dart
│
├── screens/                 # One screen per route
│   ├── home_screen.dart
│   ├── rankings_screen.dart
│   ├── fund_detail_screen.dart
│   ├── compare_screen.dart
│   ├── calculator_screen.dart
│   ├── search_screen.dart
│   └── watchlist_screen.dart
│
├── widgets/
│   ├── cards/               # CategoryCard, FundListTile, MetricCard, StatRow
│   ├── charts/              # NavChart, SectorPieChart, SipGrowthChart, CompareChart
│   └── common/              # ReturnBadge, CategoryBadge, LoadingShimmer,
│                            #   EmptyState, ErrorState, SectionHeader
│
├── utils/
│   ├── formatters.dart      # formatReturn, formatINR, formatINRShort, formatNavDate
│   └── constants.dart       # Category display names, color mappings
│
├── router.dart              # go_router route definitions
└── main.dart                # App entry point, ProviderScope, theme, dotenv
```

---

## Screens

| Route | Screen |
|---|---|
| `/` | Home — category grid |
| `/rankings` | Rankings — filterable fund list |
| `/rankings/:category` | Rankings pre-filtered to category |
| `/fund/:id` | Fund detail — full research screen |
| `/compare` | Fund comparison |
| `/calculator` | SIP calculator |
| `/search` | Full-screen fund search |
| `/watchlist` | Saved funds |

Navigation uses a persistent `BottomNavigationBar` with tabs: Home · Rankings · Compare · Calculator · Watchlist. Search is accessible via AppBar icon on Home and Rankings screens.

---

## Getting Started

### Prerequisites

- Flutter 3.x SDK ([install guide](https://docs.flutter.dev/get-started/install))
- [prism-backend](https://github.com/your-username/prism-backend) running and reachable
- For physical device: backend must be accessible on your local network (use LAN IP, not localhost)

### Setup

```bash
# Clone the repo
git clone https://github.com/your-username/prism-app
cd prism-app

# Install dependencies
flutter pub get

# Configure environment
cp .env.example .env
# Set API_BASE_URL:
#   Emulator:        http://10.0.2.2:8000
#   Physical device: http://192.168.x.x:8000  (your machine's LAN IP)
#   Deployed:        https://your-api-domain.com

# Run the app
flutter run
```

### Platform-specific

```bash
# iOS (requires macOS + Xcode)
flutter run -d ios

# Android
flutter run -d android

# Check connected devices
flutter devices
```

---

## Environment Variables

```bash
# .env
API_BASE_URL=http://10.0.2.2:8000
```

---

## State Management

Riverpod 2.x with code generation. Every screen uses `AsyncValue` from Riverpod to handle loading, error, and data states explicitly — no screen ever renders blank or crashes silently on API failure.

```dart
// Pattern used across all data screens
ref.watch(rankingsProvider(category: selected)).when(
  data:    (data)         => RankingsListView(funds: data.funds),
  loading: ()             => LoadingShimmer.listTile(),
  error:   (error, stack) => ErrorState(
                               message: error.toString(),
                               onRetry: () => ref.invalidate(rankingsProvider),
                             ),
);
```

The fund list is fetched once on app start and cached for 10 minutes. Search runs client-side against this cache — no per-keystroke API calls.

---

## pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0
  fl_chart: ^0.67.0
  shared_preferences: ^2.2.0
  intl: ^0.19.0
  flutter_dotenv: ^5.1.0
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0
```

---

## Design Decisions

**Riverpod over Provider or Bloc** — Riverpod's `AsyncValue` pattern makes loading/error/data states first-class. Combined with `ref.invalidate()` for retry, it removes most of the boilerplate that Bloc requires for straightforward API-driven screens.

**fl_chart over syncfusion or charts_flutter** — fl_chart is MIT licensed, actively maintained, and handles touch interactions well. The NAV chart's touch tooltip and the SIP growth chart's dual-area fill were both straightforward to implement.

**go_router over Navigator 2.0 directly** — declarative routing with deep link support and type-safe parameters, without the verbosity of implementing Navigator 2.0 from scratch.

**SharedPreferences for watchlist only** — no local database (sqflite or Drift). All data comes from the API. SharedPreferences stores only a list of bookmarked fund IDs — simple, reliable, and impossible to get out of sync with the server.

---

## Related Repositories

- [prism-backend](https://github.com/your-username/prism-backend) — FastAPI backend and data engine
- [prism-web](https://github.com/your-username/prism-web) — React web dashboard
