//
//  ButtonFeedBack.swift
//  WanderBoard
//
//  Created by David Jang on 7/1/24.
//

import SwiftUI
import AVFoundation

struct ButtonFeedBack: View {
    @State private var showFeedback = false
    @State private var showPin = false
    @State private var showText = false
//    @State private var feedbackText = "완료!"
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            Spacer()

            if showFeedback {
                VStack {
                    if showPin {
                        Image("pin")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .transition(.move(edge: .top))
                    }
                    
//                    if showText {
//                        Text(feedbackText)
//                            .foregroundColor(.white)
//                            .padding(.top, -16)
//                    }
                }
                .frame(width: 80, height: 80)
                .background(Color.black.opacity(0.5))
                .cornerRadius(40)
                .onAppear {
                    withAnimation(.bouncy(duration: 0.6)) {
                        self.showPin = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
//                            self.showText = true
                        }
                        playSoundIfNotSilent()
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation {
                                self.showFeedback = false
                                self.showPin = false
//                                self.showText = false
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            self.triggerFeedback()
        }
    }

    private func triggerFeedback() {
        withAnimation {
            self.showFeedback = true
        }
    }

    private func playSoundIfNotSilent() {
        if !isDeviceInSilentMode() {
            playSound()
        }
    }

    private func isDeviceInSilentMode() -> Bool {
        let session = AVAudioSession.sharedInstance()
        return session.outputVolume == 0
    }

    private func playSound() {
        if let soundURL = Bundle.main.url(forResource: "success", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
}
