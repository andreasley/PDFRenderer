import SwiftUI
import PDFKit

open class PDFRenderer<Content> where Content : View
{
    enum Error : Swift.Error {
        case failedToCreateCGContext
        case failedToConvertDataToPdf
        case failedToCalculatePageCount
    }
    
    let format:PaperFormat
    let content: () -> Content
    
    public init(format:PaperFormat = .default, content: @escaping () -> Content)
    {
        self.format = format
        self.content = content
    }
    
    var body: some View {
        content()
    }

    public func render() async throws -> PDFDocument
    {
        let data:Data = try await render()
        guard let document = PDFDocument(data: data) else {
            throw Error.failedToConvertDataToPdf
        }
        return document
    }

    public func render() async throws -> Data
    {
        let mergedPdfData = NSMutableData()

        var mediaBox = CGRect(origin: .zero, size: format.mediaSize)
        
        guard
            let consumer = CGDataConsumer(data: mergedPdfData),
            let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)
        else {
            throw Error.failedToCreateCGContext
        }
        
        let environment = DocumentEnvironment()
        let flowAreaCollection = FlowAreaCollection()

        // First pass to calculate number of pages
        // Making two passes obviously slows down PDF generation, but there's no easy way around this; all views need to be laid out to know the total number of pages
        while environment.pageNumber == 0 || flowAreaCollection.hasMorePages {
            environment.startNewPage()
                        
            let viewToRender = content()
                .environmentObject(environment)
                .environmentObject(flowAreaCollection)
                .frame(width: format.artSize.width, height: format.artSize.height)
            
            let renderer = await ImageRenderer(content: viewToRender)
            await renderer.render { _, _ in }
        }
        
        environment.resetForRendering()
        
        guard let pageCount = environment.pageCount else { throw Error.failedToCalculatePageCount }

        // Second pass to render the views into the PDF
        while environment.pageNumber < pageCount {
            environment.startNewPage()
                        
            let viewToRender = content()
                .environmentObject(environment)
                .environmentObject(flowAreaCollection)
                .frame(width: format.artSize.width, height: format.artSize.height)
            
            let renderer = await ImageRenderer(content: viewToRender)
            await renderer.render { size, renderer in
                
                pdfContext.beginPDFPage(nil)
                
                // center the content on the page
                pdfContext.translateBy(x: mediaBox.size.width / 2 - size.width / 2, y: mediaBox.size.height / 2 - size.height / 2)

                renderer(pdfContext)
                
                pdfContext.endPDFPage()
            }
        }

        pdfContext.closePDF()
        
        return mergedPdfData as Data
    }
}

extension View
{
    public func renderToPdf() async throws -> Data
    {
        let renderer = PDFRenderer { self }
        return try await renderer.render()
    }
    
    public func renderToPdf() async throws -> PDFDocument
    {
        let renderer = PDFRenderer { self }
        return try await renderer.render()
    }
}
