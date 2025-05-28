//
//  TipScreenView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/8/25.
//

import SwiftUI
import AVKit

struct TipScreenView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var videoManager = LoopingVideoPlayer(filename: "explanation", filetype: "mp4")

    var body: some View {
        VStack {
            Text("Tip: You can press on the times to find out more information on them!")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            // Video takes up all available space
            VideoPlayer(player: videoManager.player)
                .onAppear {
                    videoManager.play()
                }
                .onDisappear {
                    videoManager.stop()
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
            
            Button {
                goBackToRootView()
            } label: {
                Text("Okay")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(Color.black)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Tip!")
    }


    private func goBackToRootView() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
          return
        }
        guard let firstWindow = firstScene.windows.first else {
          return
        }
        firstWindow.rootViewController = UIHostingController(rootView: ContentView())
        firstWindow.makeKeyAndVisible()
    }
}

import AVFoundation

class LoopingVideoPlayer: ObservableObject {
    let player: AVPlayer
    private var playerLooper: Any?

    init(filename: String, filetype: String) {
        if let path = Bundle.main.path(forResource: filename, ofType: filetype) {
            let url = URL(fileURLWithPath: path)
            self.player = AVPlayer(url: url)
            self.player.isMuted = true

            // Loop playback manually
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                self.player.seek(to: .zero)
                self.player.play()
            }
        } else {
            self.player = AVPlayer()
        }
    }

    func play() {
        player.play()
    }

    func stop() {
        player.pause()
    }
}

#Preview {
    TipScreenView()
}
