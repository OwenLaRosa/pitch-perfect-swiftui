//
//  PlaybackView.swift
//  Pitch Perfect
//
//  Created by Owen LaRosa on 6/6/19.
//  Copyright © 2019 Owen LaRosa. All rights reserved.
//

import SwiftUI
import AVFoundation

struct PlaybackView : View {
    
    @ObjectBinding var audioData: AudioData
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select a sound filter").padding()
                HStack {
                    Button(action: {
                        self.audioData.playSound(rate: 0.5)
                    }) {
                        Image("Slow").renderingMode(.original)
                    }
                    Button(action: {
                        self.audioData.playSound(rate: 2.0)
                    }) {
                        Image("Fast").renderingMode(.original)
                    }
                }
                HStack {
                    Button(action: {
                        self.audioData.playSound(pitch: 1000)
                    }) {
                        Image("HighPitch").renderingMode(.original)
                    }
                    Button(action: {
                        self.audioData.stopAudio()
                    }) {
                        Image("Pause")
                    }.foregroundColor(Color.black)
                    Button(action: {
                        self.audioData.playSound(pitch: -1000)
                    }) {
                        Image("LowPitch").renderingMode(.original)
                    }
                }
                HStack {
                    Button(action: {
                        self.audioData.playSound(echo: true)
                    }) {
                        Image("Echo").renderingMode(.original)
                    }
                    Button(action: {
                        self.audioData.playSound(reverb: true)
                    }) {
                        Image("Reverb").renderingMode(.original)
                    }
                }
                Spacer()
            }
        }.navigationBarItem(title: Text("Pitch Perfect"), titleDisplayMode: .inline, hidesBackButton: false)
    }
    
}

#if DEBUG
struct PlaybackView_Previews : PreviewProvider {
    static var previews: some View {
        PlaybackView(audioData: AudioData())
    }
}
#endif
