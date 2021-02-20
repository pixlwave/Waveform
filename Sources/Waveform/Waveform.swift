import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    let audioFile: AVAudioFile
    
    private let audioBuffer: AVAudioPCMBuffer
    @State private var generator: WaveformGenerator?
    @State private var waveformData: [WaveformData] = []
    
    @State private var frameSize: CGSize = .zero
    
    @State private var zoomSamples: ClosedRange<AVAudioFramePosition> = 0...1
    
    @State private var currentZoom: CGFloat = 1
    @State private var gestureZoom: CGFloat = 1
    
    init?(audioFile: AVAudioFile) {
        let capacity = AVAudioFrameCount(audioFile.length)
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: capacity) else { return nil }
        
        do {
            try audioFile.read(into: audioBuffer)
        } catch {
            return nil
        }
        
        self.audioFile = audioFile
        self.audioBuffer = audioBuffer
        
        zoomSamples = 0...AVAudioFramePosition(audioBuffer.frameLength)
    }
    
    var body: some View {
        GeometryReader { geometry in
            WaveformRenderer(waveformData: waveformData, zoom: currentZoom)
                .preference(key: SizeKey.self, value: geometry.size)
                .scaleEffect(x: gestureZoom, y: 1, anchor: .center)
        }
        .onPreferenceChange(SizeKey.self) {
            guard frameSize != $0 else { return }
            frameSize = $0
        }
        .onChange(of: frameSize) {
            print("Frame size \($0)")
            generateWaveformData(width: $0.width)
        }
        .gesture(magnification)
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                gestureZoom = amount
            }
            .onEnded { finalAmount in
                currentZoom *= finalAmount
                gestureZoom = 1
            }
    }
    
    func position(of sample: AVAudioFramePosition) -> CGFloat? {
        let ratio = frameSize.width / CGFloat(zoomSamples.count)
        let position = CGFloat(sample - zoomSamples.lowerBound) * ratio
        return (0...frameSize.width).contains(position) ? position : nil
    }
    
    func sample(for position: CGFloat) -> AVAudioFramePosition {
        let ratio = CGFloat(zoomSamples.count) / frameSize.width
        let sample = zoomSamples.lowerBound + AVAudioFramePosition(position * ratio)
        return min(max(0, sample), AVAudioFramePosition(audioBuffer.frameLength))
    }
    
    func generateWaveformData(width: CGFloat) {
        generator?.cancel()
        generator = WaveformGenerator(audioBuffer: audioBuffer)
        
        waveformData = [WaveformData](repeating: .zero, count: Int(width))
        generator?.generateWaveformData(width: width) { index, data in
            self.waveformData[index] = data
        }
    }
}
