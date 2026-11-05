# Recommended PPT changes for FoodLoop

Keep the original 12-slide structure and six core features. Add the constraints as first-class design requirements rather than replacing the original story.

## Slide-by-slide changes

- **Slide 1 – Title:** Keep “The Invisible Cafeteria”. Add subtitle: “Offline-first demand intelligence, adaptive supply and safe surplus redistribution.”
- **Slide 2 – Problem:** Add two operational causes: demand changes sharply on festivals/semester breaks/rainy days; unreliable counts and delayed telemetry make manual planning harder.
- **Slide 3 – Evidence:** Keep the global food-waste figures already cited in the deck. Add a separate campus-data panel only after collecting real SRM data; do not present illustrative forecast factors as measured facts.
- **Slide 4 – Cost:** Add avoidable shortage and emergency replenishment alongside waste. Label all cost/time numbers as team estimates unless measured in the pilot.
- **Slide 5 – Solution:** Update the one-line solution to: “FoodLoop predicts demand from campus patterns, adjusts supply using live signals, works offline, and redistributes only operator-verified safe surplus.”
- **Slide 6 – Dashboard:** Add forecast for today, expected hostel occupancy, festival/exam indicator, rain condition, live demand trend, recommended next-batch quantity, sensor-health status and offline status.
- **Slide 7 – Features:** Expand the six existing features with Calendar Intelligence, Rain Impact, Surge Management, Offline Mode and Sensor Reliability Monitor.
- **Slide 8 – Safety:** Keep the original operator verification and handling-window sequence. Add a second safety lane: “Sensor quality check → valid data only → manual fallback if degraded.” Clarify that sensor validation is not food-safety verification.
- **Slide 9 – Before/After:** Add “internet/API dependency → local-first workflow” and “blind reliance on telemetry → validated readings + manual fallback”.
- **Slide 10 – Impact:** Keep 13h/3h and ₹20,000/₹3,000 only as team estimates unless validated. Add forecast error (MAE/MAPE), stockout rate, surplus redistributed and rejected sensor readings as pilot metrics.
- **Slide 11 – Team:** Assign one owner to forecasting/calendar, one to Android UI/offline data, one to sensor validation/supply adjustment, and one to testing/safety/presentation.
- **Slide 12 – Next steps:** Add local SQLite persistence, offline demo test, sensor fault-injection tests, and a one-canteen pilot with measured sales/footfall.

## Suggested feature descriptions

1. **Adaptive Demand Forecast:** Learns from recent sales for the same menu item and weekday; adjusts for hostel occupancy, festivals, holidays, exams, rain and campus events.
2. **Surge Manager:** Recalculates expected demand from current sales/footfall every 10–15 minutes and recommends a small replenishment batch when demand rises.
3. **Sensor Reliability Monitor:** Detects missing, stale, duplicate, out-of-range, spiking and conflicting readings; uses manual counts when telemetry is unreliable.
4. **Offline-first Campus Mode:** Local database supports listings, reservations, operator verification and collection records without internet. Sync is optional later, never required for the core journey.
5. **Safe Surplus Matching:** Continues to require authorised operator safety/handling verification, verified dietary metadata, unexpired handling window, compatible collection point and confirmed physical handover.

## Demo sequence for the judges

1. Switch internet off and show the core app still opens and can create a local reservation.
2. Select a festival day and low hostel occupancy; show the forecast decreasing.
3. Select heavy rain; show a further demand adjustment.
4. Simulate a sudden rise in footfall/sales; show the next-batch recommendation increasing.
5. Inject a stale or duplicate sensor reading; show it rejected and a visible manual-fallback warning.
6. Create an unverified surplus batch; show it cannot be matched. Verify it as an authorised operator and show it becomes eligible only within its handling window.
