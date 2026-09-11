// Non-authoritative OpenTelemetry mirror of the compliance ledger.
//
// The signed append-only ledger remains the system of record. When enabled, each
// ledger append is also emitted as an OpenTelemetry log record for observability
// (dashboards, alerting, trace correlation). Only non-sensitive, allow-listed fields
// are exported — never signatures, secrets, prompts, tool arguments/results, or
// credentials. Telemetry is best-effort and must never affect the ledger.

const NOOP = { onLedgerAppend: null };

// Explicit allow-list. Anything not listed here is never exported.
function projectAttributes(record) {
  const attributes = {
    'ledger.seq': record.seq,
    'ledger.kind': record.kind,
    'ledger.id': record.id,
    'ledger.digest': record.hash,
    'ledger.previous_hash': record.previousHash,
    'ledger.timestamp': record.timestamp,
  };
  const optional = {
    'pda.chat_id': record.chatId,
    'pda.agent_id': record.agentId,
    'pda.level': record.level,
    'pda.sovereignty': record.sovereignty,
    'pda.route_id': record.routeId,
    'pda.model': record.model,
    'pda.outcome': record.outcome,
    'pda.policy_version': record.policyVersion,
    'pda.policy_digest': record.policyDigest,
    'pda.reason': record.reason,
    'pda.tool_id': record.toolId,
    'pda.http_status': record.httpStatus,
  };
  for (const [key, value] of Object.entries(optional)) {
    if (value !== undefined && value !== null && value !== '') {
      attributes[key] = typeof value === 'object' ? undefined : value;
    }
  }
  return attributes;
}

export async function initTelemetry() {
  if (process.env.PDA_OTEL_ENABLED !== '1') {
    return NOOP;
  }
  const connectionString = process.env.APPLICATIONINSIGHTS_CONNECTION_STRING;
  if (!connectionString) {
    return NOOP;
  }

  try {
    const { useAzureMonitor } = await import('@azure/monitor-opentelemetry');
    useAzureMonitor({
      azureMonitorExporterOptions: { connectionString },
      // The Copilot SDK and app own their own signals; only export what we emit here.
      instrumentationOptions: {
        http: { enabled: true },
      },
    });

    const { logs, SeverityNumber } = await import('@opentelemetry/api-logs');
    const logger = logs.getLogger('pda.ledger');

    const onLedgerAppend = (record) => {
      logger.emit({
        severityNumber: SeverityNumber.INFO,
        severityText: 'INFO',
        body: `ledger.${record.kind}`,
        attributes: projectAttributes(record),
      });
    };

    return { onLedgerAppend };
  } catch {
    // If OpenTelemetry packages or the exporter fail to initialise, run without a
    // telemetry mirror. The ledger is unaffected.
    return NOOP;
  }
}
