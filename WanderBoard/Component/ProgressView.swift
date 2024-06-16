//
//  ProgressView.swift
//  WanderBoard
//
//  Created by David Jang on 6/16/24.
//

import SwiftUI

struct ProgressView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer().frame(height: 240)
                PinAnimationView()
                    .frame(width: 50, height: 50)
                Spacer()
            }
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}


