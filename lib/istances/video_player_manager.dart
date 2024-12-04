// ignore_for_file: non_constant_identifier_names

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

final class VpNode extends LinkedListEntry<VpNode> {
  final String id;
  final ValueNotifier<int>? reload;
  final VideoPlayerController vp;
  VpNode(this.id, this.reload, this.vp);

  @override 
  String toString() {
    return id;
  }
}

class VideoPlayerManager {

  static final VideoPlayerManager instance = VideoPlayerManager._init();
  VideoPlayerManager._init();

  final bool _printDebugInfo = false;
  final int _maxVp = 3;
  final LinkedList<VpNode> _vps = LinkedList<VpNode>();
  
  /// All the blocked element will not be disposed untile they are unlocked. And they can be access again even if they are being removed
  /// from _vps because the vp can be restored from the _blockedVps.
  final List<String> _blockedIds = [];
  final LinkedList<VpNode> _blockedVps = LinkedList<VpNode>();

  /// Id of the videoPlayer that is being creted. 
  String? _creatingVp;

  /// If an id is setted when a vp is created if the id of the video is equal to this variable value than the video will play.
  String? playVpId;

  /// Default valoume for all vp
  bool _isMute = false;
  double _volume = 1.0;


  /// Notify other function that a vp is being created updating _creatingVp.
  /// If already exist a vp for an AssetEntity in the vps:
  ///   - Move the vp in head of vps if not blocked.
  ///   - Return it.
  /// If not:
  ///   - Create the new vp.
  ///   - Add it to the head of vps.
  ///   - Return it.
  /// If the playVpId is equal to the id of the video before returning play it.
  /// This function does NOT update the reload value.
  Future<VpNode> request(AssetEntity video, [ValueNotifier<int>? reload]) async {

    _creatingVp = video.id;

    if(_printDebugInfo) print("[INFO] Requested vp for video: ${video.id}");

    VpNode? node = _search(video.id);

    if(node != null){
      /// Mantain the FILO for the unlockAll function
      if(!_isIdBlocked(video.id)) _move_to_head(node);
      if(_printDebugInfo) print("[INFO] Finded vp for video: ${video.id}");
    } 
    else {
      node = _insert_head(video.id, reload, await _create_vp(video));
      if(_printDebugInfo) print("[INFO] Generated vp for video: ${video.id}");
    }

    if(_printDebugInfo) _printList(_vps);
    if(video.id == playVpId) node.vp.play();
    _creatingVp = null;
    return node;
  }

  /// Play the vp and update the reload values
  void play(VpNode? node) {
    if(node == null) return;
    node.vp.play().then( (_) { if(node.reload != null) node.reload!.value++;});
  }
  
  /// Play the vp correlated to the id if: 
  ///  - it exists
  ///  - it's being created
  ///  - will be created. 
  /// If argument is null than it stop trying to play a video.
  /// Keep try to play only the last id passed.
  /// Update reload value.
  Future<void> keepPlayId(String? id) async {

    /// Ensure that if the VP will be created after this point, it will automatically be played.
    playVpId = id;

    if (id == null) return;
    if (_creatingVp == id) return;

    /// Search for the video player by ID and play it
    for (VpNode node in _vps) {
      if (node.id == id) {
        play(node);
        return;
      }
    }
  }

  /// Ensure that all the vp in vps are paused. One can be excluded. Return the exept value.
  String? pauseAll([String? exept]) {
    for (VpNode node in _vps) {
      if(node.id != exept){
        node.vp.pause().then( (_) { if(node.reload != null) node.reload!.value++;});
      } 
    }
    return exept;
  }

  /// Search for the Node and move it to the _blockedVps list. Copy the id in the _blockedId array.
  void block(String id){

    /// Node already blocked
    if(_isIdBlocked(id)) return;

    VpNode? node = _search(id);
    if(node == null){
      if(_printDebugInfo) print("[WARN] Node $id not found in vps!");
      return;
    }

    _blockedIds.add(id);
    /// Move node to _blockedVps
    node.unlink();
    _blockedVps.addFirst(node);

    if(_printDebugInfo) {
      print("[INFO] Blocked $id");
      _printList(_blockedVps);
    }
  }

