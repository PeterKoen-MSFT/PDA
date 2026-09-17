# Astra Prompt: Explain the Demo Mechanics in Clipchamp

Use the following prompt without shortening it.

---

You are the computer-use operator and video editor for a mechanics-focused explanation of Policy Driven Agent. Create a new synchronized Clipchamp project using the exact companion narration, read-only inspection of the demo, and clearly labelled architecture cards. Do not replay the business stories. Operate the supplied applications; do not merely describe what the user should do.

## Objective and Deliverables

Explain to a first-time viewer how the demo is built, how a request is governed, what the runtime can do, and where its assurance ends. Follow the request lifecycle, not employee personas or a guided scenario.

Deliver a saved, reopenable project named `PDA Mechanics - Inside the Governed Agent`, containing:

1. Preserved raw screen capture of the required UI inspections.
2. An edited sequence of UI shots and native Clipchamp architecture cards.
3. Exactly 16 independently positioned narration segments, copied verbatim from the authoritative narrative.
4. A complete cue sheet and a content-verification report.

Target approximately 9 to 11 minutes, but let actual narration duration and readable visuals determine length. Do not truncate speech or increase its speed to hit a target. Do not export the finished video unless explicitly asked. Do not modify, replace, or delete either existing two-story project.

## Authoritative Inputs

- Repository: `C:\Users\pkoen\Source\PDA`
- Exact narration: `C:\Users\pkoen\Source\PDA\docs\demo mechanics narrative.md`
- Operating notes: `C:\Users\pkoen\Source\PDA\docs\DEMO.md`
- Implementation references: the table at the end of the narrative.
- Demo URL: `http://127.0.0.1:8110/`
- External Edge session: existing CDP connection at `http://127.0.0.1:9222`.

Parse each numbered narrative heading and pair its **Visual cue:** with its immediately following **Voice-over:**. There must be exactly 16 pairs, in the same order as the shot list below. Copy only voice-over text into text to speech. Visual cues, Production Notes, headings, references, and this prompt must never be spoken. Do not substitute either of the business-story narratives.

## Operating Boundaries

- Use the existing supplied Clipchamp session. Prefer the already-open Clipchamp web editor in the external Edge session; use the supplied desktop app only if that is the established available editor. Do not migrate workflows or create an account without approval.
- Attach only to the existing external Edge session. Never use an integrated browser, replacement profile, or another browser instance.
- Do not close, restart, resize, maximize, minimize, emulate, or change viewport dimensions of the shared Edge window. Preserve the desktop-only demo layout.
- Do not close or rearrange unrelated tabs. Navigate only the supplied demo and Clipchamp tabs.
- Every captured application action must use visible normal UI interaction. Prefer accessible role/name locators. No application API calls, backend requests, injected JavaScript clicks, or invisible state changes.
- Read-only inspection includes navigation, scrolling, expanding disclosures, selecting evidence filters and records, and Verify ledger. Creating one fresh Public chat for the opening is permitted. Do not post prompts, run Next or Auto, or replay stories.
- Do not edit policy, route settings, credentials, source files, or existing chat contents. Do not publish, revoke, save a draft, probe a provider, or trigger an export.
- Do not start, stop, restart, benchmark, or reconfigure the demo or a model. Do not run builds or tests, install dependencies, or create helper scripts.
- Keep video, audio, images, and cue-sheet artifacts outside the repository, under `%LOCALAPPDATA%/PDA/video-analysis/` or a user-approved external folder. Do not add recordings to Git.
- Do not expose secrets, provider keys, tokens, personal information, unrelated tabs, internal model context, or filesystem paths in the capture. Signed public credential records are not provider keys; inspect only fields needed for the explanation.

Stop for one specific manual action if capture selection cannot be automated, the supplied session is unavailable, a sign-in/MFA/secret/account-consent prompt appears, or capture or text to speech is unavailable. Never ask the user to transmit a secret through chat. Do not select a fallback application, browser, voice, or provider silently.

## Evidence Rules

This is an explanation using existing application evidence, not a claim of a new live run.

