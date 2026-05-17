// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_zitadel/otel_zitadel.dart';
import 'package:test/test.dart';

void main() {
  group('otel_zitadel', () {
    test('suppression toggles in zone', () async {
      expect(zitadelInstrumentationSuppressed(), isFalse);
      await runWithoutZitadelInstrumentationAsync(() async {
        expect(zitadelInstrumentationSuppressed(), isTrue);
      });
      expect(zitadelInstrumentationSuppressed(), isFalse);
    });

    test('ZitadelResult fields default null', () {
      const r = ZitadelResult();
      expect(r.statusCode, isNull);
    });
  });
}
