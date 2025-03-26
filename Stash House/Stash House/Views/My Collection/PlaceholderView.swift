//
//  PlaceholderView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/8/25.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 100, height: 100)
            .overlay(Text("Image\nPlaceholder").font(.caption).foregroundColor(.black))
    }
}
struct Placeholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 100, height: 100)
            .overlay(Text("Image\nPlaceholder").font(.caption).foregroundColor(.black))
    }
}

