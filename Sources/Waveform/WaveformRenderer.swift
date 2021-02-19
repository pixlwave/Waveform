import SwiftUI

struct WaveformRenderer: Shape {
    @Binding var waveformData: [WaveformData]
    let displayScale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.midY))
            
            for index in 0..<waveformData.count {
                let x = CGFloat(index) / displayScale
                let max = rect.midY + (rect.midY * CGFloat(waveformData[index].max))
                path.addLine(to: CGPoint(x: x, y: max))
            }
            
            for index in (0..<waveformData.count).reversed() {
                let x = CGFloat(index) / displayScale
                let min = rect.midY + (rect.midY * CGFloat(waveformData[index].min))
                path.addLine(to: CGPoint(x: x, y: min))
            }
            
            path.closeSubpath()
        }
    }
}
