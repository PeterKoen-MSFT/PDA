# Demo Mechanics: How Policy Governs the Agent

An architecture explanation for viewers who have not seen the business stories. The narrative follows a request through the system, not an employee through a scenario. Approximately 9 to 11 minutes at a natural presentation pace; actual generated audio determines the final duration.

## Production Notes

- Exactly 16 numbered segments, each with one **Visual cue:** and one **Voice-over:** block.
- Speak only the voice-over text. Headings, visual cues, and implementation references are not narration.
- Use the companion [recording prompt](astra%20clipchamp%20mechanics%20recording%20prompt.md) for capture, editing, and verification.
- Architecture cards are explanatory illustrations, not screenshots or evidence of a live execution. Label them `Architecture explanation`.
- Existing chat evidence is a recorded example, not a new live run. Do not replay guided stories or introduce employee personas.
- The UI's Authorization map describes the effective draft. Published versions and a chat's pinned policy establish what governed that chat; never substitute the draft for that authority.

## 01 - The Question Behind the Interface

**Visual cue:** A fresh chat shows Public confidentiality, Public cloud environment, and no business scope. Hold the chat interface without sending a prompt.

**Voice-over:**

What prevents an AI agent from sending the wrong information to the wrong model or tool? In this demonstration, the answer is an application layer that checks policy at the points where information is about to move. This is Policy Driven Agent. The chat is deliberately simple, but behind it are separate controls for policy, conversation state, model routing, tools, and evidence. We will follow those mechanics, rather than a business story. Every new chat starts Public, in the Public cloud environment, with no inherited business scope.

## 02 - The Architecture in One View

**Visual cue:** An architecture card shows `Browser: Chat | Administrator | Compliance`, followed by `Local Node.js service`, then `Governance checks + Copilot SDK runtime`, then `Authorized models and governed tools`. A separate line reads `Signed policy, chat state, and evidence`.

**Voice-over:**

The browser provides three views of one local Node application. Chat is where requests enter. Administrator manages the policy and participant configuration. Compliance inspects the resulting evidence. Inside the service, the governance layer decides what is permitted, while the GitHub Copilot SDK runs the agent conversation and its custom tools. Storage keeps policy versions, chat state, credentials, and signed events. These are responsibilities within the demo application, not a fleet of independently deployed services. The key design choice is that the model performs the task, but application code controls the permissions.

## 03 - Policy Is Versioned Authority

**Visual cue:** In Administrator, show Authorization map with its `Effective draft` label, then Generated ODRL and Published versions. Use separate readable shots rather than trying to fit the entire page at once.

**Voice-over:**

Policy describes which models, tools, and environments are allowed at each confidentiality level. It also defines the vocabulary for business boundaries. The Administrator page exposes a constrained profile of ODRL, a language for expressing permissions, prohibitions, and obligations. This is not a general-purpose ODRL engine: the server validates the supported profile. Notice that the authorization map is a draft view. Publication creates a signed version. A new chat pins the active version and its content digest, so a later publication does not silently replace the policy governing that existing conversation.

## 04 - Three Independent Facts

**Visual cue:** Show Protection levels, Execution environments, and Business boundaries in Administrator, then a card listing `Confidentiality`, `Execution environment`, and `Accumulating business scope`.

**Voice-over:**

Conversation protection has three parts. Confidentiality describes sensitivity: Public, Internal, or Highly Confidential. Execution environment describes the permitted processing boundary: Public cloud, a named restricted region, or On-premises. Business scope records partner networks and enterprise organizations involved in the work. These facts are related, but they are not interchangeable. Public information can require a regional environment. Internal information can remain in an authorized region. A business boundary can add its own environment requirement. Route selection must satisfy the combined state, not just one colored label.

## 05 - Protection Only Moves Up

**Visual cue:** An architecture card reads `Confidentiality can increase`, `Environment can become more restrictive`, `Business scope accumulates`, and `Named region A cannot switch to named region B`. Follow with retained markers on an existing protected chat, labelled as recorded evidence.

**Voice-over:**

The state transitions are monotonic: protection can become stronger, but cannot silently become weaker within a chat. Earlier protected context still matters when a later request sounds harmless. Partner and organization memberships accumulate rather than disappearing. Named regions are not interchangeable steps on a ladder: a chat already bound to one cannot simply switch to another. An incompatible regional request is refused for that turn, while the existing state is retained. Starting a new chat creates separate context; it does not authorize copying protected material into a Public conversation.

## 06 - Classification Before Inference

