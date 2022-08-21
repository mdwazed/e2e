import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  final sdpController = TextEditingController();

  bool _offer = false;
  bool _connected = false;
  bool _candidateSent = false;
  List logList = [];
  bool _clickedCall = false;
  bool _clickedCAnswer = false;

  IO.Socket socket = IO.io(
      'https://rt-comm-server.b664fshh19btg.eu-central-1.cs.amazonlightsail.com',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoconnect': false,
      });

  _connect() {
    setState(() {
      logList.add('establishing connection...');
    });
    socket.connect();
    socket.onConnect((data) {
      setState(() {
        logList.add('connected ${socket.id}');
      });
    });
    socket.on('msg', (data) async {
      if (data['type'] == 'offer') {
        _setRemoteDescription(data['sdp'], data['type']);
        setState(() {
          _offer = data['type'] == 'offer' ? true : false;
        });
        if (_clickedCAnswer) {
          _createAnswer();
          setState(() {
            _clickedCAnswer = false;
          });
        } else {
          FlutterRingtonePlayer.playRingtone(volume: 10.0);
        }
      } else if (data['type'] == 'answer') {
        _setRemoteDescription(data['sdp'], data['type']);
        if (_clickedCall) {
          _createOffer();
          setState(() {
            _clickedCall = false;
          });
        }
      } else if (data['type'] == 'candidate' && !_offer) {
        _addCandidate(data['candidate']);
      } else if (data['type'] == 'disconnect') {
        _disconnect();
      }
    });
  }

  _disconnect() {
    setState(() {
      _offer = false;
      _connected = false;
      _candidateSent = false;
      logList = ['Call Disconnected By User'];
      _clickedCall = false;
      _clickedCAnswer = false;
    });
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _reRenderVideo();
    _peerConnection?.close();
  }

  _reRenderVideo() {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    initRenderer();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
    });
  }

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    sdpController.dispose();
    // socket.disconnect();
    _disconnect();
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    initRenderer();
    _connect();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
    });
    if (socket.connected){
      setState(() {
        logList.add('connected ${socket.id}');
      });
    }
    Wakelock.enable();
    super.initState();
  }

  initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
        {
          "urls": "turn:openrelay.metered.ca:80",
          "username": "openrelayproject",
          "credential": "openrelayproject",
        },
        {
          "urls": "turn:openrelay.metered.ca:443",
          "username": "openrelayproject",
          "credential": "openrelayproject",
        },
        {
          "urls": "turn:openrelay.metered.ca:443?transport=tcp",
          "username": "openrelayproject",
          "credential": "openrelayproject",
        },
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
      if (e.candidate != null && !_candidateSent && _offer) {
        //if (e.candidate != null) {
        socket.emit('msg', {
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
      setState(() {
        if (e.name.toString() == "RTCIceConnectionStateChecking") {
          logList.add('Trying to connect call...');
        }
        if (e.name.toString() == "RTCIceConnectionStateConnected") {
          logList.add('Connected..!');
          _connected = true;
        }
        if (e.name.toString() == "RTCIceConnectionStateDisconnected") {
          logList.add('Disconnected :( ');
          _connected = false;
        }
      });
    };

    pc.onAddStream = (stream) {
      logList.add('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };

    return pc;
  }

  _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    _localRenderer.srcObject = stream;

    return stream;
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    socket.emit('msg', {'type': 'offer', 'sdp': session});
    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    socket.emit('msg', {'type': 'answer', 'sdp': session});
    _peerConnection!.setLocalDescription(description);
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
  }

  Row offerAndAnswerButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        _connected
            ? ElevatedButton(
          onPressed: () {
            _disconnect();
            socket.emit('msg', {
              'type': 'disconnect',
            });
          },
          child: const Text(
            'Disconnect',
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
        )
            : !_offer
            ? ElevatedButton(
          onPressed: () {
            _createOffer();
            setState(() {
              _clickedCall = true;
            });
          },
          child: const Text('Call'),
          // color: Colors.amber,
        )
            : ElevatedButton(
          onPressed: () {
            _createAnswer();
            setState(() {
              _clickedCAnswer = true;
            });
            FlutterRingtonePlayer.stop();
          },
          child: const Text('Answer'),
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
        Container(
          margin: const EdgeInsets.only(top: 20),
          height: 250,
          width: MediaQuery.of(context).size.width - 50,
          color: Colors.black,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(logList.length, (index) {
                return Text(
                  logList[index],
                  style: const TextStyle(color: Colors.white),
                );
              }),
            ),
          ),
        ),
      ],
    )));
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
}
