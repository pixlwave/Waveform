import AVFoundation
import SwiftUI

class WaveformAudio: ObservableObject {
    let audioFile: AVAudioFile
    let audioBuffer: AVAudioPCMBuffer
    
    private var generateTask: GenerateWaveformTask?
    @Published private(set) var sampleData: [SampleData] = []
    @Published var renderSamples: ClosedRange<Int>
    
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
        self.renderSamples = 0...Int(capacity)
    }
    
    func refreshData(width: CGFloat) {
        generateTask?.cancel()
        generateTask = GenerateWaveformTask(audioBuffer: audioBuffer)
        
        sampleData = [SampleData](repeating: .zero, count: Int(width))
        generateTask?.resume(width: width, renderSamples: renderSamples) { index, data in
            self.sampleData[index] = data
        }
    }
}