**Visual cue:** Open a completed answer's Activity disclosure and frame its classification and protection-change rows. The card for this segment reads `Prompt vocabulary + service requirements + existing state = proposed transition`.

**Voice-over:**

Before invoking the model, the application classifies the prompt using deterministic demo rules. It recognizes configured terms, named environments, services, and business boundaries. It combines their requirements with the chat's existing protection and proposes a transition. A compatible transition is committed and recorded; a conflicting request is refused. This is not the model deciding how sensitive its own input should be. It is also not enterprise data-loss prevention or a universal sensitive-data detector. The example demonstrates where classification belongs in the execution path, using a deliberately bounded vocabulary.

## 07 - Route Selection Is a Policy Decision

**Visual cue:** Show Administrator Model routes, then an actual model-authorization record in Compliance. Use a card reading `Pinned policy + current state + route configuration + valid credential`.

**Voice-over:**

The next question is which model may receive the conversation. The application checks the pinned policy, the complete protection state, route configuration, environment eligibility, and the participant's credential. Copilot is limited to Public cloud work here. Mistral and SimpleLLM are configured routes with provider-declared EU locations. Ollama provides local execution, including the demo's simulation of named regional environments. Those declarations are not independent proof of geography. When fallback is enabled, another provider must still be eligible under the same protection requirements. An outage does not authorize a weaker route.

## 08 - What the SDK Is Allowed to Do

**Visual cue:** An architecture card lists `GitHub Copilot SDK 1.0.13`, `Explicit custom-tool allowlist`, `Built-in and MCP tools excluded`, and `Fresh session with bounded conversation history`.

**Voice-over:**

The agent uses the published GitHub Copilot SDK, version one point zero point thirteen. For each execution attempt, the application creates a session with explicitly exposed custom tools. Built-in tools and MCP tools are excluded, and automatic configuration discovery, skills, and persistent session memory are disabled. The application supplies a bounded recent conversation history from its own chat store. Permission handling and a pre-tool hook restrict requests to the exposed tool set. That hook is only one control: the custom-tool handler still performs the substantive policy checks. This is not an unrestricted coding agent running behind the chat.

## 09 - The Model Traffic Boundary

**Visual cue:** A two-part architecture card distinguishes `Copilot: Public-only SDK route` from `Configured non-Copilot routes: SDK -> local model proxy -> eligible provider`. Then show a recorded provider-egress event if available.

**Voice-over:**

The non-Copilot routes use a local model proxy between the SDK and the provider. It checks the active turn, re-evaluates routing, validates the credential, and records authorization before forwarding a bounded request to the configured endpoint. Provider secrets remain server-side. The proxy also limits requests, applies timeouts, and records provider failures and permitted fallback attempts. Copilot uses the SDK's own provider path after the application's Public-only authorization; it is not routed through this same proxy. That distinction matters when describing exactly where this demonstration mediates traffic, and what its evidence can establish.

## 10 - A Tool Call Is Another Boundary

**Visual cue:** Show Tool catalog entries with different minimum restrictions, then a completed tool's Activity rows or signed authorization and execution records.

**Voice-over:**

A model asking for a tool is a request, not permission. The handler checks the tool's requirements against the current chat, including confidentiality, environment, business scope, and its signed demo credential. It can raise protection before proceeding, or deny the action. The catalog contains three generic tools and eighteen fictional business services. Their tool calls use the working governed execution path, but their business results are synthetic. The public-send tool is a dry run: even an allowed invocation does not deliver a message. The capability being demonstrated is controlled invocation, not a production business-system integration.

## 11 - Why Results Need Their Own Check

**Visual cue:** An architecture card shows `Tool request check`, `Synthetic result created`, `Result metadata check`, and `Release or withhold`. Keep this labelled as an implementation explanation, not a captured incident.

**Voice-over:**

Checking the request is not enough, because a result may introduce stronger requirements. Before returning a tool result to the model, the handler evaluates its governance metadata and the resulting conversation state. If the transition is incompatible, the result is withheld. If stronger protection requires another route, the current attempt is stopped without returning that protected result to the old model. Result metadata in this demo is fictional and self-declared. The mechanics show a pre-release decision point; they do not establish that an arbitrary external tool will label its data correctly.

## 12 - Restart Without Lowering Protection

**Visual cue:** An architecture card reads `Protection rises`, `Old attempt stops`, `New eligible route is selected`, and `New SDK attempt uses retained protection`. Add `At most two protection attempts per turn`.

**Voice-over:**

