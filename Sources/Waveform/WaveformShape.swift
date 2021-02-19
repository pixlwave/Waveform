import SwiftUI

struct WaveformShape: Shape {
    @Binding var waveformData: [WaveformData]
    let displayScale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            for index in 0..<waveformData.count {
                let x = CGFloat(index) / displayScale
                let min = rect.midY + (rect.midY * CGFloat(waveformData[index].min))
                let max = rect.midY + (rect.midY * CGFloat(waveformData[index].max))
                path.move(to: CGPoint(x: x, y: min))
                path.addLine(to: CGPoint(x: x, y: max))
            }
        }
    }
}
