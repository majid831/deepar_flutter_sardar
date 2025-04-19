// To parse this JSON data, do
//
//     final multiFaceTrackData = multiFaceTrackDataFromJson(jsonString);

import 'dart:convert';

class MultiFaceTrackData {
  List<PluginFaceData>? pluginFaceData;

  MultiFaceTrackData({
    this.pluginFaceData,
  });

  factory MultiFaceTrackData.fromRawJson(String str) => MultiFaceTrackData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MultiFaceTrackData.fromJson(Map<String, dynamic> json) => MultiFaceTrackData(
    pluginFaceData: List<PluginFaceData>.from(json["PluginFaceData"].map((x) => PluginFaceData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "PluginFaceData": pluginFaceData == null ? null : List<dynamic>.from(pluginFaceData!.map((x) => x.toJson())),
  };
}

class PluginFaceData {
  bool? faceDetected;
  int? faceNumber;
  List<double>? faceRect;
  List<double>? landmarks;
  List<double>? landmarks2D;
  List<double>? poseMatrix;
  List<double>? rotation;
  List<double>? translation;

  PluginFaceData({
    this.faceDetected,
    this.faceNumber,
    this.faceRect,
    this.landmarks,
    this.landmarks2D,
    this.poseMatrix,
    this.rotation,
    this.translation,
  });

  factory PluginFaceData.fromRawJson(String str) => PluginFaceData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PluginFaceData.fromJson(Map<String, dynamic> json) => PluginFaceData(
    faceDetected: json["faceDetected"] == null ? null : json["faceDetected"],
    faceNumber: json["faceNumber"] == null ? null : json["faceNumber"],
    faceRect: json["faceRect"] == null ? null : List<double>.from(json["faceRect"].map(mapToDouble)),
    landmarks: json["landmarks"] == null ? null : List<double>.from(json["landmarks"].map(mapToDouble)),
    landmarks2D: json["landmarks2d"] == null ? null : List<double>.from(json["landmarks2d"].map(mapToDouble)),
    poseMatrix: json["poseMatrix"] == null ? null : List<double>.from(json["poseMatrix"].map(mapToDouble)),
    rotation: json["rotation"] == null ? null : List<double>.from(json["rotation"].map(mapToDouble)),
    translation: json["translation"] == null ? null : List<double>.from(json["translation"].map(mapToDouble)),
  );

  Map<String, dynamic> toJson() => {
    "faceDetected": faceDetected == null ? null : faceDetected,
    "faceNumber": faceNumber == null ? null : faceNumber,
    "faceRect": faceRect == null ? null : List<dynamic>.from(faceRect!.map((x) => x)),
    "landmarks": landmarks == null ? null : List<dynamic>.from(landmarks!.map((x) => x)),
    "landmarks2d": landmarks2D == null ? null : List<dynamic>.from(landmarks2D!.map((x) => x)),
    "poseMatrix": poseMatrix == null ? null : List<dynamic>.from(poseMatrix!.map((x) => x)),
    "rotation": rotation == null ? null : List<dynamic>.from(rotation!.map((x) => x)),
    "translation": translation == null ? null : List<dynamic>.from(translation!.map((x) => x)),
  };

  static double mapToDouble(dynamic x){
    if (x is double) {
      return x;
    }else{
      return x.toDouble();
    }
  }
}
