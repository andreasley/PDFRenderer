import PDFKit
import SwiftUI

#if os(macOS)
struct CrossplatformPDFView: NSViewRepresentable
{
    let document: PDFDocument
    let displayMode: PDFDisplayMode

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = document
        pdfView.displayMode = displayMode
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.autoScales = true
        pdfView.document = document
        pdfView.displayMode = displayMode
    }
}
#else
struct CrossplatformPDFView: UIViewRepresentable
{
    typealias UIViewType = PDFView

    let document: PDFDocument
    let displayMode: PDFDisplayMode

    func makeUIView(context _: UIViewRepresentableContext<CrossplatformPDFView>) -> UIViewType
    {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = displayMode
        return pdfView
    }

    func updateUIView(_ pdfView: UIViewType, context: UIViewRepresentableContext<CrossplatformPDFView>)
    {
        pdfView.document = document
    }
}
#endif
