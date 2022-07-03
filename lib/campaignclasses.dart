import 'package:json_annotation/json_annotation.dart';
part 'campaignclasses.g.dart';

@JsonSerializable()
class GameMap {
  String title = "New Article";
  String mapID = "dummymap";
  String description = "Enter Description here.";

  GameMap();

  GameMap.titleDefined(String titleX) {
    title = titleX;
  }

  factory GameMap.fromJson(Map<String, dynamic> json) =>
      _$GameMapFromJson(json);
  Map<String, dynamic> toJson() => _$GameMapToJson(this);
}

@JsonSerializable()
class Nation {
  List<GameMap> nationMaps = [];

  Nation();

  factory Nation.fromJson(Map<String, dynamic> json) => _$NationFromJson(json);
  Map<String, dynamic> toJson() => _$NationToJson(this);
}

@JsonSerializable()
class Campaign {
  String campaignName = "";
  List<String> nationNames = [];
  List<Nation> maps = [];

  Campaign();

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);
  Map<String, dynamic> toJson() => _$CampaignToJson(this);
}

enum campaignID { OWS, SoP, MR }
