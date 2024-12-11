import SwiftUI
import WebRTC
import SocketIO

class WebRTCViewModel: ObservableObject {
    // WebRTC needs some kind of actual connection in order to be created. This connection is made via SocketIO.
    private var socket: SocketIOClient!
    // Variables to establish peer connection between phone and Raspi.
    private var peerConnectionFactory: RTCPeerConnectionFactory!
    private var peerConnection: RTCPeerConnection?
    // Variables to display the Raspi video (displaying and rendering using Metal).
    private var remoteVideoTrack: RTCVideoTrack?
    private var videoView: RTCMTLVideoView?

    init() {
        setupWebRTC()
    }

    // Set up WebRTC.
    func setupWebRTC() {
        peerConnectionFactory = RTCPeerConnectionFactory()
        // Make the view for displaying video.
        videoView = RTCMTLVideoView(frame: .zero)
        setupWebSocket()
    }

    // Set up WebSocket connection to Raspi server. Handles signaling.
    func setupWebSocket() {
        // Raspi's IP on the local network (its own WiFi) needed.
        // *********** This is undergoing revision. **********
        let socketManager = SocketManager(socketURL: URL(string: "ws://<raspberry_pi_ip>:8765")!, config: [.log(true), .compress])
        socket = socketManager.defaultSocket

        // Handles phone's connection to WebSocket. Once connected, sends an SDP offer
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected!")
            self.sendOffer()
        }

        // Receives an SDP "answer" from the Raspi
        socket.on("answer") { data, ack in
            // Handle SDP Answer from Raspberry Pi
            if let answer = data[0] as? [String: Any] {
                self.handleSDPAnswer(answer)
            }
        }

        // Listens for ICE candidates from the Raspi (finds the best network path)
        socket.on("candidate") { data, ack in
            if let candidate = data[0] as? [String: Any] {
                self.handleICECandidate(candidate)
            }
        }

        // Establishes socket connection
        socket.connect()
    }

    // Makes an SDP offer and sends it to the Raspi
    func sendOffer() {
        // RTCSessionDescription needed for WebRTC to start peer connection
        let offer = RTCSessionDescription(type: .offer, sdp: "Offer SDP here")
        socket.emit("offer", ["sdp": offer.sdp, "type": offer.type.rawValue])
    }

    // ******** I have been getting many errors with the rest of the commands below. *******

    // Parses SDP answer from Raspi's JSON format and makes an RTCSessionDescription
    func handleSDPAnswer(_ answer: [String: Any]) {
        // Handle the SDP Answer received from Raspberry Pi
        if let sdpString = answer["sdp"] as? String, let typeString = answer["type"] as? String {
            let type: RTCSessionDescriptionType
            if typeString == "offer" {
                type = .offer
            } else if typeString == "answer" {
                type = .answer
            } else {
                print("Unknown SDP type")
                return
            }

            let answerSDP = RTCSessionDescription(type: type, sdp: sdpString)  // Correct way to initialize RTCSessionDescription
            peerConnection?.setRemoteDescription(answerSDP, completionHandler: { error in
                if let error = error {
                    print("Error setting remote description: \(error)")
                }
            })
        }
    }


    // Handles ICE candidate from Raspi
    func handleICECandidate(_ candidate: [String: Any]) {
        if let sdpMid = candidate["sdpMid"] as? String, let sdpMLineIndex = candidate["sdpMLineIndex"] as? Int,
           let candidateString = candidate["candidate"] as? String {
            let iceCandidate = RTCIceCandidate(sdpMid: sdpMid, sdpMLineIndex: Int32(sdpMLineIndex), candidate: candidateString)
            peerConnection?.add(iceCandidate)
        }
    }

    // Makes peer connection and starts the stream
    func startStream() {
        let config = RTCConfiguration()
        config.sdpSemantics = .unifiedPlan
        peerConnection = peerConnectionFactory.peerConnection(with: config, constraints: RTCMediaConstraints(), delegate: self)
        // Set up video track for rendering
        peerConnection?.addTrack(remoteVideoTrack!)
    }
}

/* This bit was written in a content view. Idk how to mix it in with the existing UI though.
struct ContentView: View {
    @StateObject private var viewModel = WebRTCViewModel()

    var body: some View {
        VStack {
            RTCMTLVideoViewWrapper(videoView: viewModel.videoView)
                .frame(width: 320, height: 240)
                .background(Color.black)

            Button("Start Taking Video") {
                viewModel.startStream()
            }
            .padding()
        }
        .onAppear {
            viewModel.setupWebRTC()
        }
    }
}

struct RTCMTLVideoViewWrapper: UIViewRepresentable {
    var videoView: RTCMTLVideoView?

    func makeUIView(context: Context) -> RTCMTLVideoView {
        return videoView ?? RTCMTLVideoView(frame: .zero)
    }

    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {}
}

extension WebRTCViewModel: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        if let videoTrack = stream.videoTracks.first {
            self.remoteVideoTrack = videoTrack
            videoTrack.add(self.videoView!)
        }
    }
}


#Preview {
    ContentView()
}
*/