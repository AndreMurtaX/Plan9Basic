# Plan9Basic Media Player Library Guide

## Introduction

The Media Player Library provides comprehensive audio and video playback capabilities for Plan9Basic applets. It enables you to create media-rich applications that can play various audio and video formats across all supported platforms.

## Overview

The library provides two main components:

1. **Media Player** (`media_player#`): A non-visual component ideal for playing audio files in the background.

2. **Media Control** (`media_control#`): A visual component that displays video content within a form.

Both components share similar playback controls but serve different purposes. Use the Media Player for audio-only applications or background music, and the Media Control when you need to display video content.

---

## Platform Support

The Media Player Library works on all platforms supported by Plan9Basic. Since Plan9Basic applets run natively on each platform, media playback uses the operating system's built-in media capabilities. This means that supported formats vary depending on where your applet runs:

| Platform | Best Supported Formats |
|----------|------------------------|
| Windows | **WMV**, WMA, MP3, WAV, AVI |
| macOS | **MOV**, M4V, MP4 (H.264), AAC, MP3 |
| Linux | Depends on system codecs installed |
| Android | **MP4** (H.264), 3GP, WebM, AAC, MP3 |
| iOS | **MOV**, M4V, MP4 (H.264), AAC, MP3 |

### Understanding Format Compatibility

Plan9Basic delegates media decoding to the host operating system's native media services. This approach provides the best performance and integration, but it means your applet inherits the format limitations of each platform:

- **Windows** works best with Microsoft formats (WMV, WMA). While MP4 files may work, compatibility depends on how the video was encoded. For reliable playback on Windows, use WMV format.

- **macOS and iOS** prefer Apple formats (MOV, M4V) and standard MP4 files encoded with H.264 video and AAC audio.

- **Android** works best with MP4 files using H.264/AAC codecs, which is the standard for mobile video.

- **Linux** support varies based on which multimedia codecs are installed on the user's system.

### Local Files vs. URLs

