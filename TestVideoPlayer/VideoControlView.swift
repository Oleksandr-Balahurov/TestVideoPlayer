//
//  VideoControlView.swift
//  TestVideoPlayer
//
//  Created by Oleksandr Balahurov on 08.05.2024.
//

import SwiftUI

enum VideoControlAction {
    case playToggle
    case fastForward
    case rewind
}

struct VideoControlView: View {
    let isPlaying: Bool
    let controlAction: (VideoControlAction) -> Void
    
    var body: some View {
        HStack(spacing: 28) {
            button(for: .rewind)
            button(for: .playToggle)
            button(for: .fastForward)
        }
        .foregroundStyle(.black)
        
    }
    
}

private extension VideoControlView {
    func button(for action: VideoControlAction) -> some View {
        Button {
            controlAction(action)
        } label: {
            image(for: action)
        }
    }
    
    func image(for action: VideoControlAction) -> some View {
        let systemName: String
        switch action {
        case .playToggle:
            systemName = isPlaying ? "pause.fill" : "play.fill"
        case .fastForward:
            systemName = "goforward.10"
        case .rewind:
            systemName = "gobackward.5"
        }
        
        return Image(systemName: systemName)
            .resizable()
            .frame(width: 32, height: 32)
            .foregroundStyle(.gray)
    }
    
}
