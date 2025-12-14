import SwiftUI
import PDFKit
import PDFRenderer
import CoreTransferable
import Charts

@MainActor
struct ContentView: View
{
    enum SelectedView : String, CaseIterable, Identifiable {
        
        var id:String { self.rawValue }
        
        case pdf = "PDF"
        case direct = "Direct"
    }
    
    @Binding var document:PDFDocument?
    let pointsPerMillimeter = 2.8346456693
    @State var selectedView:SelectedView? = .pdf
    
    var body: some View {
        VStack {
            if selectedView == .direct {
                ScrollView {
                    PDFPreview {
                        PrintTemplate()
                    }
                }
            } else {
                NavigationStack {
                    if let document {
                        CrossplatformPDFView(document: document, displayMode: .singlePageContinuous)
                            .toolbar {
                                ToolbarItem {
                                    ShareLink(item: document, preview: .init("test.pdf")) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                    } else {
                        ProgressView()
                            .task {
                                do {
                                    self.document = try await PrintTemplate().renderToPdf()
                                } catch {
                                    print("Failed to generate PDF: \(error.localizedDescription)")
                                }
                            }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Picker("", selection: $selectedView) {
                    ForEach(SelectedView.allCases) { option in
                        Text(option.rawValue)
                            .tag(option as SelectedView?)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(idealWidth: 200)
            }
        }
    }
}

