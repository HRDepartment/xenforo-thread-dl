# xenforo-thread-dl

XFTDL is a little tool that downloads all the images in a Xenforo forum thread. It can be gracefully stopped at any time and will resume when you restart it.

## Usage

`./xenforo-thread-dl [url]`

Inside a folder with a .manifest.json, you can run `xenforo-thread-dl` without needing to specify the URL again. It will continue where it left off.

## Development

running a debug build
`$ shards install`
`$ crystal run ./cli.cr -- [url]`

building an executable
`$ crystal build --release cli.cr -o xenforo-thread-dl`

You might need to install `cmake` on your system in order to install the shards.

## License

Copyright (C) 2021 Tycho Kaster

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
[GNU General Public License](COPYING) for more details.
