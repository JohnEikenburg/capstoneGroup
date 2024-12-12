//
//  WebRTCManager.swift
//  webrtc 3
//
//  Created by Lynn Pham on 12/10/24.
//

import SwiftUI

struct ContentView: View {
    // Instance of WebRTCManager
    @StateObject private var webRTCManager = WebRTCManager()

    var body: some View {
        VStack {
            // Show Raspberry Pi video feed using VideoView
            if let videoTrack = webRTCManager.remoteVideoTrack {
                VideoView(videoTrack: videoTrack)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            } else {
                // Placeholder UI
                Text("Waiting for video...")
                    .foregroundColor(.gray)
                    .padding()
            }

            // Button to initiate WebRTC connection
            Button("Connect") {
                // Connect to signaling server
                webRTCManager.connectToSignalingServer()
                // Begin WebRTC negotiation process
                webRTCManager.createOffer()
            }
            .padding()
        }
        // Make video full screen
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
