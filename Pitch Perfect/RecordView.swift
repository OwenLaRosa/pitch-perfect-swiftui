//
//  RecordView.swift
//  Pitch Perfect
//
//  Created by Owen LaRosa on 6/6/19.
//  Copyright © 2019 Owen LaRosa. All rights reserved.
//

import SwiftUI

struct RecordView : View {
    
    @ObjectBinding var audioData: AudioData
    
    var body: some View {
        return NavigationView {
            VStack {
                Spacer()
                if audioData.recordingState == .recording {
                    Text("Recording in Progress...")
                } else {
                    Text("Tap to Record")
                }
                Spacer()
                NavigationButton(destination: PlaybackView(audioData: audioData), isDetail: false, onTrigger: { () -> Bool in
                    if self.audioData.recordingState == .recording {
                        self.audioData.stopRecording()
                        return true
                    } else {
                        self.audioData.recordAudio()
                        return false
                    }
                }) {
                    audioData.recordingState == .recording ? Image("Stop").renderingMode(.original) : Image("Record").renderingMode(.original)
                }
                Spacer()
                }
                .navigationBarItem(title: Text("Pitch Perfect"), titleDisplayMode: .inline, hidesBackButton: false)
        }
    }
}

#if DEBUG
struct RecordView_Previews : PreviewProvider {
    static var previews: some View {
        RecordView(audioData: AudioData())
    }
}
#endif
