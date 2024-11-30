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
  /// Id of the videoPlayer that is being creted. 
  String? _creatingVp;

  /// If an id is setted when a vp is created if the id of the video is equal to this variable value than the video will play.
  String? playVpId;


  /// Notify other function that a vp is being created updating _creatingVp.
  /// If already exist a vp for an AssetEntity in the vps:
  ///   - Move the vp in head of vps.
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
      _move_to_head(node);
      if(_printDebugInfo) print("[INFO] Finded vp for video: ${video.id}");
    } 
    else {
      node = _insert_head(video.id, reload, await _create_vp(video));
      if(_printDebugInfo) print("[INFO] Generated vp for video: ${video.id}");
    }

    if(_printDebugInfo) _printList();
    if(video.id == playVpId) node.vp.play();
    _creatingVp = null;
    return node;
  }

  /// Try to play the vp corralated to the id once if exist. Update reload value.
  void play(String? id) {
    if(id == null) return;

    for (VpNode node in _vps) {
        if(node.id == id) {
          node.vp.play().then( (_) { if(node.reload != null) node.reload!.value++;});
        return;
      }
    }

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

    if (_creatingVp == id) {
      return;
    }

    /// Search for the video player by ID and play it
    for (VpNode node in _vps) {
      if (node.id == id) {
        await node.vp.play();
        if (node.reload != null) {
          node.reload!.value++;
        }
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

  /// Print the list of vp
  void _printList() {
    print("[INFO] List _vps:");
    print("----------------------------");
    for (VpNode node in _vps) {
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
    ..setLooping(true);
      
    (playVpId == video.id) ? vp.play() : vp.pause();
    await vp.initialize();

    return vp;
  }

  /// Search if there is a vp of a AssetEntity already created in the vps list. Return the element if exist
  /// else return null.
  VpNode? _search(String id) {
    if(_vps.isEmpty) return null;
    try {
      return _vps.firstWhere((node) => node.id == id);
    } catch(e){
      /// Element not found.
      return null;
    }
  }

  /// If the list is full free the tail, create the new node and add it to the head. Return the node.
  VpNode _insert_head(String id, ValueNotifier<int>? vn, VideoPlayerController vp){
    if(_vps.length >= _maxVp) _remove_tail();
    VpNode vpn = VpNode(id, vn, vp);
    _vps.addFirst(vpn);
    return vpn;
  }

  /// Remove the last vp from vps and dispose the removed element.
  void _remove_tail(){
    if(_vps.isEmpty) return;
    
    VpNode tail = _vps.last;
    tail.vp.dispose();
    _vps.remove(tail);
  }

  /// Move a node to the head of vps.
  void _move_to_head(VpNode node){
    node.unlink();
    _vps.addFirst(node);
  }

}