
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'package:rxdart/rxdart.dart';

//import 'playerPositionIndicator.dart';
import 'player.dart';

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
  final playerButtonIconsSize = 32.0;

  /// Tracks the position while the user drags the seek bar.
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<BasicPlaybackState>(
          stream: Player.basicPlaybackStateStream,
          builder: playerControlsStreamBuilder
        )
    );
  }

  Row controlsRowWidget(final BasicPlaybackState basicPlaybackState) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<bool>(
              stream: Player.isFirstMediaItem,
              builder: (_, snap) => IconButton(
                padding: const EdgeInsets.all(4.0),
                icon: Icon(Icons.skip_previous),
                iconSize: playerButtonIconsSize,
                onPressed:
                    (snap == null || snap.data == null || snap.data)
                        ? null
                        : AudioService.skipToPrevious,
              ),
            ),

            if (basicPlaybackState == BasicPlaybackState.playing)
              pauseButton()
            else
              playButton(basicPlaybackState),

            StreamBuilder<bool>(
              stream: Player.isLastMediaItem,
              builder: (_, snap) => IconButton(
                padding: const EdgeInsets.all(4.0),
                icon: Icon(Icons.skip_next),
                iconSize: playerButtonIconsSize,
                onPressed:
                    (snap == null || snap.data == null || snap.data)
                        ? null
                        : Player.skipToNext,
              ),
            ),
          ],
        );
  }


  Row playPauseRowWidget(final BasicPlaybackState basicPlaybackState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (basicPlaybackState == BasicPlaybackState.playing)
          pauseButton()
        else if (basicPlaybackState == BasicPlaybackState.paused)
          playButton(basicPlaybackState)
        else if (basicPlaybackState == BasicPlaybackState.buffering ||
            basicPlaybackState == BasicPlaybackState.skippingToNext ||
            basicPlaybackState == BasicPlaybackState.skippingToPrevious)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: playerButtonIconsSize,
              height: playerButtonIconsSize,
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  StreamBuilder<PositionIndicator> positionIndicatorBuilder() {
    return StreamBuilder<PositionIndicator>(
      stream: Player.positionIndicator,
      initialData: PositionIndicator(position: 0, duration: 0),
      builder: (_, snap) {
        log('Playback state updated');
        double _seekPos;
        return StreamBuilder(
          stream: Rx.combineLatest2<double, double, double>(
              _dragPositionSubject.stream,
              Stream.periodic(Duration(milliseconds: 1000)),
              (dragPosition, _) => dragPosition),
          builder: (context, snapshot) {
            double position = AudioService.playbackState?.currentPosition?.toDouble();
            position ??= 0.0;
                //snapshot.data ?? snap.data?.position?.toDouble();

            double duration = snap.data?.duration?.toDouble();
            final playbackTimestamp = position ?? 0.0;
            final playbackTimestampStr = "${(playbackTimestamp / 1000).toStringAsFixed(2)}";
            return Column(
              children: [
                if (duration != null)
                  Slider(
                    min: 0.0,
                    max: duration,
                    value: _seekPos ??
                        math.max(0.0, math.min(position, duration)),
                    onChanged: (value) {
                      _dragPositionSubject.add(value);
                    },
                    onChangeEnd: (value) {
                      AudioService.seekTo(value.toInt());
                      _seekPos = value;
                      _dragPositionSubject.add(null);
                    },
                  ),
                Text(playbackTimestampStr),
              ],
            );
          },
        );
      },
    );
  }

  Widget playerControlsStreamBuilder(BuildContext context, AsyncSnapshot<BasicPlaybackState> snapshot) {
    final basicPlaybackState = snapshot.data;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /*if (basicPlaybackState == null || basicPlaybackState == BasicPlaybackState.none) ... [
          Placeholder()
        ] else ... [*/
        controlsRowWidget(basicPlaybackState),
        //playPauseRowWidget(basicPlaybackState),
        if (basicPlaybackState != BasicPlaybackState.stopped)
          positionIndicatorBuilder()
      ],
      //]
    );
  }

  IconButton playButton(BasicPlaybackState basicPlaybackState) => IconButton(
    icon: Icon(Icons.play_arrow),
    iconSize: playerButtonIconsSize,
    onPressed: () => playHandler(basicPlaybackState),
  );
  
  void playHandler(BasicPlaybackState basicPlaybackState) {
    log('playback state in play button: ${basicPlaybackState.toString()}');
    if (basicPlaybackState == null || basicPlaybackState == BasicPlaybackState.none ) {
      log('Null handling');
      Player.start();
    }
    else {
      log('let\'s play');
      AudioService.play();
    }
  }

  IconButton pauseButton() => IconButton(
    icon: Icon(Icons.pause),
    iconSize: playerButtonIconsSize,
    onPressed: AudioService.pause,
  );

  IconButton stopButton() => IconButton(
    padding: const EdgeInsets.all(4.0),
    icon: Icon(Icons.stop),
    iconSize: playerButtonIconsSize,
    onPressed: AudioService.stop,
  );
}

