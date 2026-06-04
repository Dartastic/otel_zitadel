// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'zitadel')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.instance != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('zitadel.instance', res.instance!)]));
      }
      if (res.organization != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('zitadel.organization', res.organization!)]));
      }
      if (res.project != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('zitadel.project', res.project!)]));
      }
      if (res.userId != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('user.id', res.userId!)]));
      }
      if (res.username != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('user.name', res.username!)]));
      }
      if (res.email != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('user.email', res.email!)]));
      }
      if (res.role != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('zitadel.role', res.role!)]));
      }
      if (res.action != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('zitadel.action', res.action!)]));
      }
      if (res.eventType != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('zitadel.event.type', res.eventType!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('zitadel.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
