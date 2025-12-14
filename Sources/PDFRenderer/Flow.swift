import SwiftUI
import os

public struct Flow<Content> : View where Content : View
{
    @EnvironmentObject private var documentEnvironment: DocumentEnvironment
    @EnvironmentObject private var flowAreaCollection: FlowAreaCollection

    public let name:String
    public let content: () -> Content
    
    public init(_ name: String = "default",  @ViewBuilder content: @escaping () -> Content)
    {
        self.name = name
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geo in
            FlowLayout(collection:flowAreaCollection, area: flowAreaCollection[self.name], pageNumber: documentEnvironment.pageNumber) {
                content()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

public class FlowArea
{
    public var totalSubviewCount = 0
    public var sizedSubviews = [PlacedSubview]()
    public var processedPageNumbers = [Int]()
    public var lastPageNumber:Int?
    
    public var hasUnplacedSubviews:Bool {
        totalSubviewCount - sizedSubviews.count > 0
    }

    public struct PlacedSubview
    {
        let index:Int
        let width:CGFloat
        let height:CGFloat
        let relativeX:CGFloat
        let relativeY:CGFloat
        let pageNumber:Int
    }
}

public class FlowAreaCollection : ObservableObject
{
    @Published fileprivate(set) var lastPageNumber: Int?
    
    public var areas = [String:FlowArea]()
    
    public subscript(name:String) -> FlowArea
    {
        if let existingArea = areas[name] {
            return existingArea
        } else {
            let area = FlowArea()
            areas[name] = area
            return area
        }
    }
    
    public var hasMorePages:Bool {
        areas.values.contains { $0.hasUnplacedSubviews }
    }
    
    public func reportAreaSized(_ pageNumber:Int)
    {
        guard !areas.values.contains(where: { $0.hasUnplacedSubviews }) else {
            // Not all Flow areas have been sized; the final page number is still unknown
            return
        }

        let lastPageNumbers = areas.values.compactMap { $0.lastPageNumber }
        let lastPageNumber = lastPageNumbers.reduce(1) { max($0, $1 ) }

        Task { @MainActor in
            self.lastPageNumber = lastPageNumber
        }
    }
}

public struct FlowLayout : Layout
{
    static let logger = Logger()

    public struct Cache
    {
        let subviewsPlacedInDocument:Int
        var subviewsPlacedOnPage:Int = 0
    }
    
    public let collection: FlowAreaCollection
    public let area: FlowArea
    public let pageNumber: Int
    
    public func makeCache(subviews: Subviews) -> Cache
    {
        area.totalSubviewCount = subviews.count
        return Cache(subviewsPlacedInDocument: area.sizedSubviews.count)
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize
    {
        guard let width = proposal.width, let height = proposal.height else { return .zero }
        return CGSize(width: width, height: height)
    }
    
    public func calculateSubviewSizesForCurrentPage(in bounds: CGRect, proposal: ProposedViewSize, subviews:Subviews)
    {
        FlowLayout.logger.log(level: .debug, "Calculating for page \(pageNumber)")
        var index = area.sizedSubviews.count
        let unplacedSubviews = Array(subviews)[index...]

        var totalHeight:CGFloat = 0
        var sizedSubviewCountForThisPage = 0

        for subview in unplacedSubviews
        {
            defer { index += 1 }

            // Preferred dimensions are always limited to the available `Flow` area size
            let preferredDimensions = subview.dimensions(in: ProposedViewSize(bounds.size))
            FlowLayout.logger.log(level: .debug, "PreferredDimensions for subview \(index): \(Int(preferredDimensions.width)) x \(Int(preferredDimensions.height))")
            
            // If this isn't the first view on this page (in this FlowArea), check if the available height is sufficient.
            // It if is the first view, it will be placed regardless of the height requirements (and potentially clipped), because the following pages will probably not provide more vertical space.
            if sizedSubviewCountForThisPage > 0 {
                let projectedTotalHeightIncludingNextSubview = totalHeight + preferredDimensions.height
                guard projectedTotalHeightIncludingNextSubview <= bounds.height else {
                    // Defer placing all remaining subviews to the next page(s)
                    FlowLayout.logger.log(level: .debug, "Too tall; ending calculation for page \(pageNumber).")
                    break
                }
            }
            
            let sizedSubview = FlowArea.PlacedSubview(index: index, width: preferredDimensions.width, height: preferredDimensions.height, relativeX: 0, relativeY: totalHeight, pageNumber: pageNumber)
            area.sizedSubviews.append(sizedSubview)
            sizedSubviewCountForThisPage += 1

            totalHeight += preferredDimensions.height
        }

        area.processedPageNumbers.append(pageNumber)
        if area.sizedSubviews.count == subviews.count && sizedSubviewCountForThisPage > 0 {
            area.lastPageNumber = pageNumber
        }
        collection.reportAreaSized(pageNumber)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache)
    {
        FlowLayout.logger.log(level: .debug, "Placing for page \(pageNumber) in bounds \(bounds.debugDescription)")
        
        if !area.processedPageNumbers.contains(pageNumber) {
            if pageNumber == 1 || area.processedPageNumbers.contains(pageNumber-1) {
                // When this is called for the very first time, the area's bounds on the current page are known.
                // This allows calculating the size for every view on this page and caching the results.
                calculateSubviewSizesForCurrentPage(in: bounds, proposal: proposal, subviews: subviews)
            } else {
                // If the previous page hasn't been sized, there's no point in placing any views, because it's unclear which views would have been placed on a previous page.
                FlowLayout.logger.log(level: .debug, "Failed to calculate for page \(pageNumber)")
            }
        }
        
        for index in subviews.indices
        {
            let subview = subviews[index]

            // If this view isn't sized, the current page was probably computed out of order and the subview positions can't be known.
            guard let sizedSubview = area.sizedSubviews.first(where: { $0.pageNumber == pageNumber && $0.index == index }) else {
                // Hack to hide views that shouldn't be shown on this page.
                // Most views can just be placed at some coordinate far outside the media box. However, some views (e.g. `SwiftUI.Chart`) don't show correctly when doing that, so we place them at .zero instead and use `anchor` to push the content way out of the rendered area.
                subview.place(at: .zero, anchor: .init(x: 100_000, y: 100_000),  proposal: .zero)
                continue
            }

            // The subview is sized and belongs on this page
            let point = CGPoint(x: bounds.origin.x + sizedSubview.relativeX, y: bounds.origin.y + sizedSubview.relativeY)
            subview.place(at: point, anchor: .topLeading, proposal: ProposedViewSize(CGSize(width: sizedSubview.width, height: sizedSubview.height)))

            FlowLayout.logger.log(level: .debug, "Page \(pageNumber): Placing subview \(index) at \(Int(point.x)),\(Int(point.y)) with size \(Int(sizedSubview.width)) x \(Int(sizedSubview.height))")
        }
    }
}
