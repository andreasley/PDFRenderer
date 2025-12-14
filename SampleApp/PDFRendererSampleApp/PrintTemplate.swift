import SwiftUI
import PDFRenderer

struct PrintTemplate : View
{
    struct Header : View
    {
        var body: some View {
            HStack {
                Image("company-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: .mm(50))
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("www.company.com")
                    Text("info@company.ch")
                    Text("+1 234 567 890")
                }
                .foregroundColor(.gray)
                .padding(.trailing, .mm(10))
                VStack(alignment: .leading) {
                    Text("Company")
                        .fontWeight(.bold)
                    Text("Some Street")
                    Text("Some City")
                    Text("Some Postcode")
                }
            }
            .padding(.bottom, .mm(40))
        }
    }
    
    struct Footer : View
    {
        let pageNumber:Int
        let pageCount:Int?

        var body: some View {
            Text("Page \(pageNumber) of \(pageCount ?? 0)")
                .padding()
        }
    }
    
    var body: some View {
        Page { pageNumber, pageCount in
            VStack {
                Header()
                    .onPage(1)
                Flow("default") {
                    Text("Some city, 12.01.1984")
                    Text("Fugiat nulla pariatur")
                        .font(.system(size: 30, weight: .bold))
                        .padding([.top, .bottom], .mm(5))
                    Group {
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                        SampleChart()
                            .frame(height: .mm(50))
                            .padding([.top, .bottom], .mm(10))
                        Text("Aliquet bibendum enim facilisis gravida neque convallis a cras semper. Et malesuada fames ac turpis. Quis ipsum suspendisse ultrices gravida dictum fusce ut placerat. Quis commodo odio aenean sed adipiscing diam. Tortor dignissim convallis aenean et tortor at risus viverra adipiscing.")
                        Divider()
                            .padding([.top, .bottom], .mm(5))
                        Text("Sollicitudin nibh sit amet commodo nulla facilisi. Diam quis enim lobortis scelerisque. Risus nec feugiat in fermentum.")
                        Text("業てび夜導者ウシミ住埼無フト欺4栗阻せ底際がトイレ流1見ウ転7収ヤ万子こ能数ミ治婚梨ざ。")
                            .padding(.mm(5))
                            .background(Color.gray.opacity(0.1))
                            .padding([.top, .bottom], .mm(5))
                        Text("Vestibulum lectus mauris ultrices eros in cursus turpis. Vel orci porta non pulvinar neque laoreet suspendisse. Nunc non blandit massa enim nec. Gravida neque convallis a cras semper. In hac habitasse platea dictumst. Mi sit amet mauris commodo quis imperdiet massa tincidunt. Vitae nunc sed velit dignissim sodales ut eu.")
                    }
                    Text("Sagittis rhoncus (malesuada bibendum)")
                        .font(.system(size: 20, weight: .bold))
                        .padding([.top, .bottom], .mm(5))
                    HStack(alignment: .top, spacing: .mm(10)) {
                        SampleGrid()
                        Text("Sagittis nisl rhoncus mattis rhoncus urna neque viverra. Sagittis aliquam malesuada bibendum arcu vitae. Nibh mauris cursus mattis molestie a. Mattis molestie a iaculis at erat pellentesque adipiscing.")
                            .frame(width: .mm(80))
                    }
                    .padding([.top, .bottom], .mm(5))
                    Group {
                        Image("image1")
                            .resizable()
                            .scaledToFit()
                        VStack(alignment: .leading) {
                            Text("Non curabitur gravida arcu ac tortor dignissim convallis.")
                            Text("@2023 Nunc vel risus")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, .mm(2))
                        .padding(.bottom, .mm(5))
                    }
                    ForEach(1..<4) { number in
                        Text("Capsule \(number)")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(.blue)
                            .clipShape(Capsule())
                    }
                    Text("In hac habitasse")
                        .font(.system(size: 20, weight: .bold))
                        .padding([.top, .bottom], .mm(5))
                    ForEach(1..<40) { number in
                        HStack {
                            Text("\(number * 10)")
                                .frame(width: .mm(50), alignment: .leading)
                            Text("oiua lhaslfk s")
                                .frame(width: .mm(50), alignment: .leading)
                            Text("asjpaosfasdf")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, .mm(2))
                        Divider()
                    }
                }
                .frame(maxHeight: .infinity)
                Footer(pageNumber: pageNumber, pageCount: pageCount)
            }
        }
        .font(.system(size: 9))
    }
}



struct PrintTemplate_Previews: PreviewProvider
{
    static var previews: some View {
        PDFPreview {
            PrintTemplate()
        }
    }
}

