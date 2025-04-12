// ColorMatchApp/UIColor+Extensions.swift (새 파일 내용)
import UIKit

extension UIColor {
    // isLight 함수
    func isLight(threshold: CGFloat = 0.6) -> Bool {
        var white: CGFloat = 0
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil) {
             return brightness > threshold
        } else if self.getWhite(&white, alpha: nil) {
            return white > threshold
        }
        return false
    }

    // hexString 연산 프로퍼티
    var hexString: String {
        let components = cgColor.components
        guard let component = components else { return "#000000" }
        let componentCount = cgColor.numberOfComponents

        if componentCount == 2 { // Grayscale
            let white = component[0]
            let gray = lroundf(Float(white * 255))
            return String(format: "#%02lX%02lX%02lX", gray, gray, gray)
        } else if componentCount >= 3 { // RGB(A)
            let r = component[0]
            let g = component[1]
            let b = component[2]
            return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        } else {
            return "#000000"
        }
    }

    // Hex 문자열로부터 UIColor 생성
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        let start: String.Index

        if hex.hasPrefix("#") {
            start = hex.index(hex.startIndex, offsetBy: 1)
        } else {
            start = hex.startIndex
        }
        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        }
        return nil
    }
}
