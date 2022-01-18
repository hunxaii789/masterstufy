import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/video/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoScreenArgs {
  final String title;
  final String videoLink;

  VideoScreenArgs(this.title, this.videoLink);
}

class VideoScreen extends StatelessWidget {
  static const routeName = 'videoScreen';
  final VideoBloc _bloc;

  const VideoScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final VideoScreenArgs args = ModalRoute.of(context).settings.arguments;

    return BlocProvider<VideoBloc>(
        create: (c) => _bloc,
        child: _VideoScreenWidget(args.title, args.videoLink));
  }
}

class _VideoScreenWidget extends StatefulWidget {
  final String videoLink;
  final String title;

  const _VideoScreenWidget(this.title, this.videoLink);

  @override
  State<StatefulWidget> createState() {
    return _VideoScreenState();
  }
}

class _VideoScreenState extends State<_VideoScreenWidget> {
  VideoBloc _bloc;
  VideoPlayerController _controller;
  YoutubePlayerController _youtubePlayerController;

//test
  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  Future<bool> saveVideo(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/GLearningCenter";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded = await saveVideo(widget.videoLink, widget.title + '.mp4');
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
    setState(() {
      loading = false;
    });
  }

//test
  bool video = false;
  bool videoPlayed = false;
  bool videoLoaded = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<VideoBloc>(context)
      ..add(FetchEvent(widget.title, widget.videoLink));

    var format = widget.videoLink.split(".");
    if (format.last == 'mp4') {
      //http://motors.stylemixthemes.com/landing/motors-landing.mp4

      setState(() {
        video = true;
      });
      _controller = VideoPlayerController.network(widget.videoLink)
        ..setLooping(true)
        ..play()
        ..initialize().then((_) {
          setState(() {
            videoLoaded = true;
          });
        });
    } else if (video == false) {
      //https://www.youtube.com/watch?v=wGtDvLkVvaQ
      String videoId = YoutubePlayer.convertUrlToId(widget.videoLink);
      if (videoId != "") {
        _youtubePlayerController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: HexColor.fromHex("#000000"),
          appBar: AppBar(
              backgroundColor: HexColor.fromHex("#000000"),
              automaticallyImplyLeading: false,
              title: Text(widget.title,
                  textScaleFactor: 1.0,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  )),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15.0),
                  child: SizedBox(
                    width: 42,
                    height: 30,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Icon(Icons.fullscreen),
                  onPressed: () {
                    if (MediaQuery.of(context).orientation ==
                        Orientation.portrait) {
                      //if Orientation is portrait then set to landscape mode
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    } else {
                      //if Orientation is landscape then set to portrait
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitDown,
                        DeviceOrientation.portraitUp,
                      ]);
                    }
                  },
                ),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  child: loading
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.blueAccent,
                            color: Colors.white,
                            value: progress,
                          ),
                        )
                      : ElevatedButton(
                          child: Icon(
                            Icons.download_outlined,
                            color: Colors.white,
                            size: 20.0,
                          ),
                          onPressed: downloadFile,
                        ),
                ),
              ]),
          body: Padding(
            padding: EdgeInsets.all(1.0),
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  _buildBody(state) {
    if (state is LoadedVideoState) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              loadPlayer(),
            ]),
      );
    }

    if (state is InitialVideoState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  loadPlayer() {
    {
      if (video) {
        return Column(
          children: <Widget>[
            Container(
              child: _controller.value.isInitialized
                  ? Center(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 300.0,
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio * 5,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  VideoPlayer(_controller),
                                ],
                              ),
                            ),
                          ),
                          VideoProgressIndicator(_controller,
                              padding: EdgeInsets.only(top: 0.5),
                              allowScrubbing: true),
                          SizedBox(
                              width: 42,
                              height: 10,
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                padding: EdgeInsets.all(0.0),
                                color: HexColor.fromHex("#000000"),
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: HexColor.fromHex("#FFFFFF"),
                                  size: 24.0,
                                ),
                              )),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
            ),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(
              child: YoutubePlayer(
                  controller: _youtubePlayerController,
                  showVideoProgressIndicator: true,
                  actionsPadding: EdgeInsets.only(left: 16.0),
                  bottomActions: [
                    CurrentPosition(),
                    SizedBox(width: 10.0),
                    ProgressBar(isExpanded: true),
                    SizedBox(width: 10.0),
                    RemainingDuration(),
                    FullScreenButton(),
                  ],
                  onReady: () {}),
            ),
          ],
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _youtubePlayerController.dispose();
  }
}
