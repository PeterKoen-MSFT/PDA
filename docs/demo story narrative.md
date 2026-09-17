# Demo Story Narrative

This script follows the short recorded demonstration: the Public chat opening, the Administrator experience, Elena's EU cloud launch, Min-jun's Korea delivery recovery, the Compliance experience, and the protected-chat close.

## Production Notes

- Text under **Visual cue** is an editing instruction and should not be voiced.
- Text under **Voice-over** is written for narration.
- Start each segment when the named screen or event becomes visible.
- Natural pauses can cover model activity. Long waits can be shortened without changing the narration.
- Business records, services, credentials, organizations, and results shown here are fictional or demo-issued.

## Opening: Public Chat

**Visual cue:** The Public opening shows the User chat with Public confidentiality and Public cloud environment markers.

**Voice-over:**

This is Policy Driven Agent, a working demonstration of enterprise governance for AI agents. We are following employees of Cumulus Granitus, a fictional global manufacturer. Every new conversation begins Public, with no inherited business scope. The markers above the chat show two independent controls: how confidential the conversation is, and where it is permitted to execute. As the conversation gains protected context, those controls can become stricter, but they cannot silently move back to a weaker state.

## Administrator: Policy Authority

**Visual cue:** The Administrator policy authorization map is visible.

**Voice-over:**

The Administrator experience defines the authority behind that behavior. A signed, versioned policy specifies which models, tools, and execution environments are permitted at each confidentiality level. It also defines named regional environments and business boundaries such as partner networks, Finance, HR, and manufacturing organizations. A new policy version affects new chats; it does not rewrite the policy pinned to an existing conversation.

**Visual cue:** The governed model routes are visible.

**Voice-over:**

Model selection is governed rather than left to the language model. Before any prompt leaves the application, the current conversation state is checked against the pinned policy, the route's declared environment, its configuration, and its signed demo credential. Availability alone never grants permission to send protected context to an ineligible provider.

**Visual cue:** The governed tool catalog is visible.

**Voice-over:**

Tools are governed in the same way. Each service declares a minimum confidentiality level, an execution requirement, and any partner or organizational boundary it needs. Tool results in this demo are synthetic, but requests follow the real policy enforcement path before execution and again before release.

**Visual cue:** The participant credential list is visible.

**Voice-over:**

The model and tool participants accept the active policy through signed, demo-issued credentials. These credentials make acceptance verifiable inside the demonstration. They are not external provider certifications or proof of production behavior.

## How Classification Works

**Visual cue:** Return to the User chat and select Elena's story.

**Voice-over:**

Classification happens in the governance layer before model execution. The application recognizes policy vocabulary in the request, including confidentiality cues, named regions, named services, and business boundaries. It calculates the minimum required confidentiality, environment, and scope, then checks whether the proposed transition is compatible with everything already in the chat. The same policy is checked again before model egress, before a tool runs, and before a result is released. The Activity panel shows this sanitized execution telemetry; it is not hidden model reasoning.

## Elena: EU Cloud Launch

**Visual cue:** Elena step 1 begins and the CISPE Cloud Registry activity appears.

**Voice-over:**

Elena Rossi is a digital platform director choosing a cloud platform for a factory-analytics release. Her first request names the CISPE Cloud Registry. The information remains Public, but the CISPE business boundary requires the EU execution environment. Notice that confidentiality and environment change independently: Public data can still have a regional execution requirement. CISPE is added to the chat's accumulating business scope.

**Visual cue:** Elena step 2 cross-checks EuroTrust Atlas.

**Voice-over:**

Elena now challenges the residency claim with EuroTrust Atlas. The agent separates concrete controls from statements that are only provider-declared. No weaker route is introduced, and the EU and CISPE boundaries remain attached to the conversation. The demo is careful not to turn a provider declaration into an independent attestation.

**Visual cue:** Elena step 3 invokes LedgerLens Finance and the confidentiality marker changes.

**Voice-over:**