- **Audio files** can be loaded from local files or URLs (http:// and https://).
- **Video files** should use local files. Video URL streaming has not been tested due to server restrictions, so local files are recommended for reliability.

### Recommendations for Cross-Platform Applets

If your applet needs to run on multiple platforms, consider one of these strategies:

1. **Provide multiple format versions** of your media files and load the appropriate one based on the detected platform.

2. **Use MP3 for audio** - it works reliably on all platforms and can be streamed from URLs.

3. **For video**, test your specific files on each target platform, or provide platform-specific versions.

---

## Media States

Both the Media Player and Media Control use the same state values:

| Value | State | Description |
|-------|-------|-------------|
| 0 | Unavailable | No media loaded or an error occurred |
| 1 | Stopped | Media is loaded but not playing |
| 2 | Playing | Media is currently playing |
| 3 | Paused | Playback is paused (platform-dependent) |

---

## Part 1: Media Player (Audio)

The Media Player is a non-visual component designed primarily for audio playback. It works in the background without requiring a visible control on the screen.

### Creating a Media Player

```basic
let player# = media_player#()
```

This creates a new media player instance and returns a pointer to it.

### Loading and Playing Audio

```basic
' Create the player
let player# = media_player#()

' Load an audio file from the web
media_load#(player#, "https://www.w3schools.com/html/horse.mp3")

' Start playback
media_play(player#)
```

### Complete Audio Example

```basic
' Simple MP3 Player
' ==================

let player# = Pointer#(0)

' Create the media player
player# = media_player#()

' Load the audio file from URL
media_load#(player#, "https://www.w3schools.com/html/horse.mp3")

' Set volume to 50%
media_volume#(player#, 0.5)

' Set up callbacks
media_onend#(player#, "OnMusicEnd")
media_onstatechanged#(player#, "OnStateChanged")

' Start playing
media_play(player#)

println "Music is playing..."

function OnMusicEnd(sender#)
    println "Music playback completed!"
endfunction

function OnStateChanged(sender#, state)
    if state = 0 then println "State: Unavailable"
    if state = 1 then println "State: Stopped"
    if state = 2 then println "State: Playing"
    if state = 3 then println "State: Paused"
endfunction
```

### Media Player Functions Reference

#### Creation and Lifecycle

| Function | Description |
|----------|-------------|
| `media_player#()` | Creates a new media player, returns pointer |
| `media_free(player#)` | Frees a media player |

#### Loading and Playback

| Function | Description |
|----------|-------------|
| `media_load#(player#, filename$)` | Loads a media file |
| `media_play(player#)` | Starts playback |
| `media_pause(player#)` | Pauses playback |
| `media_stop(player#)` | Stops playback and resets position to beginning |
| `media_clear(player#)` | Clears the loaded media |

#### Properties

| Function | Description |
|----------|-------------|
| `media_state(player#)` | Returns current state (0-3) |
| `media_volume#(player#, vol)` | Sets volume (0.0 to 1.0) |
| `media_volume(player#)` | Gets current volume |
| `media_duration(player#)` | Gets total duration in seconds |
| `media_position#(player#, secs)` | Sets playback position in seconds |
| `media_position(player#)` | Gets current position in seconds |
| `media_filename$(player#)` | Gets the loaded filename |
| `media_isplaying(player#)` | Returns 1 if playing, 0 otherwise |

#### Events

| Function | Description |
|----------|-------------|
| `media_onend#(player#, "callback")` | Sets callback for when playback ends |
| `media_onstatechanged#(player#, "callback")` | Sets callback for state changes |

---

## Part 2: Media Control (Video)

The Media Control is a visual component that can display video content. It must be placed on a form and supports both audio and video playback.

### Creating a Media Control

```basic
let frm# = form#("Video Player", 800, 600)
let video# = media_control#(frm#, 10, 10, 640, 480)
```

Parameters for `media_control#`:
- `parent#`: The form or container to place the control in
- `x`: X position
- `y`: Y position  
- `width`: Width of the control
- `height`: Height of the control

### Loading and Playing Video

```basic
' Load a video file
' Use platform-appropriate formats for best results:
' Windows: .wmv works best
' macOS/iOS: .mov or .mp4 (H.264)
' Android: .mp4 (H.264)
media_ctrl_load#(video#, "movie.wmv")

' Start playback
media_ctrl_play(video#)
```

> **Tip:** For cross-platform compatibility, consider providing videos in multiple formats and loading the appropriate one based on the platform.

### Complete Video Player Example

```basic
' Simple Video Player
' ====================

let frm# = Pointer#(0)
let video# = Pointer#(0)
let btnPlay# = Pointer#(0)
let btnPause# = Pointer#(0)
let btnStop# = Pointer#(0)
let lblStatus# = Pointer#(0)
let trkVolume# = Pointer#(0)
let trkPosition# = Pointer#(0)

' Create the main form
frm# = form#("Plan9Basic Video Player", 800, 650)
form_position#(frm#, 4)  ' Center on screen

' Create the video control
video# = media_control#(frm#, 10, 10, 780, 480)

' Create playback controls
btnPlay# = button#(frm#, 10, 500, 80, 30)
button_text#(btnPlay#, "Play")
button_onclick#(btnPlay#, "OnPlay")

btnPause# = button#(frm#, 100, 500, 80, 30)
button_text#(btnPause#, "Pause")
button_onclick#(btnPause#, "OnPause")

btnStop# = button#(frm#, 190, 500, 80, 30)
button_text#(btnStop#, "Stop")
button_onclick#(btnStop#, "OnStop")

' Volume control
let lblVol# = label#(frm#, "...", 300, 505, 60, 20)
label_text#(lblVol#, "Volume:")

trkVolume# = trackbar#(frm#, 360, 500, 150, 30)
trackbar_max#(trkVolume#, 100)
trackbar_value#(trkVolume#, 80)
trackbar_onchange#(trkVolume#, "OnVolumeChange")

' Status label
lblStatus# = label#(frm#, "...", 10, 540, 780, 25)
label_text#(lblStatus#, "Ready")

' Position slider
trkPosition# = trackbar#(frm#, 10, 570, 780, 30)
trackbar_max#(trkPosition#, 1000)
trackbar_onchange#(trkPosition#, "OnPositionChange")

' Set up video callbacks
media_ctrl_onend#(video#, "OnVideoEnd")
media_ctrl_onstatechanged#(video#, "OnVideoStateChanged")

' Load video file
media_ctrl_load#(video#, "file_example_WMV_480_1_2MB.wmv")
media_ctrl_volume#(video#, 0.8)

' Create update timer for position display
let tmr# = timer#()
timer_interval#(tmr#, 250)
timer_ontimer#(tmr#, "OnUpdatePosition")
timer_enabled#(tmr#, 1)

form_show(frm#)
end

' Playback control callbacks
function OnPlay(sender#)
    media_ctrl_play(video#)
endfunction

function OnPause(sender#)
    media_ctrl_pause(video#)
endfunction

function OnStop(sender#)
    media_ctrl_stop(video#)
    trackbar_value#(trkPosition#, 0)
endfunction

' Volume change callback
function OnVolumeChange(sender#) local vol
    let vol = trackbar_value(trkVolume#) / 100
    media_ctrl_volume#(video#, vol)
endfunction

' Position seek callback
function OnPositionChange(sender#) local duration, pos, newTime
    let duration = media_ctrl_duration(video#)
    let pos = trackbar_value(trkPosition#)
    let newTime = (pos / 1000) * duration
    media_ctrl_position#(video#, newTime)
endfunction

' Update position display
function OnUpdatePosition(sender#) local pos, dur, pct, posMin, posSec, durMin, durSec, status$
    let pos = media_ctrl_position(video#)
    let dur = media_ctrl_duration(video#)
    
    if dur > 0 then
        let pct = (pos / dur) * 1000
        trackbar_value#(trkPosition#, int(pct))
        
        let posMin = int(pos / 60)
        let posSec = int(pos) mod 60
        let durMin = int(dur / 60)
        let durSec = int(dur) mod 60
        
        let status$ = "Position: " + str$(posMin) + ":" + right$("0" + str$(posSec), 2)
        status$ = status$ + " / " + str$(durMin) + ":" + right$("0" + str$(durSec), 2)
        label_text#(lblStatus#, status$)
    endif
endfunction

' Media event callbacks
function OnVideoEnd(sender#)
    label_text#(lblStatus#, "Playback completed")
    trackbar_value#(trkPosition#, 0)
endfunction

function OnVideoStateChanged(sender#, state)
    if state = 0 then label_text#(lblStatus#, "No video loaded")
    if state = 1 then label_text#(lblStatus#, "Stopped")
    if state = 2 then label_text#(lblStatus#, "Playing")
    if state = 3 then label_text#(lblStatus#, "Paused")
endfunction
```

### Media Control Functions Reference

#### Creation and Lifecycle

| Function | Description |
|----------|-------------|
| `media_control#(parent#, x, y, w, h)` | Creates a media control |
| `media_ctrl_free(ctrl#)` | Frees a media control |

#### Loading and Playback

| Function | Description |
|----------|-------------|
| `media_ctrl_load#(ctrl#, filename$)` | Loads a media file |
| `media_ctrl_play(ctrl#)` | Starts playback |
| `media_ctrl_pause(ctrl#)` | Pauses playback |
| `media_ctrl_stop(ctrl#)` | Stops and resets position |
| `media_ctrl_clear(ctrl#)` | Clears loaded media |

#### Playback Properties

| Function | Description |
|----------|-------------|
| `media_ctrl_state(ctrl#)` | Returns current state (0-3) |
| `media_ctrl_volume#(ctrl#, vol)` | Sets volume (0.0 to 1.0) |
| `media_ctrl_volume(ctrl#)` | Gets current volume |
| `media_ctrl_duration(ctrl#)` | Gets total duration in seconds |
| `media_ctrl_position#(ctrl#, secs)` | Sets position in seconds |
| `media_ctrl_position(ctrl#)` | Gets current position in seconds |
| `media_ctrl_filename$(ctrl#)` | Gets loaded filename |
| `media_ctrl_isplaying(ctrl#)` | Returns 1 if playing |
| `media_ctrl_hasplayer(ctrl#)` | Returns 1 if an internal player is present |

#### Visual Properties

| Function | Description |
|----------|-------------|
| `media_ctrl_pos#(ctrl#, x, y)` | Sets X and Y position |
| `media_ctrl_size#(ctrl#, w, h)` | Sets width and height |
| `media_ctrl_bounds#(ctrl#, x, y, w, h)` | Sets x, y, width, height |
| `media_ctrl_x(ctrl#)` | Gets X position |
| `media_ctrl_y(ctrl#)` | Gets Y position |
| `media_ctrl_width(ctrl#)` | Gets width |
| `media_ctrl_height(ctrl#)` | Gets height |
| `media_ctrl_visible#(ctrl#, flag)` | Sets visibility (0 or 1) |
| `media_ctrl_visible(ctrl#)` | Gets visibility |
| `media_ctrl_enabled#(ctrl#, flag)` | Sets enabled state |
| `media_ctrl_enabled(ctrl#)` | Gets enabled state |
| `media_ctrl_align#(ctrl#, align)` | Sets alignment |
| `media_ctrl_align(ctrl#)` | Gets alignment |

#### Alignment Constants

| Value | Alignment |
|-------|-----------|
| 0 | None |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fills parent) |
| 11 | Center |

