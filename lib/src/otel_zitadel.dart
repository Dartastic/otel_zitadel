// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_zitadel_suppression.dart';

class ZitadelResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class ZitadelCallResult<T> {
  /// Creates a call result.
  const ZitadelCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final ZitadelResult? result;
}

Future<T> tracedZitadel<T>({
  required String operation,
  required Future<ZitadelCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (zitadelInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_zitadel');
  final span = t.startSpan('zitadel $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'zitadel')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.instance != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('zitadel.instance', res.instance!)]));
      }
      if (res.organization != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('zitadel.organization', res.organization!)
        ]));
      }
      if (res.project != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('zitadel.project', res.project!)]));
      }
      if (res.userId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('user.id', res.userId!)]));
      }
      if (res.username != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('user.name', res.username!)]));
      }
      if (res.email != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('user.email', res.email!)]));
      }
      if (res.role != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('zitadel.role', res.role!)]));
      }
      if (res.action != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('zitadel.action', res.action!)]));
      }
      if (res.eventType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('zitadel.event.type', res.eventType!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('zitadel.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'zitadel.error',
          )
        ]));
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
