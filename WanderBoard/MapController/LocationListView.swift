//
//  LocationListView.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import SwiftUI
import MapKit

struct LocationListView: View {
    let searchResults: [MKLocalSearchCompletion]
    let onSelectLocation: (MKLocalSearchCompletion) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(searchResults.prefix(6), id: \.self) { item in
                HStack {
                    Image(systemName: "pin.circle.fill")
                        .foregroundColor(.black)
                        .padding(.trailing, 4)
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.callout)
                        Text(item.subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
                .onTapGesture {
                    onSelectLocation(item)
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView(searchResults: [], onSelectLocation: { _ in })
    }
}
