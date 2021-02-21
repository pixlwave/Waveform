import AVFoundation
import SwiftUI

public class WaveformAudio: ObservableObject {
    public let audioFile: AVAudioFile
    public let audioBuffer: AVAudioPCMBuffer
    
    private var generateTask: GenerateTask?
    @Published private(set) var sampleData: [SampleData] = []
    @Published public var renderSamples: SampleRange {
        didSet { refreshData() }
    }
    
    var width: CGFloat = 0 {     // would publishing this be bad?
        didSet { refreshData() }
    }
    
    public init?(audioFile: AVAudioFile) {
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
        self.renderSamples = 0..<Int(capacity)
    }
    
    func refreshData() {
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
        let sample = renderSamples.lowerBound + Int(position * ratio)
        return min(max(0, sample), Int(audioBuffer.frameLength))
    }
    
    func sample(_ oldSample: Int, with offset: CGFloat) -> Int {
        let ratio = CGFloat(renderSamples.count) / width
        let sample = oldSample + Int(offset * ratio)
        return min(max(0, sample), Int(audioBuffer.frameLength))
    }
}
