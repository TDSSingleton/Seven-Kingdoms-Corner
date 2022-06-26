import 'package:json_annotation/json_annotation.dart';
part 'compendiumclasses.g.dart';

@JsonSerializable()
class CompendiumArticle {
  String title = "New Article";
  String subtitle = "";
  String description = "Enter Description here.";
  compendiumImage image = compendiumImage.None;

  CompendiumArticle();

  CompendiumArticle.titleDefined(String titleX) {
    title = titleX;
  }

  factory CompendiumArticle.fromJson(Map<String, dynamic> json) =>
      _$CompendiumArticleFromJson(json);
  Map<String, dynamic> toJson() => _$CompendiumArticleToJson(this);
}

@JsonSerializable()
class CompendiumCategory {
  List<CompendiumArticle> categoryArticles = [];

  CompendiumCategory();

  factory CompendiumCategory.fromJson(Map<String, dynamic> json) =>
      _$CompendiumCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CompendiumCategoryToJson(this);
}

@JsonSerializable()
class CompendiumHolder {
  List<String> mainCategories = [];
  List<CompendiumCategory> subCategories = [];

  CompendiumHolder();

  factory CompendiumHolder.fromJson(Map<String, dynamic> json) =>
      _$CompendiumHolderFromJson(json);

  Map<String, dynamic> toJson() => _$CompendiumHolderToJson(this);
}

enum compendiumImage { None, AliImage }
