import AVFoundation
import Accelerate

class WaveformGenerator {
    let audioBuffer: AVAudioPCMBuffer
    private var isCancelled = false
    
    init(audioBuffer: AVAudioPCMBuffer) {
        self.audioBuffer = audioBuffer
    }
    
    func cancel() {
        isCancelled = true
    }
    
    func generateWaveformData(width: CGFloat, completion: @escaping (Int, WaveformData) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let channels = Int(self.audioBuffer.format.channelCount)
            let length = Int(self.audioBuffer.frameLength)
            let samplesPerPoint = length / Int(width)
            
            guard let floatChannelData = self.audioBuffer.floatChannelData else { return }
            
            DispatchQueue.concurrentPerform(iterations: Int(width)) { point in
                // don't begin work if the generator has been cancelled
                guard !self.isCancelled else { return }
                
                var data: WaveformData = .zero
                for channel in 0..<channels {
                    let pointer = floatChannelData[channel].advanced(by: point * samplesPerPoint)
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
