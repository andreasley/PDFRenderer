# PDFRenderer for SwiftUI

An _experimental_ library to render page-sized PDFs from SwiftUI code, based on Apple's [`ImageRenderer`](https://developer.apple.com/documentation/swiftui/imagerenderer). 

The goal is to make printing from a SwiftUI app as simple as possible.

# Supported platforms

- macOS 13 and higher
- iOS 16 and higher

# Features

- Supports output over multiple pages
- Fast rendering
- High-quality PDF output with small file size
- Supports printing all SwiftUI layout fundamentals (Stacks, ForEach etc.)
- Supports printing Images
- Supports printing vector graphics, e.g. SVG files in Assets.xcassets
- Supports printing `Charts`
- Supports printing `Grid`

# Limitations

- Renders native SwiftUI controls, so if Apple changes those in a system update, the print output will change, too.
- Probably won't ever work on other platforms.
- Doesn't support custom image compression (yet).
- Does not support printing native platform views or SwiftUI views that are backed by a native platform view (like SwiftUI.Table)

# Known issues

* ⚠️ Barely tested

# Run the SampleApp

To run the SampleApp, you need to set your development team by duplicating the file `Config.xcconfig.template`, renaming it to `Config.xcconfig` and update it with your Development Team Identifier:
 
```
DEVELOPMENT_TEAM = <YOUR_DEVELOPMENT_TEAM_IDENTIFIER>
```

# Usage

To define a page layout, regular SwiftUI code can be used – with a few special functions to enable print-specific features.

```swift
import SwiftUI
import PDFRenderer
import PDFKit

// Render the template to a `PDFDocument`
let document: PDFDocument = try await PrintTemplate().renderToPdf()


struct PrintTemplate : View
{
    var body: some View {
        Page { pageNumber, pageCount in // repeating page
            VStack {
                Header()
                    .onPage(1) // this element is only rendered on page 1
                Flow("default") { // Area with a flowing layout, repeating on each page and wrapping whole elements
                    Text("Some city, 12.01.1984")
                    Text("Fugiat nulla pariatur")
                        .font(.system(size: 30, weight: .bold))
                        .padding([.top, .bottom], .mm(5)) // use print-friendly units
                    Group {
                        Text("This is some text.")
                        SampleChart()
                            .frame(height: .mm(50))
                            .padding([.top, .bottom], .mm(10))
                    }
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
                }
                .frame(maxHeight: .infinity)
                Footer(pageNumber: pageNumber, pageCount: pageCount)
            }
        }
        .font(.system(size: 9))
    }
}
```