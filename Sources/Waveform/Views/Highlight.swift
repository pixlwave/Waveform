import SwiftUI

struct Highlight: Shape {
    let selectedSamples: SampleRange
    let renderSamples: SampleRange
    let samplesPerPoint: Int
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            guard selectedSamples.count > 0, samplesPerPoint > 0 else { return }
            
            let x = CGFloat((selectedSamples.lowerBound - renderSamples.lowerBound) / samplesPerPoint)
            let width = CGFloat(selectedSamples.count / samplesPerPoint)// * scale
            
            path.addRect(CGRect(x: x, y: rect.origin.y, width: width, height: rect.height))
        }
    }
}
