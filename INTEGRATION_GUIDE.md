# FoodLoop upgrade: forecasting + offline constraints

## What this pack contains
- `lib/foodloop_engine.dart`: pure Dart, no network/API dependency. It contains a transparent demand forecast and a sensor-quality guard.
- `local_database_schema.sql`: suggested local SQLite schema for persistence and offline operation.
- `PPT_CHANGES.md`: suggested presentation changes based on the 12-page Code Titans presentation and the two constraint cards.

## Add the Dart engine
1. Copy `lib/foodloop_engine.dart` into the Flutter repository's `lib/` folder.
2. Import it where the cafeteria operator dashboard is built:
   `import 'foodloop_engine.dart';`
3. Store daily prepared/sold data as `SalesObservation` records. Do not train on stockout days as if sold quantity represented total demand.
4. Store festival, holiday, semester-break, exam and campus-event settings locally in `LocalCalendarDay` records. An operator/admin can enter these before the offline challenge.
5. Use the forecast result to show baseline, adjusted forecast, live projection and `extraToPrepare`. Treat factors as initial demo assumptions; calibrate them using actual SRM cafeteria records.
6. Use `SensorQualityGuard` before accepting sensor/telemetry values. Only `ReadingStatus.valid` readings should feed automatic decisions. Missing, stale, duplicate, spike, out-of-range and conflicting readings must be flagged and fall back to manual counts.

## Forecast behaviour
- Starts with the mean sold quantity for up to the last eight comparable weekdays for the same item.
- Excludes stockout days because recorded sales are lower than true demand when food ran out.
- Learns a weekday factor from available valid history.
- Applies local hostel occupancy/calendar, rain and campus-event factors.
- Blends the forecast with live sales/footfall to detect a surge.
- Recommends preparation with a small configurable buffer, not a large one-shot cook. Recalculate every 10–15 minutes and prepare in small batches.

The default rain and calendar factors are illustrative starting values, not measured SRM statistics. Replace them after collecting campus data.

## Constraint 1: offline operation
The current Flutter demo keeps `meals` and `pickups` in Dart memory, so it works during one app session but loses changes after the app is closed. To fully meet the offline constraint, integrate local SQLite using the supplied schema. Do not make login, food discovery, reservations, operator verification, matching or collection depend on Firebase, internet, remote images, maps, weather APIs or third-party APIs during the challenge. Seed demo records locally. If internet later returns, synchronise queued changes with conflict handling; the app must not wait for sync to complete a local action.

## Constraint 10: unreliable telemetry
- Keep sensor ID, sequence ID, recorded time and received time for every message.
- Reject duplicate sequence IDs; mark old messages stale; check physical min/max; detect implausible rate-of-change spikes.
- Compare independent sensors where available. Conflicting values are quarantined rather than averaged blindly.
- Show a visible `Sensor data degraded` warning and the reason.
- Fall back to operator-entered prepared/sold/footfall counts. Never let a suspect sensor reading silently increase or reduce food preparation.
- Log every rejected reading and manual override for later review.

## Important safety boundary
Forecasting predicts quantity, not food safety. Keep the existing rule: only an authorised operator can verify the food batch and its handling window; expired or unverified batches cannot be listed for redistribution. A reservation is not proof of collection; count impact only after handover is confirmed.
