//
//  SignInWithKakao.swift
//  WanderBoard
//
//  Created by David Jang on 5/30/24.
//

import SwiftUI
import UIKit

struct PageControlButton: View {
    @State private var selectedIndex = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    var onIndexChanged: ((Int) -> Void)? //페이지 뷰 컨트롤러랑 연결하면서 많이 건들였습니다.. - 한빛
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                ZStack {
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color("PageCtrlSelectedBG"))
                            .opacity(0.9)
                            .frame(height: 32)
                            .padding(EdgeInsets(top: -4, leading: 4, bottom: -4, trailing: 4))
                        
                        HStack {
                            Image(systemName: iconName(for: index))
                                .foregroundColor(Color("PageCtrlSelectedText"))
                                .font(.system(size: 14))
                            Text(title(for: index))
                                .foregroundColor(Color("PageCtrlSelectedText"))
                                .font(.system(size: 8.5))
                        }
                        .padding(.horizontal)
                    } else {
                        Image(systemName: iconName(for: index))
                            .foregroundColor(Color("PageCtrlUnselectedText"))
                    }
                }
                .frame(maxWidth: selectedIndex == index ? 120 : 44, maxHeight: 44) //사이즈 수정 - 한빛 //사이즈 수정(높이 조절) - 시안
                .background(Color("PageCtrlUnselectedBG"))
                
                .clipShape(Capsule())
                .onTapGesture {
                    withAnimation(.interactiveSpring) {
                        selectedIndex = index
                    }
                    hapticFeedback.impactOccurred()
                    onIndexChanged?(index)
                }
            }
        }
        .background(Color("BackgroundColor"))
        .clipShape(Capsule())
        .shadow(color: .pageCtrlShadow, radius: 8, x: 0, y: 4)
        .padding()
        .gesture(
            DragGesture().updating($dragOffset, body: { value, state, _ in
                state = value.translation.width
            }).onEnded { value in
                let threshold: CGFloat = 45
                if value.translation.width < -threshold {
                    selectedIndex = min(selectedIndex + 1, 2)
                } else if value.translation.width > threshold {
                    selectedIndex = max(selectedIndex - 1, 0)
                }
                hapticFeedback.impactOccurred()
                NotificationCenter.default.post(name: .didChangePage, object: nil, userInfo: ["selectedIndex": selectedIndex])
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .didChangePage)) { notification in
            if let index = notification.userInfo?["selectedIndex"] as? Int {
                withAnimation(.interactiveSpring) {
                    selectedIndex = index
                }
            }
        }
    }
    
    private func iconName(for index: Int) -> String {
        switch index {
            case 0: return "globe.americas"
            case 1: return "square.on.square"
            case 2: return "gearshape"
            default: return ""
        }
    }
    
    private func title(for index: Int) -> String {
        switch index {
            case 0: return "Exploer"
            case 1: return "My trips"
            case 2: return "Settins"
            default: return ""
        }
    }
}

#Preview {
    PageControlButton()
}
