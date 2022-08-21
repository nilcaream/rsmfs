# Renoise Simple Midi File Support

## General idea

Renoise has built-in support for midi files importing. It works by creating a new midi instrument and adds new dedicated tracks in existing patterns.

This plugin will reuse existing instrument and will only update existing tracks with notes from the file.

### Release notes

#### Version 0.1

- reads midi files with `.xrmid` extension,
- prints notes and file information in Scripting Terminal.
- adds midi note events (note, volume, delay) to selected pattern track.
- adjusts number of pattern lines and visible note columns to match the midi file (optional).

#### Version 0.2

- added an option to skip note volume information (Options - Include velocity = false).
- fixed an issue with old notes cleanup when pattern was too short but had hidden notes in it (outside of pattern lines range).
- fixed an issue with tool crashing on trying to add notes outside of the Renoise max 512 pattern lines length.  
- skipped setting note volume for midi notes with maximum velocity (127).
- added note-off commands for first line of the track.

#### Version 0.3 (in progress)

- set volume and delay columns as visible.

## Capabilities and limitations

This is my first Renoise tool and first code in Lua. I am also new to the midi file format and midi events. The use case implemented here is very simple and might be limited to my specific need. It is not meant to be a replacement for the built-in midi files import nor a general purpose midi file to Renoise song converter.

It is not possible to override midi files import procedure so the midi files need to be renamed to have `.xrmid`   extension. E.g. `my-file.mid` needs to be renamed or copied to `my-file.xrmid` or to `my-file.mid.xrmid`.

Currently, it only interprets `note-on` and `note-off` midi events. All notes will use currently selected instrument. On import, currently select track will be cleared and extended if needed. All midi channels are read and all use the same instrument.

Due to pattern number of lines limitation only 512 notes are inserted (per track notes section). No new patterns are created. To overcome this decrease the Options - Resolution value though this might result in missing some of the notes.

It might not work well for multi-instrument or percussion midi files.

### Batch file copy / rename

To create a copy of all `.mid` files in current directory (`.`) and all nested directories execute the following command:

    find . -type f -name '*.mid' -print0 | xargs --null -I{} cp -v {} {}.xrmi

In a similar way, to rename all `.mid` files execute:

    find . -type f -name '*.mid' -print0 | xargs --null -I{} mv -v {} {}.xrmi

Newly created files will be suffixed with `.xrmi` extension. E.g. `my-file.mid` will be copied or renamed to `my-file.mid.xrmid`.

It works in GNU/Linux environment and should work on macOS/OSX. On Windows use Total Commander's built-in Multi-rename tool or anything else with a similar capability.

## Usage

Double click any `.xrmid` file in instruments file browser. Currently selected track in currently selected pattern will be replaced with the notes from the file.

## Feedback

This tool works fine for the collection of midi files I have. I haven't tested it enough on other midi files available on the internet, hence the pre-1.0 version. Any suggestions on other use cases that it should support is much appreciated. Example midi files for testing are welcomed.

## Credits

MIDI file import is done with MIDI.lua by **Peter J Billam**. It was released under MIT/X11 licence and has been included here without any changes in the code.

* https://pjb.com.au/comp/lua/MIDI.html
* http://luarocks.org/modules/peterbillam/midi/6.9-0

General plugin structure has been significantly inspired by [Additional File Format Import Support](https://www.renoise.com/tools/additional-file-format-import-support) code by **Martin Bealby**.

Thanks!

## Licence

This tool is available on [GitHub](https://github.com/nilcaream/rsmfs) and is released under Apache License Version 2.0.

## Download

https://github.com/nilcaream/rsmfs/releases