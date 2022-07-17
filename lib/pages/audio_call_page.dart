import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({Key? key}) : super(key: key);

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  final sdpController = TextEditingController();
  bool _offer = false;
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

  // conenct to socket
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
      }
    });
  }

  _closeConnection() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket.disconnect();
    _peerConnection?.close();
  }

  @override
  dispose() {
    _closeConnection();
    super.dispose();
  }

  @override
  void initState() {
    initRenderer();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    // _getUserMedia();
    _connect();
    super.initState();
  }

  initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        // {"url": "stun:stun.l.google.com:19302"},
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
        if (e.name.toString() == "RTCIceConnectionStateChecking") {
          logList.add('Connecting...');
        }
        if (e.name.toString() == "RTCIceConnectionStateConnected") {
          logList.add('Connected');
        }
        if (e.name.toString() == "RTCIceConnectionStateDisconnected") {
          logList.add('Disconnected');
        }
      });
      print('iceConnectionState ${e.name.toString()}');
    };

    pc.onAddStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };

    return pc;
  }

  _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': false,
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRenderer.srcObject = stream;
    // _localRenderer.mirror = true;

    return stream;
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReceiveAudio': 1});
    var session = parse(description.sdp.toString());
    // print(json.encode(session));
    socket.emit('msg', {'type': 'offer', 'sdp': session});
    _peerConnection!.setLocalDescription(description);

  }

  void _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection!.createAnswer({'offerToReceiveAudio': 1});
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
  }

  Row offerAndAnswerButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        !_offer
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
                },
                child: const Text('Answer'),
                style: ElevatedButton.styleFrom(primary: Colors.amber),
              ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                offerAndAnswerButtons(),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 350,
                  width: MediaQuery.of(context).size.width - 50,
                  color: Colors.black,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: List.generate(logList.length, (index) {
                        return Text(
                          logList[index],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            )));
  }
}