- Label reused UI evidence `Recorded demo evidence`. Refer to chats by short identifiers, not employee stories.
- Label every conceptual card `Architecture explanation`. Use native Clipchamp text on a restrained solid background, with readable high-contrast type. Match the demo's visual language. No stock footage, decorative animation, music, or simulated application UI.
- A conceptual release or restart card explains implemented control flow. It must not contain invented timestamps, success badges, event records, signatures, or provider responses.
- Actual selected records must support any claim that an event happened. A tool catalog entry or a route setting alone is not execution evidence.
- The authorization map is the effective draft, not proof of a selected chat's active policy. Show Published versions and inspect the chat's recorded policy version/digest separately.
- Existing credentials may be expired or revoked. Do not renew them for filming or claim that a currently invalid credential is valid. Explain the displayed state; stop if it contradicts the exact narration's required visual.
- Provider locations are declared, not independently attested. Named regional Ollama execution is a local simulation. Services and business results are synthetic. Public send never delivers.
- Do not claim universal DLP, an output-content firewall, inspection of all Copilot provider traffic, immutable storage, independent provider acceptance, or enterprise role separation. The narrative deliberately makes narrower claims.

## Preflight

Complete this without recording:

1. Read all 16 narrative segments and construct the cue sheet skeleton.
2. Confirm the supplied demo is available at the loopback URL, with Chat, Admin, and Compliance visible and no turn running. If stopped, ask the user to start it; do not start it yourself.
3. Identify existing synthetic chat evidence for classification, retained protected state, model authorization, a completed tool, an environment conflict, and a forbidden public-send decision. Record the relevant chat identifiers, policy versions, and record identifiers outside the repo.
4. Inspect these records through Compliance. The two refusal records may belong to different chats; do not imply one continuous execution if they do. Locate the corresponding chat Activity where the current UI permits it.
5. If the UI cannot reopen a required chat, plan a clearly labelled Compliance-record shot with the same actual state and event. Log that visual substitution. Do not invoke a hidden endpoint to restore it.
6. Confirm Administrator exposes Policies, Models & tools, and Credentials. Note the difference between the draft and published policy. Do not edit anything.
7. Confirm a signed credential can be inspected without exposing secrets. Confirm the ledger can be verified. If verification fails, stop and report the actual failure; never replace it with a success card.
8. If evidence required by segments 06, 07, 10, or 13 is absent, stop and report the missing event. Request permission for a separate evidence-generation session; do not silently run business stories. A model-egress event in segment 09 is optional because the card explains the path without asserting a captured provider call.
9. Create the new 16:9 Clipchamp project without overwriting any project. Confirm screen recording and text to speech are available. Keep microphone, camera, and system audio off.
10. Select Ava Multilingual, English (United States), default pitch, default 1x pace, matching the prior video when available. If unavailable, ask for approval of one named alternative. Keep one approved voice throughout.
11. Create one fresh Public chat through the normal UI for segment 01. Verify Public, Public cloud, and no business scope. Preserve all earlier chats and evidence.
12. Confirm notifications and unrelated content will not appear. Do not resize the browser to make a shot fit; use normal page scrolling and separate shots.

## Capture and Assembly Strategy

Record the UI inspections in the shot-list order. Capture only the supplied demo window or tab using Clipchamp's available screen-recorder control. If capture would expose the editor, other tabs, or personal content, request the appropriate manual source selection rather than hiding it later.

Architecture cards are timeline elements, not fake application pages. Create them with Clipchamp's native title/text and background controls. No separate website, slide deck, helper script, or generated application is required. Use only the exact card phrases specified by the narrative and the two provenance labels above. No automatic captions or extra on-screen transcript.

Preserve raw captures in project media. Multiple source captures are permitted if needed for editor limits, but the final sequence must contain all 16 scenes in order. Record a clean lead-in and tail. Hover briefly before a visible click when capture renders the pointer. Let the named cue settle before narration begins.

Generate the 16 audio segments before final trimming so their actual durations define the required holds. UI shots must last for their narration plus one second of breathing room. If the raw shot is too short, use an explicitly static hold of that same read-only view or recapture it. Never loop a spinner or fabricate continuing model activity.

## Required 16-Segment Shot List

### 01 - The Question Behind the Interface

- Show the fresh Public chat and its three empty/default protection facts.
- Do not send anything. No story selection or persona introduction.
- Anchor narration when the Public and Public cloud markers are readable.

### 02 - The Architecture in One View

- Use the exact architecture-card labels from narrative segment 02, in top-to-bottom reading order.
- Keep storage/evidence visually separate from the execution sequence, not another external provider.
- Anchor when the full card is readable. This is an illustration of local responsibilities, not a deployment screenshot.

### 03 - Policy Is Versioned Authority

- Click Admin, then Policies if needed. Show Authorization map and its Effective draft label.
- Scroll to and expand Generated ODRL, then show Published versions.
- Use readable sequential shots. Do not click Save draft, Save ODRL, Apply JSON, or Publish draft.
- Align the draft shot with the draft explanation, and Published versions with the publication explanation.

