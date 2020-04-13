import 'package:audio_service/audio_service.dart';

class PlayList {
  final List<MediaItem> queue;
  final String id;

  int _currentIdx = -1;
  
  PlayList(this.id, this.queue);

  MediaItem get next {
    if (hasNext) {
       return queue[_currentIdx++];
    } else {
      return null;
    }
  }

  MediaItem get previous {
    if (hasPrevious) {
       return queue[_currentIdx--];
    } else {
      return null;
    }
  }

  MediaItem get current => queue[_currentIdx];

  bool get hasNext => _currentIdx + 1 < queue.length;
  bool get hasPrevious => _currentIdx > 0;


  List<MediaItem> getQueue() => queue;


}