#### Media Events

| Function | Description |
|----------|-------------|
| `media_ctrl_onend#(ctrl#, "callback")` | Callback when playback ends |
| `media_ctrl_onstatechanged#(ctrl#, "callback")` | Callback when state changes |

#### Mouse Events

| Function | Callback Signature |
|----------|-------------------|
| `media_ctrl_onclick#(ctrl#, "name")` | `function name(sender#)` |
| `media_ctrl_ondblclick#(ctrl#, "name")` | `function name(sender#)` |
| `media_ctrl_onmousedown#(ctrl#, "name")` | `function name(sender#, button, x, y)` |
| `media_ctrl_onmouseup#(ctrl#, "name")` | `function name(sender#, button, x, y)` |
| `media_ctrl_onmousemove#(ctrl#, "name")` | `function name(sender#, x, y)` |
| `media_ctrl_onresize#(ctrl#, "name")` | `function name(sender#)` |

---

## Part 3: Error Handling

The library provides error handling functions to help diagnose issues:

### Error Functions

| Function | Description |
|----------|-------------|
| `media_error()` | Returns the last error code (0 = no error) |
| `media_errormsg$()` | Returns the last error message |
| `media_strerror$(code)` | Returns error description for a code |
| `media_clearerror()` | Clears the error state |

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_INVALID_PLAYER | Invalid media player pointer |
| 2 | ERR_INVALID_CONTROL | Invalid media control pointer |
| 3 | ERR_INVALID_PARENT | Invalid parent for control |
| 4 | ERR_INVALID_VALUE | Invalid parameter value |
| 5 | ERR_CREATE_FAILED | Failed to create component |
| 6 | ERR_LOAD_FAILED | Failed to load media file |
| 7 | ERR_FILE_NOT_FOUND | Media file not found |
| 8 | ERR_NOT_LOADED | No media is loaded |
| 9 | ERR_INVALID_CALLBACK | Invalid callback function |

