# Renoise Simple Midi File Support

## General idea

Renoise has built-in support for midi files importing. It works by creating a new midi instrument and adds new dedicated tracks in existing patterns.

This plugin will reuse existing instrument and will only update currently selected track with notes from the file.

### Release notes

#### Version 0.1

- reads midi files with `.xrmid` extension,
- print notes and file information in Scripting Terminal.
- adds midi note events (note, volume, delay) to selected pattern track.
- adjusts number of pattern lines and visible note columns to match the midi file (optional).

#### Version 0.2

- added an option to skip note volume information (`Tools - Renoise Simple Midi File Support - Include velocity` = `false`).
- fixed an issue with old notes cleanup when pattern was too short but had hidden notes in it (outside of pattern lines range).
- fixed an issue with tool crashing on trying to add notes outside the Renoise max 512 pattern lines length.
- skipped setting note volume for midi notes with maximum velocity (127).
- added note-off commands for first line of the track.

#### Version 0.3

- added a file browser that accepts both `.mid` and `.xrmid` files in `Tools - Renoise Simple Midi File Support - Select file`.
- fixed an issue with tool crashing on trying to add more than 12 note columns.
- set volume and delay columns as always visible.

#### Version 0.4

- redesigned tools options flow for file loading and removed `Select file` button.
- added submenus to `Tools - Renoise Simple Midi File Support`
    - `Options` - opens tool options.
    - `Import midi file` - opens file browser.
- added `Import midi file` context menu for pattern track (right click).

#### Version 0.5

- changed file browser to show all files instead of `.mid` and `.xrmid` to a fix an issue on Windows (thanks, Roppenzo).
- improved the workflow for file browser to first select the file and then show Options dialog if `Options - Show for each file` is enabled.
- added an option to skip note delay information (`Options - Include delay` = `false`).
- added an option to skip note-off (OFF) events (`Options - Include note-off` = `false`).
- added an option to correct note start or end position if delay is higher than FD (disabled by default) (`Options - Correct positions` = `true`).
- added tooltips for options.
- reviewed, corrected and updated this readme.

#### Version 0.6

- added an option to insert notes at cursor position (`Options - Insert at cursor position` = `true`; thanks, Neuro... No Neuro).

#### Version 0.7

- fixed a note off placement on insert at cursor position.
- fixed an issue with missing note delays on insert at cursor position.
- added an option to maintain existing track notes instead of clearing them by default (`Options - Clear existing notes` = `false`).
- fixed an issue with invalid number of pattern lines needed to fit all notes.

## Capabilities and limitations

This is my first Renoise tool and first code in Lua. I am also new to the midi file format and midi events. The use case implemented here is very simple and might be limited a single, specific scenario. It is not meant to be a replacement for the built-in midi files import nor a general purpose midi file to Renoise song converter.

It is not possible to override midi files import procedure (double-click on a `.mid` file) in the standard file browser (bottom-right panel). To use this file browser, midi files need to be renamed to have `.xrmid` extension. E.g. `my-file.mid` needs to be renamed or copied to `my-file.xrmid` or to `my-file.mid.xrmid`.

To load `.mid` file directly go to `Tools - Renoise Simple Midi File Support - Import midi file` or right-click on a track and select `Import midi file`.

Currently, the tool only interprets `note-on` and `note-off` midi events. All notes will use currently selected instrument. On midi file load, currently selected track will be cleared and extended. This is configurable in `Options`. All midi channels are read and all use the same instrument.

Due to pattern number of lines limitation, only 512 notes are inserted (per track notes section). No new patterns are created. To overcome this, decrease `Options - Resolution` value though this might result in missing some notes.

For percussion midi files consider enabling `Options - Correct positions` or disabling `Options - Include note-off`.

To work with short midi files like single chords or chord progressions consider enabling `Options - Insert at cursor position` and disabling `Options - Include note off` and `Options - Clear existing notes`. Experiment with other options to find the best solution.

### Batch file copy / rename

To create a copy of all `.mid` files in current directory (`.`) and all nested directories execute the following command:

    find . -type f -name '*.mid' -print0 | xargs --null -I{} cp -v {} {}.xrmid

In a similar way, to rename all `.mid` files execute:

    find . -type f -name '*.mid' -print0 | xargs --null -I{} mv -v {} {}.xrmid

Newly created files will be suffixed with `.xrmid` extension. E.g. `my-file.mid` will be copied or renamed to `my-file.mid.xrmid`.

It works in GNU/Linux environment and should work on macOS/OSX. On Windows use Total Commander's built-in Multi-rename tool or anything else with a similar capability.

## Usage

Go to `Tools - Renoise Simple Midi File Support - Import midi file` to load `.mid` or `.xrmid` file. Alternatively double-click a `.xrmid` file in instruments file browser. Currently selected track in currently selected pattern will be replaced with the notes from the file.

Midi files can also be loaded by right-clicking on a pattern track and selecting `Import midi file`. It will work the same as clicking the `Import midi file` in `Tools - Renoise Simple Midi File Support` menu described above.

## Feedback

This tool is currently under development (pre-1.0 version). Suggestions on other use cases that it should support is much appreciated. Example midi files for testing are welcomed.

## Credits

MIDI file import is done with MIDI.lua by **Peter J Billam**. It was released under MIT/X11 licence and has been included here without any changes in the code.

* https://pjb.com.au/comp/lua/MIDI.html
* http://luarocks.org/modules/peterbillam/midi/6.9-0

General plugin structure has been significantly inspired by [Additional File Format Import Support](https://www.renoise.com/tools/additional-file-format-import-support) code by **Martin Bealby**.

Additional testing, design ideas and feedback were provided by [Roppenzo](https://forum.renoise.com/u/Roppenzo).

Insert at cursor idea by [Neuro... No Neuro](https://ab-nnn.bandcamp.com).

Thanks!

## Licence

This tool is available on [GitHub](https://github.com/nilcaream/rsmfs) and is released under Apache License Version 2.0. Feel free to reuse, fork or contribute!

## Download

https://github.com/nilcaream/rsmfs/releases
