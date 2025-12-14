import SwiftUI

public class DocumentEnvironment : ObservableObject
{
    fileprivate(set) var pageNumber:Int = 0
    @Published var pageCount:Int?

    public init() {}
    
    public init(pageNumber:Int, pageCount:Int? = nil)
    {
        self.pageNumber = pageNumber
        self.pageCount = pageCount
    }
    
    public func startNewPage()
    {
        pageNumber += 1
    }
    
    public func resetForRendering()
    {
        pageCount = pageNumber
        pageNumber = 0
    }
}
