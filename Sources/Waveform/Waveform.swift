import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    @ObservedObject var audio: WaveformAudio
    
    @State private var frameSize: CGSize = .zero
    @State private var zoomGestureValue: CGFloat = 1
    
    var body: some View {
        GeometryReader { geometry in
            WaveformRenderer(waveformData: audio.sampleData)
                .preference(key: SizeKey.self, value: geometry.size)
                .scaleEffect(x: zoomGestureValue)
        }
        .gesture(magnification)
        .onPreferenceChange(SizeKey.self) {
            guard frameSize != $0 else { return }
            frameSize = $0
        }
        .onChange(of: frameSize) {
            print("Frame size \($0)")
            refreshData()
        }
        .onChange(of: audio.renderSamples) { _ in
            refreshData()
        }
    }
    
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged {
                zoomGestureValue = $0
            }
            .onEnded { _ in
                commitZoom()
                zoomGestureValue = 1
            }
    }
    
    func commitZoom() {
        let count = audio.renderSamples.count
        let newCount = CGFloat(count) / zoomGestureValue
        let delta = (count - Int(newCount)) / 2
        let renderStartSample = audio.renderSamples.lowerBound + delta
        let renderEndSample = audio.renderSamples.upperBound - delta
        audio.renderSamples = renderStartSample...renderEndSample
    }
    
    func refreshData() {
        audio.refreshData(width: frameSize.width)
    }
}