### 04 - Three Independent Facts

- Inspect Protection levels, Execution environments, and Business boundaries through normal scrolling.
- Follow with the exact three-axis card from segment 04.
- Keep the relevant vocabulary readable while its corresponding sentence is spoken.

### 05 - Protection Only Moves Up

- Show the four exact card statements from segment 05.
- Then show an existing protected chat's retained markers, or its actual Compliance state if the chat is not reopenable.
- Label the latter Recorded demo evidence. Do not claim a fresh elevation occurred in this shot.

### 06 - Classification Before Inference

- Open the selected completed answer's Activity disclosure and show classification and protection rows.
- Use its actual Compliance records if reopening the answer is not supported; preserve the same chat identity.
- Follow with the classification formula card. The formula is conceptual, not a mathematical sensitivity score.

### 07 - Route Selection Is a Policy Decision

- Click Admin, Models & tools, and frame Model routes without modifying controls.
- Show the exact four-input route-eligibility card.
- Inspect an actual model-authorization record in Compliance, showing its policy version and route identity.
- Do not infer successful provider execution from authorization alone or imply every configured provider is currently available.

### 08 - What the SDK Is Allowed to Do

- Show the exact SDK card from narrative segment 08.
- Keep all four statements visible for the full explanation.
- Do not expose source code, terminal windows, working-directory paths, or unrelated coding tools as B-roll.

### 09 - The Model Traffic Boundary

- Show the two distinct provider paths from narrative segment 09 on the same card.
- Keep the Copilot path visually distinct from the non-Copilot local-proxy path.
- If a real model-egress event is available, show it after the card with Recorded demo evidence. Otherwise retain the explanatory card; do not fabricate a record.

### 10 - A Tool Call Is Another Boundary

- Inspect Tool catalog entries with differing minimum confidentiality and environment requirements.
- Show actual authorization and completion evidence for one synthetic tool, keeping its identifier consistent across shots.
- The example is about the handler's decision, not an employee's task. Do not recount the prompt's business background.

### 11 - Why Results Need Their Own Check

- Show the four-stage result-gate card from narrative segment 11.
- Treat the entire shot as Architecture explanation. Do not imply the selected completed tool actually caused a late result elevation.
- No fake animation of protected records moving to a provider.

### 12 - Restart Without Lowering Protection

- Show the exact four-stage restart card and the two-attempt bound from segment 12.
- Keep this an implementation walkthrough unless a separately identified actual restart record is available. Such a record is not required.
- Do not force a route change, alter settings, or run inference to manufacture a restart for filming.

### 13 - Refusal Is a Recorded Outcome

- Open the preflight-selected ENVIRONMENT_CONFLICT record and its retained state.
- Then open the TOOL_FORBIDDEN_AT_CURRENT_LEVEL record and its retained state.
- Keep each code legible when its meaning is narrated. Identify distinct chats if applicable.
- Do not send another public-send request or suggest that a dry run delivered anything.

### 14 - What Participant Acceptance Means

- Click Admin, Credentials; expand Credential details for the preselected participant.
- Show policy binding, claims, validity, and the demo-issued warning through separate readable shots.
- Do not click revoke controls or expose a provider-key input. Never describe the signature as an external provider's signature.

### 15 - Evidence, Not Hidden Reasoning

- Show recorded Activity, then Compliance for the same chat, with Selected chat timeline and Inspect record.
- Click Verify ledger visibly. Anchor the verification sentence to the actual successful result, not the click.
- Show Export selected chat only in a separate shot if it cannot share the frame with verification. Do not export.
- Do not imply full-ledger verification is limited to the chat filter, or that a selected-chat export is itself the complete ledger.

### 16 - The Design to Take Away

- Return to existing protected chat markers, or the same chat's recorded protection state in Compliance if restoration is unsupported.
- Close with the exact lifecycle card and final policy statement from narrative segment 16.
- Hold the final frame until narration ends, plus one second. No additional claims or calls to action.

## Timing and Voice Workflow

Maintain a cue sheet outside the repository. For every segment, record:

