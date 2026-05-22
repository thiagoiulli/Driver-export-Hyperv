# Driver-export-Hyperv

Code for exporting the required driver files for GPU-P on Hyper-v, as explained on [this tutorial by Craft Computing](https://www.youtube.com/watch?v=XLLcc29EZ_8)

## How to use

* Change in the second line the name of the GPU as it appears on the device manager. You can use wildcards, for example ```$GPUNAME = "*6800 XT*"``` that will work.
* Change in the third line the path of the folder you want to dump your driver files. You can use windows variables like ```$OUTPUTPAH = "%USERPROFILE%\Downloads\Output"```.

## Credits

[Craft Computing](https://www.youtube.com/watch?v=XLLcc29EZ_8)
