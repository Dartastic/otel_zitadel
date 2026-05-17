# otel_zitadel

Dartastic OpenTelemetry bridge for ZITADEL (cloud-native IAM).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_zitadel/otel_zitadel.dart';

await tracedZitadel<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return ZitadelCallResult(value: r, result: ZitadelResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutZitadelInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
