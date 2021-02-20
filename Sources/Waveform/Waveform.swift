import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    @ObservedObject var audio: WaveformAudio
    
    @State private var frameSize: CGSize = .zero
    @State private var zoomGestureValue: CGFloat = 1
    @State private var panGestureValue: DragGesture.Value?
    
    var body: some View {
        GeometryReader { geometry in
            WaveformRenderer(waveformData: audio.sampleData)
                .preference(key: SizeKey.self, value: geometry.size)
                .scaleEffect(x: zoomGestureValue)
                .transformEffect(CGAffineTransform(translationX: panGestureValue?.translation.width ?? 0, y: 0))
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
                zoomGestureValue = $0
            }
            .onEnded {
                zoomGestureValue = $0
                commitZoom()
                zoomGestureValue = 1
            }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged {
                panGestureValue = $0
            }
            .onEnded {
                panGestureValue = $0
                commitPan()
                panGestureValue = nil
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
    
    func commitPan() {
        guard let deltaX = panGestureValue?.translation.width else { return }
        let samplesPerPoint = audio.renderSamples.count / Int(frameSize.width)
        let delta = samplesPerPoint * Int(deltaX)
        let renderStartSample = audio.renderSamples.lowerBound - delta
        let renderEndSample = audio.renderSamples.upperBound - delta
        audio.renderSamples = renderStartSample...renderEndSample
    }
    
    func refreshData() {
        audio.refreshData(width: frameSize.width)
    }
}
