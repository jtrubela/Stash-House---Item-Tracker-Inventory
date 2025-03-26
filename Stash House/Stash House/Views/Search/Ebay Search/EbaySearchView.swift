//
//  EbaySearchView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//
//


import SwiftUI

struct EbaySearchView: View {
    @EnvironmentObject var authManager: EbayAuthManager
    @State private var searchTerm = "Shrek 3"
    @State private var products: [EbayProduct] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search eBay...", text: $searchTerm)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button("Search") {
                    EbayAPIService.fetchProducts(keyword: searchTerm, token: authManager.bearerToken) { results in
                        DispatchQueue.main.async {
                            self.products = results
                        }
                    }
                }
                .padding()
                
                List(products) { product in
                    NavigationLink(destination: EbayDetailView(productId: product.id)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.title)
                                .font(.headline)
                            
                            if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            
                            Text(product.price)
                            
                            Link("View on eBay", destination: URL(string: product.itemWebUrl)!)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("eBay Finder")
        }
    }
}

#Preview {
    EbaySearchView()
}
