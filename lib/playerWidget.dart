import 'package:idiomi/playlist.dart';
import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';

import 'package:rxdart/rxdart.dart';

import 'audioPlayer.dart';
import 'playerPositionIndicator.dart';

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

class PlayerControlsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControlsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<ScreenState>(
      stream: Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
              ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState)),
      builder: (context, snapshot) {
        final screenState = snapshot.data;
        final queue = screenState?.queue;
        final mediaItem = screenState?.mediaItem;
        final state = screenState?.playbackState;
        final basicState = state?.basicState ?? BasicPlaybackState.none;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (queue != null && queue.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    iconSize: 64.0,
                    onPressed: mediaItem == queue.first
                        ? null
                        : AudioService.skipToPrevious,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    iconSize: 64.0,
                    onPressed: mediaItem == queue.last
                        ? null
                        : AudioService.skipToNext,
                  ),
                ],
              ),
            if (mediaItem?.title != null) Text(mediaItem.title),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (basicState == BasicPlaybackState.playing)
                  pauseButton()
                else if (basicState == BasicPlaybackState.paused)
                  playButton()
                else if (basicState == BasicPlaybackState.buffering ||
                    basicState == BasicPlaybackState.skippingToNext ||
                    basicState == BasicPlaybackState.skippingToPrevious)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 64.0,
                      height: 64.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                stopButton(),
              ],
            ),
            if (basicState != BasicPlaybackState.none &&
                basicState != BasicPlaybackState.stopped) ...[
              PlayerPositionIndicator(mediaItem, state),
              Text("State: " + "$basicState".replaceAll(RegExp(r'^.*\.'), '')),
            ]
          ],
        );
      },
    ));
  }

  void startPlayer() {
    startButton(
      'AudioPlayer',
      () {
        AudioService.start(
          backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
          androidNotificationChannelName: 'Audio Service Demo',
          notificationColor: 0xFF2196f3,
          androidNotificationIcon: 'mipmap/ic_launcher',
          enableQueue: true,
        );
      },
    );
  }

  RaisedButton startButton(String label, VoidCallback onPressed) =>
      RaisedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: AudioService.stop,
      );
}

void _audioPlayerTaskEntrypoint() async {
  final _queue = <MediaItem>[
    MediaItem(
      id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      duration: 5739820,
      artUri:
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
    ),
    MediaItem(
      id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
      album: "Science Friday",
      title: "From Cat Rheology To Operatic Incompetence",
      artist: "Science Friday and WNYC Studios",
      duration: 2856950,
      artUri:
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
    ),
  ];

  final englishToSpanishPlaylist = PlayList('english-spanish', _queue);
  AudioServiceBackground.run(() => AudioPlayerTask(englishToSpanishPlaylist));
}
