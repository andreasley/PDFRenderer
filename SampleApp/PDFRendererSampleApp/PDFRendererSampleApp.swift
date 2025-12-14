import SwiftUI
import PDFKit
import PDFRenderer

@main
struct PDFRenderedSampleApp: App
{
    @State var document:PDFDocument?
    
    var body: some Scene {
        WindowGroup {
            ContentView(document: $document)
        }
        #if os(macOS)
        .commands {
            CommandGroup(after: .newItem) {
                Button {
                    savePdfDocument()
                } label: {
                    Text("Save")
                }
                .keyboardShortcut("s")
                .disabled(document == nil)
            }
        }
        #endif
    }
    
    #if os(macOS)
    func savePdfDocument()
    {
        guard let data = document?.dataRepresentation() else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save the generated file"
        savePanel.message = "Choose where to save the generated PDF file"
        savePanel.nameFieldLabel = "File name:"

        let response = savePanel.runModal()
        
        guard response == .OK, let url = savePanel.url else { return }
        
        do {
            try data.write(to: url)
        } catch {
            print("Failed to save PDF: \(error.localizedDescription)")
        }
    }
    #endif
}
