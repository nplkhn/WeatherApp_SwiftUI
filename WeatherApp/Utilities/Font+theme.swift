import SwiftUI

extension Font {
    static let theme = FontTheme()
}

struct FontTheme {
    private func font(size: CGFloat, weight: Font.Weight) -> Font {
        Font.custom("Poppins", size: size).weight(weight)
    }
    
    func regular(size: CGFloat) -> Font {
        font(size: size, weight: .regular)
    }
    
    func semibold(size: CGFloat) -> Font {
        font(size: size, weight: .semibold)
    }
    
    func bold(size: CGFloat) -> Font {
        font(size: size, weight: .bold)
    }
    
    func medium(size: CGFloat) -> Font {
        font(size: size, weight: .medium)
    }
}
