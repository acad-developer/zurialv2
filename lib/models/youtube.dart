import 'package:youtube_metadata/youtube_metadata.dart';
import 'package:zuriel/tools/tools.dart';
import 'handler.dart';
import 'utils.dart';
import 'package:flutter/material.dart';

class YoutubeData implements BaseModel {
  final String title;
  final String thumbnail;
  final String youtubeLink;
  final int updated;
  final String duration;

  YoutubeData(
      {required this.title,
      required this.thumbnail,
      required this.youtubeLink,
      required this.updated,
      required this.duration});

  factory YoutubeData.fromJson(Map<String, dynamic> json) {
    return YoutubeData(
      title: json['title'],
      updated: int.parse(json['updated'].toString()),
      thumbnail: json['thumbnail'],
      youtubeLink: json['youtubeLink'],
      duration: json['duration'],
    );
  }

  static List<TitleValue> getOrderTerms() {
    return [
      TitleValue(title: "DateTime", value: "updated"),
      TitleValue(title: "Title", value: "title"),
    ];
  }

  static List<String> getSearchTerm() {
    return ["title"];
  }

  static checkitem() => "title";

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'updated': updated,
      'thumbnail': thumbnail,
      'duration': duration,
      'youtubeLink': youtubeLink
    };
  }
}

String? getYouTubeVideoId(String url) {
  final regex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
    multiLine: false,
  );
  final match = regex.firstMatch(url);
  return match?.group(1);
}

class YoutubeDataFetcher {
  static Future<YoutubeData> fetchMetadata(String youtubeLink) async {
    MetaDataModel videoMetaData = await YoutubeMetaData.getData(youtubeLink);
    DateTime now = DateTime.now();
    int formattedDate = now.millisecondsSinceEpoch;
    return YoutubeData(
        title: videoMetaData.title!,
        thumbnail: videoMetaData.thumbnailUrl!,
        youtubeLink: youtubeLink,
        updated: formattedDate,
        duration: 0.toString());
  }
}

Widget videoListTemplate(Map<String, dynamic> inputdata, BuildContext context,
    VoidCallback deletecallback) {
  YoutubeData data = YoutubeData.fromJson(inputdata);
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Card(
      child: ListTile(
        leading: Image.network(
          data.thumbnail,
          height: 50,
          width: 50,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Container(
               height: 50,
          width: 50,
              color: Colors.grey,
              alignment: Alignment.center,
              child: const Text('Image Failed'),
            );
          },
        ),
        contentPadding: const EdgeInsets.all(10),
        title: Text(data.title),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Text(dateDDMMYYHHMMTimeFormatter(data.updated)),
          Text(data.youtubeLink),
        ]),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => openUrlInBrowser(data.youtubeLink),
                  icon: const Icon(Icons.open_in_browser)),
              IconButton(
                  onPressed: deletecallback, icon: const Icon(Icons.delete))
            ],
          ),
        ),
      ),
    ),
  );
}
