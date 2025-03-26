//
//  EbayDetailView.swift
//  Stash House
//
//  Created by Justin Trubela on 3/23/25.
//


import SwiftUI

struct EbayDetailView: View {
    @EnvironmentObject var authManager: EbayAuthManager
    let productId: String
    //Test preview
    var mockDetail: EbayProductDetail? = nil
    
    @State private var detail: EbayProductDetail?
    
    var body: some View {
        ScrollView {
            if let detail = detail {
                VStack(alignment: .leading, spacing: 16) {
                    if let imageURL = detail.imageURL, let url = URL(string: imageURL) {
                        Link(destination: url) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    
                    Text(detail.title)
                        .font(.title)
                        .bold()
                    
                    if let desc = detail.shortDescription {
                        SectionHeader("Overview")
                        Text(desc)
                    }
                    
                    if let category = detail.categoryPath {
                        SectionHeader("Category")
                        Text(category)
                    }
                    
                    if detail.upc != nil || detail.epid != nil {
                        SectionHeader("Identifiers")
                        VStack(alignment: .leading, spacing: 4) {
                            if let upcs = detail.upc {
                                Text("UPC: \(upcs.joined(separator: ", "))")
                            }
                            if let epid = detail.epid {
                                Text("eBay Product ID: \(epid)")
                            }
                        }
                    }
                    
                    SectionHeader("Key Product Features")
                    VStack(alignment: .leading, spacing: 4) {
                        DetailRow("Edition", detail.edition)
                        DetailRow("Rating", detail.rating)
                        DetailRow("Title", detail.movieTitle)
                        DetailRow("Director", detail.directors?.joined(separator: ", "))
                        DetailRow("Format", detail.format)
                        DetailRow("Release Year", detail.releaseYear)
                        DetailRow("Genre", detail.genre)
                        DetailRow("Sub-Genre", detail.subGenre)
                        DetailRow("Language", detail.language)
                        DetailRow("Country", detail.country)
                        if let discs = detail.numberOfDiscs {
                            DetailRow("Number of Discs", "\(discs)")
                        }
                        
                        DisclosureGroup("Additional Details") {
                            if let raw = detail.rawJSON {
                                let excludedKeys = Set([
                                    "itemId",
                                    "title",
                                    "shortDescription",
                                    "gtin",
                                    "epid",
                                    "categoryPath",
                                    "categoryIdPath",
                                    "image",
                                    "localizedAspects",
                                    "itemWebUrl"
                                ])
                                
                                ForEach(raw.keys.sorted(), id: \.self) { key in
                                    if !excludedKeys.contains(key),
                                       let value = raw[key] {
                                        
                                        if let dict = value as? [String: Any] {
                                            DisclosureGroup("\(key.capitalized)") {
                                                ForEach(dict.keys.sorted(), id: \.self) { subKey in
                                                    if let subValue = dict[subKey] {
                                                        Text("\(subKey): \(subValue)")
                                                            .font(.footnote)
                                                            .padding(.vertical, 2)
                                                    }
                                                }
                                            }
                                        } else if let array = value as? [[String: Any]] {
                                            DisclosureGroup("\(key.capitalized)") {
                                                ForEach(0..<array.count, id: \.self) { index in
                                                    DisclosureGroup("Item \(index + 1)") {
                                                        ForEach(array[index].keys.sorted(), id: \.self) { subKey in
                                                            if let subValue = array[index][subKey] {
                                                                Text("\(subKey): \(subValue)")
                                                                    .font(.footnote)
                                                                    .padding(.vertical, 2)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                        
                                        else if let array = value as? [Any] {
                                            DisclosureGroup("\(key.capitalized)") {
                                                ForEach(0..<array.count, id: \.self) { index in
                                                    Text("\(array[index])")
                                                        .font(.footnote)
                                                        .padding(.vertical, 2)
                                                }
                                            }
                                        } else {
                                            Text("\(key.capitalized): \(value)")
                                                .font(.footnote)
                                                .padding(.vertical, 2)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            } else {
                ProgressView("Loading...")
                    .padding()
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Don't fetch if we're using a mock
            if let mock = mockDetail {
                self.detail = mock
                return
            }
            
            EbayAPIService.fetchProductDetail(itemId: productId, token: authManager.bearerToken) { detail in
                DispatchQueue.main.async {
                    self.detail = detail
                }
            }
        }
    }
    
    // MARK: - View Helpers
    
    private func SectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.top, 12)
    }
    
    private func DetailRow(_ label: String, _ value: String?) -> some View {
        Group {
            if let value = value, !value.isEmpty {
                HStack(alignment: .top) {
                    Text("\(label):")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(value)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    
    private func stringify(_ value: Any) -> String {
        if let string = value as? String {
            return string
        } else if let number = value as? NSNumber {
            return number.stringValue
        } else if let bool = value as? Bool {
            return bool ? "Yes" : "No"
        } else {
            return String(describing: value)
        }
    }
    
}


// MARK: - Mock Auth & Detail (place above or outside the view struct)

class MockAuth: EbayAuthManager {
    override init() {
        super.init()
        self.bearerToken = "mock_token"
    }
}

let mockDetail = EbayProductDetail(
    rawJSON: [
        "itemLocation": [
            "city": "Fort Lauderdale",
            "stateOrProvince": "Florida",
            "postalCode": "333**",
            "country": "US"
        ],
        "shippingOptions": [
            [
                "type": "Economy Shipping",
                "shippingCarrierCode": "USPS",
                "shippingCost": ["value": "4.63", "currency": "USD"]
            ]
        ],
        "returnTerms": [
            "returnsAccepted": false
        ],
        "buyingOptions": ["FIXED_PRICE", "BEST_OFFER"]
    ],
    imageURL: "https://i.ebayimg.com/images/g/4t8AAOSwDclnO~1E/s-l1600.jpg",
    id: "test123",
    title: "Shrek the Third (Blu-ray, 2007)",
    shortDescription: "A hilarious animated adventure featuring Shrek and friends.",
    categoryPath: "Movies & TV | Blu-ray Discs",
    categoryIdPath: "11232|617",
    upc: ["0097361388847"],
    epid: "8071199149",
    edition: "Widescreen",
    rating: "PG",
    movieTitle: "Shrek the Third",
    directors: ["Chris Miller", "Raman Hui"],
    format: "Blu-ray",
    releaseYear: "2007",
    genre: "Family",
    subGenre: "Animated",
    numberOfDiscs: 1,
    country: "USA",
    language: "English, Spanish, French"
)

#Preview {
    
    NavigationStack {
        EbayDetailView(productId: "mock", mockDetail: mockDetail)
            .environmentObject(MockAuth())
    }
}
