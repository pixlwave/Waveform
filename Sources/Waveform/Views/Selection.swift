import SwiftUI

struct Selection: View {
    @Binding var selectedSamples: ClosedRange<Int>
    
    let renderSamples: ClosedRange<Int>
    let samplesPerPoint: Int
    
    @State private var dragGestureValue: CGFloat = 0
    
    var body: some View {
        let x = CGFloat((selectedSamples.lowerBound - renderSamples.lowerBound) / samplesPerPoint)
        let width = CGFloat(selectedSamples.count / samplesPerPoint)
        
        Highlight(x: x, width: width)
            .opacity(0.7)
        Handle(x: x)
            .blendMode(.normal)
            .gesture(drag)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged {
                let amount = $0.translation.width - dragGestureValue
                updateSelection(delta: amount)
                dragGestureValue = $0.translation.width
            }
            .onEnded {
                let amount = $0.translation.width - dragGestureValue
                updateSelection(delta: amount)
                dragGestureValue = 0
            }
    }
    
    func updateSelection(delta: CGFloat) {
        let startSample = selectedSamples.lowerBound + (Int(delta) * samplesPerPoint)
        selectedSamples = startSample...selectedSamples.upperBound
    }
}

struct Highlight: Shape {
    let x: CGFloat
    let width: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addRect(CGRect(x: x, y: rect.origin.y, width: width, height: rect.height))
        }
    }
}

struct Handle: Shape {
    let x: CGFloat
    private let radius: CGFloat = 15
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addRect(CGRect(x: x - 1, y: 0, width: 2, height: rect.height))
            path.addEllipse(in: CGRect(x: x - radius, y: rect.height - (2 * radius), width: 2 * radius, height: 2 * radius))
        }
    }
}
