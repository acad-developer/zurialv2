import 'package:flutter/material.dart';
import 'package:zuriel/models/youtube.dart';
import '../../tools/tools.dart';
import 'addVideo.dart';
import '../../tools/blockList.dart';

class VideoManagement extends StatefulWidget {
  static const route_name = "videomanagement";
  const VideoManagement({super.key});
  @override
  _VideoManagementState createState() => _VideoManagementState();
}

class _VideoManagementState extends State<VideoManagement> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Video Management", context),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const AddVideo(),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            );
          }),
      body: DataListView(
        collectionname: "youtubevideodata",
        searchTerm: YoutubeData.getSearchTerm(),
        orderByItems: YoutubeData.getOrderTerms(),
        template: videoListTemplate,
      ),
    );
  }
}
