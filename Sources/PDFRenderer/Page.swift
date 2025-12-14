import SwiftUI

public struct Page<Content> : View where Content : View
{
    @EnvironmentObject private var documentEnvironment: DocumentEnvironment
    public let content: (Int, Int?) -> Content
    
    public init(content: @escaping (Int, Int?) -> Content)
    {
        self.content = content
    }
    
    @ViewBuilder
    public var body: some View {
        content(documentEnvironment.pageNumber, documentEnvironment.pageCount)
    }
}

public struct OnPageModifier: ViewModifier
{
    @EnvironmentObject private var documentEnvironment: DocumentEnvironment

    let page:Int
    
    public func body(content: Content) -> some View
    {
        if documentEnvironment.pageNumber == page {
            content
        }
    }
}

extension View
{
    public func onPage(_ page:Int) -> some View
    {
        modifier(OnPageModifier(page:page))
    }
}

