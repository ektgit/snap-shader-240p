# snap-shader-240p

For Raspberry Pi with built-in composite out to a CRT TV.  (This may work with the RetroTINK as well, offering the same benefit of not having to tune every game system).

Ensures games on CRT will look as good as on original hardware.  Makes games crisp vertically, and not shimmer horizontally.

Virtually eliminates the need for separate configurations per core (console).

How it works:
* Centers games instead of stretching them.
* Aligns lines so that only horizontal linear filtering happens.

Make sure you:
* Copy one or both shaders to the Shader folder of your Raspberry Pi.
* I recommend Lakka 2.1 or newer.
* In /flash/config.txt, set sdtv_mode=16, or 18 for PAL.  This ensures 240p with "scanlines", just like on original hardware.
* In Video settings, set "Aspect Ratio" to "Custom".
* Set the Custom Aspect Ratio to 640x480, or the PAL* equivalent.
* Make sure "Bilinear Filtering" is off in the Settings/Video menu.
* In the Settings/Driver menu, make sure "Video Driver" is "gl".
* In the Quick Menu/Shaders menu, set the shader to the basic or deluxe version of this shader.
* Set the filter to "Linear" in the Quick Menu/Shader menu.

Deluxe version:
Will fit vertical games correctly on horizontal TVs.
It will also make two-screen games more playable by only showing the bottom screen.

Tested only on a Raspberry Pi 3 on NTSC but should work on PAL as well.

*Please report any problems with PAL.  It's possible Sega Master System games will appear too tall on PAL TVs unless you shrink the video height to less than 576 lines.  It's because 192 fits into 576 three times rather than two.

Please feel free to submit any improvements.

Areas for improvement:
* If there is a way to get the Raspbery Pi composite hardware to shrink the 720 horizontal pixels down to a 4:3 aspect ratio, we would get even less crawling pixels.

Technical details:
* Most of the computation is done on the vertex shader.  Since there are only six vertices, this shader should be very fast.
* It might be possible to move the pixel shader computations to the vertex shader in the future.
