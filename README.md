## ffcast

[ffcast](https://github.com/chilicuil/ffcast/) helps the user interactively select a screen region and hands over the geometry to an external command, such as ffmpeg, for screen recording. This is a custom version for POSIX sh shells, refer to [lolilolicon](https://github.com/lolilolicon/FFcast2) for the original one.

<p align="center">
<img src="http://javier.io/assets/img/ffcast.gif" alt="ffcast"/>
</p>

## Quick start

### On Ubuntu

   ```
   $ sudo add-apt-repository ppa:chilicuil/sucklesstools
   $ sudo apt-get update
   $ sudo apt-get install ffcast
   ```

### On other Linux distributions + BSD

1. Type `make`

1. Type `make install`

### Requirements

* POSIX compatible shell 
* ffmpeg
* xdpyinfo - for the -x option
* xrectsel - for the -s option (included)
* xwininfo - for the -w option

* xrectsel
 * libX11

## Usage

   ```
   ffcast [-l|-s|-w|-k|-x <n|list>|-b|-m|-p|-q|-v|-h] [command [args] [--] [args]]"
   ```

### Examples

   ```
   $ ffcast -h #show help
   $ ffcast    #record fullscreen and saves to $HOME
   $ ffcast -s #record a region selected with mouse and saves to $HOME
   $ ffcast -w #record a selected window and saves to $HOME
   $ ffcast -k #stop latest ffcast started session
   $ ffcast -w % echo %wx%h+%x+%y # print width, hight, x and y coordinates
   $ ffcast.sh -vv -s ffmpeg -r 25 -- -f alsa -i hw:0 -vcodec libx264 cast.mkv
   $ ffcast.sh -vv -s ffmpeg -follow_mouse centered -r 25 -- -f alsa -i hw:0 -vcodec libx264 cast.mkv
   $ ffcast -w recordmydesktop -- -o cast.ogv
   ```

## Differences

* Doesn't require bash, any posix shell is enough
* Geometry options were removed
* Options must be separated by `-`, `-vv -s` instead of `-vvs`
* No multiple `ws` options allowed, `-s` is preferred over `-w`
* Default file is a random 8 character string with a .mkv suffix saved to $HOME
* Uses notifications when available
* Support additionally avconv