  /// If the id is in the _blockedId remove it and move the node to _vps (and dispose other vp if thera are too many).
  void unlock(String id) {
    /// Node not blocked
    if(!_isIdBlocked(id)) return;

    VpNode? node = _search(id);
    if(node == null){
      if(_printDebugInfo) print("[WARN] Node $id not found in vpsBlocked!");
      return;
    }

    _blockedIds.remove(id);
    /// Move node to head of vps
    node.unlink();
    _insert_head_node(node);

    if(_printDebugInfo) {
      print("[INFO] Unlocked $id");
      _printList(_blockedVps);
    }

  }

  double get volume {
    return _volume;
  }

  bool get isMute {
    return _isMute;
  }

  /// Move all the nodes to _vps and clear the _blockedId. 
  /// LIFO if the user ask to block a node when restored the last access one (the first one the list) will be the last one added.
  void unlockAll() {
    
    for (VpNode? head = _blockedVps.first; head != null;) {
      /// Copy the node
      VpNode temp = head;

      /// Change the head to the next element
      head = head.next;

      /// Move temp to the head of _vps
      temp.unlink();
      _insert_head_node(temp);
    }
    _blockedIds.clear();
  }

  /// Save the volume in the _volume variable so that all the future vp are going to be created with the new volume
  /// and update all the vp already created.
  void setVolume(double volume){
    _volume = volume;
    _isMute = (_volume == 0.0);
    for (VpNode node in _vps) node.vp.setVolume(volume);
    for (VpNode node in _vps) node.vp.setVolume(volume);
  }

  void muteAll(){
    _isMute = true;
    for (VpNode node in _vps) node.vp.setVolume(0.0);
    for (VpNode node in _vps) node.vp.setVolume(0.0);
  }

  void unmuteAll([double? newVolume = 1.0]){
    _isMute = false;
    setVolume(newVolume??_volume);
  }

  /// Print the list of vp
  void _printList(LinkedList<VpNode> ll) {
    print("[INFO] List:");
    print("----------------------------");
    for (VpNode node in ll) {
      print(node);
    }
    print("----------------------------");
  }

  /// Create a vp for a specific AssetEntity and return it. The Vp will start in pause if is id is different from the _playVpId.
  Future<VideoPlayerController> _create_vp( AssetEntity video) async{
    final File? videoFile = await video.file;

    VideoPlayerController vp = VideoPlayerController.file(videoFile!, videoPlayerOptions: VideoPlayerOptions(
      /// With this option if the user is listening music from Spotify, for example, the video wont stop the
      /// music but will play the audio on top of it.
      mixWithOthers: true
    ))
    ..setVolume(_isMute ? 0.0 : _volume)
    ..setLooping(true);
      
    (playVpId == video.id) ? vp.play() : vp.pause();
    await vp.initialize();

    return vp;
  }

  /// Search if there is a vp of a AssetEntity already created in the vps or blockedVps list. Return the element if exist
  /// else return null.
  VpNode? _search(String id) {
    LinkedList<VpNode> searchIn = (_isIdBlocked(id)) ? _blockedVps : _vps;
    try {
      return searchIn.firstWhere((node) => node.id == id);
    } catch(e){
      /// Element not found.
      return null;
    }
  }

  /// Create the node and insert it to the head. Return the node
  VpNode _insert_head(String id, ValueNotifier<int>? vn, VideoPlayerController vp){
    return _insert_head_node(VpNode(id, vn, vp));
  }

  /// If the list is full free the tail and add the node to the head. Return the node.
  VpNode _insert_head_node(VpNode node){
    if(_vps.length >= _maxVp) _remove_tail();
    _vps.addFirst(node);
    return node;
  }

  /// Remove the last vp from vps and dispose the removed element.
  void _remove_tail(){
    if(_vps.isEmpty) return;
    
    VpNode tail = _vps.last;
    tail.vp.dispose();
    _vps.remove(tail);
  }

  /// Move a node to the head of its list.
  void _move_to_head(VpNode node){
    if (node.list == null) return; // If the node doesn't have a list quit
    final LinkedList<VpNode> ll = node.list!;
    node.unlink(); 
    ll.addFirst(node); 
  }

  bool _isIdBlocked(String id){
    return _blockedIds.contains(id);
  }

}