import SwiftUI

struct Handle: View {
    let radius: CGFloat = 15
    @Binding var selectedSamples: ClosedRange<Int>
    let renderSamples: ClosedRange<Int>
    let samplesPerPoint: Int
    
    @State var dragGestureValue: CGFloat = 0
    
    var xPosition: CGFloat {
        guard samplesPerPoint > 0 else { return 0 }
        return CGFloat((selectedSamples.lowerBound - renderSamples.lowerBound) / samplesPerPoint)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 2)
            Circle()
                .frame(width: 2 * radius, height: 2 * radius, alignment: .center)
                .gesture(drag)
        }
        .offset(x: xPosition - radius)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged {
                updateSelection($0.location.x - radius)
            }
            .onEnded {
                updateSelection($0.location.x - radius)
            }
    }
    
    func updateSelection(_ location: CGFloat) {
        var startSample = selectedSamples.lowerBound + (Int(location) * samplesPerPoint)
        if startSample >= selectedSamples.upperBound { startSample = selectedSamples.upperBound - 1 }
        if startSample < 0 { startSample = 0 }
        selectedSamples = startSample...selectedSamples.upperBound
    }
}
