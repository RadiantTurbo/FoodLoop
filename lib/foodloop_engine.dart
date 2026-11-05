import 'dart:math' as math;

/// Offline-first forecasting and data-quality logic for FoodLoop.
/// This file has no network or third-party API dependency.

enum RainLevel { none, light, moderate, heavy }
enum ReadingStatus { valid, missing, stale, duplicate, outOfRange, spike, conflict }

class SalesObservation {
  const SalesObservation({
    required this.date,
    required this.itemId,
    required this.sold,
    required this.prepared,
    this.stockout = false,
  });

  final DateTime date;
  final String itemId;
  final int sold;
  final int prepared;
  /// True when demand was limited by stock running out. Such sales are censored
  /// and should not be treated as the full demand for training.
  final bool stockout;
}

class LocalCalendarDay {
  const LocalCalendarDay({
    required this.date,
    this.isFestival = false,
    this.isHoliday = false,
    this.isExamPeriod = false,
    this.isSemesterBreak = false,
    this.hostelOccupancy = 1.0,
    this.campusEventMultiplier = 1.0,
  });

  final DateTime date;
  final bool isFestival;
  final bool isHoliday;
  final bool isExamPeriod;
  final bool isSemesterBreak;
  /// Locally configured expected hostel occupancy, from 0.0 to 1.0.
  final double hostelOccupancy;
  /// Locally entered event effect. Use >1 for a large campus event.
  final double campusEventMultiplier;
}

class LiveDemandSignal {
  const LiveDemandSignal({
    required this.soldSoFar,
    required this.minutesElapsed,
    required this.minutesRemaining,
    required this.preparedSoFar,
    this.footfallSoFar,
    this.queueCount,
  });

  final int soldSoFar;
  final int minutesElapsed;
  final int minutesRemaining;
  final int preparedSoFar;
  final int? footfallSoFar;
  final int? queueCount;
}

class DemandForecast {
  const DemandForecast({
    required this.baseline,
    required this.dayFactor,
    required this.occupancyFactor,
    required this.rainFactor,
    required this.eventFactor,
    required this.staticForecast,
    required this.liveProjection,
    required this.recommendedDemand,
    required this.recommendedPreparation,
    required this.extraToPrepare,
    required this.explanation,
  });

  final int baseline;
  final double dayFactor;
  final double occupancyFactor;
  final double rainFactor;
  final double eventFactor;
  final int staticForecast;
  final int liveProjection;
  final int recommendedDemand;
  final int recommendedPreparation;
  final int extraToPrepare;
  final List<String> explanation;
}

class FoodLoopForecastEngine {
  const FoodLoopForecastEngine();

  /// Transparent baseline forecast. It uses recent comparable weekdays,
  /// excludes stockout days, then applies locally entered context factors.
  /// Factors are initial demo defaults and must be calibrated from campus data.
  DemandForecast forecast({
    required String itemId,
    required DateTime targetDate,
    required List<SalesObservation> history,
    required LocalCalendarDay calendar,
    required RainLevel rain,
    required int alreadyPrepared,
    required int availableUncookedStock,
    LiveDemandSignal? live,
    double bufferPercent = 0.08,
  }) {
    final comparable = history
        .where((h) => h.itemId == itemId &&
            h.date.isBefore(DateTime(targetDate.year, targetDate.month, targetDate.day)) &&
            h.date.weekday == targetDate.weekday &&
            !h.stockout && h.prepared > 0)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final recent = comparable.take(8).toList();
    final baseline = recent.isNotEmpty
        ? _round(recent.map((e) => e.sold.toDouble()).reduce((a, b) => a + b) / recent.length)
        : _fallbackMean(history.where((h) => h.itemId == itemId && !h.stockout).toList());

    // Weekday pattern is learned from available history relative to all valid days.
    final validItemHistory = history.where((h) => h.itemId == itemId && !h.stockout).toList();
    final allMean = _mean(validItemHistory.map((e) => e.sold.toDouble()).toList());
    final weekdayValues = validItemHistory
        .where((e) => e.date.weekday == targetDate.weekday)
        .map((e) => e.sold.toDouble()).toList();
    final dayFactor = allMean <= 0 || weekdayValues.isEmpty
        ? 1.0
        : _clamp(_mean(weekdayValues) / allMean, 0.70, 1.30);

    // Occupancy is locally maintained: festivals, holidays and semester breaks
    // reduce hostel population. It is not fetched from an external service.
    var occupancyFactor = _clamp(calendar.hostelOccupancy, 0.20, 1.10);
    if (calendar.isFestival || calendar.isHoliday || calendar.isSemesterBreak) {
      occupancyFactor = math.min(occupancyFactor, 0.65);
    }
    if (calendar.isExamPeriod) occupancyFactor *= 0.95;

    final rainFactor = switch (rain) {
      RainLevel.none => 1.0,
      RainLevel.light => 0.96,
      RainLevel.moderate => 0.88,
      RainLevel.heavy => 0.75,
    };
    final eventFactor = _clamp(calendar.campusEventMultiplier, 0.70, 1.60);

    final staticForecast = _round(baseline * dayFactor * occupancyFactor * rainFactor * eventFactor);
    var liveProjection = staticForecast;
    if (live != null && live.minutesElapsed > 0) {
      final soldRate = live.soldSoFar / live.minutesElapsed;
      final salesProjection = live.soldSoFar + soldRate * live.minutesRemaining;
      var footfallProjection = 0.0;
      if (live.footfallSoFar != null && live.footfallSoFar! > 0) {
        final conversion = live.soldSoFar / live.footfallSoFar!;
        final projectedFootfall = live.footfallSoFar! +
            (live.footfallSoFar! / live.minutesElapsed) * live.minutesRemaining;
        footfallProjection = projectedFootfall * conversion;
      }
      final liveEstimate = footfallProjection > 0
          ? (salesProjection * 0.65 + footfallProjection * 0.35)
          : salesProjection;
      // Blend the local forecast with observed live demand; don't let one noisy
      // count replace the baseline entirely.
      liveProjection = _round(staticForecast * 0.35 + liveEstimate * 0.65);
    }

    final recommendedDemand = math.max(staticForecast, liveProjection);
    final recommendedPreparation = _round(recommendedDemand * (1 + bufferPercent));
    final totalReady = alreadyPrepared + availableUncookedStock;
    final extraToPrepare = math.max(0, recommendedPreparation - totalReady);

    final explanation = <String>[
      'Baseline: $baseline portions from recent comparable weekdays.',
      'Weekday pattern factor: ${dayFactor.toStringAsFixed(2)}.',
      'Hostel/calendar occupancy factor: ${occupancyFactor.toStringAsFixed(2)}.',
      'Rain factor: ${rainFactor.toStringAsFixed(2)} (${rain.name}).',
      'Campus event factor: ${eventFactor.toStringAsFixed(2)}.',
      if (live != null) 'Live sales/footfall are blended with the forecast to detect a surge.',
      'Recommended preparation includes ${(bufferPercent * 100).round()}% safety buffer; cook in small batches and re-check.',
    ];

    return DemandForecast(
      baseline: baseline,
      dayFactor: dayFactor,
      occupancyFactor: occupancyFactor,
      rainFactor: rainFactor,
      eventFactor: eventFactor,
      staticForecast: staticForecast,
      liveProjection: liveProjection,
      recommendedDemand: recommendedDemand,
      recommendedPreparation: recommendedPreparation,
      extraToPrepare: extraToPrepare,
      explanation: explanation,
    );
  }

