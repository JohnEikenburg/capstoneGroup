//
//  WebRTCManager.swift
//  webrtc 3
//
//  Created by Lynn Pham on 12/10/24.
//

import SwiftUI
import WebRTC

class WebRTCManager: NSObject, ObservableObject {
    // Peer connection object needed for WebRTC
    private var peerConnection: RTCPeerConnection?
    // WebSocket used as a signalling server
    private var signalingWebSocket: URLSessionWebSocketTask?
    // Factory makes stuff
    private let factory = RTCPeerConnectionFactory()
    
    // Connection status
    @Published var isConnected = false
    // Remote video track is the Raspberry Pi's video
    @Published var remoteVideoTrack: RTCVideoTrack?

    // Initialize peer connection
    override init() {
        super.init()
        setupPeerConnection()
    }

    // Connect to the WebSocket signaling server on the Raspberry Pi. The string is the Pi's static IP on its own wifi hotspot
    func connectToSignalingServer() {
        let url = URL(string: "ws://<RASPBERRY_PI_IP>:8765")!
        signalingWebSocket = URLSession.shared.webSocketTask(with: url)
        // Make WebSocket connection
        signalingWebSocket?.resume()
        // Listen for messages from the Raspberry Pi
        listenForMessages()
    }

    // Listen for WebSocket messages (SDP offers/answers or ICE candidates)
    private func listenForMessages() {
        signalingWebSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                // Handle SDP message from WebSocket
                case .string(let sdpString):
                    let sessionDescription = RTCSessionDescription(type: .answer, sdp: sdpString)
                    self?.peerConnection?.setRemoteDescription(sessionDescription) { error in
                        if let error = error {
                            print("Could not set remote description: \(error.localizedDescription)")
                        } else {
                            print("Remote description set.")
                        }
                    }
                default:
                    break
                }
            // Handle errors
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
            // Continue listening for other messages
            self?.listenForMessages()
        }
    }

    // Configure the WebRTC peer connection
    private func setupPeerConnection() {
        let config = RTCConfiguration()
        // Use a public STUN server to help make peer to peer connection. STUN servers provide ICE candidates, or potential network paths. The most optimal one is chosen
        config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        
        // Constraints for video feed
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        // Make the actual peer connection
        peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: self)
    }
    
    // Make an SDP offer to initiate connection
    func createOffer() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        // Set up local SDP
        peerConnection?.offer(for: constraints) { [weak self] sdp, error in
            guard let sdp = sdp else { return }
            self?.peerConnection?.setLocalDescription(sdp) { error in
                // Error handling
                if let error = error {
                    print("Could not set remote description: \(error.localizedDescription)")
                } else {
                    print("Remote description set.")
                }
            }
            // Send the SDP offer to the Raspberry Pi
            self?.sendSDP(sdp)
        }
    }

    // Send the SDP offer to the Raspberry Pi
    private func sendSDP(_ sdp: RTCSessionDescription) {
        // Prepare SDP offer as a string
        let message = URLSessionWebSocketTask.Message.string(sdp.sdp)
        signalingWebSocket?.send(message) { error in
            // Error handling
            if let error = error {
                print("Error sending SDP: \(error)")
            }
        }
    }
}

extension WebRTCManager: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("Signaling state changed.")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("ICE connection state changed: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ICE gathering state changed: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("New ICE candidate: \(candidate.sdp)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("Removed ICE candidates")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("Data channel opened")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Peer connection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("Raspberry Pi stream received")
        // Extract the  video track and assign it for rendering
        if let videoTrack = stream.videoTracks.first {
            DispatchQueue.main.async { [weak self] in
                self?.remoteVideoTrack = videoTrack
            }
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("Raspberry Pi stream removed")
    }
}
