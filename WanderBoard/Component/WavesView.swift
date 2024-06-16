//
//  WavesView.swift
//  WanderBoard
//
//  Created by David Jang on 6/16/24.
//

import SwiftUI


struct WavesView: View {
    
    let colors: [Color] = [Color(hex: 0xD9D9D9), Color(hex: 0x979797), Color(hex: 0x383838), Color(hex: 0x1A1C1D)]
    
    init() {}
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {

                ForEach(0..<colors.count, id: \.self) { index in
                    let color = colors[index]
                    WaveView(
                        waveColor: color,
                        waveHeight: Double.random(in: 0.02...0.04),
                        progress: Double(colors.count - index) * 16,
                        initialOffset: Angle(degrees: Double.random(in: 0...360))
                    )
                }
                VStack {
                    Spacer()
                    ZStack {
                        Image("logoFont")
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width * 0.6)
                        PinAnimationView()
                            .frame(width: 20, height: 20)
                            .offset(x: proxy.size.width * 0.18, y: proxy.size.height * 0.025)
                    }
                    Spacer()
                }
            }
//            .frame(width: proxy.size.width, height: proxy.size.height)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

fileprivate struct WaveShape: Shape {
    
    var offset: Angle
    var waveHeight: Double
    var percent: Double
    
    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        let waveHeight = waveHeight * rect.height
        let yoffset = CGFloat(1.0 - percent) * (rect.height - 8 * waveHeight)
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 361)
        
        p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 8) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}

fileprivate struct WaveView: View {

    var waveColor: Color
    var waveHeight: Double
    var progress: Double
    var initialOffset: Angle

    @State private var waveOffset = Angle(degrees: 0)

    var body: some View {
        ZStack {
            WaveShape(offset: waveOffset + initialOffset, waveHeight: waveHeight, percent: progress / 100)
                .fill(waveColor)
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(Animation.linear(duration: 5.0 + (Double(progress / 20))).repeatForever(autoreverses: false)) {
                    self.waveOffset = Angle(degrees: 360)
                }
            }
        }
    }
}

extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}

struct WavesView_Previews: PreviewProvider {
    static var previews: some View {
        WavesView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct PinAnimationView: View {
    @State private var pinRotation: Double = 0

    var body: some View {
        Image("pin")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: pinRotation), anchor: .bottom)
            .onAppear {
                startAnimation()
            }
    }

    func startAnimation() {
        withAnimation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true)) {
            pinRotation = 20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                pinRotation = -20
            }
        }
    }
}
