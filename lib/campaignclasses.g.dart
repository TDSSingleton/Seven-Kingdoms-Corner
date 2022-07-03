// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaignclasses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameMap _$GameMapFromJson(Map<String, dynamic> json) => GameMap()
  ..title = json['title'] as String
  ..mapID = json['mapID'] as String
  ..description = json['description'] as String;

Map<String, dynamic> _$GameMapToJson(GameMap instance) => <String, dynamic>{
      'title': instance.title,
      'mapID': instance.mapID,
      'description': instance.description,
    };

Nation _$NationFromJson(Map<String, dynamic> json) => Nation()
  ..nationMaps = (json['nationMaps'] as List<dynamic>)
      .map((e) => GameMap.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$NationToJson(Nation instance) => <String, dynamic>{
      'nationMaps': instance.nationMaps,
    };

Campaign _$CampaignFromJson(Map<String, dynamic> json) => Campaign()
  ..campaignName = json['campaignName'] as String
  ..nationNames =
      (json['nationNames'] as List<dynamic>).map((e) => e as String).toList()
  ..maps = (json['subCategories'] as List<dynamic>)
      .map((e) => Nation.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$CampaignToJson(Campaign instance) => <String, dynamic>{
      'campaignName': instance.campaignName,
      'nationNames': instance.nationNames,
      'maps': instance.maps,
    };
