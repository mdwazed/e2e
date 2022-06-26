import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
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
  List logList = [];

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
      if (data['type'] == 'answer' || data['type'] == 'offer') {
        setState(() {
          _offer = data['type'] == 'offer' ? true : false;
          logList.insert(
              0, data['type'] == 'offer' ? 'Incoming Call' : 'Replied to Call');
        });
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
        logList.add("onIceConnectionState ${e}");
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
    // _localRenderer.mirror = true;

    return stream;
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    setState(() {
      logList.add("Calling The Connected User");
    });
    socket.emit('msg', {'type': 'offer', 'sdp': session});
    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    setState(() {
      logList.add("Replying Answer for incoming call");
    });
    RTCSessionDescription description =
        await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    socket.emit('msg', {'type': 'answer', 'sdp': session});
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
    setState(() {
      logList.add("ice candidate added");
    });
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
        !_offer
            ? ElevatedButton(
                onPressed: _createOffer,
                child: const Text('Call'),
                // color: Colors.amber,
              )
            : ElevatedButton(
                onPressed: _createAnswer,
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
}
