import AVFoundation
import SwiftUI

class WaveformAudio: ObservableObject {
    let audioFile: AVAudioFile
    let audioBuffer: AVAudioPCMBuffer
    
    private var generateTask: GenerateTask?
    @Published private(set) var sampleData: [SampleData] = []
    @Published var renderSamples: SampleRange
    
    var width: CGFloat = 0      // would publishing this be bad?
    
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
        generateTask = GenerateTask(audioBuffer: audioBuffer)
        
        generateTask?.resume(width: width, renderSamples: renderSamples) { sampleData in
            self.sampleData = sampleData
        }
    }
    
    // MARK: Conversions
    func position(of sample: Int) -> CGFloat {
        let radio = width / CGFloat(renderSamples.count)
        return CGFloat(sample - renderSamples.lowerBound) * radio
    }
    
    func sample(for position: CGFloat) -> Int {
        let ratio = CGFloat(renderSamples.count) / width
        return renderSamples.lowerBound + Int(position * ratio)
    }
}
