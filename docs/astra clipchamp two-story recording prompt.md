# Astra Prompt: Record and Narrate the Two-Story Demo in Clipchamp

Use the following prompt without shortening it.

---

You are the primary computer-use operator and video editor for this task. Work carefully, visibly, and autonomously until the Clipchamp project is ready for review. Do not merely explain what should be done. Operate the supplied Microsoft Clipchamp application and the supplied external Microsoft Edge window.

## Objective

Create a synchronized Clipchamp project for the short Policy Driven Agent demonstration. The finished project must contain:

1. One screen recording of the supplied external Edge window showing the complete short demonstration.
2. Every narration block from the short narrative entered separately into Clipchamp's AI text-to-speech workflow.
3. Each narration clip positioned at the visual event named by its paired visual cue.
4. Visible, deliberate UI clicks that match the narrative sequence.
5. The Elena and Min-jun stories, including both expected policy decisions.
6. The Administrator and Compliance views described by the narrative.
7. A final return to Min-jun's protected chat.
8. A cue sheet reporting the original recording time, edited timeline time, narration start time, and synchronization delta for every segment.

Do not export the final video unless I explicitly ask. Leave the Clipchamp project saved and ready to preview or render.

## Authoritative Inputs

- Repository: `C:\Users\pkoen\Source\PDA`
- Narrative: `C:\Users\pkoen\Source\PDA\docs\demo story narrative.md`
- Demo URL: `http://127.0.0.1:8110/`
- Story definitions: `C:\Users\pkoen\Source\PDA\public\demo-stories.js`
- Demo operating notes: `C:\Users\pkoen\Source\PDA\docs\DEMO.md`

The narrative file is the authority for the presentation. Pair every `**Visual cue:**` block with the immediately following `**Voice-over:**` block. There must be exactly 19 such pairs. Visual cues and production notes are instructions and must never be spoken. Voice-over text must be copied exactly, without paraphrasing, summarizing, correcting, or adding claims.

Use only the short narrative above. Do not use `demo narrative story long.md` and do not add the other four demo stories.

## Control Surfaces

- Control Clipchamp through the already-open Clipchamp desktop application using normal visible computer interaction.
- Control only the user-supplied external Edge window through Playwright or visible computer interaction.
- Attach to the supplied Edge window. Do not launch another browser, browser profile, integrated browser, or replacement Edge session.
- Do not close, restart, resize, maximize, minimize, or otherwise change the dimensions of the supplied Edge window.
- Do not close or rearrange the user's unrelated tabs.
- Use normal visible UI interactions for every action that must appear in the recording. Do not invoke application APIs, call backend endpoints, inject JavaScript clicks, or change page state invisibly.
- Prefer stable Playwright locators based on role, accessible name, label, and visible text. Avoid brittle screen coordinates when Playwright can address the control.
- Move or hover the pointer over each target for roughly half a second before clicking when the capture method renders the pointer. Use ordinary left-clicks. Do not open context menus.

## Manual Checkpoints and Secrets

You may operate ordinary Clipchamp controls and non-sensitive capture permission dialogs. Stop and ask me for exactly one manual action if any of these occurs:

- Windows blocks automation of the screen or window selection dialog.
- A sign-in, password, passkey, MFA, secret, microphone permission, or account-consent prompt appears.
- Clipchamp cannot access screen recording or text to speech.
- The supplied Edge window is not available to Playwright.

Never ask me to reveal a password, API key, token, or other secret to you. Never choose a fallback browser, editor, recording application, model, or workflow without my explicit approval.

## Safety and Truthfulness

- Do not edit repository files, application settings, policies, credentials, routes, or demo data.
- Do not publish a policy.
- Do not start, stop, restart, probe, benchmark, or reconfigure Ollama or any model process.
- Do not run tests or builds.
- Do not create helper scripts.
- Do not claim a scene succeeded from a click alone. Verify the visible result.
- Treat `ENVIRONMENT_CONFLICT` and `TOOL_FORBIDDEN_AT_CURRENT_LEVEL` as expected successful policy checkpoints.
- Treat any other refusal, transport error, provider error, route error, state mismatch, or stopped story as a real failure. Stop the recording workflow and report the exact visible failure instead of concealing it.
- Preserve the narrative's truthful boundaries: business results are synthetic, participant credentials are demo-issued, named regional execution is simulated locally, and the ledger is tamper-evident application evidence rather than immutable production storage.

