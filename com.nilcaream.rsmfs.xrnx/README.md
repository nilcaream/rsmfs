# Renoise Simple Midi File Support

## General idea

Renoise has built-in support for midi files importing. It works by creating a new midi instrument and adds new dedicated tracks in existing patterns. 

This plugin will reuse existing instrument and will only update existing tracks with notes from the file.

### Current implementation

- reads midi files with `.xrmid` extension,
- prints notes and file information in Scripting Terminal.
- converts midi note events to Renoise patterns (print only).

## Capabilities and limitations

This is my first Renoise tool and first code in Lua. I am also new to the midi file format and midi events. The use case implemented here is very simple and might be limited to my specific need. It is not meant to be a replacement for the built-in midi files import nor a general purpose midi file to Renoise song converter.

It is not possible to override midi files import procedure so the midi files need to be renamed to have `.xrmid`   extension. E.g. `my-file.mid` needs to be renamed to `my-file.xrmid`.

Currently, it only interprets `note-on` and `note-off` midi events. All notes will use currently selected instrument. On import, currently select track will be cleared and extended if needed. Only midi chanel 1 will be read.

It will not work well for multi-instrument or percussion midi files.

## Credits

MIDI file import is done with [MIDI.lua](MIDI.lua) by **Peter J Billam**. It was released under MIT/X11 licence and has been included here without any changes in the code.

* https://pjb.com.au/comp/lua/MIDI.html
* http://luarocks.org/modules/peterbillam/midi/6.9-0

General plugin stucture has been significantly inspired by [Additional File Format Import Support](https://www.renoise.com/tools/additional-file-format-import-support) code by **Martin Bealby**.

Thanks!

## Licence

This tool is available on [GitHub](https://github.com/nilcaream/rsmfs) and is released under Apache License Version 2.0.