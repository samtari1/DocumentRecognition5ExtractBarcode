//
//  DocumentView.swift
//  DocumentRecognition2ExtractKeyInformation
//
//  Created by Quanpeng Yang on 3/17/26.
//

import SwiftUI
import Vision
import DataDetection

struct DocumentView: View {
    @State private var textFound: String = "Recognizing..."
    
    var body: some View {
        VStack {
            ScrollView {
                Text(textFound)
                    .padding()
                    .font(.system(.body, design: .monospaced)) // Makes data easier to read
            }
            Spacer()
        }
        .task {
            // 1. Load the invoice image from Assets
            guard let uiImage = UIImage(named: "HelloPinehurstBarcode"),
                  let cgImage = uiImage.cgImage else {
                textFound = "HelloPinehurstBarcode image not found in Assets."
                return
            }
            
            do {
                // 2. Initialize the request
                var request = RecognizeDocumentsRequest()
                
                // 3. IMPORTANT: Explicitly enable barcode detection
                // (By default, it may only focus on text to save processing power)
                request.barcodeDetectionOptions.enabled = true
                
                // 4. Perform the request on the CGImage
                let result = try await request.perform(on: cgImage)
                
                var barcodeList = ""
                
                if let document = result.first?.document {
                    // 5. Iterate through all detected barcodes
                    for barcode in document.barcodes {
                        // payloadString contains the actual data (URL, ID, Serial Number)
                        let payload = barcode.payloadString ?? "Illegible"
                        barcodeList += "📦 QR Code: \(payload)\n"
                    }
                    
                    // 6. Update the UI
                    if barcodeList.isEmpty {
                        textFound = "No barcodes detected on this document."
                    } else {
                        textFound = "Detected QR Codes:\n\n" + barcodeList
                    }
                }
            } catch {
                textFound = "Error: \(error.localizedDescription)"
                print("Barcode Extraction Error: \(error)")
            }
        }
    }
}
