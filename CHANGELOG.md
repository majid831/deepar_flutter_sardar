## 0.0.7

- Updated build.gradle file content for fixing the build issue in the latest gradle
- Added instructions into readme.md for android installation.


## 0.0.6

- Fixed some resources not being disposed on android devices. 
- Added new "Resolution" setting into the constructor. Default device camera resolution is set to screen width and height. 
  Other camera resolutions are: 
    ```dart
      enum CameraResolutionPreset{
          RESOLUTION_PRESET_10920x1080,
          RESOLUTION_PRESET_1280x720,
          RESOLUTION_PRESET_640x480,
          RESOLUTION_PRESET_DEVICE //Set according to screen resolution in android, and default camera resolution in IOS
    }
  ```

## 0.0.5

- added proguard.rules description for android projects into readme.md
- fixed compability issues with older android devices
- changed screenshot filename creation (screenshow_UUID.jpg)
- performance optimizations (by disabling face track data if not set to true)
- fixed IOS problems about camera not running after switching back from background mode

