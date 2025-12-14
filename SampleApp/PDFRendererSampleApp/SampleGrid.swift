import SwiftUI
import Charts

struct SampleGrid : View
{
    struct RowContent: Identifiable {
        let first: String
        let second: String
        let third: String
        let id = UUID()
    }

    @State private var rows = [
        RowContent(first: "Faucibus", second: "Purus", third: "senectus et netus et malesuada fames"),
        RowContent(first: "Massa", second: "Tempor", third: "libero enim sed faucibus turpis"),
        RowContent(first: "Morbi", second: "Tristique", third: "volutpat consequat mauris nunc"),
        RowContent(first: "Hendrerit", second: "Dolor", third: "sit amet risus nullam eget")
    ]
    
    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: .mm(6)) {
            GridRow {
                Text("")
                Text("Vitae congue")
                Text("Sodales")
                Text("Proin sagittis")
            }
            .bold()
            ForEach(rows) { rowContent in
                Divider()
                GridRow {
                    Image(systemName: "checkmark.circle.fill")
                        .renderingMode(.original)
                        .imageScale(.large)
                    Text(rowContent.first)
                    Text(rowContent.second)
                    Text(rowContent.third)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
