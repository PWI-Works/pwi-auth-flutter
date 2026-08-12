# AI implementation prompt: repository lifecycle and timed-fetch support

Use this prompt in the repository that owns `BaseDataStreamRepository`.

---

Implement a backward-compatible improvement to the package's data repository base classes. Read the target repository's `AGENTS.md` and applicable local guidance before editing. Inspect the existing implementation and tests instead of assuming that the code shown in another repository is still current. Continue through implementation, tests, and final validation without waiting for discretionary approval.

## Objectives

1. Fix `BaseDataStreamRepository` so its source stream is canceled when its final real consumer unsubscribes.
2. Add a reusable base repository for data loaded through a single `Future`-based fetch, with optional automatic refresh scheduling.
3. Share lifecycle and listener-management behavior between the stream and fetch repositories where that reduces duplication.
4. Preserve all existing `BaseDataStreamRepository` public APIs and existing subclass compatibility.

## Known defect

`BaseDataStreamRepository.unsubscribeFromData()` currently uses `data.hasListeners` to determine whether any consumers remain. The `Property` created by `Model.createProperty` installs an internal `notifyListeners` callback, so `data.hasListeners` can remain true after every consumer has unsubscribed. As a result, the source stream may remain active indefinitely.

Do not fix this by removing the internal `notifyListeners` callback from `data`. That is a fragile workaround based on framework internals. Do not blindly subtract one from the listener count either. Track subscriptions made through the repository API explicitly.

## Required design

### Common repository lifecycle

Introduce a narrowly scoped common abstraction, preferably `BaseDataRepository<T>`, if it fits the target package's naming and file conventions. `BaseDataStreamRepository<T>` and the new fetch repository should extend it.

The common abstraction should own:

- `Property<T?> data`, initially `null`.
- `subscribeToData(VoidCallback listener)`.
- `unsubscribeFromData(VoidCallback listener)`.
- Explicit accounting for listeners registered through those two methods.
- Starting the concrete data source when the listener-registration count changes from zero to one.
- Stopping the concrete data source and resetting `data` to `null` when the count changes from one to zero.
- Disposal validation based on repository consumer registrations, not `data.hasListeners`.
- Existing debug logging behavior, if it is currently part of `BaseDataStreamRepository`.
- The existing protection against calling repository `addListener` or `removeListener` directly.

Use identity-aware registration accounting rather than a raw decrement-only integer. Preserve the existing behavior if the same callback is registered more than once: each subscription must require a corresponding unsubscription. Unsubscribing an unregistered callback must not reduce the active count or stop the source.

Make start/stop transitions safe if starting the source throws synchronously. Do not leave a phantom registration or partially active source. Ensure a synchronously emitting source does not cause a new subscriber to miss its first value or receive an accidental duplicate immediate callback.

Direct listeners attached to `data` by framework internals or callers must not influence source lifecycle. Continue documenting that consumers must use `subscribeToData` and `unsubscribeFromData`.

### Backward-compatible stream repository

Keep `BaseDataStreamRepository<T>` source-compatible with all existing subclasses and consumers:

- Preserve the class name.
- Preserve `StreamSubscription<T> createDataStream()` with its current signature and subclass contract.
- Preserve `subscribeToData`, `unsubscribeFromData`, `resetStream`, `enableDebugLogging`, `data`, and existing disposal behavior except for fixing the defective listener test.
- Do not add required constructor arguments.
- Do not require changes to existing subclasses.
- Keep one shared source subscription while one or more repository consumers exist.
- Cancel that subscription exactly once when the final consumer unsubscribes.
- Reset `data` to `null` after shutdown, as the current contract specifies.
- Allow a later subscription to create a fresh source stream.

If cancellation is asynchronous, prevent a rapid unsubscribe/resubscribe sequence from allowing an older cancellation or source event to corrupt the newly active lifecycle.

### New Future-based repository

Add `BaseDataFetchRepository<T>` unless the target repository already has a more appropriate established term for a one-shot fetch repository. It represents retained data produced by one `Future<T>` fetch at a time; it is not itself a business data stream.

Its subclass contract should be a single abstract method with a clear name following package conventions, for example:

```dart
Future<T> fetchData();
```

Required behavior:

- The first consumer triggers an immediate fetch.
- The first consumer also activates refresh scheduling for that consumer lifecycle. Do not start a refresh timer before the initial subscription.
- A successful fetch publishes the returned value through `data` and notifies all consumers.
- An empty collection returned by the fetch remains an empty collection. Do not convert it to `null`.
- `null` remains reserved for not loaded, stopped, or reset state because `T` itself is non-nullable at this boundary.
- Additional consumers share the retained result and refresh lifecycle; they do not start duplicate fetches.
- Only one fetch may be in flight at a time. Coalesce or safely ignore overlapping automatic refresh triggers.
- When the final consumer unsubscribes, cancel the refresh timer, invalidate any in-flight result, and reset `data` to `null`.
- After final unsubscription, retain no active timer, periodic callback, background loop, pending scheduling task, or other refresh-related resource. An unavoidable in-flight `Future` may finish, but its result must be ignored and it must not restart scheduling.
- A `Future` that completes after shutdown or after a newer lifecycle starts must not publish stale data or schedule another timer.
- A later first consumer begins a new lifecycle and fetches immediately.
- A failed refresh must not be converted into empty data. Preserve the original error and stack trace according to the package's existing asynchronous error convention.
- If an initial fetch fails, `data` remains `null`.
- If a scheduled refresh fails after a successful load, retain the last successful value.
- A failed automatic attempt must not permanently disable future scheduled attempts unless the repository has stopped.
- Do not introduce a user-facing error string or presentation-state concern into the repository base.

