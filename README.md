
![NPeg](/bambucli.png)

This is an experimental CLI interface to the Bambu printer family. I
exclusively use my printer in LAN only mode, and it makes me happy to see that
Bambu chose to use standard open protocols for their interface.



## Building

- `nimble install nmqtt`
- `nim c -d:ssl bambucli.nim`


## Usage

Create a file `~/.bambu` containing one line with the IP address of your printer and the password, separated by a `:`, mine looks
like this:

```
10.0.0.30:734f29a1
```
 
run `./bambucli`


## TODO

- basic control (pause, resume, etc)
- uPnP device discovery