  int _fallbackMean(List<SalesObservation> rows) =>
      rows.isEmpty ? 0 : _round(_mean(rows.map((e) => e.sold.toDouble()).toList()));
  double _mean(List<double> values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
  int _round(double value) => value.isFinite ? value.round() : 0;
  double _clamp(double v, double min, double max) => v.clamp(min, max).toDouble();
}

class SensorReading {
  const SensorReading({
    required this.sensorId,
    required this.metric,
    required this.value,
    required this.recordedAt,
    required this.sequenceId,
  });
  final String sensorId;
  final String metric;
  final double? value;
  final DateTime recordedAt;
  /// Unique device sequence/message ID; use this to identify retransmissions.
  final String sequenceId;
}

class SensorCheck {
  const SensorCheck(this.status, this.acceptedValue, this.message);
  final ReadingStatus status;
  final double? acceptedValue;
  final String message;
  bool get usable => status == ReadingStatus.valid;
}

class SensorQualityGuard {
  const SensorQualityGuard({
    this.staleAfter = const Duration(minutes: 10),
    this.conflictTolerance = 2.0,
  });

  final Duration staleAfter;
  final double conflictTolerance;

  SensorCheck validate({
    required SensorReading reading,
    required DateTime now,
    required double minValue,
    required double maxValue,
    required Set<String> seenSequenceIds,
    SensorReading? previous,
    double? maxChangePerMinute,
  }) {
    final value = reading.value;
    if (value == null || !value.isFinite) {
      return const SensorCheck(ReadingStatus.missing, null, 'Missing or non-numeric reading; use manual fallback.');
    }
    if (reading.recordedAt.isAfter(now.add(const Duration(minutes: 2)))) {
      return const SensorCheck(ReadingStatus.stale, null, 'Timestamp is in the future; quarantine this reading.');
    }
    if (now.difference(reading.recordedAt) > staleAfter) {
      return const SensorCheck(ReadingStatus.stale, null, 'Reading is too old; do not use it for live decisions.');
    }
    if (seenSequenceIds.contains(reading.sequenceId)) {
      return const SensorCheck(ReadingStatus.duplicate, null, 'Duplicate telemetry message; ignore retransmission.');
    }
    if (value < minValue || value > maxValue) {
      return const SensorCheck(ReadingStatus.outOfRange, null, 'Value outside configured physical limits; quarantine.');
    }
    if (previous != null && maxChangePerMinute != null) {
      final minutes = reading.recordedAt.difference(previous.recordedAt).inSeconds.abs() / 60.0;
      if (minutes > 0 && (value - (previous.value ?? value)).abs() > maxChangePerMinute * minutes) {
        return const SensorCheck(ReadingStatus.spike, null, 'Abrupt change detected; request a second reading or manual check.');
      }
    }
    return SensorCheck(ReadingStatus.valid, value, 'Reading accepted.');
  }

  SensorCheck compareSensors({required double first, required double second}) {
    if ((first - second).abs() > conflictTolerance) {
      return const SensorCheck(ReadingStatus.conflict, null, 'Sensors disagree; do not auto-adjust stock or demand.');
    }
    return SensorCheck(ReadingStatus.valid, (first + second) / 2, 'Sensor readings agree.');
  }
}
