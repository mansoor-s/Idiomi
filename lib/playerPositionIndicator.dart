import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

class PlayerPositionIndicator extends StatefulWidget {
  const PlayerPositionIndicator(this.mediaItem, this.playbackState);

  final MediaItem mediaItem;
  final PlaybackState playbackState;

  @override
  State<StatefulWidget> createState() => _PositionIndicatorSate();
}

class _PositionIndicatorSate extends State<PlayerPositionIndicator> {
  final BehaviorSubject<double> _dragPositionSubject =
    BehaviorSubject.seeded(null);

  @override
  Widget build(BuildContext context) {
    double seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position = snapshot.data ?? widget.playbackState.currentPosition.toDouble();
        double duration = widget.mediaItem?.duration?.toDouble();
        return Column(
          children: [
            if (duration != null)
              Slider(
                min: 0.0,
                max: duration,
                value: seekPos ?? max(0.0, min(position, duration)),
                onChanged: (value) {
                  _dragPositionSubject.add(value);
                },
                onChangeEnd: (value) {
                  AudioService.seekTo(value.toInt());
                  // Due to a delay in platform channel communication, there is
                  // a brief moment after releasing the Slider thumb before the
                  // new position is broadcast from the platform side. This
                  // hack is to hold onto seekPos until the next state update
                  // comes through.
                  // TODO: Improve this code.
                  seekPos = value;
                  _dragPositionSubject.add(null);
                },
              ),
            Text("${(widget.playbackState.currentPosition / 1000).toStringAsFixed(3)}"),
          ],
        );
      },
    );
  }
  
}

