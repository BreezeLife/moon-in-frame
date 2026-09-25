# Device acceptance

No physical glasses or real nighttime footage is available in this workspace. A real-scene sample cannot be marked complete from a browser preview or an AIX package.

1. Import the project in AIUI Studio and open `pages/smoke/index` on Rokid Glasses.
2. Point the glasses at a real night scene. Start AR recording, read “中秋快乐” aloud, stop after five seconds, and export to the phone.
3. Inspect the exported file for the custom green greeting, the real scene, recorded voice, and a usable centered 9:16 crop. Record device model, firmware, AIUI runtime, recording route, and exported dimensions.
4. If the custom page appears, open `pages/index/index`. Repeat in Chinese, Japanese, and Korean, checking line breaks, timer stages, single and double tap, and text inside the exported safe area.
5. Capture one 15-second 9:16 real-night sample containing both poem lines and the user's voice. Store the original and the exported version outside Git unless rights and consent permit publishing.

If the native recording omits AIUI, keep the original glasses video and voice. Composite the green moon and poem on the phone's video editor with the same 3+5+5+2-second timeline. Save that sample separately and log the native recording issue with the device and firmware details.