### Example: Using Error Functions

The error functions are available for diagnosing issues, but note that some operations may report errors even when they succeed. The most reliable way to check if media loaded correctly is to start playback and monitor the state:

```basic
let player# = media_player#()

media_load#(player#, "https://www.w3schools.com/html/horse.mp3")
media_onstatechanged#(player#, "OnState")
media_play(player#)

function OnState(sender#, state)
    if state = 2 then
        println "Playing successfully"
    endif
endfunction
```

---

## Part 4: Event Callbacks

Both Media Player and Media Control support event callbacks that let your applet respond to playback events.

### OnEnd Event

Fired when media playback reaches the end.

**Signature:**
```basic
function CallbackName(sender#)
    ' Your code here
endfunction
```

**Example:**
```basic
media_onend#(player#, "OnPlaybackEnd")

function OnPlaybackEnd(sender#)
    println "Playback finished!"
    ' Optional: Loop playback
    media_position#(sender#, 0)
    media_play(sender#)
endfunction
```

### OnStateChanged Event

Fired when the media state changes (playing, stopped, etc.).

**Signature:**
```basic
function CallbackName(sender#, state)
    ' state: 0=unavailable, 1=stopped, 2=playing, 3=paused
endfunction
```

**Example:**
```basic
media_onstatechanged#(player#, "OnMediaState")

function OnMediaState(sender#, state)
    if state = 2 then
        println "Now playing..."
    endif
    if state = 1 then
        println "Playback stopped"
    endif
endfunction
```

