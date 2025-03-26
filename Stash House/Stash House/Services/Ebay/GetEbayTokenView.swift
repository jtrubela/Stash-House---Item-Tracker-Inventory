//
//  GetEbayTokenView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//


import SwiftUI

struct GetEbayTokenView: View {
    @State private var token: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("eBay OAuth2 Token Generator")
                .font(.title2)
                .padding()

            if isLoading {
                ProgressView("Fetching Token...")
            } else {
                Button("Get eBay Token") {
                    isLoading = true
                    EbayOAuthService.fetchAccessToken() { result in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.token = result ?? "Failed to fetch token"
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if !token.isEmpty {
                ScrollView {
                    Text(token)
                        .font(.caption)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .contextMenu {
                            Button("Copy Token") {
                                UIPasteboard.general.string = token
                            }
                        }
                }
                .padding()
                .frame(maxHeight: 200)
            }
        }
        .padding()
    }
}

#Preview {
    GetEbayTokenView()
}
