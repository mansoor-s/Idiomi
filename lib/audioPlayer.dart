import 'package:idiomi/playlist.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:audio_service/audio_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);



class AudioPlayerTask extends BackgroundAudioTask {
  PlayList _playList;
  List<MediaItem> _queue;
  
  AudioPlayerTask(PlayList playList) {
    _playList = playList;
    _queue = playList.getQueue();

    //_loadPlayerState(_playList.ID);

    //this should only start after the state has been loaded, or could lead to race condition
    /*Timer.periodic(const Duration(seconds:10), (_) {
      if (!_playing) {
        return;
      }
      var position = _audioPlayer.playbackEvent.position.inMilliseconds;
      _persistPlayerState(_playList.ID, _queueIndex, position);
    });
    */
  }

  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing = false;


  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      case AudioPlaybackState.buffering:
        return BasicPlaybackState.buffering;
      case AudioPlaybackState.connecting:
        return _skipState ?? BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception("Illegal state");
    }
  }

  @override
  Future<void> onStart() async {
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _stateToBasicState(event.state);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    AudioServiceBackground.setQueue(_queue);
    //await onSkipToNext();
    _loadPlayerState(_playList.id);

    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() async {
    if (hasNext) {
      await onSkipToNext();
    } else {
      await onStop();
    }
  }

  Future<void> playPause() async {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      await onPause();
    else
      await onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      await onPlay();
    } else {
      await _setState(state: BasicPlaybackState.paused);
    }
  }

  Future<void> _playPlaylistMedia(int index) async {
    _queueIndex = index;
    AudioServiceBackground.setMediaItem(mediaItem);
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;

    // Resume playback if we were playing
    if (_playing != null && _playing) {
      await onPlay();
      await _setState(state: BasicPlaybackState.playing);
    } else {
      await _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  Future<void> onPlay() async {
    if (_skipState == null) {
      _playing = true;
      await _audioPlayer.play();
    }
  }

  @override
  Future<void> onPause() async{
    if (_skipState == null) {
      _playing = false;
      await _audioPlayer.pause();
    }
  }

  @override
  Future<void> onSeekTo(int position) async {
    await _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  Future<void> onClick(MediaButton button) async {
    await playPause();
  }

  @override
  Future<void> onStop() async {
    _audioPlayer.stop();
    await _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  Future<void> _setState({@required BasicPlaybackState state, int position}) async {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
    await _persistPlayerState(_playList.id, _queueIndex, position);
  }

  String _playerStateForPlaylistKey(String playlistID) {
    return 'player_state::$playlistID';
  }

  Future<void> _persistPlayerState(String playlistID, int queueIndex, int position) async {
    SharedPreferences _playerPrefs = await SharedPreferences.getInstance();
    var currentPlayerPlaylist = _playerStateForPlaylistKey(playlistID);
    var currentPlayerStateValue = '$playlistID::$queueIndex::$position';
    await _playerPrefs.setString(currentPlayerPlaylist, currentPlayerStateValue);
  }

  Future<void> _loadPlayerState(String playlistID) async {
    SharedPreferences _playerPrefs = await SharedPreferences.getInstance();
    var currentPlayerPlaylist = _playerStateForPlaylistKey(playlistID);

    var seralizedState = _playerPrefs.getString(currentPlayerPlaylist);
    if (seralizedState == null){
      return;
    }

    var stateParts = seralizedState.split('::');
    if (stateParts.length != 3) {
      throw FormatException("Invalid player state. Unable to deserialize");
    }

    final index = int.parse(stateParts[1]);
    final playerSeekLocation = int.parse(stateParts[2]);
    //PlaybackState stat = AudioService.playbackState;
    await _playPlaylistMedia(index);
    _audioPlayer.seek(Duration(milliseconds: playerSeekLocation) );
    _playing = true;
    await _audioPlayer.play();
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }
}