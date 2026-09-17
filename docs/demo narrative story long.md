# Long Demo Narrative: All Six Stories

This script follows the complete recorded run in order: Aiko, Min-jun, Elena, Mariana, Daniel, and Li Wei.

## Production Notes

- Text under **Visual cue** is an editing instruction and should not be voiced.
- Text under **Voice-over** is written for narration.
- Start a segment when its named story step becomes visible.
- Model waits may be shortened during editing. Preserve the visible protection change, expected policy decision, and final answer for each step.
- All companies, people, business services, records, credentials, and tool results in the demonstration are fictional or demo-issued.

## Introduction: What the Demo Proves

**Visual cue:** The User chat and Demo stories selector are visible before the first story starts.

**Voice-over:**

This is Policy Driven Agent, a working demonstration of enterprise governance for an AI agent built through the GitHub Copilot SDK. The six stories follow employees of Cumulus Granitus, a fictional global manufacturer of industrial robotics and motion-control equipment.

Every story begins in a fresh Public chat. From there, governance tracks three independent facts. Confidentiality can be Public, Internal, or Highly Confidential. The execution environment can be Public cloud, a named restricted region, or On-premises. Business scope accumulates the partner networks and enterprise organizations whose information enters the conversation.

Classification happens before the model runs. The governance layer matches the request against policy vocabulary, including confidentiality cues, regional terms, named services, and business boundaries. It proposes the minimum state needed for the work and checks that proposal against the state already attached to the chat. Protection can increase, but it cannot silently decrease. This one-way rule is monotonic protection. Partner and organization scope is append-only, and a chat cannot jump laterally between incompatible named regions.

The Activity panel shows what the application is doing: prompt acceptance, classification, protection changes, route authorization, SDK execution, tool requests, and release or refusal. This is sanitized execution telemetry, not model chain-of-thought. Model routing is a policy decision based on the complete chat state, not a choice delegated to the model. The same signed policy is enforced again before model egress, before tool execution, and before a result is released.

Named regional environments in this demo are logical policy boundaries. Japan, Korea, Brazil, the United States, and China use local Ollama execution on the workstation. They demonstrate enforcement behavior, not physical in-country hosting. All business results use synthetic data.

## Story 1: Aiko - Audit Moved Forward

**Visual cue:** Aiko's story starts in a new Public chat.

**Voice-over:**

Aiko Tanaka is a regional operations director. An automotive customer has moved a Nagoya robotics-line audit forward by four days, leaving Aiko to determine whether inventory, suppliers, and the plant can support the new date.

**Visual cue:** Step 1 invokes Sakura Exchange and the markers change to Internal and Japan.

**Voice-over:**

Aiko first checks Sakura Exchange for inventory and logistics across the Japan sites. The named service requires Internal confidentiality and the Japan environment. The governance layer commits both changes before execution, then authorizes an eligible route and allows the synthetic service result to reach the model.

**Visual cue:** Step 2 invokes ForgeLink Exchange and adds Industrial Community.

**Voice-over:**

The likely bottleneck is a servo controller, so Aiko checks ForgeLink Exchange for supplier capacity and lead time. That request adds the Industrial Community partner network to the chat. Japan remains the governing environment. The new boundary accumulates alongside the earlier logistics context rather than replacing it.

**Visual cue:** Step 3 invokes Kaizen Plant Console and moves to Highly Confidential and On-premises.

**Voice-over:**

Plant readiness is more sensitive. Requesting the Kaizen Plant Console adds Manufacturing Japan, raises confidentiality to Highly Confidential, and moves execution On-premises. The stronger environment means protected plant information is not exposed through the route used for less sensitive work. Policy is evaluated before the tool runs and before its result is released.

**Visual cue:** Step 4 displays the customer briefing.

**Voice-over:**

The agent turns the evidence into a five-point customer briefing covering capacity, supplier risk, quality posture, the required decision, and what should not yet be promised. The final prompt sounds like simple writing, but the response retains the complete Highly Confidential, On-premises, Industrial Community, and Manufacturing Japan state.

## Story 2: Min-jun - Delivery Recovery

**Visual cue:** Min-jun's story starts in a new Public chat.

**Voice-over:**

Min-jun Park is an APAC logistics manager. A delayed morning shipment threatens a Korea customer promise and may require a weekend recovery shift.

**Visual cue:** Step 1 invokes the Han River Index and selects Internal and Korea.