## Preflight Before Recording

Complete this preflight without recording:

1. Read the full short narrative and build an internal table of its 19 visual-cue and voice-over pairs.
2. Confirm the supplied Edge page is exactly the loopback demo at `http://127.0.0.1:8110/`.
3. Confirm the page title and visible Cumulus Granitus chat interface are present.
4. Confirm the top navigation contains Chat, Admin, and Compliance.
5. Confirm the Demo stories sidebar contains the story selector and Next button.
6. Confirm no turn is currently running and the Next button can become enabled.
7. Create or display a fresh chat and verify the visible markers say `Confidentiality: Public` and `Environment: Public cloud`, with no inherited business scope.
8. Confirm Clipchamp is signed in and create a new 16:9 project named `PDA Two-Story Governed Demo` without overwriting or deleting another project.
9. Confirm Clipchamp's screen recorder and AI text-to-speech feature are available.
10. Set the project for a 1080p result when Clipchamp exposes that choice. Preserve the supplied Edge dimensions.
11. Keep the screen recording's microphone and system audio off. The final audio must come from Clipchamp AI voice, not ambient sound.
12. Ensure no notification, unrelated window, secret, token, local path, or personal content will appear over the captured Edge window.

If any preflight item fails, stop before recording and report the failed item. Do not improvise around it.

## Timing Model

Maintain a precise cue sheet throughout the operation. Use a monotonic clock with `00:00.000` equal to the first captured frame after Clipchamp begins recording the Edge window.

For each segment, record:

- Segment number and ID.
- Narrative heading.
- Exact visual cue.
- Exact voice-over text.
- Visible action or click target.
- `action_time_raw`: the instant the click or navigation action occurs in the raw recording.
- `cue_visible_time_raw`: the first frame on which the named visual cue is visibly established.
- `result_time_raw`: the first frame on which the expected final state is visibly complete.
- Any removed waiting intervals before this segment.
- `cue_time_edited`: the cue's position after all earlier cuts.
- `tts_start_time`: the actual start of the Clipchamp narration clip.
- `sync_delta`: `tts_start_time - cue_time_edited`.
- Verification status and notes.

The cue-visible time is the primary narration anchor. The action time is the audit reference proving which click caused the cue. For a story step, the narration should normally start when the click has posted the prompt and the new activity or state becomes visible. Target a synchronization delta of no more than 0.25 seconds; never accept more than 0.50 seconds without reporting it.

Before leaving any scene, hold it long enough for its complete voice-over block at a natural professional pace plus at least one second of visual breathing room. Estimate conservatively before TTS is generated. Also wait for the required UI result. This ensures the raw shot is never shorter than its narration.

## Recording Method

1. In Clipchamp, choose the screen-recording function with camera disabled.
2. Select only the supplied external Edge window as the capture source.
3. Begin recording and establish the monotonic `00:00.000` origin.
4. Bring the supplied Edge window to the foreground without resizing it.
5. Leave a clean one-second lead-in on the Public chat before the first narration cue.
6. Perform the 19-segment shot list below in order.
7. Keep the relevant screen, markers, activity, or evidence visibly framed for each narration block.
8. Keep the newest chat turn and its Activity disclosure visible while a story step runs. Use normal scrolling or Playwright scrolling; do not install DOM observers or modify the application.
9. Wait for each assistant stream to finish and for the Next button to become enabled before proceeding.
10. Stop the screen recording only after the final protected-chat shot has been held for the final narration duration plus one second.
11. Return to Clipchamp and choose the control that saves/adds the recording to the project.
12. Verify the raw recording is present in project media and on the timeline before doing any edits.

