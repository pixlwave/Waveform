import SwiftUI

struct StartHandle: View {
    let radius: CGFloat = 12
    @Binding var selectedSamples: SampleRange
    
    @EnvironmentObject var generator: WaveformGenerator
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 2)
            Circle()
                .frame(width: 2 * radius, height: 2 * radius, alignment: .center)
                .gesture(drag)
        }
        .offset(x: generator.position(of: selectedSamples.lowerBound) - radius)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { // $0.location is in the Circle's coordinate space
                updateSelection($0.location.x - radius)
            }
            .onEnded {
                updateSelection($0.location.x - radius)
            }
    }
    
    func updateSelection(_ offset: CGFloat) {
        let sample = generator.sample(selectedSamples.lowerBound, with: offset)
        guard sample < selectedSamples.upperBound else { return }
        selectedSamples = sample..<selectedSamples.upperBound
    }
}


struct EndHandle: View {
    let radius: CGFloat = 12
    @Binding var selectedSamples: SampleRange
    
    @EnvironmentObject var generator: WaveformGenerator
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 2)
            Circle()
                .frame(width: 2 * radius, height: 2 * radius, alignment: .center)
                .gesture(drag)
        }
        .offset(x: generator.position(of: selectedSamples.upperBound) - radius)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { // $0.location is in the Circle's coordinate space
                updateSelection($0.location.x - radius)
            }
            .onEnded {
                updateSelection($0.location.x - radius)
            }
    }
    
    func updateSelection(_ offset: CGFloat) {
        let sample = generator.sample(selectedSamples.upperBound, with: offset)
        guard sample > selectedSamples.lowerBound else { return }
        selectedSamples = selectedSamples.lowerBound..<sample
    }
}