---

## Part 5: Practical Examples

### Background Music Player with GUI

```basic
' Background Music Player with Playlist
' ======================================

dim playlist$(5)
let currentTrack = 0
let player# = Pointer#(0)
let frm# = Pointer#(0)
let lblTrack# = Pointer#(0)

' Initialize playlist with local files
playlist$(0) = "track1.mp3"
playlist$(1) = "track2.mp3"
playlist$(2) = "track3.mp3"
playlist$(3) = "track4.mp3"
playlist$(4) = "track5.mp3"

' Create simple UI
frm# = form#("Music Player", 400, 150)
form_position#(frm#, 4)

lblTrack# = label#(frm#, "...", 10, 10, 380, 30)
label_text#(lblTrack#, "Ready")

let btnPrev# = button#(frm#, 10, 50, 80, 30)
button_text#(btnPrev#, "Previous")
button_onclick#(btnPrev#, "OnPrev")

let btnPlay# = button#(frm#, 100, 50, 80, 30)
button_text#(btnPlay#, "Play")
button_onclick#(btnPlay#, "OnPlay")

let btnNext# = button#(frm#, 190, 50, 80, 30)
button_text#(btnNext#, "Next")
button_onclick#(btnNext#, "OnNext")

let btnStop# = button#(frm#, 280, 50, 80, 30)
button_text#(btnStop#, "Stop")
button_onclick#(btnStop#, "OnStop")

' Create player
player# = media_player#()
media_volume#(player#, 0.7)
media_onend#(player#, "PlayNextTrack")

form_show(frm#)

sub UpdateDisplay()
    label_text#(lblTrack#, "Track " + str$(currentTrack + 1) + ": " + playlist$(currentTrack))
endsub

function OnPlay(sender#)
    media_load#(player#, playlist$(currentTrack))
    media_play(player#)
    UpdateDisplay()
endfunction

function OnStop(sender#)
    media_stop(player#)
endfunction

function OnNext(sender#)
    currentTrack = currentTrack + 1
    if currentTrack >= 5 then currentTrack = 0
    media_load#(player#, playlist$(currentTrack))
    media_play(player#)
    UpdateDisplay()
endfunction

function OnPrev(sender#)
    currentTrack = currentTrack - 1
    if currentTrack < 0 then currentTrack = 4
    media_load#(player#, playlist$(currentTrack))
    media_play(player#)
    UpdateDisplay()
endfunction

function PlayNextTrack(sender#)
    currentTrack = currentTrack + 1
    if currentTrack >= 5 then currentTrack = 0
    media_load#(player#, playlist$(currentTrack))
    media_play(player#)
    UpdateDisplay()
endfunction
```

