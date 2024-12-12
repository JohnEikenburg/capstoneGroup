//
//  VideoView.swift
//  webrtc 3
//
//  Created by Lynn Pham on 12/11/24.
//

// Displays Raspberry Pi video

import SwiftUI
import WebRTC

struct VideoView: UIViewRepresentable {
    // Video track is Raspberry Pi's video
    let videoTrack: RTCVideoTrack?

    func makeUIView(context: Context) -> RTCMTLVideoView {
        let videoView = RTCMTLVideoView()
        videoView.contentMode = .scaleAspectFit
        return videoView
    }

    // Attach the remote video track to the Metal video view
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        videoTrack?.add(uiView)
    }
}

