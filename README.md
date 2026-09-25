# 月入镜

Rokid AIUI 0.17 single-page experience. Open `pages/index/index` in AIUI Studio; the transparent page runs a 15-second Mid-Autumn performance in Chinese, Japanese, or Korean. Open `pages/smoke/index` for the first physical-device recording test. The current test package is `artifacts/moon-in-frame-v1.1.aix`.

## Flow

Select a language on the home screen. Start the glasses' AR recording, then tap Start or the focused touchpad. The sequence runs automatically: 3-second countdown, first line for 5 seconds, both lines for 5 seconds, greeting for 2 seconds. A single tap advances; a double tap returns home. Stop recording after the greeting and export on the phone.

The poem uses vertical character columns with timed reveals. A faint horizon, water reflection, and line of moonlight provide context without drawing a circular moon or covering the camera scene. The font stack starts with Kaiti-style Chinese fonts and falls back to serif where unavailable; confirm the actual typeface on the target glasses.

The app does not request camera or microphone access, start recording, analyze the scene or speech, or synthesize a video. Recording and export depend on the Rokid host. The middle 190px composition is intended to remain inside a centered 9:16 crop of a 480x352 AIUI canvas; confirm actual alignment with an exported file.

See [TESTING.md](TESTING.md) for device acceptance and fallback sample procedure.