### Audio Progress Display with GUI

```basic
' Audio Progress Display
' ======================

let player# = Pointer#(0)
let frm# = Pointer#(0)
let lblProgress# = Pointer#(0)
let btnStop# = Pointer#(0)

' Create simple progress window
frm# = form#("Now Playing", 400, 100)
form_position#(frm#, 4)

lblProgress# = label#(frm#, "...", 10, 10, 380, 30)
label_text#(lblProgress#, "Loading...")

btnStop# = button#(frm#, 160, 50, 80, 30)
button_text#(btnStop#, "Stop")
button_onclick#(btnStop#, "OnStopClick")

' Create player and timer
player# = media_player#()
let tmr# = timer#()

media_load#(player#, "https://www.w3schools.com/html/horse.mp3")
media_onend#(player#, "OnSongEnd")
media_play(player#)

timer_interval#(tmr#, 500)
timer_ontimer#(tmr#, "UpdateProgress")
timer_enabled#(tmr#, 1)

form_show(frm#)

function UpdateProgress(sender#) local pos, dur, pct, bar$, i
    let pos = media_position(player#)
    let dur = media_duration(player#)
    let pct = 0
    
    if dur > 0 then pct = int((pos / dur) * 100)
    
    let bar$ = "["
    for i = 1 to 20
        if i <= pct / 5 then
            bar$ = bar$ + "="
        else
            bar$ = bar$ + " "
        endif
    next
    bar$ = bar$ + "] " + str$(pct) + "%"
    
    label_text#(lblProgress#, bar$)
endfunction

function OnStopClick(sender#)
    timer_enabled#(tmr#, 0)
    media_stop(player#)
    form_close(frm#)
endfunction

function OnSongEnd(sender#)
    timer_enabled#(tmr#, 0)
    label_text#(lblProgress#, "Playback complete!")
endfunction
```

### Fullscreen Video Player

```basic
' Fullscreen Video Player
' =======================

let frm# = form#("", 1024, 768)
form_windowstate#(frm#, 2)  ' Maximize
form_borderstyle#(frm#, 0)  ' No border

let video# = media_control#(frm#, 0, 0, 100, 100)
media_ctrl_align#(video#, 9)  ' Client - fills entire form

media_ctrl_load#(video#, "movie.wmv")
media_ctrl_ondblclick#(video#, "OnDoubleClick")
media_ctrl_onend#(video#, "OnVideoEnd")

media_ctrl_play(video#)
form_show(frm#)
end

function OnDoubleClick(sender#)
    ' Toggle fullscreen
    if form_windowstate(frm#) = 2 then
        form_windowstate#(frm#, 0)  ' Normal
        form_borderstyle#(frm#, 1)
    else
        form_windowstate#(frm#, 2)  ' Maximized
        form_borderstyle#(frm#, 0)
    endif
endfunction

function OnVideoEnd(sender#)
    form_close(frm#)
endfunction
```

---

## Part 6: Tips and Best Practices

### 1. Always Initialize Pointers

```basic
let player# = Pointer#(0)  ' Initialize before use
player# = media_player#()
```

### 2. Use State Change Callbacks

Monitor playback state to know when media is playing:

```basic
media_onstatechanged#(player#, "OnState")
media_load#(player#, filename$)
media_play(player#)

function OnState(sender#, state)
    if state = 2 then println "Now playing"
    if state = 1 then println "Stopped"
endfunction
```

### 3. Clean Up Resources

```basic
' When done with the player
media_stop(player#)
media_free(player#)
```

### 4. Use Appropriate Volume Levels

```basic
' Volume is 0.0 to 1.0
' Start at a reasonable level
media_volume#(player#, 0.7)  ' 70% volume
```