If a public manual refresh method is added, name it consistently with the package. It must return a `Future` that completes with the same failure and stack trace as the underlying fetch. Clearly define and test its behavior when there are no active consumers. Do not add a manual method merely to make tests easier.

## Refresh configuration

Define an enum with these semantic values:

```dart
enum DataRefreshType {
  daily,
  interval,
  never,
}
```

Use the target package's established naming if an equivalent enum already exists. Do not encode a specific hour count in enum member names.

Use an immutable configuration value, such as `DataRefreshSchedule`, to pair the enum with the values needed by each strategy. Prefer named constructors that prevent invalid combinations, for example:

```dart
const DataRefreshSchedule.daily({int hour = 0, int minute = 0});
const DataRefreshSchedule.interval(Duration interval);
const DataRefreshSchedule.never();
```

The default for `BaseDataFetchRepository` must be daily refresh at local `00:00`.

Validate configuration at construction:

- Daily hour must be 0 through 23.
- Daily minute must be 0 through 59.
- Interval duration must be greater than zero.
- Values irrelevant to the selected refresh type should not be publicly mutable or ambiguously accepted.

Scheduling semantics:

- `daily`: after each automatic attempt finishes, schedule the next occurrence of the configured local wall-clock time that is strictly later than the current time. Construct the next local `DateTime` and recompute it after every attempt so daylight-saving changes are handled by the platform's local-time rules. Do not implement daily refresh as a repeating 24-hour timer.
- `interval`: schedule the next attempt for the configured duration after the current attempt finishes. This is fixed-delay scheduling and must not overlap fetches.
- `never`: perform the initial fetch but do not create a refresh timer.

Treat consumer presence as a hard scheduling boundary:

- Zero active repository consumers means zero active refresh timers and no new fetch attempts.
- The zero-to-one consumer transition starts a fresh lifecycle, performs an immediate fetch, and schedules future refreshes according to the configured strategy.
- The one-to-zero transition synchronously cancels and clears the current timer before returning from unsubscription, invalidates in-flight work, and prevents completion callbacks from scheduling replacement timers.
- A later zero-to-one transition must create a new lifecycle and a new timer only after its new immediate fetch attempt finishes.
- Do not use a process-wide periodic timer, keepalive, polling loop, or timer that merely checks whether listeners exist. When inactive, the repository must consume no timer or polling resources.

Keep time and timer creation testable. Prefer small injected clock/timer factories or an existing package-approved clock abstraction. Do not make tests wait on real time, and do not add a new dependency if the target repository already provides equivalent test support.

## Tests

Retain all existing tests and add focused tests covering at least the following.

### Shared listener lifecycle

- Internal `Property`/`Model` listeners do not count as repository consumers.
- The first repository consumer starts the source exactly once.
- Multiple consumers share one source lifecycle.
- Removing a non-final consumer leaves the source active.
- Removing the final consumer stops the source exactly once and resets data to `null`.
- Resubscribing starts a new lifecycle.
- Repeated registration of the same callback requires matching unsubscriptions.
- Unsubscribing an unknown callback has no effect.
- Disposal detects actual repository consumers without relying on `data.hasListeners`.

### Stream repository regression coverage

- Existing subclasses compile unchanged.
- A real source `StreamController` receives `onCancel` after the final repository consumer unsubscribes.
- A later consumer obtains a new source subscription.
- Rapid unsubscribe/resubscribe does not allow the old source lifecycle to clear or overwrite the new one.
- `resetStream()` retains its previous externally observable behavior.

### Fetch repository behavior

- Default configuration is daily at local midnight.
- First subscription fetches immediately.
- A successful empty collection is published as empty, not `null`.
- Multiple consumers do not duplicate the initial fetch.
- Daily scheduling calculates the next configured local time, including when today's configured time has already passed.
- Daily scheduling is recomputed rather than treated as a fixed 24-hour interval.
- Interval scheduling uses the specified positive duration after completion.
- `never` creates no timer after the initial fetch.
- Automatic refreshes never overlap.
- Final unsubscription cancels the timer and resets data.
- After final unsubscription, fake time can advance indefinitely without another fetch or timer callback occurring.
- Resubscription after an inactive period performs a new immediate fetch and establishes a newly calculated schedule; it does not resume an old timer.
- A late in-flight completion after shutdown is ignored.
- A late completion from an older lifecycle cannot overwrite a newer lifecycle.
- Initial failure leaves data `null` and preserves the original error/stack behavior.
- Refresh failure retains the last successful value and does not prevent the next scheduled attempt.
- Invalid daily times and non-positive intervals are rejected.

Use deterministic fake time for all scheduling tests.

## Documentation and compatibility verification

- Update API documentation to explain null-versus-loaded-empty state and consumer-controlled lifecycle.
- Include a concise migration note stating that no consumer migration is required for `BaseDataStreamRepository`.
- If the repository maintains a changelog or package version, update it according to repository conventions, but do not publish the package or mutate external package state unless explicitly authorized.
- Run formatting, static analysis, all existing package tests, and the new focused tests.
- Search for every existing subclass and consumer of `BaseDataStreamRepository` and verify that it still compiles without edits. If compatibility cannot be maintained, stop and report the exact conflict rather than silently changing public behavior.

## Out of scope

- Do not edit consuming applications as part of this package change.
- Do not add presentation loading or error messages.
- Do not change business-specific cache policies.
- Do not add background execution when the repository has no consumers.
- Do not publish, deploy, or push unless separately authorized.

## Completion report

When finished, report:

1. The common abstraction and final public API.
2. How listener registrations are counted and why the old leak is fixed.
3. The precise daily, interval, and never scheduling semantics.
4. Backward-compatibility checks performed.
5. Tests and static analysis run, including their results.
6. Any follow-up needed in consuming applications, such as removing temporary listener-lifecycle workarounds after updating the dependency revision.
