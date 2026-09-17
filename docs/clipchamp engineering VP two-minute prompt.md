# Clipchamp Prompt: Two-Minute Engineering VP Briefing

Create a new two-minute narrated video named `PDA - Engineering VP Briefing - 2 Minutes`. Use the six prepared slide PNGs and the exact narration in `C:\Users\pkoen\Source\PDA\docs\engineering VP two-minute video.md`. Do not reuse the employee-story narration or the longer mechanics script.

## Inputs and Output

- Slides: `%LOCALAPPDATA%/PDA/video-analysis/engineering-vp-briefing/slide-01.png` through `slide-06.png`.
- Editable source: `Policy Driven Agent - Engineering VP Briefing.pptx` in that same folder.
- Story, timings, slide copy, and six Voice-over blocks: the narrative document above.
- Output: a 16:9, 1920x1080 MP4, exactly 120 seconds, with narration and visible burned-in English subtitles.
- Save the export as `pda-engineering-vp-2min-captioned.mp4` in the same external folder. Do not overwrite an existing export without asking; use a numbered suffix instead.
- Preserve the editable Clipchamp project, slide media, and individual narration clips. Creating this final MP4 is explicitly part of this production prompt; do not stop at an unexported timeline.

## Scope and Safety

Use the already-open Clipchamp editor in the supplied external Edge session at CDP 9222. Do not launch another browser/profile, use the integrated browser, resize the shared browser, or close unrelated tabs. Create a new project; leave all existing videos unchanged.

Operate normal visible Clipchamp controls. Do not edit application code, policy, routes, credentials, or chats. Do not run the demo, models, stories, builds, or tests. This video uses prepared slides only; no screen recording is necessary. Keep all generated assets outside Git. Do not install tools or create helper scripts.

If sign-in, MFA, a secret, account consent, or an unavailable feature blocks work, stop and request one specific manual action. Never ask for a password or token through chat. Do not buy premium features, add stock assets, or substitute applications without approval.

## Preflight

1. Read the full narrative. Confirm exactly six Voice-over blocks and slide PNGs in numeric order.
2. Confirm each image is 1920x1080, legible, and has a clear bottom subtitle band. Do not import the PowerPoint file as if it were a rendered video.
3. Create the new 16:9 project. Confirm text to speech, captions, and 1080p export are available.
4. Choose Ava Multilingual, English (United States), default pitch and normal 1x pace, as used in the earlier demo. Ask for approval of a named alternative if unavailable.
5. Confirm the external output folder exists and does not contain a file that would be overwritten.

## Assemble the Story

Import the six PNGs and place them consecutively with no transitions, pans, zooms, cropping, or gaps. Set each image duration to exactly 20 seconds. Use fit, not fill, if Clipchamp presents that choice. Do not record a slideshow in a browser or PowerPoint window.

| Slide | Start | End | Message |
| --- | --- | --- | --- |
| 01 | 00:00 | 00:20 | Capability is not permission. |
| 02 | 00:20 | 00:40 | Separate execution from authority. |
| 03 | 00:40 | 01:00 | Context carries restrictions. |
| 04 | 01:00 | 01:20 | Recheck before releasing a result. |
| 05 | 01:20 | 01:40 | Evidence has explicit trust limits. |
| 06 | 01:40 | 02:00 | Validate one bounded production pilot. |

The recommendation on slide 06 is a proposed next step, not a claim of production deployment. Do not add metrics, testimonials, live-success badges, or capability claims.

## Narration

Generate one separate text-to-speech clip per Voice-over block, copying it exactly. Exclude headings, slide copy, timing fields, and notes. Keep the approved voice and settings identical across all six.

Save each generated item into project media, named by slide number. Record its actual duration. Place its start 0.3 seconds after the matching slide start: 00:00.300, 00:20.300, 00:40.300, 01:00.300, 01:20.300, and 01:40.300.

Each narration must finish by 19.5 seconds into its slide. If one exceeds 19.2 seconds, stop and request a shorter approved script for that segment. Do not accelerate the voice, cut words, overlap clips, or lengthen the video. Do not speak slide titles separately. Leave short silent holds intact. They provide reading time, not wasted footage.

Preview pronunciation of Policy Driven Agent, GitHub Copilot, SDK, and Node. Use supported pronunciation controls only when they preserve the wording. Report any pronunciation review that could not actually be heard.

No microphone audio, music, sound effects, decorative motion, or additional closing bumper.

## Subtitles Are Required

After narration and timing are final, open Captions and generate English (United States) autocaptions. Enable Show captions in video. Do not invoke silence removal or filler-word removal.

Proofread every caption against the six exact narration blocks. Correct proper nouns, policy terminology, omitted words, and punctuation through the transcript editor without moving narration or image clips. Speech recognition is a draft, not the text authority.

Use high-contrast subtitles at the bottom of the frame, within the reserved band. Keep them to one or two readable lines, away from slide content. Check the longest captions for wrapping and clipping. Do not cover diagram labels or trust limitations. Do not treat a downloaded SRT alone as an embedded-subtitle deliverable: captions must be visible in the final MP4 pixels.

## Verify, Export, and Deliver

1. Preview all 120 seconds at normal speed. Verify all six slides and exact narration blocks appear once, in order, with no missing or overlapping audio.
2. Check each slide change at 20-second boundaries and each voice start at its planned offset. Confirm every clip finishes before the next slide.
3. Check captions throughout, especially proper nouns, slide boundaries, and the last sentence. Preserve exact narration and the explicit demo limitations.
4. Save and reopen the project. Recheck all six images, audio durations/positions, visible-caption setting, and total runtime before export.
5. Export at 1080p as MP4, including narration and visible captions. Wait for actual render and download completion. Do not report success merely because export was clicked.
6. Verify the downloaded file exists, has nonzero size, is approximately 120 seconds within one frame, and contains an audio stream and 1920x1080 video. Use existing media tools only; no installation without approval.
7. Play the exported MP4, not just the project. Sample beginning, middle, end, and slide changes to confirm burned-in subtitles, audible narration, and correct framing. If audio cannot be heard with available tools, state that limitation rather than claiming an auditory check.
8. Report the exact MP4 path, duration, resolution, subtitle inclusion, voice settings, project name, and any unverified item. Leave the editable project intact.