### 5. Handle Playback End

Always set up an `onend` callback if you need to know when playback finishes:

```basic
media_onend#(player#, "OnEnd")

function OnEnd(sender#)
    ' Clean up or play next track
endfunction
```

### 6. Use Timers for UI Updates

Don't update UI in a tight loop. Use a timer:

```basic
let tmr# = timer#()
timer_interval#(tmr#, 250)  ' Update 4 times per second
timer_ontimer#(tmr#, "UpdateUI")
timer_enabled#(tmr#, 1)
```

### 7. Platform Considerations

- Test your applet on target platforms, as codec support varies
- Use common formats (MP3, MP4) for best compatibility
- Consider providing multiple format options for critical media

---

## Quick Reference Card

### Media Player (Audio)

```basic
' Create
let player# = media_player#()

' Load and play
media_load#(player#, "https://www.w3schools.com/html/horse.mp3")
media_play(player#)

' Control
media_pause(player#)
media_stop(player#)

' Properties
media_volume#(player#, 0.8)          ' Set volume
let vol = media_volume(player#)       ' Get volume
let pos = media_position(player#)     ' Get position
media_position#(player#, 30.5)        ' Seek to 30.5 seconds
let dur = media_duration(player#)     ' Get duration
let state = media_state(player#)      ' Get state

' Events
media_onend#(player#, "OnEnd")
media_onstatechanged#(player#, "OnState")

' Cleanup
media_free(player#)
```

### Media Control (Video)

```basic
' Create
let video# = media_control#(frm#, x, y, w, h)

' Load and play
media_ctrl_load#(video#, "video.wmv")
media_ctrl_play(video#)

' Control
media_ctrl_pause(video#)
media_ctrl_stop(video#)

' Properties
media_ctrl_volume#(video#, 0.8)
media_ctrl_position#(video#, 30.5)
media_ctrl_visible#(video#, 1)
media_ctrl_align#(video#, 9)

' Events
media_ctrl_onend#(video#, "OnEnd")
media_ctrl_onclick#(video#, "OnClick")

' Cleanup
media_ctrl_free(video#)
```

---

## Troubleshooting

### "Unsupported media file" Error

This error means the operating system cannot decode the file format. Each platform has different built-in codec support. Solutions:

1. **On Windows:** Convert your video to WMV format for best compatibility. While MP4 may work, results depend on how the video was encoded.

2. **On macOS/iOS:** Use MOV or M4V format, or MP4 with standard H.264 video and AAC audio codecs.

3. **On Android:** Use MP4 with H.264/AAC codecs, or 3GP format.

4. **On Linux:** Install additional multimedia codecs for your distribution. The available formats depend on your system's multimedia configuration.

### Video Loads But Doesn't Display

- Ensure the media control is properly parented to a visible form
- Check that the control has non-zero width and height
- Verify the form is shown before loading media

### State Remains 0 After Loading

- The file may have loaded successfully but the state only changes to 1 (Stopped) or 2 (Playing) after calling play
- Some platforms report state changes asynchronously - use `media_ctrl_onstatechanged#` to track state

### No Audio on Video Playback

- Check volume: `media_ctrl_volume#(video#, 1.0)`
- Verify the video file has an audio track
- On some platforms, system volume settings may affect playback

### URL Streaming Not Working (Audio)

Audio files support URL streaming, but if it's not working:

- Verify the URL is accessible (try in a browser first)
- HTTPS URLs may require proper SSL configuration on some platforms
- Some servers may block non-browser requests (Cloudflare protection, etc.)
- For video files, use local files as URL streaming has not been reliably tested

---

## Conclusion

The Media Player Library provides a powerful yet simple way to add audio and video capabilities to your Plan9Basic applets. Whether you're creating a simple music player, a video presentation, or adding background music to a game, this library has the functionality you need.

For the latest updates and more examples, consult the Plan9Basic documentation.