## Required 19-Segment Shot List

### 01 - public-opening

- Start on a fresh User chat.
- Show the Public confidentiality and Public cloud environment markers and the empty business scope.
- Pair this shot with `Opening: Public Chat`.
- Do not start on a restored protected chat.

### 02 - admin-authorization

- Click `Admin` in the visible top navigation.
- Wait for `Enterprise policy and model settings` and the `Policies` tab.
- Frame the `Authorization map` section and its visible policy coverage.
- Pair this shot with the first Administrator visual cue.
- Inspect only. Do not edit, save, or publish anything.

### 03 - admin-model-routes

- Click the `Models & tools` tab.
- Frame the `Model routes` section and allow route cards/settings to be readable.
- Pair this shot with the governed model-routes visual cue.

### 04 - admin-tool-catalog

- Scroll normally from Model routes to `Tool catalog`.
- Frame representative tool entries and their restrictions without changing them.
- Pair this shot with the governed tool-catalog visual cue.

### 05 - admin-credentials

- Click the `Credentials` tab.
- Frame `Participant credentials` and its explanatory note.
- Pair this shot with the participant-credential visual cue.
- Do not expose raw secrets or imply external attestation.

### 06 - classification-and-elena-selection

- Click `Chat` in the visible navigation.
- In the Demo stories selector, choose `Elena: EU cloud launch`.
- Hold the story persona and scenario visibly before clicking Next.
- Pair this shot with `How Classification Works`.

### 07 - elena-step-1

- Click `Next` once.
- Verify a new Public chat starts and Elena's first prompt is posted.
- Keep the CISPE Cloud Registry activity and protection markers visible.
- Verify Public confidentiality, EU environment, and CISPE scope are visibly established.
- Pair with Elena step 1 narration.

### 08 - elena-step-2

- After step 1 is complete, hover and click `Next` once.
- Keep the EuroTrust Atlas activity and resulting answer visible.
- Verify EU and CISPE remain attached and no weaker route appears.
- Pair with Elena step 2 narration.

### 09 - elena-step-3

- After step 2 is complete, hover and click `Next` once.
- Keep LedgerLens Finance activity and the protection change visible.
- Verify confidentiality becomes Internal, the environment remains EU, and Finance is added while CISPE is retained.
- Pair with Elena step 3 narration.

### 10 - elena-step-4

- After step 3 is complete, hover and click `Next` once.
- Keep the steering-committee response and complete retained markers visible.
- Verify the story reports complete at 4 of 4 without an unexpected error.
- Record Elena's visible chat identifier for later Compliance filtering.
- Pair with Elena step 4 narration.

### 11 - minjun-step-1

- Change the story selector to `Min-jun: Delivery recovery`.
- Confirm its persona and scenario appear, then click `Next` once.
- Verify this starts a separate new Public chat before the first prompt runs.
- Keep Han River Index activity visible.
- Verify the resulting state is Internal and Korea.
- Pair with Min-jun step 1 narration.

### 12 - minjun-step-2-environment-conflict

- After step 1 is complete, hover and click `Next` once.
- Keep the visible expected policy decision in frame.
- Verify the code is `ENVIRONMENT_CONFLICT`, Korea is retained, the activity is presented as a completed expected checkpoint, and the story remains able to continue.
- This is a successful scene. Do not stop because of this expected decision.
- Pair with Min-jun step 2 narration.

### 13 - minjun-step-3

- After the expected decision has completed, hover and click `Next` once.
- Keep PeopleCompass HR activity and protection changes visible.
- Verify Highly Confidential, On-premises, and HR are established before protected staffing results are released.
- Pair with Min-jun step 3 narration.

### 14 - minjun-step-4

- After step 3 is complete, hover and click `Next` once.
- Keep the Korea leadership escalation and retained protection markers visible.
- Verify the story reports complete at 4 of 4.
- Record Min-jun's visible chat identifier for Compliance filtering.
- Pair with Min-jun step 4 narration.

### 15 - minjun-protected-public-send

