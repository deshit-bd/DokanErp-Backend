import 'dart:async';

import 'package:dokan_erp/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps loader active until all concurrent requests finish', () async {
    final tracker = ApiActivityTracker();
    final first = Completer<void>();
    final second = Completer<void>();
    final counts = <int>[];
    final subscription = tracker.changes.listen(counts.add);

    final firstRequest = tracker.track(() => first.future);
    final secondRequest = tracker.track(() => second.future);

    expect(tracker.activeRequests, 2);

    first.complete();
    await firstRequest;
    expect(tracker.activeRequests, 1);

    second.complete();
    await secondRequest;
    expect(tracker.activeRequests, 0);
    expect(counts, [1, 2, 1, 0]);

    await subscription.cancel();
    await tracker.dispose();
  });

  test('releases loader when a request fails', () async {
    final tracker = ApiActivityTracker();

    await expectLater(
      tracker.track<void>(() => Future<void>.error(StateError('failed'))),
      throwsStateError,
    );

    expect(tracker.activeRequests, 0);
    await tracker.dispose();
  });
}
