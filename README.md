# Driver-export-Hyperv

Code for exporting the required driver files for GPU-P on Hyper-v, as explained on [this tutorial by Craft Computing](https://www.youtube.com/watch?v=XLLcc29EZ_8)

## How to use

* Change in the second line the name of the GPU as it appears on the device manager. You can use wildcards, for example ```$GPUNAME = "*6800 XT*"``` that will work.
* Change in the third line the path of the folder you want to dump your driver files. You can use windows variables like ```$OUTPUTPAH = "%USERPROFILE%\Downloads\Output"```.

## Notes

* I don´t have a Nvidia or Intel GPU, so I only tested for AMD. Any errors or problems just open an issue or pull request.
* This script only export the driver files, you still need to configure GPU-P yourself and copy the files into the VM on the correct locations.

## Credits

[Craft Computing](https://www.youtube.com/watch?v=XLLcc29EZ_8)
