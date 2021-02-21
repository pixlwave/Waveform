import AVFoundation
import SwiftUI

/// An object that generates waveform data from an `AVAudioFile`.
public class WaveformAudio: ObservableObject {
    /// The audio file initially used to create the generator.
    public let audioFile: AVAudioFile
    /// An audio buffer containing the original audio file decoded as PCM data.
    public let audioBuffer: AVAudioPCMBuffer
    
    private var generateTask: GenerateTask?
    @Published private(set) var sampleData: [SampleData] = []
    
    /// The range of samples to display. The value will update as the waveform is zoomed and panned.
    @Published public var renderSamples: SampleRange {
        didSet { refreshData() }
    }
    
    var width: CGFloat = 0 {     // would publishing this be bad?
        didSet { refreshData() }
    }
    
    /// Creates an instance from an `AVAudioFile`.
    /// - Parameter audioFile: The audio file to generate waveform data from.
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
