//
//  SignInWithKakao.swift
//  WanderBoard
//
//  Created by David Jang on 5/30/24.
//

import SwiftUI
import UIKit

struct DetailPageControlButton: View {
    @State private var selectedIndex = 0
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    var onIndexChanged: ((Int) -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                ZStack {
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.clear)
                            .opacity(1)
                            .frame(width: widthForIndex(index), height: 44)
                            .padding(EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4)) // 상하 3, 좌우 4의 패딩
                        
                        Image(systemName: iconName(for: index))
                            .foregroundColor(.black) // 선택된 아이콘의 색상을 블랙으로 설정
                            .font(.system(size: 16)) // 아이콘 크기 설정
                            .frame(width: 16, height: 16) // 아이콘 크기 설정
                    } else {
                        Image(systemName: iconName(for: index))
                            .foregroundColor(Color("PageCtrlUnselectedText"))
                            .font(.system(size: 16)) // 아이콘 크기 설정
                            .frame(width: 16, height: 16) // 아이콘 크기 설정
                    }
                }
                .frame(width: selectedIndex == index ? widthForIndex(index) : 50, height: 50) // 선택되지 않은 버튼의 크기 고정
                .background(Color.clear)
                .clipShape(Capsule())
                .disabled(selectedIndex == index)
                .onTapGesture {
                    guard selectedIndex != index else { return }
                    withAnimation(.interactiveSpring) {
                        selectedIndex = index
                    }
                    hapticFeedback.impactOccurred()
                    onIndexChanged?(index)
                }
            }
        }
        .frame(width: 130, height: 20) // HStack의 크기를 고정
        .clipShape(Capsule())
        .padding()
        .background(ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.4), radius: 1.5, x: 0, y: 4)
        })
    }
    
    private func widthForIndex(_ index: Int) -> CGFloat {
        switch index {
            case 0: return 44
            case 1: return 44
            case 2: return 44
            default: return 44
        }
    }
    
    private func iconName(for index: Int) -> String {
        switch index {
            case 0: return "photo"
            case 1: return "text.quote"
            case 2: return "gearshape"
            default: return ""
        }
    }
}

#Preview {
    DetailPageControlButton()
}

