import SwiftUI

public struct PDFPreview<Content> : View where Content : View
{
    // There are various hacks in here to enable rendering the print template as a regular SwiftUI view.
    // This theoretically also makes Xcode Live Previews work for print templates, but they sometimes render just a single page for some reason.
    
    @ObservedObject var flowAreaCollection = FlowAreaCollection()
    @State var isFirstPass = true
    @State var renderedPages = 1
    
    public let format: PaperFormat
    public let content: () -> Content
        
    public init(format: PaperFormat = .default, content: @escaping () -> Content)
    {
        self.format = format
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let lastPageNumber = flowAreaCollection.lastPageNumber {
                Pages(lastPageNumber: lastPageNumber, content: content, flowAreaCollection: flowAreaCollection, format: format)
            } else {
                Pages(lastPageNumber: renderedPages, content: content, flowAreaCollection: flowAreaCollection, format: format)
                    .task {
                        while flowAreaCollection.lastPageNumber == nil {
                            try? await Task.sleep(for: .seconds(0.01))
                            renderedPages += 1
                        }
                    }
            }
       }
    }
    
    struct Pages : View
    {
        let lastPageNumber:Int
        let content: () -> Content
        let flowAreaCollection: FlowAreaCollection
        let format: PaperFormat

        var body : some View {
            ForEach(1...lastPageNumber, id:\.self) { page in
                content()
                    .environmentObject(DocumentEnvironment(pageNumber: page, pageCount: lastPageNumber))
                    .environmentObject(flowAreaCollection)
                    .frame(width: format.artSize.width, height: format.artSize.height)
                    .padding(format.margin)
                    .background(.white)
                Divider()
            }
        }
    }
    
}
