import 'package:flutter/material.dart';

enum FeedId {
  main,
  like,
  trash,
}

class FeedController {
  final ValueNotifier<int> reloadFeed = ValueNotifier<int>(0);
}

class FeedManager {

  static final FeedManager instance = FeedManager._init();
  FeedManager._init();

  final List<FeedController?> _fcs = List.filled(FeedId.values.length, null, growable: false);

  /// Create the FeedController and assign it to the _fcs. If it already exist skip.
  FeedController _requestFeedController(FeedId id){
    if(_fcs[id.index] != null) return _fcs[id.index]!;

    FeedController newFc = FeedController();
    _fcs[id.index] = newFc;

    return newFc;    
  }

  /// If the FeedController exist we upate is ValueNotifier
  void reloadFeed(FeedId id){
    if(_fcs[id.index] != null) _fcs[id.index]!.reloadFeed.value++;
  } 

  // Return the ValueNotifier associate with that Feed. If not exist create.
  ValueNotifier<int> getReloadFeedListener(FeedId id) {
    return _requestFeedController(id).reloadFeed;
  }


}