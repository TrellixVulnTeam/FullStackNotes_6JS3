```dart

// 需要dart model实现toJson的方法才能使用json.encode方法


class ConfigModel {
  final String searchUrl;

  ConfigModel({this.searchUrl});

  factory ConfigModel.fromJson(Map<String,dynamic>json) {
    return json != null
        ? ConfigModel(
            searchUrl:json['searchUrl'],
        ) :null;
  }

  Map<String,dynamic> toJson() {
    final Map<String,dynamic> data = new Map<String,dynamic>();
    data['searchUrl'] = this.searchUrl;
    return data;
  }
}


```