**Voice-over:**

The first request checks the Han River Index for delivery risk. The policy classifier recognizes the Korea service and its minimum confidentiality. The chat moves from Public cloud to the Korea environment and from Public to Internal before the tool is called.

**Visual cue:** Step 2 requests a Japan comparison and shows an expected policy decision.

**Voice-over:**

Min-jun asks whether Japan could absorb the overflow. Korea and Japan are separate named regional boundaries at the same protection tier. Moving sideways would mix incompatible regional contexts, so the request is refused with an environment conflict. Korea remains in force. This is a successful policy checkpoint, not a technical error, and the refused turn does not prevent later compatible work.

**Visual cue:** Step 3 invokes PeopleCompass HR and moves to Highly Confidential and On-premises.

**Voice-over:**

Min-jun keeps the plan within the existing boundary and asks PeopleCompass HR about weekend staffing. Workforce information raises the chat to Highly Confidential, moves execution On-premises, and adds HR scope. The model and tool must now satisfy this complete stronger state.

**Visual cue:** Step 4 displays the leadership escalation.

**Voice-over:**

The resulting escalation combines delivery risk, staffing constraints, and a recommended recovery plan. The chat does not become less protected when the tool call is over. Highly Confidential, On-premises, and HR remain attached to the conversation.

## Story 3: Elena - EU Cloud Launch

**Visual cue:** Elena's story starts in a new Public chat.

**Voice-over:**

Elena Rossi is a digital platform director. She needs a defensible hosting recommendation and budget decision for the next release of a factory-analytics platform.

**Visual cue:** Step 1 invokes the CISPE Cloud Registry and selects the EU environment.

**Voice-over:**

Elena starts with the CISPE Cloud Registry. The information remains Public, while the CISPE partner boundary selects the EU environment. This demonstrates that confidentiality and execution location are separate controls. Public information can still be required to stay within a regional execution boundary.

**Visual cue:** Step 2 cross-checks EuroTrust Atlas.

**Voice-over:**

Security wants evidence rather than a marketing statement, so Elena cross-checks EuroTrust Atlas. The response separates residency controls from claims that are only self-declared. The EU and CISPE boundaries remain unchanged, and the interface does not present provider declarations as independent attestations.

**Visual cue:** Step 3 invokes LedgerLens Finance and raises confidentiality to Internal.

**Voice-over:**

Adding the internal financial forecast raises confidentiality from Public to Internal and adds Finance scope. The chat remains in the EU environment. The full accumulated state is checked before finance data is used, showing that an environment can stay fixed while confidentiality becomes stronger.

**Visual cue:** Step 4 displays the steering note.

**Voice-over:**

The agent prepares a steering-committee note that separates residency evidence, financial exposure, and assumptions that still require validation. The answer retains both CISPE and Finance because summaries inherit the protection of their source context.

## Story 4: Mariana - Flood-Response Sourcing

**Visual cue:** Mariana's story starts in a new Public chat.

**Voice-over:**

Mariana Alves is a community operations lead. Flooding near Recife has interrupted deliveries to three apprentice training centers, creating an urgent need for local support and backup suppliers.

**Visual cue:** Step 1 invokes Verde Supply Pulse and selects Brazil.

**Voice-over:**

Mariana first checks Verde Supply Pulse. The request selects the Brazil environment while confidentiality remains Public. The regional marker describes where this work is permitted to execute, not whether the underlying supply summary is secret.

**Visual cue:** Step 2 invokes CivicBridge Network, adds NGO Community, and moves On-premises.

**Voice-over:**

Next, Mariana searches CivicBridge Network for local programs. The NGO Community boundary requires On-premises execution, but the information can remain Public. This unusual-looking combination is intentional: confidentiality and execution environment are independent axes. A public result may still require a tightly controlled processing location.

**Visual cue:** Step 3 invokes SourceLine Procurement and raises confidentiality to Internal.

**Voice-over:**

Approved vendors and active contracts introduce internal procurement data. The chat rises to Internal, adds Procurement, and remains On-premises. NGO Community is retained, giving the conversation both partner and enterprise scope.

**Visual cue:** Step 4 attempts public send and shows an expected policy decision.

**Voice-over:**

Mariana attempts to send the vendor shortlist and program details to an external address. Public delivery is not eligible for a protected Internal, On-premises chat. The action is denied before execution, and no protected data is released. The visible policy decision is therefore a successful control outcome.