- Segment number, ID/heading, and visual type: UI evidence or architecture explanation.
- Source recording/media identifier; selected chat and event identifiers where applicable.
- `action_time_raw`, `cue_visible_time_raw`, and `result_time_raw` for captured UI actions.
- `card_start_edited` for a card; raw-time fields are `N/A` for native cards, never invented.
- Removed source intervals and any inserted holds/cards before the cue.
- `cue_time_edited`, actual `tts_start_time`, audio duration, and `sync_delta`.
- Additional within-segment visual switches and their corresponding narration sentences.
- Pass/fail, visual substitutions, and unresolved limitations.

With multiple captures and inserted cards, do not calculate the final cue by subtracting cuts alone. Map each retained source interval to its actual timeline position and account for inserted media. For a retained UI cue: edited clip start plus the cue's offset within that retained source interval. For a card: the first timeline frame where its text is readable.

Set `sync_delta = tts_start_time - cue_time_edited`. Target an absolute delta of at most 0.25 seconds and report any above 0.50 seconds as a failure. Within a segment, align each named sub-shot to its corresponding sentence; starting the clip correctly is not sufficient if the rest of the narration describes a different view.

Create one separate Clipchamp text-to-speech item for each exact voice-over block. Save/generate each item into project media; do not leave text only in an unsaved panel. Name items with segment number and heading when possible. Keep voice, language, pitch, and pace identical. If a length limit forces splitting, split at sentence boundaries and keep those pieces contiguous as one segment.

Preview pronunciation of ODRL, SDK, MCP, Ollama, Mistral, and SimpleLLM. Do not rewrite the script silently. Supported pronunciation controls may be used only without changing wording. If auditory inspection is unavailable, explicitly report pronunciation as unverified; visible waveforms or completed playback do not prove it was heard.

## Static Holds and Silence Removal

Remove navigation mistakes, blank capture, and unnecessary silence before final synchronization. A static screen under narration is intentional and must remain.

- Cut only intervals where there is no narration or other intended audio AND no meaningful visual change AND no required reading/breathing hold.
- Keep visible navigation clicks, disclosure openings, changes of record selection, policy identifiers, state markers, refusal codes, and verification results.
- Preserve at least 0.5 seconds around narration boundaries and one second of visual context around important changes.
- Never shorten a shot below the full narration duration and breathing room. Never cut words, overlap voice clips, accelerate speech, or trim an architecture card merely because it is static.
- Detection tools may propose cuts, but review their meaning visually. Do not install tools or create analysis scripts without separate permission.
- After every timing edit, recompute cue positions and verify audio placement against the actual timeline. Do not trust old offsets or snap behavior.

## Verification Gate

Preview the entire final sequence at normal speed, including every narration clip. Pausing to inspect is permitted; skipping unreviewed intervals is not. Also play from half a second before each cue through its first sentence.

Pass only when:

1. All 16 exact voice-over blocks occur once, in order, without spoken production text.
2. Every segment and within-segment visual switch matches the corresponding explanation.
3. All narration starts are within 0.50 seconds of their intended cue; no clips overlap or are truncated.
4. The recording contains no guided-story playback, persona narrative, unapproved prompt, policy edit, or provider probe.
5. Architecture cards and recorded evidence are visibly distinguished. No card is presented as a live event.
6. Draft policy, published policy, and pinned chat policy are not conflated.
7. SDK restrictions, the distinct Copilot/provider paths, tool request checks, result withholding, and bounded restart are explained without overclaiming their enforcement.
8. Both actual refusal codes and the actual successful ledger-verification result are readable. Export is shown but not performed.
9. Synthetic results, dry-run sending, local regional simulation, demo-issued credentials, trusted-operator UI, and tamper-evident rather than immutable storage remain in the narration.
10. No secret, unrelated content, or browser dimension change appears.
11. All raw media remain preserved. Any removed interval satisfies both the visual and audio conditions above.
12. The project is saved, reopened, and rechecked for missing media, all 16 narration segments, and unchanged timings.

If a check fails, repair that segment and repeat its focused check. Do not conceal missing evidence with an illustration or report unavailable auditory verification as passed.

## Completion Report

Report concise bullets plus the 16-row cue sheet:

- Project name and saved/reopened status; no export unless separately authorized.
- Exact voice settings and whether pronunciation was actually heard and checked.
- Final runtime, narration count, source preservation, and removed interval count/duration.
- Cue sheet: segment, source type, raw cue or N/A, edited cue, TTS start, delta, pass/fail.
- Actual evidence identifiers for model authorization, tool execution, both refusals, and verification.
- Any permitted visual substitutions, missing evidence, unverified assertions, or manual action still needed.

Do not claim completion until the actual content and saved project have passed the available verification checks. Distinguish any unresolved limitation explicitly.

---
