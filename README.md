# snap-shader-240p

For Raspberry Pi with built-in composite out to a CRT TV.

Ensures retro games on CRT will look as good as on original hardware.  Makes games crisp vertically, and not shimmer horizontally.

How it works:
* Centers games less than 240 pixels tall instead of stretching them.
* Aligns lines so that only horizontal linear filtering happens.

Make sure you:
* Copy one or both shaders in the Shader folder of your Raspberry Pi.
* Until Lakka/RetroPie supports 240p out of the box, you will have to install popcornmix's 240p patch for Raspberry Pi.
* In the Settings/Driver menu, set the video driver to "gl".
* Turn off "Bilinear Filtering" in the Settings/Video menu.
* In the Shader menu, set the shader to use the basic or deluxe version of this shader.
* Set filter to "Linear" in the Quick Menu/Shader menu.
* Make sure in Video settings, set the resolution to 640x480.  PAL resolutions may work as well.

Deluxe version:
Will display vertical games correctly on horizontal TVs.
It will also make two-screen games more playable by only showing the bottom screen.

Tested only on a Raspberry Pi 3 on NTSC but should work on PAL as well.

Please feel free to submit any improvements.

Future room for improvements (open to contributions):
* Better quality scale for vertical games.

Technical details:
* Most of the computation is done on the vertex shader.  Since there are only six vertices, this shader should be very fast.
* It might be possible to move the pixel shader computations to the vertex shader in the future.
