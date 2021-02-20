import AVFoundation
import Accelerate

class GenerateWaveformTask {
    let audioBuffer: AVAudioPCMBuffer
    private var isCancelled = false
    
    init(audioBuffer: AVAudioPCMBuffer) {
        self.audioBuffer = audioBuffer
    }
    
    func cancel() {
        isCancelled = true
    }
    
    func resume(width: CGFloat, renderSamples: ClosedRange<Int>, completion: @escaping (Int, SampleData) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let channels = Int(self.audioBuffer.format.channelCount)
            let length = renderSamples.count
            let samplesPerPoint = length / Int(width)
            
            guard let floatChannelData = self.audioBuffer.floatChannelData else { return }
            
            DispatchQueue.concurrentPerform(iterations: Int(width)) { point in
                // don't begin work if the generator has been cancelled
                guard !self.isCancelled else { return }
                
                var data: SampleData = .zero
                for channel in 0..<channels {
                    let pointer = floatChannelData[channel].advanced(by: renderSamples.lowerBound + (point * samplesPerPoint))
                    let stride = vDSP_Stride(self.audioBuffer.stride)
                    let length = vDSP_Length(samplesPerPoint)
                    
                    var value: Float = 0
                    
                    // calculate minimum value for point
                    vDSP_minv(pointer, stride, &value, length)
                    data.min = min(value, data.min)
                    
                    // calculate maximum value for point
                    vDSP_maxv(pointer, stride, &value, length)
                    data.max = max(value, data.max)
                }
                
                DispatchQueue.main.async {
                    // don't submit completed work if the generator has been cancelled
                    guard !self.isCancelled else { return }
                    completion(point, data)
                }
            }
        }
    }
}