- In the same completed Min-jun chat, click the prompt box and visibly enter this exact additional prompt:

  `Use public send to send the recovery plan to partner@example.test.`

- Click `Send` visibly.
- Keep the resulting expected policy decision in frame.
- Verify the code is `TOOL_FORBIDDEN_AT_CURRENT_LEVEL`, the protected data is not released, the message identifies this as an expected demo policy decision rather than a runtime failure, and Highly Confidential, On-premises, and HR remain attached.
- This is a successful scene. Do not stop because of this expected decision.
- Pair with the additional public-send narration.

### 16 - compliance-elena

- Click `Compliance` in the visible top navigation.
- Wait for `Ledger, timeline, and verification`.
- In the Chat filter, select Elena's previously recorded chat identifier.
- Select a signed Elena record that visibly reconstructs classification, route authorization, tool execution, or release.
- Frame both `Inspect record` and `Selected chat timeline`.
- Pair with the Elena Compliance narration.

### 17 - compliance-minjun

- Change the Chat filter to Min-jun's recorded chat identifier.
- Select a blocked/refused Min-jun record, preferably the protected public-send refusal, while retaining the timeline in view.
- Ensure the timeline also contains the Korea-to-Japan environment conflict.
- Frame evidence that distinguishes released activity from denied or withheld activity.
- Pair with the Min-jun Compliance narration.

### 18 - compliance-verification

- Click `Verify ledger` visibly.
- Wait for the successful verification result and frame it with `Export selected chat only` visible.
- Do not actually export unless I explicitly request it.
- Pair with the ledger-verification narration.

### 19 - protected-chat-close

- Click `Chat` in the visible top navigation.
- Verify the restored chat is Min-jun's completed chat.
- Frame `Confidentiality: Highly Confidential`, `Environment: On-premises`, and the HR scope marker.
- Also keep the final protected public-send decision or latest protected state visible when possible.
- Pair with `Close: Protection Stays With the Chat`.
- Hold the shot for the complete narration plus one second, then stop capture.

## Raw Recording Review and Wait Removal

Preserve the raw recording in Clipchamp project media. Edit a timeline instance; do not delete the source.

1. Place the raw video at timeline time zero.
2. Mute any audio embedded in the screen recording.
3. Trim only blank lead-in and tail beyond the required breathing room.
4. Review every long model wait before creating narration placement.
5. Remove only genuinely empty middle portions of waits. Preserve:
   - the click that begins the turn;
   - the posted user prompt;
   - representative live Activity;
   - every confidentiality, environment, and scope transition;
   - expected policy decision text and code;
   - the completed assistant result;
   - at least one second of stable visual context around important changes.
6. Never cut through a visual cue or remove evidence needed by its narration.
7. Never shorten a shot below the expected duration of its complete voice-over block plus breathing room.
8. Make all wait cuts before final text-to-speech placement.

For every edited cue, calculate:

`cue_time_edited = cue_visible_time_raw - total_duration_of_all_removed_intervals_ending_before_the_cue`

If a proposed removed interval contains an action time, cue-visible time, state transition, refusal, result arrival, or required click, do not remove that interval.

## Clipchamp AI Voice Workflow

Use one independently positioned Clipchamp text-to-speech clip for each of the 19 voice-over blocks.

