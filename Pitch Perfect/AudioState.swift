//
//  AudioState.swift
//  Pitch Perfect
//
//  Created by Owen LaRosa on 6/6/19.
//  Copyright © 2019 Owen LaRosa. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation

enum RecordingState {
    case recording, notRecording
}

enum PlayingState {
    case playing, notPlaying
}

class AudioData: NSObject, BindableObject, AVAudioRecorderDelegate {
    
    let didChange = PassthroughSubject<AudioData, Never>()
    
    var recordingState: RecordingState = .notRecording {
        didSet {
            didChange.send(self)
        }
    }
    
    var playingState: PlayingState = .notPlaying {
        didSet {
            didChange.send(self)
        }
    }
    
    var recordingUrl: URL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        return filePath!
    }
    
    var audioRecorder: AVAudioRecorder!
    
    func recordAudio() {
        recordingState = .recording
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        do {
            try audioRecorder = AVAudioRecorder(url: recordingUrl, settings: [:])
        } catch {
            print(error.localizedDescription)
        }

        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingState = .notRecording
    }
    
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        // stop ongoing audio playback
        stopAudio()
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        let audioFile = try! AVAudioFile(forReading: recordingUrl)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioFile: audioFile, audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioFile: audioFile, audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioFile: audioFile, audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioFile: audioFile, audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(audioFile.length - playerTime.sampleTime) / Double(audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(audioFile.length - playerTime.sampleTime) / Double(audioFile.processingFormat.sampleRate)
                }
            }
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(AudioData.stopAudio), userInfo: nil, repeats: false)
        }
        
        do {
            try audioEngine.start()
        } catch {
            return
        }
        
        playingState = .playing
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    func connectAudioNodes(audioFile: AVAudioFile, _ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    @objc func stopAudio() {

        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }

        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        playingState = .notPlaying

        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
}
