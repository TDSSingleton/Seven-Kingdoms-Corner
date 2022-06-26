// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compendiumclasses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompendiumArticle _$CompendiumArticleFromJson(Map<String, dynamic> json) =>
    CompendiumArticle()
      ..title = json['title'] as String
      ..subtitle = json['subtitle'] as String
      ..description = json['description'] as String
      ..image = $enumDecode(_$compendiumImageEnumMap, json['image']);

Map<String, dynamic> _$CompendiumArticleToJson(CompendiumArticle instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'description': instance.description,
      'image': _$compendiumImageEnumMap[instance.image],
    };

const _$compendiumImageEnumMap = {
  compendiumImage.None: 'None',
  compendiumImage.AliImage: 'AliImage',
};

CompendiumCategory _$CompendiumCategoryFromJson(Map<String, dynamic> json) =>
    CompendiumCategory()
      ..categoryArticles = (json['categoryArticles'] as List<dynamic>)
          .map((e) => CompendiumArticle.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$CompendiumCategoryToJson(CompendiumCategory instance) =>
    <String, dynamic>{
      'categoryArticles': instance.categoryArticles,
    };

CompendiumHolder _$CompendiumHolderFromJson(Map<String, dynamic> json) =>
    CompendiumHolder()
      ..mainCategories = (json['mainCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..subCategories = (json['subCategories'] as List<dynamic>)
          .map((e) => CompendiumCategory.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$CompendiumHolderToJson(CompendiumHolder instance) =>
    <String, dynamic>{
      'mainCategories': instance.mainCategories,
      'subCategories': instance.subCategories,
    };
