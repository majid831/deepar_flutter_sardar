// To parse this JSON data, do
//
//     final pluginMessage = pluginMessageFromJson(jsonString);

import 'dart:convert';

PluginMessage pluginMessageFromJson(String str) => PluginMessage.fromJson(json.decode(str));

String pluginMessageToJson(PluginMessage data) => json.encode(data.toJson());

class PluginMessage {

  PluginActionEnum? actionEnum; //enum value of the action
  String? action; //int value of the actionEnum
  String? description; //description field, used for debugging purposes only
  int? numValue; //numeric value of the action (if available)
  String? strValue; //string value (if available)
  bool? isSuccess; // return if there is an error

  PluginMessage({
    this.action,
    this.description,
    this.numValue,
    this.strValue,
    this.isSuccess,
  }){
    this.actionEnum = PluginActionEnumHelper.getPluginActionEnum(this.action);
  }

  factory PluginMessage.fromJson(Map<String, dynamic> json) => PluginMessage(
    action: json["action"] == null ? null : json["action"],
    description: json["description"] == null ? null : json["description"],
    numValue: json["numValue"] == null ? null : json["numValue"],
    strValue: json["strValue"] == null ? null : json["strValue"],
    isSuccess: json["isSuccess"] == null ? null : json["isSuccess"],
  );

  Map<String, dynamic> toJson() => {
    "action": action == null ? null : action,
    "description": description == null ? null : description,
    "numValue": numValue == null ? null : numValue,
    "strValue": strValue == null ? null : strValue,
    "isSuccess": isSuccess == null ? null : isSuccess,
  };
}


enum PluginActionEnum{
  undefined_action,
  finish_prepare_video_recording,
  did_start_video_recording,
  did_finish_video_recording,
  error_video_recording,
  screenshot,
  did_initialize,
  face_visible,
  face_tracked,
  number_of_visible_faces_changed,
  did_finish_shutdown,
  image_visibility_changed,
  did_switch_effect
}

class PluginActionEnumHelper{
  static PluginActionEnum getPluginActionEnum(String? value){
    return PluginActionEnum.values.firstWhere((e)=>e.toString().contains(value ?? ""),orElse: ()=>PluginActionEnum.undefined_action);
  }
}