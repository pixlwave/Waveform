import AVFoundation
import SwiftUI

class WaveformAudio: ObservableObject {
    let audioFile: AVAudioFile
    let audioBuffer: AVAudioPCMBuffer
    
    init?(audioFile: AVAudioFile) {
        let capacity = AVAudioFrameCount(audioFile.length)
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: capacity) else { return nil }
        
        do {
            try audioFile.read(into: audioBuffer)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        self.audioFile = audioFile
        self.audioBuffer = audioBuffer
    }
}
