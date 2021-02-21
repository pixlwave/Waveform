import SwiftUI
import AVFoundation
import Accelerate

/// A range of integers representing samples from an AVAudioFile.
public typealias SampleRange = Range<Int>

/// An interactive waveform generated from an `AVAudioFile`.
public struct Waveform: View {
    @ObservedObject var generator: WaveformGenerator
    
    @State private var zoomGestureValue: CGFloat = 1
    @State private var panGestureValue: CGFloat = 0
    @Binding var selectedSamples: SampleRange
    @Binding var selectionEnabled: Bool
    
    /// Creates an instance powered by the supplied generator.
    /// - Parameters:
    ///   - generator: The object that will supply waveform data.
    ///   - selectedSamples: A binding to a `SampleRange` to update with the selection chosen in the waveform.
    ///   - selectionEnabled: A binding to enable/disable selection on the waveform
    public init(generator: WaveformGenerator, selectedSamples: Binding<SampleRange>, selectionEnabled: Binding<Bool>) {
        self.generator = generator
        self._selectedSamples = selectedSamples
        self._selectionEnabled = selectionEnabled
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // invisible rectangle needed to register gestures that aren't on top of the waveform
                Rectangle()
                    .foregroundColor(Color(.systemBackground).opacity(0.01))
                
                Renderer(waveformData: generator.sampleData)
                    .preference(key: SizeKey.self, value: geometry.size)
                
                if selectionEnabled {
                    Highlight(selectedSamples: selectedSamples)
                        .foregroundColor(.accentColor)
                        .opacity(0.7)
                }
            }
            .padding(.bottom, selectionEnabled ? 30 : 0)
            
            if selectionEnabled {
                StartHandle(selectedSamples: $selectedSamples)
                    .foregroundColor(.accentColor)
                EndHandle(selectedSamples: $selectedSamples)
                    .foregroundColor(.accentColor)
            }
        }
        .gesture(SimultaneousGesture(zoom, pan))
        .environmentObject(generator)
        .onPreferenceChange(SizeKey.self) {
            guard generator.width != $0.width else { return }
            generator.width = $0.width
        }
    }
    
    var zoom: some Gesture {
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
    
    var pan: some Gesture {
        DragGesture()
            .onChanged {
                let panAmount = $0.translation.width - panGestureValue
                pan(offset: -panAmount)
                panGestureValue = $0.translation.width
            }
            .onEnded {
                let panAmount = $0.translation.width - panGestureValue
                pan(offset: -panAmount)
                panGestureValue = 0
            }
    }
    
    func zoom(amount: CGFloat) {
        let count = generator.renderSamples.count
        let newCount = CGFloat(count) / amount
        let delta = (count - Int(newCount)) / 2
        let renderStartSample = max(0, generator.renderSamples.lowerBound + delta)
        let renderEndSample = min(generator.renderSamples.upperBound - delta, Int(generator.audioBuffer.frameLength))
        generator.renderSamples = renderStartSample..<renderEndSample
    }
    
    func pan(offset: CGFloat) {
        let count = generator.renderSamples.count
        var startSample = generator.sample(generator.renderSamples.lowerBound, with: offset)
        var endSample = startSample + count
        
        if startSample < 0 {
            startSample = 0
            endSample = generator.renderSamples.count
        } else if endSample > Int(generator.audioBuffer.frameLength) {
            endSample = Int(generator.audioBuffer.frameLength)
            startSample = endSample - generator.renderSamples.count
        }
        
        generator.renderSamples = startSample..<endSample
    }
}
