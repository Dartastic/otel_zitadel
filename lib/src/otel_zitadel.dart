// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_zitadel_suppression.dart';

class ZitadelResult {
  const ZitadelResult({
    this.instance,
    this.organization,
    this.project,
    this.userId,
    this.username,
    this.email,
    this.role,
    this.action,
    this.eventType,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? instance;
  final String? organization;
  final String? project;
  final String? userId;
  final String? username;
  final String? email;
  final String? role;
  final String? action;
  final String? eventType;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class ZitadelCallResult<T> {
  const ZitadelCallResult({required this.value, this.result});
  final T value;
  final ZitadelResult? result;
}

Future<T> tracedZitadel<T>({
  required String operation,
  required Future<ZitadelCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (zitadelInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_zitadel');
  final span = t.startSpan('zitadel $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'zitadel');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.instance != null) {
        span.setStringAttribute('zitadel.instance', res.instance!);
      }
      if (res.organization != null) {
        span.setStringAttribute('zitadel.organization', res.organization!);
      }
      if (res.project != null) {
        span.setStringAttribute('zitadel.project', res.project!);
      }
      if (res.userId != null) {
        span.setStringAttribute('user.id', res.userId!);
      }
      if (res.username != null) {
        span.setStringAttribute('user.name', res.username!);
      }
      if (res.email != null) {
        span.setStringAttribute('user.email', res.email!);
      }
      if (res.role != null) {
        span.setStringAttribute('zitadel.role', res.role!);
      }
      if (res.action != null) {
        span.setStringAttribute('zitadel.action', res.action!);
      }
      if (res.eventType != null) {
        span.setStringAttribute('zitadel.event.type', res.eventType!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('zitadel.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'zitadel.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
