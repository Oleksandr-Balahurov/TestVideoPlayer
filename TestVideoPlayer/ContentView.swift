//
//  ContentView.swift
//  TestVideoPlayer
//
//  Created by Oleksandr Balahurov on 07.05.2024.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    private let videoURL = URL(string: "https://assets.mixkit.co/videos/preview/mixkit-red-frog-on-a-log-1487-large.mp4")!
    @State private var title = ""
    @State private var play = false
    @State private var time: CMTime = .zero
    
    var body: some View {
        VideoPlayer(
            url: videoURL,
            play: $play,
            time: $time
        )
        .onStateChanged { handler in
            print(handler)
        }
        .ignoresSafeArea()
        .overlay {
            VStack(spacing: 20) {
                Text(title)
                
                VideoControlView(isPlaying: play) { action in
                    handleControlAction(action)
                }
            }
        }
        .task {
            title = await videoTitle()
        }
    }
    
    private func handleControlAction(_ action: VideoControlAction) {
        switch action {
        case .playToggle:
            play.toggle()
        case .fastForward:
            time = CMTimeMakeWithSeconds(time.seconds + 5, preferredTimescale: time.timescale)
        case .rewind:
            time = CMTimeMakeWithSeconds(max(0, time.seconds - 5), preferredTimescale: time.timescale)
        }
    }
    
    private func videoTitle() async -> String {
        let asset = AVAsset(url: videoURL)
        do {
            let metadata = try await asset.load(.metadata)
            let titleItems = AVMetadataItem.metadataItems(
                from: metadata,
                filteredByIdentifier: .commonIdentifierTitle
            )
            guard let item = titleItems.first else { return "" }
            return item.description
        } catch {
            return ""
        }
    }
}

#Preview {
    ContentView()
}
