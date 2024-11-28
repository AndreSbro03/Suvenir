// ignore_for_file: non_constant_identifier_names

import 'dart:collection';
import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

final class VpNode extends LinkedListEntry<VpNode> {
  final String id;
  final VideoPlayerController vp;
  VpNode(this.id, this.vp);
}

class VideoPlayerManager {

  final int _maxVp = 3;
  final LinkedList<VpNode> _vps = LinkedList<VpNode>();


  /// If already exist a vp for an AssetEntity in the vps:
  ///   - Move the vp in head of vps.
  ///   - Return it.
  /// If not check if the vps.length >= _maxVp and if so dispose the last vp then:
  ///   - Create the new vp.
  ///   - Add it to the haed of vps.
  ///   - Return it.
  Future<VideoPlayerController> request(AssetEntity video) async {

    VpNode? node = _search(video.id);

    if(node != null){
      _move_to_head(node);
      return node.vp;
    } 
      
    if(_vps.length >= _maxVp) {
      _remove_tail();
    }

    VideoPlayerController vp = await _create_vp(video);
    _insert_head(video.id, vp);

    return vp;
  }

  /// Ensure that all the vp in vps are paused.
  void pauseAll() {
    for (VpNode node in _vps) {
      node.vp.pause();
    }
  }

  /// Create a vp for a specific AssetEntity and return it.
  Future<VideoPlayerController> _create_vp( AssetEntity video) async{
    final File? videoFile = await video.file;

    VideoPlayerController vp = VideoPlayerController.file(videoFile!, videoPlayerOptions: VideoPlayerOptions(
      /// With this option if the user is listening music from Spotify, for example, the video wont stop the
      /// music but will play the audio on top of it.
      mixWithOthers: true
    ))
      ..play()
      ..setLooping(true)
      ..initialize();

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

  /// Create the node and insert the vp in the head of vps.
  void _insert_head(String id, VideoPlayerController vp){
    _vps.addFirst(VpNode(id, vp));
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