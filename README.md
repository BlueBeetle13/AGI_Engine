# AGI_Engine

Create an AGI Engine for the 1980's and 1990's games that were created by Sierra On-Line using Swift.

This project is based on the [AGI Specifications](https://wiki.scummvm.org/index.php?title=AGI/Specifications) created by the developers at ScumVM.

It should be able to play any game [listed here](https://wiki.scummvm.org/index.php?title=AGI#Games_using_this_engine).

Presently it only runs on MacOS but should be able to run on Linux as well with a few small tweaks as it basically just provides as array of bytes for drawing.

## How to Run this

You can clone the repo and open up into Xcode. You will need the original game files for these games. They can be purchased from [GOG](https://www.gog.com) or you can copy these files from your old disks. I have tested on all the supported games (mostly PC versions). Just run the app, press the 'Load' button, and point it to the folder where the game files reside.

## Why Write this?

ScumVM provides and engine that plays all AGI and SCI (the later engine developed by Sierra On-Line) games, so why bother?

When I was a kid I was amazed by these Sierra On-Line games. They were so immersive, creative and fun. I wanted to be a game developer and create games like these. I would look through the files on the 3.5" floppy disks and try and figure out what was going on, but I never could.

Now that I have been a programmer (for 20+ years) I am finally finding the time and interest in learning how these games worked. From the vector based drawing, to the various forms of compression to the custom logic language they developed, it has been a fun challenge to figure this out. Without the ScumVM specs this would have taken years.
