# Firestore data model

- `users/{uid}`: email, displayName, role, verified, createdAt
- `food_batches/{batchId}`: cafeteriaId, itemName, quantityAvailable, dietaryCategory, allergenText, allergenVerified, safetyApproved, pickupLocation, pickupDeadline, status, createdAt
- `reservations/{reservationId}`: studentUid, batchId, portions, status, qrTokenHash, createdAt, collectedAt
- `collection_points/{pointId}`: name, locationText, capacity, acceptedDietaryCategories, active
- `audit_logs/{eventId}`: actorUid, action, entityId, timestamp, details

Security:
- Students read only approved active batches.
- Students create reservations only for themselves.
- Cafeteria users edit only batches belonging to their assigned cafeteria.
- Only authorised staff can confirm collection.
- Role assignment is controlled by trusted administrators.
- Reservation, cancellation and collection must be server-validated and transactional.