A protection-driven restart is different from retrying a failed network call. The chat keeps its stronger state, the old SDK attempt is stopped, and a new attempt is created on an authorized route. The application can then request the required data under that protection. This is not a rollback of information already sent: the important control is withholding the newly protected tool result before release to an ineligible model. The demo allows at most two protection attempts per turn. If it cannot complete within that bound, it stops rather than weakening policy or restarting indefinitely.

## 13 - Refusal Is a Recorded Outcome

**Visual cue:** In Compliance, inspect existing records for `ENVIRONMENT_CONFLICT` and `TOOL_FORBIDDEN_AT_CURRENT_LEVEL`, in separate shots if necessary. Show their retained state and outcome without recounting their business stories.

**Voice-over:**

Two examples make refusal concrete. An environment conflict rejects an incompatible regional transition and retains the chat's existing environment. A tool forbidden at the current level prevents an action such as public sending after protected context has accumulated. These are expected policy outcomes, not successful business actions and not provider failures. Each decision leaves evidence of what was requested, why it was refused, and which protection remained in force. A timeout, broken provider, or missing credential must not be edited into a successful policy demonstration. The reason for stopping is part of the result.

## 14 - What Participant Acceptance Means

**Visual cue:** Open Administrator Credentials and expand a participant's Credential details. Frame policy version, digest, claims, validity, and the demo-issued warning without displaying any provider secret.

**Voice-over:**

Participant credentials connect a model or tool identity to a particular policy version and digest. The runtime checks the signature, trusted issuer, expiry, revocation status, and matching policy. In this demonstration, the local demo authority issues those signed commitments on behalf of the fictional participants. A valid signature proves that the trusted demo issuer signed these claims; it does not prove that an external provider personally accepted them or actually obeys them. This distinction separates a verifiable acceptance record inside the application from independent assurance about behavior outside it.

## 15 - Evidence, Not Hidden Reasoning

**Visual cue:** Show one recorded chat's Activity disclosure, then its Compliance timeline and Inspect record. Click Verify ledger and hold the actual result. Show Export selected chat only in a separate shot if necessary; do not export.

**Voice-over:**

Activity gives the user a sanitized execution trace: classification, routes, tool requests, and outcomes. It is not hidden model reasoning. Compliance provides the underlying signed application records and a timeline for the selected chat. Verification checks signatures and hash-chain continuity. A selected-chat export can package its records, pinned policy, relevant credentials, and a signed manifest. These are useful controls for reconstructing what the application recorded. They are not immutable production storage or independent proof that every external action was observed. The local UI also assumes a trusted workstation operator; its three pages are not enterprise role-based access control.

## 16 - The Design to Take Away

**Visual cue:** Close on the retained markers of an existing protected chat, followed by a clean card reading `Classify -> Authorize -> Execute -> Check release -> Record evidence` and `Policy remains attached to the conversation`.

**Voice-over:**

The design is a governed execution loop: classify the request, authorize the route, check each tool, check the result before release, and preserve evidence of the decisions. Policy version and accumulated protection remain attached to the conversation as models and tools change. This demo exercises real SDK execution with bounded rules, synthetic services, and explicitly labelled trust assumptions. It does not supply enterprise identity, comprehensive data classification, independently attested hosting, or immutable audit storage. Those remain production responsibilities. What it makes concrete is the separation between an agent's ability to act and the application's authority to permit that action.

## Implementation References

These references support the explanation; do not voice them or expose source code in the finished video.

| Segments | Implementation anchor | What it establishes |
| --- | --- | --- |
| 01-02 | [server.mjs](../server.mjs), [README.md](../README.md) | Local application, browser views, SDK integration, separate responsibilities. |
| 03-07 | [app/governance.mjs](../app/governance.mjs): `publish`, `classify`, `planInputTransition`, `routePlan` | Versioned policy, deterministic classification, accumulated state, eligible routes. |
| 08-09 | [app/agent.mjs](../app/agent.mjs): `run`, `proxyRequest` | Session restrictions, history window, provider-path distinction, bounded model traffic. |
| 10-12 | [app/agent.mjs](../app/agent.mjs): `tool`, `run`; [app/catalog.mjs](../app/catalog.mjs) | Synthetic execution, result gate, withholding and bounded restart. |
| 13-14 | [app/governance.mjs](../app/governance.mjs): `classify`, `credential`, `_issueCredentialsForPolicy` | Refusal outcomes and locally issued policy commitments. |
| 15-16 | [app/storage.mjs](../app/storage.mjs), [server.mjs](../server.mjs), [docs/DEMO.md](DEMO.md) | Signed evidence, selected-chat export, operational and assurance limits. |