**Visual cue:** Step 5 displays the internal handoff.

**Voice-over:**

Mariana responds by keeping the handoff internal. The agent summarizes approved options, NGO coverage, and the reason external delivery was blocked, all within the accumulated protected state.

## Story 5: Daniel - US Capacity Decision

**Visual cue:** Daniel's story starts in a new Public chat.

**Voice-over:**

Daniel Brooks is a North America network planner. The board needs to know whether the United States manufacturing network can absorb a new actuator program.

**Visual cue:** Step 1 invokes Stateside Market Grid and selects the US environment.

**Voice-over:**

Daniel begins with facility utilization from Stateside Market Grid. The chat remains Public but selects the United States environment. The route is authorized against that named boundary before the synthetic market data is retrieved.

**Visual cue:** Step 2 invokes ForgeLink Exchange and adds Industrial Community.

**Voice-over:**

Supplier capacity may change the recommendation, so ForgeLink Exchange adds Industrial Community scope. The United States environment remains in force while partner evidence is added to the conversation.

**Visual cue:** Step 3 requests China production numbers and shows an expected policy decision.

**Voice-over:**

Daniel then asks to fold China factory production numbers into the board case. The chat is already bound to the United States, so policy rejects the incompatible switch to China. The existing state remains intact, and the refusal is recorded as an expected environment decision rather than a provider failure.

**Visual cue:** Step 4 invokes Heartland Plant Console and moves to Highly Confidential and On-premises.

**Voice-over:**

The Heartland Plant Console introduces confidential manufacturing distribution data. The chat rises to Highly Confidential, moves On-premises, and adds Manufacturing US scope. Industrial Community remains attached, so supplier and internal manufacturing evidence are now governed together.

**Visual cue:** Step 5 displays the United States recommendation.

**Voice-over:**

The agent gives the board a recommendation supported by capacity and lead-time evidence, while identifying the largest remaining unknown. The response retains the strongest state reached by the conversation.

## Story 6: Li Wei - Quality Incident

**Visual cue:** Li Wei's story starts in a new Public chat.

**Voice-over:**

Li Wei is a reliability engineering lead. Three China-built X7 actuator batches have failed vibration testing, requiring factory evidence, research context, and a controlled containment response.

**Visual cue:** Step 1 frames the incident and moves to Internal and China.

**Voice-over:**

The opening request names the China incident and asks for an internal review. Classification raises confidentiality to Internal and selects the China environment before the model structures the first quality questions.

**Visual cue:** Step 2 invokes Pearl Plant Console and adds Manufacturing China.

**Voice-over:**

Li Wei pulls the Pearl Plant Console to examine line status and quality indicators. The tool adds Manufacturing China scope while retaining Internal confidentiality and the China environment. This is scope accumulation without an unnecessary confidentiality increase.

**Visual cue:** Step 3 invokes Horizon Research Notebook and moves On-premises.

**Voice-over:**

The Horizon Research Notebook adds Research scope and requires On-premises execution. Manufacturing China remains attached, allowing factory and research evidence to be considered together under one stronger execution boundary.

**Visual cue:** Step 4 attempts public send and shows an expected policy decision.

**Voice-over:**

Li Wei attempts to send the incident summary and plant findings to an external supplier address. Public send is blocked before execution because this conversation contains protected manufacturing and research context. The fictional public-send tool never performs real delivery, and in this case policy prevents even the dry-run action from receiving the protected data.

**Visual cue:** Step 5 displays the containment plan.

**Voice-over:**

The final request keeps the work inside Cumulus Granitus and adds Engineering to the existing Manufacturing China and Research scope. The agent produces a containment plan with owners while preserving Internal confidentiality and On-premises execution.

## Closing: Policy Follows the Conversation

**Visual cue:** Li Wei's completed story and final protection markers remain visible.

**Voice-over:**

Across all six stories, the model never decides whether policy applies. The governance layer classifies each request, calculates the required state, authorizes eligible routes and tools, and checks results before release. Compatible boundaries accumulate. Incompatible regional switches and public egress are refused precisely, while valid work continues.

Every decision is written to a signed, append-only compliance ledger with the policy version and state that governed it. The evidence is tamper-evident rather than production-immutable, and the named regions are simulated policy boundaries rather than claims of in-country hosting. Within those honest limits, the demonstration shows the core pattern: policy follows the conversation, and enterprise authority remains in control as an agent's work evolves.