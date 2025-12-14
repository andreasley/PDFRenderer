import PDFKit
import CoreTransferable

extension PDFDocument : Transferable
{
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .image) { item in
            return item.dataRepresentation() ?? Data()
        }
    }
}
