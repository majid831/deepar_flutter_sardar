enum CameraResolutionPreset{
  RESOLUTION_PRESET_10920x1080,
  RESOLUTION_PRESET_1280x720,
  RESOLUTION_PRESET_640x480,
  RESOLUTION_PRESET_DEVICE
}

extension CameraResolutionPresetHelper on CameraResolutionPreset{
  String getSettingValue(){
    return this.toString().replaceAll("CameraResolutionPreset.", "");
  }
}