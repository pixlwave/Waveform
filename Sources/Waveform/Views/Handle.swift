import SwiftUI

struct Handle: View {
    let radius: CGFloat = 12
    @Binding var selectedSamples: SampleRange
    
    @EnvironmentObject var audio: WaveformAudio
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 2)
            Circle()
                .frame(width: 2 * radius, height: 2 * radius, alignment: .center)
                .gesture(drag)
        }
        .offset(x: audio.position(of: selectedSamples.lowerBound) - radius)
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
        let sample = audio.sample(selectedSamples.lowerBound, with: offset)
        guard sample <= selectedSamples.upperBound else { return }
        selectedSamples = sample..<selectedSamples.upperBound
    }
}
