import SwiftUI

struct BulkAddDetailsView: View {
    @State var scannedBarcodes: [String]
    var onComplete: (([String]) -> Void)?

    var body: some View {
        VStack {
            Text("Bulk Add Details")
                .font(.title)
                .padding()

            List {
                ForEach(scannedBarcodes, id: \.self) { barcode in
                    NavigationLink(destination: ItemDetailView(barcode: barcode)) {
                        Text(barcode)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .onDelete(perform: deleteBarcode)
            }

            Button(action: {
                onComplete?(scannedBarcodes)  // ✅ Send selected barcodes to ContentView
            }) {
                Text("Add to Inventory")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }

    // ✅ Allows deletion of a barcode
    func deleteBarcode(at offsets: IndexSet) {
        scannedBarcodes.remove(atOffsets: offsets)
    }
}
