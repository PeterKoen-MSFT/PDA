# Policy Driven Agent: Engineering VP Briefing

## Story and Purpose

An agent becomes more useful as it gains access to models, tools, and enterprise context. That also creates more places where information can leave a permitted boundary. This project demonstrates separating task execution from permission to act. The leadership decision is whether to validate that pattern in one bounded production pilot, not whether this demo is already an enterprise platform.

Audience: engineering VPs. Six slides, exactly two minutes. No employee stories, live inference, source-code walkthrough, fabricated metrics, or claims of production readiness.

The editable deck and six 1920x1080 PNG slide images are generated outside the repository in `%LOCALAPPDATA%/PDA/video-analysis/engineering-vp-briefing/`. Use the PNGs in Clipchamp; retain the deck for editing. Slides are architecture illustrations, not proof of a new live execution.

## 01 - Capability Is Not Permission

**Timing:** 00:00-00:20

**Slide title:** Policy Driven Agent

**On screen:** Capability is not permission. Three connected labels: Models / Tools / Enterprise context. One contrasting label: Application-controlled authority.

**Voice-over:**

An enterprise agent can become more capable with every model, tool, and data source we connect. But capability is not permission. Policy Driven Agent demonstrates an architectural boundary: let the model perform the task, while application code decides which actions and information flows are permitted.

## 02 - Separate Execution From Authority

**Timing:** 00:20-00:40

**Slide title:** The model works. The application governs.

**On screen:** Chat -> Governed SDK runtime -> Eligible models / Governed tools. Signed policy feeds governance; decision records feed Compliance. Footer: Local Node.js application | GitHub Copilot SDK 1.0.13.

**Voice-over:**

The working demo uses the GitHub Copilot SDK inside a local Node application. A governance layer checks policy around model routing and custom tools. Administrator publishes signed policy versions; each chat pins one version. Compliance reads the decision records produced by that execution path.

## 03 - Context Carries Its Restrictions

**Timing:** 00:40-01:00

**Slide title:** Protection stays with the conversation.

**On screen:** Sensitivity: Public -> Internal -> Highly Confidential. Environment: Public cloud -> Restricted region -> On-premises. Scope: Partner networks + enterprise organizations. Callout: No silent downgrade. No lateral region switch.

**Voice-over:**

Every chat starts Public. As protected context accumulates, confidentiality can rise, execution requirements can tighten, and business scope accumulates. A harmless summary request does not reset those restrictions. Named regions cannot switch laterally within a chat. Model choice must remain compatible with the complete state.

## 04 - Check Again Before Release

**Timing:** 01:00-01:20

**Slide title:** A tool request is not permission to release.

**On screen:** Request check -> Tool execution -> Result check. Branches: Release to eligible model / Withhold; restart or refuse. Footer: Protection-driven restart is bounded to two attempts per turn.

**Voice-over:**

The critical control is at release. Tool requests are checked, and result metadata is evaluated before returning data to the model. If stronger protection requires another route, the result is withheld and the attempt restarts under retained protection. Forbidden actions are refused, with reasons recorded.

## 05 - Evidence With Explicit Limits

**Timing:** 01:20-01:40

**Slide title:** Inspect the decision. Know the trust boundary.

**On screen:** Recorded: Policy binding / State changes / Route and tool decisions. Boundaries: Synthetic services / Demo-issued credentials / Local regional simulation. Footer: Signed, tamper-evident evidence; not immutable storage.

**Voice-over:**

The demo produces inspectable, signed evidence of policy bindings, state changes, routing, and tool outcomes. It exercises real SDK execution, but business results are synthetic, credentials are demo-issued, and named regional execution can be simulated locally. The ledger is tamper-evident application evidence, not immutable production storage.

## 06 - Validate One Production Boundary

**Timing:** 01:40-02:00

**Slide title:** Next decision: one bounded pilot.

**On screen:** Choose one workflow + one real integration. Validate: Identity and classification / Provider assurance and egress / Audit durability and operating cost. Success gate: Correct refusals + useful completion + acceptable latency.

**Voice-over:**

The next engineering decision is a bounded pilot, not a fleet rollout. Select one workflow and real integration. Validate identity, classification, provider assurance, egress controls, durable audit, and operating cost. Measure correct refusals, useful completion, and latency before expanding. Keep permission independent of model capability.

## Production Notes

- Six visual slots of exactly 20 seconds total 120 seconds. Narration is approximately 270 words; validate actual generated duration before assembly.
- Speak only Voice-over blocks. Slide text, headings, timings, and notes are not additional narration.
- Use a professional neutral voice. Natural pace first; do not silently accelerate or truncate speech to meet the clock.
- Start each voice clip 0.3 seconds after its slide starts. It must finish by 19.5 seconds into that slide. Shorter audio leaves an intentional visual hold.
- If any generated clip exceeds 19.2 seconds, stop and request a wording reduction for that segment. Do not shift the six fixed slide boundaries.
- Use native slide visuals, not screenshots of editing applications. Subtitles occupy the reserved bottom band without covering claims or diagrams.
- Production-pilot criteria are recommendations, not implemented capabilities or measured results.

## Fact Anchors

- [README.md](../README.md): current architecture, three axes, routes, evidence limits.
- [app/agent.mjs](../app/agent.mjs): SDK session restrictions, tool/result checks, protection-driven restart; non-Copilot proxy is distinct from Copilot's provider path.
- [app/governance.mjs](../app/governance.mjs): policy versioning, transition checks, deterministic classification, route eligibility, demo credentials.
- [docs/DEMO.md](DEMO.md): synthetic services, regional simulation, bounded attempts, and operational limits.
- [app/storage.mjs](../app/storage.mjs): signed application evidence and verification.
