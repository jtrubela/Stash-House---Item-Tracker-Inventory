import SwiftUI

struct EbayDetailView: View {
    @EnvironmentObject var authManager: EbayAuthManager
    let productId: String
    @State private var detail: EbayProductDetail?

    var body: some View {
        ScrollView {
            if let detail = detail {
                VStack(alignment: .leading, spacing: 12) {
                    Text(detail.title)
                        .font(.title2)
                        .bold()

                    if let desc = detail.shortDescription {
                        Text(desc)
                    }

                    Group {
                        if let upc = detail.upc?.joined(separator: ", ") {
                            Text("UPC: \(upc)")
                        }
                        if let epid = detail.epid {
                            Text("ePID: \(epid)")
                        }
                        if let edition = detail.edition {
                            Text("Edition: \(edition)")
                        }
                        if let rating = detail.rating {
                            Text("Rating: \(rating)")
                        }
                        if let movie = detail.movieTitle {
                            Text("Title: \(movie)")
                        }
                        if let directors = detail.directors?.joined(separator: ", ") {
                            Text("Director(s): \(directors)")
                        }
                        if let format = detail.format {
                            Text("Format: \(format)")
                        }
                        if let year = detail.releaseYear {
                            Text("Year: \(year)")
                        }
                        if let genre = detail.genre {
                            Text("Genre: \(genre)")
                        }
                        if let sub = detail.subGenre {
                            Text("Sub-Genre: \(sub)")
                        }
                        if let discs = detail.numberOfDiscs {
                            Text("Discs: \(discs)")
                        }
                        if let country = detail.country {
                            Text("Country: \(country)")
                        }
                    }
                    .font(.subheadline)
                }
                .padding()
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Item Details")
        .onAppear {
            EbayAPIService.fetchProductDetail(itemId: productId, token: authManager.bearerToken) { detail in
                DispatchQueue.main.async {
                    self.detail = detail
                }
            }
        }
    }
}
