import AVFoundation
import SwiftUI

class WaveformAudio: ObservableObject {
    let audioFile: AVAudioFile
    let audioBuffer: AVAudioPCMBuffer
    
    private var generateTask: GenerateWaveformTask?
    @Published private(set) var sampleData: [SampleData] = []
    
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
    
    func refreshData(width: CGFloat, startSample: Int, endSample: Int) {
        generateTask?.cancel()
        generateTask = GenerateWaveformTask(audioBuffer: audioBuffer)
        
        sampleData = [SampleData](repeating: .zero, count: Int(width))
        generateTask?.resume(width: width, startSample: startSample, endSample: endSample) { index, data in
            self.sampleData[index] = data
        }
    }
}
