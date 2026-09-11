# Demo test prompts

Requires Node 22.12 or later, the published Copilot SDK 1.0.13 and its platform
runtime, Windows DPAPI dependencies, and a configured Ollama model. Dependencies
remain under the external demo dependency directory, not in the repository.
These are local walkthrough expectations, not validation of the Azure deployment.

Start:

```powershell
.\startdemo.ps1
```

This reuses Ollama on port 11434 or starts it, then starts the Node server on 8110.
An occupied demo port is rejected. The server takes an exclusive state lock before
loading the agent. After an abnormal exit, verify the old process is stopped before
an authorized operator removes a stale `writer.lock`.

Open <http://127.0.0.1:8110/> and run these prompts in order.

Default routing remains **Public → Copilot** and **Highly Confidential / On-premises → Ollama**. Administrator can select Mistral or SimpleLLM for **Internal / EU-only**. Internal permits no tools in the current policy.

## Configure the EU route pool

1. Open Administrator and inspect the unpublished policy draft. Existing signed policy versions are unchanged; the draft adds `simplellm` where Mistral was already permitted.
2. Save and publish that signed policy revision. New chats can use the new participants; chats pinned to an earlier policy cannot.
3. In Route settings, enable the providers to use and enter their API keys. Keys are protected with Windows CurrentUser encryption outside the repository.
4. Set **Internal model preference** to Mistral or SimpleLLM.

The fixed OpenAI-compatible routes are Mistral `https://api.mistral.ai/v1` and SimpleLLM `https://api.simplellm.eu/v1`. Their EU locations are provider declarations, not independently attested execution evidence. Probing discovers the configured model but does not prove where inference ran.

The current EU pool contains only SimpleLLM; Mistral is a separate explicit route.
With that single-member pool there is no alternate provider to fall back to, even
when fallback is enabled. The fallback observations below apply only when an
authorized alternate is actually available.

| Chat | Prompt | Expected |
| --- | --- | --- |
| New Public | `What is the weather in Brussels? Use the weather tool.` | Public model and fictional weather tool. |
| Same chat | `Summarise these internal, synthetic notes: support improved; onboarding is next. Do not use tools.` | Elevates to **Internal / EU-only** before calling the first eligible configured EU-pool route. |
| Same chat | `Explain the first priority in one sentence. Do not use tools.` | Stays **Internal / EU-only**. |
| Same chat | `Use public_send to send the public greeting "Hello" to auditor@example.test.` | Refuses the public tool; stays **Internal / EU-only**. |
| Same chat | `Summarise the confidential sales contract SG-104. Use the sales tool.` | Elevates to Highly Confidential / On-premises; uses Ollama only with the approved guard, otherwise refuses before model execution. |
| Same chat | `What does a term of twelve months mean?` | Stays Highly Confidential / On-premises and retains the local requirement. |
| Same chat | `Use public_send to send that summary to auditor@example.test.` | Refuses before delivery. |
| New Public | `Process this request in the EU only. Suggest two headings for a team update. Do not use tools.` | The EU request triggers **Internal / EU-only**, without the word "internal". |
| New Internal | `Suggest two headings for a team update. Do not use tools.` | Starts **Internal / EU-only** without trigger words. |
| New Public | `Retrieve SG-104 using the appropriate lookup tool and give a short summary.` | Tool-triggered elevation happens before data release. |
| New Public | `What is the weather in Brussels? Use the weather tool.` | Does not inherit the protected chat's state. |

**Trigger rules:** whole words `internal` or `EU` select Internal / EU-only. `sales`, `contract`, `private` or `confidential` take precedence and go straight to Highly Confidential / On-premises. An already elevated chat never drops back; use **New chat** for the separate tests.

**Provider check:** a provider refusal is not a missing level. The badges must still show Internal / EU-only. When governed fallback occurs, User shows the route change and Compliance records the failed egress, alternate authorization and final route. EU location is a provider declaration, not attestation.

## Policy change

1. Allow `public_send` for Public, save, publish, and start a new Public chat.
2. Run `Use public_send to send the public greeting "Hello" to auditor@example.test.`
3. Confirm a dry-run with `delivered: false`.
4. Remove `public_send`, save, publish, and start another new Public chat.
5. Run the same prompt and confirm it is refused.

## Optional refusals

| Setup | Prompt | Expected |
| --- | --- | --- |
| Revoke the weather credential | `What is the weather in Brussels? Use the weather tool.` | Tool refusal. |
| Disable the selected model route | `Reply with one sentence: hello.` | Refusal without provider fallback. |
| Remove all enabled EU-provider keys | `Reply with one sentence: hello.` | Missing-key or no-authorized-route refusal. |
| Disable EU fallback and make the first route unavailable | `Reply with one sentence: hello.` | Provider refusal without substitution. |

Stop:

```powershell
.\stopdemo.ps1
```

This stops only the matching repository's Node processes, preserving Ollama and
unrelated applications. It removes only a lock owned by the process it just stopped;
unowned/stale locks are left for verified operator recovery.

Azure uses separate Entra sign-in/roles and Azure OpenAI for Public. Azure Ollama
is not on-premises: the confidential/on-premises fixtures are refusals in cloud
mode. See [azure-deployment-guide.md](azure-deployment-guide.md). Never submit real
restricted data to the cloud merely to demonstrate a refusal.