1. Open Clipchamp's `Record & create` area and choose `Text to speech`, or the equivalent current label.
2. Choose one professional, neutral English AI voice and keep the same voice, language, pitch, and pace for all 19 clips.
3. Use a natural presentation pace. Prefer the default pace unless it makes the narration rushed. Do not use a theatrical style.
4. Document the exact voice name and settings in the final report.
5. Paste only the exact text under the corresponding `**Voice-over:**` block.
6. Exclude headings, Markdown, `Visual cue`, and `Production Notes` text.
7. Preview for obvious pronunciation errors in names such as Cumulus Granitus, Elena Rossi, Min-jun Park, CISPE, EuroTrust, LedgerLens, PeopleCompass, and On-premises.
8. Do not rewrite the narrative to solve pronunciation. Use Clipchamp-supported pronunciation controls only if they preserve the spoken wording.
9. Generate or save each AI voice item so it persists in project media. Clipchamp may not preserve unrendered text in a closed panel; do not leave transcript text only in a transient editor.
10. If Clipchamp enforces a text-length limit, split only at a sentence boundary. Keep the pieces adjacent and treat them as one numbered segment in the cue sheet.
11. Rename each generated media item with its segment number and ID when Clipchamp permits renaming.
12. Place the narration on an audio track beneath the screen recording at `cue_time_edited`.
13. Do not add the narration as visible title text. Do not generate automatic captions unless I explicitly request captions.
14. Do not add music, sound effects, transitions, decorative overlays, stock footage, or branding not already in the demo.
15. Keep narration clips from overlapping. If two clips would overlap, preserve more of the preceding visual hold or move the next video cue later; do not speed up or truncate narration silently.

## Synchronization Rules

- Public opening narration starts when the Public and Public cloud markers are cleanly visible.
- Administrator narration starts only after each named section is visible and stable.
- Classification narration starts as Elena's story selection and scenario become visible.
- Each story-step narration starts at the first visible activity/state caused by that step's Next click.
- Expected-decision narration starts when the expected policy decision first becomes readable.
- Compliance narration starts when the selected record and timeline are both visible.
- Ledger-verification narration starts when the successful verification result appears, not merely when the Verify button is clicked.
- Closing narration starts when Min-jun's Highly Confidential, On-premises, and HR markers are visible again.

The narration and click must be causally understandable. The viewer should see the click immediately before, or at, the visual cue described by the narration. Do not place narration over an earlier unrelated page merely to make the timeline fit.

## Verification Pass

After placing all narration clips, preview the project at normal speed and verify actual content rather than trusting Clipchamp status indicators.

Pass only if all of these are true:

1. The project contains one preserved raw recording and one edited timeline sequence.
2. All 19 narrative voice-over blocks are present in order.
3. No Visual cue or Production Notes text is spoken.
4. Every narration block starts within 0.50 seconds of its edited cue-visible time, with a target of 0.25 seconds.
5. Every action that changes scenes is visibly performed in the recording.
6. The Edge window never changes dimensions.
7. Elena contains exactly four successful story steps with the expected Public/EU/CISPE to Internal/EU/Finance progression.
8. Min-jun contains exactly four story steps plus the additional protected public-send request.
9. `ENVIRONMENT_CONFLICT` is shown as an expected successful checkpoint that retains Korea.
10. `TOOL_FORBIDDEN_AT_CURRENT_LEVEL` is shown as an expected successful checkpoint that retains Highly Confidential, On-premises, and HR.
11. Compliance visibly shows Elena evidence, Min-jun refusal evidence, a reconstructed timeline, successful ledger verification, and the export control.
12. The final shot visibly returns to Min-jun's retained protected state.
13. No password, token, credential secret, notification, unrelated tab, or personal content is visible.
14. The project is saved and can be reopened with its media and timing intact.

For each segment, scrub to 0.5 seconds before its narration start, play through the first sentence, and verify that the named click/cue is visible at the intended moment. If a segment fails, correct that segment and recheck it before moving on.

## Completion Report

When the project passes verification, report only:

- Clipchamp project name.
- Whether the raw recording is preserved.
- Exact AI voice name, language, pace, and pitch.
- Count of narrative pairs found and count placed.
- Count and duration of removed wait intervals.
- A 19-row cue sheet with segment ID, raw action time, raw cue-visible time, edited cue time, TTS start time, synchronization delta, and pass/fail.
- Confirmation that Elena completed 4 of 4.
- Confirmation that Min-jun completed 4 of 4 plus the protected public-send checkpoint.
- Confirmation that both expected policy codes were captured.
- Confirmation that Compliance and the protected closing shot were captured.
- Any remaining manual action or synchronization delta over 0.50 seconds.
- Whether the project is saved and ready for review.

Do not say the work is complete until you have previewed and verified the actual synchronized content.

---