The next request introduces an internal financial forecast. That raises confidentiality from Public to Internal and adds the Finance organization to the scope. The EU environment remains in force. Before the finance tool or model can proceed, the application re-evaluates the complete state and authorizes an eligible route. This is monotonic protection: the conversation now carries both the earlier CISPE context and the new Finance context.

**Visual cue:** Elena step 4 displays the steering-committee note.

**Voice-over:**

Finally, the agent prepares a go-or-no-go note for the steering committee. It combines residency evidence, financial exposure, and unresolved assumptions while retaining Internal confidentiality, EU execution, CISPE, and Finance. A harmless-looking summary request does not erase the sensitivity of the evidence used to create it.

## Min-jun: Korea Delivery Recovery

**Visual cue:** Min-jun step 1 begins in a new Public chat and invokes the Han River Index.

**Voice-over:**

The next story begins in a separate Public chat. Min-jun Park is an APAC logistics manager responding to a delayed Korea shipment. Asking for the Han River Index raises the conversation to Internal and selects the Korea environment before the governed service runs. This new chat has its own state; it does not inherit Elena's EU and Finance boundaries.

**Visual cue:** Min-jun step 2 asks to compare Japan and the expected policy decision appears.

**Voice-over:**

Min-jun then asks whether Japan could absorb the overflow. The chat is already bound to Korea, and named regional environments cannot switch laterally inside one conversation. The application refuses this turn with an environment conflict and retains Korea. This is an expected policy decision, not a demo failure. The blocked request does not poison the chat, so Min-jun can continue with a compatible plan.

**Visual cue:** Min-jun step 3 invokes PeopleCompass HR and the markers move to Highly Confidential and On-premises.

**Voice-over:**

Min-jun keeps the recovery plan within the current country and asks PeopleCompass HR about weekend staffing. Workforce details require stronger protection. The chat rises to Highly Confidential, moves to the On-premises environment, and adds HR to its business scope. These changes happen before protected staffing data is released, and the route is checked again against the stronger state.

**Visual cue:** Min-jun step 4 displays the Korea leadership escalation.

**Voice-over:**

The agent drafts an escalation for Korea leadership using the delivery risk and staffing constraint. Even though this prompt only asks for a summary, the chat remains Highly Confidential and On-premises because its earlier HR context is still present.

**Visual cue:** The additional public-send request produces an expected policy decision.

**Voice-over:**

The final chat test attempts to send the protected recovery plan through a public-delivery tool. Policy blocks the action before execution, and no protected tool data is released. The detailed message explains the reason, the policy code, and the protection state that remains in force. A provider error would be a failed run; this deliberate refusal is the control working as designed.

## Compliance: Verifiable Evidence

**Visual cue:** Compliance shows Elena's selected signed record and reconstructed timeline.

**Voice-over:**

The Compliance experience reads the evidence generated by the application itself. Elena's records reconstruct classification, protection changes, route authorization, tool execution, and release. Each event identifies the policy version and conversation state that governed it.

**Visual cue:** Compliance switches to Min-jun's refusal record and timeline.

**Voice-over:**

Min-jun's timeline shows the successful tool calls alongside the Korea-to-Japan conflict and the blocked public-send attempt. Compliance can distinguish data that was released from an action denied before release. The refusal is preserved as evidence rather than hidden as a user-interface message.

**Visual cue:** Ledger verification succeeds and the export control is shown.

**Voice-over:**

Ledger verification checks the signatures and hash-chain continuity across the recorded events. The selected chat can also be exported with its pinned policy and relevant demo credentials. This is signed, tamper-evident, append-only application evidence. It should not be confused with immutable production storage.

## Close: Protection Stays With the Chat

**Visual cue:** Return to Min-jun's chat with the Highly Confidential, On-premises, and HR markers visible.

**Voice-over:**

Back in the User view, Min-jun's protection markers are unchanged. The demonstration closes on its central principle: policy follows the conversation. Models and tools may change, but enterprise authority, accumulated scope, and verifiable evidence remain attached to the work.