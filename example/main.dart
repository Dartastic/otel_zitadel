// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_zitadel/otel_zitadel.dart';

/// Traces Zitadel calls with OpenTelemetry.
///
/// `otel_zitadel` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Zitadel call in
/// [tracedZitadel]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'zitadel-example');

  // Traces a Zitadel call.
  final zitadelId = await tracedZitadel<String>(
    operation: 'create',
    invoke: () async {
      // Make the Zitadel call here, then report what it returned.
      const id = 'zitadel_8f3a2c';
      return const ZitadelCallResult(
          value: id,
          result: ZitadelResult(
              instance: 'example',
              organization: 'example',
              project: 'example',
              userId: 'user_8f3a2c',
              username: 'example',
              email: 'ada@example.com',
              role: 'example',
              action: 'example',
              eventType: 'order.created',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedZitadel create returned $zitadelId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutZitadelInstrumentationAsync.
  await runWithoutZitadelInstrumentationAsync(
    () => tracedZitadel<String>(
      operation: 'create',
      invoke: () async {
        const id = 'zitadel_8f3a2c';
        return const ZitadelCallResult(
            value: id,
            result: ZitadelResult(
                instance: 'example',
                organization: 'example',
                project: 'example',
                userId: 'user_8f3a2c',
                username: 'example',
                email: 'ada@example.com',
                role: 'example',
                action: 'example',
                eventType: 'order.created',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
