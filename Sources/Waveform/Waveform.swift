import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    @ObservedObject var audio: WaveformAudio
    
    @State private var frameSize: CGSize = .zero
    @State private var zoomGestureValue: CGFloat = 1
    @State private var panGestureValue: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            WaveformRenderer(waveformData: audio.sampleData)
                .preference(key: SizeKey.self, value: geometry.size)
        }
        .gesture(magnification)
        .simultaneousGesture(drag)
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
                let zoomAmount = $0 / zoomGestureValue
                zoom(amount: zoomAmount)
                zoomGestureValue = $0
            }
            .onEnded {
                let zoomAmount = $0 / zoomGestureValue
                zoom(amount: zoomAmount)
                zoomGestureValue = 1
            }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged {
                let panAmount = $0.translation.width - panGestureValue
                pan(amount: panAmount)
                panGestureValue = $0.translation.width
            }
            .onEnded {
                let panAmount = $0.translation.width - panGestureValue
                pan(amount: panAmount)
                panGestureValue = 0
            }
    }
    
    func zoom(amount: CGFloat) {
        let count = audio.renderSamples.count
        let newCount = CGFloat(count) / amount
        let delta = (count - Int(newCount)) / 2
        let renderStartSample = audio.renderSamples.lowerBound + delta
        let renderEndSample = audio.renderSamples.upperBound - delta
        audio.renderSamples = renderStartSample...renderEndSample
    }
    
    func pan(amount: CGFloat) {
        let samplesPerPoint = audio.renderSamples.count / Int(frameSize.width)
        let delta = samplesPerPoint * Int(amount)
        let renderStartSample = audio.renderSamples.lowerBound - delta
        let renderEndSample = audio.renderSamples.upperBound - delta
        audio.renderSamples = renderStartSample...renderEndSample
    }
    
    func refreshData() {
        audio.refreshData(width: frameSize.width)
    }
}
