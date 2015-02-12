## ffcast

[ffcast](https://github.com/chilicuil/ffcast/) helps the user interactively select a screen region and hands over the geometry to an external command, such as ffmpeg, for screen recording. This is a custom version for POSIX sh shells, refer to [lolilolicon](https://github.com/lolilolicon/FFcast2) for the original one.

<p align="center">
<img src="http://javier.io/assets/img/ffcast.gif" alt="ffcast"/>
</p>

## Quick start

### On Ubuntu (only LTS releases)

1. Set up the minos archive:

   ```
   $ sudo add-apt-repository ppa:minos-archive/main
   ```
2. Install:

   ```
   $ sudo apt-get update && sudo apt-get install ffcast
   ```
   
3. Enjoy ☺!

### On other Linux distributions + BSD

1. Type `make`

1. Type `make install`

### Requirements

* POSIX compatible shell 
* avconv || ffmpeg || byzanz-record || recordmydesktop
* xdpyinfo - for the -x option
* xrectsel - for the -s option (included)
* xwininfo - for the -w and -f options
* xrectsel
 * libX11

## Usage

   ```
   ffcast [-l|-s|-w|-f|-k|-x <n|list>|-m <n>|-p|-q|-v|-h] [command [args] [--] [args]]"
   ```

### Examples

   ```
   $ ffcast -h    #show help
   $ ffcast       #record fullscreen and save it to $HOME
   $ ffcast -s    #record a region selected with mouse and save it to $HOME
   $ ffcast -w    #record a selected window and save it to $HOME
   $ ffcast -f -w #record a selected window including window frames and save it to $HOME
   $ ffcast -k    #stop latest ffcast started session
   $ ffcast -w % echo %wx%h+%x+%y # print width, hight, x and y coordinates
   $ ffcast -vv -s ffmpeg -r 25 -- -f alsa -i hw:0 -vcodec libx264 cast.mkv
   $ ffcast -vv -s ffmpeg -follow_mouse centered -r 25 -- -f alsa -i hw:0 -vcodec libx264 cast.mkv
   $ ffcast -w recordmydesktop -- -o cast.ogv
   ```

## Differences

* Doesn't require bash, any posix shell is enough
* Geometry options were removed
* Options must be separated by `-`, `-vv -s` instead of `-vvs`
* No multiple `ws` options allowed, `-s` is preferred over `-w`
* Default file is a random 8 character string with a .mkv suffix saved to $HOME
* Uses notifications when available
* Support avconv
