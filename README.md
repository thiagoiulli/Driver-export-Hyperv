# Driver-export-Hyperv

Code for exporting the required driver files for GPU-P on Hyper-v, as explained on [this tutorial by Craft Computing](https://www.youtube.com/watch?v=XLLcc29EZ_8)

## How to use

* Download [this file](/driver_files_list.ps1) as RAW.
* Open a window of PowerShell ISE with Admin privileges and open the file downloaded.
* Change in the second line the name of the GPU as it appears on the device manager. You can use wildcards, for example ```$GPUNAME = "*6800 XT*"``` that will work.
* Change in the third line the path of the folder you want to dump your driver files. You can use windows variables like ```$OUTPUTPAH = "%USERPROFILE%\Downloads\Output"```.
* Some systems may require changing the execution policy of your computer, for this run ```Set-ExecutionPolicy Unrestricted```.
  * It's recommended to change it back to ```Set-ExecutionPolicy RemoteSigned``` after you finished with the file.
* Run the file and proceed with the tutorial of [this video](https://www.youtube.com/watch?v=XLLcc29EZ_8) or other similar that require copying the driver files.

## Notes

* I don´t have a Nvidia or Intel GPU, so I only tested for AMD. Any errors or problems just open an issue or pull request.
* This script only export the driver files, you still need to configure GPU-P yourself and copy the files into the VM on the correct locations.

## Credits

[Craft Computing](https://www.youtube.com/watch?v=XLLcc29EZ_8)
