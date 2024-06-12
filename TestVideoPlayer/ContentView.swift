//
//  ContentView.swift
//  TestVideoPlayer
//
//  Created by Oleksandr Balahurov on 07.05.2024.
//

import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    private let videoURL = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!
    @State private var title = ""
    @State private var play = false
    @State private var time: CMTime = .zero
    @State private var isControlViewHidden = false
    @State private var playProgress: Double = 0
    @State private var bufferProgress: Double = 0
    
    var body: some View {
        CustomVideoPlayer(
            url: videoURL,
            play: $play,
            time: $time
        )
        .contentMode(.scaleAspectFit)
        .onStateChanged { state in
            handleStateChanged(state)
        }
        .ignoresSafeArea()
        .overlay {
            if !isControlViewHidden {
                ZStack {
                    Color.black.opacity(0.1)
                    
                    VStack(spacing: 20) {
                        Text(title)
                        
                        VideoControlView(isPlaying: play) { action in
                            handleControlAction(action)
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
        .task {
            title = await videoTitle()
        }
        .onTapGesture {
            isControlViewHidden.toggle()
        }
    }
    
    private func handleStateChanged(_ state: CustomVideoPlayer.State) {
        print(state)
        switch state {
        case .paused(let playProgress, let bufferProgress):
            self.playProgress = playProgress
            self.bufferProgress = bufferProgress
        default:
            break
        }
    }
    
    private func handleControlAction(_ action: VideoControlAction) {
        switch action {
        case .playToggle:
            if playProgress >= 1 {
                time = CMTimeMakeWithSeconds(0, preferredTimescale: time.timescale)
            }
            play.toggle()
            isControlViewHidden = play
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

struct ContentView2: View {
    @State var player = AVPlayer(
        url: URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!
    )
    @State var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            VideoPlayer(player: player) {
                HStack {
                    Button {
                        isPlaying ? player.pause() : player.play()
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "stop" : "play")
                            .padding()
                    }
                    
                    Button {
                        player.seek(to: .zero)
                    } label: {
                        Text("Zero")
                    }
                    
                    Button {
                        let currentTime = player.currentTime()
                        let newTime = CMTimeAdd(currentTime, CMTime(seconds: -10, preferredTimescale: 1))
                        player.seek(to: newTime)
                        player.play()
                    } label: {
                        Text("<")
                    }

                    Button {
                        let currentTime = player.currentTime()
                        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
                        player.seek(to: newTime)
                        player.play()
                    } label: {
                        Text(">")
                    }
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200, alignment: .center)
        }
    }
}

struct ContentView3: View {
    @State var player = AVPlayer(
        url: URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!
    )
    @State private var isControlViewHidden = false

    var body: some View {
        AVPlayerControllerRepresented(player: player)
            .onAppear {
                player.play()
            }
            .overlay {
                if !isControlViewHidden {
                    ZStack {
                        Color.black.opacity(0.1)
                        
                        VStack(spacing: 20) {
                            Text("title")
                            
                            VideoControlView(isPlaying: player.timeControlStatus == .playing) { action in
                                handleControlAction(action)
                            }
                        }
                    }
                    .ignoresSafeArea()
                }
            }
            .onTapGesture {
                isControlViewHidden.toggle()
            }
    }
    
    private func handleControlAction(_ action: VideoControlAction) {
        switch action {
        case .playToggle:
            if player.playProgress >= 1 {
                player.seek(to: .zero)
            }
            player.timeControlStatus == .playing ? player.pause() : player.play()
        case .fastForward:
            let currentTime = player.currentTime()
            let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
            player.seek(to: newTime)
            player.play()
        case .rewind:
            let currentTime = player.currentTime()
            let newTime = CMTimeAdd(currentTime, CMTime(seconds: -10, preferredTimescale: 1))
            player.seek(to: newTime)
            player.play()
        }
    }
}

struct AVPlayerControllerRepresented : UIViewControllerRepresentable {
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}


#Preview {
    ContentView3()
}

