import 'package:e2e/pages/video_call.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({Key? key}) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  final sdpController = TextEditingController();
  bool _offer = false;
  bool _candidateSent = false;

  IO.Socket socket = IO.io('http://192.168.0.102:3000/', <String, dynamic>{
    'transports': ['websocket'],
    'autoconnect': false,
  });

  _connect() {
    print('establishing connection...');
    socket.connect();
    socket.onConnect((data) {
      print('connected ${socket.id}');
    });
    socket.on('message', (data) async {
      if (data['type'] == 'answer' || data['type'] == 'offer') {
        setState(() {
          _offer = data['type'] == 'offer' ? true : false;
        });
        print("\ncalling _setRemoteDescription ${data['type']}\n");
        _setRemoteDescription(data['sdp'], data['type']);
      } else if (data['type'] == 'candidate' && !_offer) {
        _addCandidate(data['candidate']);
      }
    });
  }

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    initRenderer();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    // _getUserMedia();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
    await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      print(e.toMap());
      if (e.candidate != null && !_candidateSent && _offer) {
        socket.emit('message', {
          'type': 'candidate',
          'candidate': {
            'sdpMLineIndex': e.sdpMLineIndex,
            'sdpMid': e.sdpMid,
            'candidate': e.candidate,
          },
        });
        setState(() {
          _candidateSent = true;
        });
      }
    };

    pc.onIceConnectionState = (e) {
      print("onIceConnectionState ${e}");
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };

    return pc;
  }

  _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    _localRenderer.srcObject = stream;
    // _localRenderer.mirror = true;

    return stream;
  }

  void _createOffer() async {
    RTCSessionDescription description =
    await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    // print(json.encode(session));
    print("Offer Created ...");
    socket.emit('message', {'type': 'offer', 'sdp': session});
    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    print("Answer Created ...");
    RTCSessionDescription description =
    await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    socket.emit('message', {'type': 'answer', 'sdp': session});
    _peerConnection?.setLocalDescription(description);
  }

  void _setRemoteDescription(receivedSdp, type) async {
    String sdp = write(receivedSdp, null);
    RTCSessionDescription description = RTCSessionDescription(sdp, type);
    await _peerConnection!.setRemoteDescription(description);
  }

  void _addCandidate(session) async {
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection!.addCandidate(candidate);
    print("ice candidate added ${session['candidate']}");
  }

  SizedBox videoRenderers() => SizedBox(
      height: 210,
      child: Row(children: [
        Flexible(
          child: Container(
              key: Key("local"),
              margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: BoxDecoration(color: Colors.black),
              child: RTCVideoView(_localRenderer)),
        ),
        Flexible(
          child: Container(
              key: Key("remote"),
              margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: BoxDecoration(color: Colors.black),
              child: RTCVideoView(_remoteRenderer)),
        )
      ]));

  Row offerAndAnswerButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        ElevatedButton(
          onPressed: _createOffer,
          child: Text('Offer'),
          // color: Colors.amber,
        ),
        ElevatedButton(
          onPressed: _createAnswer,
          child: Text('Answer'),
          style: ElevatedButton.styleFrom(primary: Colors.amber),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Column(
              children: [
                videoRenderers(),
                offerAndAnswerButtons(),
              ],
            )));
  }
}
