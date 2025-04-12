// ColorMatchApp/ColorAnalyzer.swift
import UIKit
import CoreGraphics

// 추천 타입 정의
enum RecommendationType {
    case analogous         // 유사색
    case complementary      // 보색
    case splitComplementary // 분할 보색
    // 추후 추가 가능: Triadic, Tetradic 등
}

class ColorAnalyzer {

    // --- Phase 1: 개선된 대표 색상 추출 (픽셀 샘플링 및 빈도 분석) ---
    static func analyzeDominantColorByFrequency(in image: UIImage, sampleSize: Int = 1000) -> UIColor? {
        guard let cgImage = image.cgImage else {
            print("Error: Could not get CGImage from UIImage.")
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height
        guard width > 0 && height > 0 else {
            print("Error: Image has zero width or height.")
            return nil
        }

        // 이미지 데이터 가져오기
        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            print("Error: Could not get image data.")
            return nil
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8 // 픽셀당 바이트 수 (보통 4 for RGBA)
        let bytesPerRow = cgImage.bytesPerRow
        let totalBytes = CFDataGetLength(data)
        let bitmapInfo = cgImage.bitmapInfo

        // 알파 채널 위치 및 바이트 순서 확인 (일반적인 RGBA, BGRA 처리)
        let alphaInfo = bitmapInfo.contains(.alphaInfoMask) ? cgImage.alphaInfo : .none
        let isAlphaFirst = alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst
        let isAlphaLast = alphaInfo == .premultipliedLast || alphaInfo == .last || alphaInfo == .noneSkipLast

        var colorCounts: [Int: Int] = [:] // [QuantizedColor: Count]
        let totalPixels = width * height
        let step = max(1, totalPixels / sampleSize) // 샘플링 간격

        for i in stride(from: 0, to: totalPixels, by: step) {
            let column = i % width
            let row = i / width
            let pixelOffset = row * bytesPerRow + column * bytesPerPixel

            // 데이터 범위 확인
            guard pixelOffset + bytesPerPixel <= totalBytes else { continue }

            var r, g, b: Int
            if isAlphaLast { // RGBA or BGRA (alpha last)
                if bitmapInfo.contains(.byteOrder32Big) { // RGBA
                     r = Int(bytes[pixelOffset])
                     g = Int(bytes[pixelOffset + 1])
                     b = Int(bytes[pixelOffset + 2])
                } else { // BGRA (likely) or other order
                     b = Int(bytes[pixelOffset])
                     g = Int(bytes[pixelOffset + 1])
                     r = Int(bytes[pixelOffset + 2])
                }
            } else if isAlphaFirst { // ARGB or ABGR (alpha first)
                 if bitmapInfo.contains(.byteOrder32Big) { // ARGB
                      r = Int(bytes[pixelOffset + 1])
                      g = Int(bytes[pixelOffset + 2])
                      b = Int(bytes[pixelOffset + 3])
                 } else { // ABGR (likely) or other order
                      b = Int(bytes[pixelOffset + 1])
                      g = Int(bytes[pixelOffset + 2])
                      r = Int(bytes[pixelOffset + 3])
                 }
            } else { // RGB (no alpha) or other unsupported format
                 // Assuming RGB or BGR based on byte order might be needed
                 // For simplicity, assume RGB if alpha is skipped. Adjust if needed.
                 if bitmapInfo.contains(.byteOrder32Big) {
                     r = Int(bytes[pixelOffset])
                     g = Int(bytes[pixelOffset + 1])
                     b = Int(bytes[pixelOffset + 2])
                 } else { // Assuming BGR
                     b = Int(bytes[pixelOffset])
                     g = Int(bytes[pixelOffset + 1])
                     r = Int(bytes[pixelOffset + 2])
                 }
            }


            // 색상 양자화 (Quantization) - 유사 색상 그룹화 (0-255 -> 0-7, 총 8단계)
            let quantizationFactor = 32
            let qR = (r / quantizationFactor) * quantizationFactor
            let qG = (g / quantizationFactor) * quantizationFactor
            let qB = (b / quantizationFactor) * quantizationFactor

            // 고유 정수로 표현 (Shift 사용이 더 효율적일 수 있음)
            let colorKey = (qR << 16) | (qG << 8) | qB // R*65536 + G*256 + B
            colorCounts[colorKey, default: 0] += 1
        }

        // 가장 빈도가 높은 색상 찾기
        guard let mostFrequentColorKey = colorCounts.max(by: { $0.value < $1.value })?.key else {
             print("Warning: Could not determine most frequent color. Falling back to center pixel.")
             return getCenterPixelColor(from: cgImage) // Fallback
        }

        // 정수 키를 다시 RGB로 변환
        let finalR = CGFloat((mostFrequentColorKey >> 16) & 0xFF) / 255.0
        let finalG = CGFloat((mostFrequentColorKey >> 8) & 0xFF) / 255.0
        let finalB = CGFloat(mostFrequentColorKey & 0xFF) / 255.0

        return UIColor(red: finalR, green: finalG, blue: finalB, alpha: 1.0)
    }

    // Fallback: 중앙 픽셀 추출
    static func getCenterPixelColor(from cgImage: CGImage) -> UIColor? {
         let width = cgImage.width
         let height = cgImage.height
         guard width > 0 && height > 0 else { return nil }

         let midX = width / 2
         let midY = height / 2

         // 중앙 픽셀 데이터 추출 시도 (단순화된 버전)
         guard let dataProvider = cgImage.dataProvider,
               let data = dataProvider.data,
               let bytes = CFDataGetBytePtr(data) else { return nil }

         let bytesPerPixel = cgImage.bitsPerPixel / 8
         let bytesPerRow = cgImage.bytesPerRow
         let pixelOffset = midY * bytesPerRow + midX * bytesPerPixel
         let totalBytes = CFDataGetLength(data)
         let bitmapInfo = cgImage.bitmapInfo

         guard pixelOffset + bytesPerPixel <= totalBytes else { return nil }

         // 색상 추출 로직 (analyzeDominantColorByFrequency 내부 로직 재활용)
         var r, g, b: Int
         let alphaInfo = bitmapInfo.contains(.alphaInfoMask) ? cgImage.alphaInfo : .none
         let isAlphaFirst = alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst
         let isAlphaLast = alphaInfo == .premultipliedLast || alphaInfo == .last || alphaInfo == .noneSkipLast

         if isAlphaLast {
             if bitmapInfo.contains(.byteOrder32Big) { r = Int(bytes[pixelOffset]); g = Int(bytes[pixelOffset + 1]); b = Int(bytes[pixelOffset + 2]) }
             else { b = Int(bytes[pixelOffset]); g = Int(bytes[pixelOffset + 1]); r = Int(bytes[pixelOffset + 2]) }
         } else if isAlphaFirst {
             if bitmapInfo.contains(.byteOrder32Big) { r = Int(bytes[pixelOffset + 1]); g = Int(bytes[pixelOffset + 2]); b = Int(bytes[pixelOffset + 3]) }
             else { b = Int(bytes[pixelOffset + 1]); g = Int(bytes[pixelOffset + 2]); r = Int(bytes[pixelOffset + 3]) }
         } else {
             if bitmapInfo.contains(.byteOrder32Big) { r = Int(bytes[pixelOffset]); g = Int(bytes[pixelOffset + 1]); b = Int(bytes[pixelOffset + 2]) }
              else { b = Int(bytes[pixelOffset]); g = Int(bytes[pixelOffset + 1]); r = Int(bytes[pixelOffset + 2]) }
         }

         return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
     }

    // 여러 색상의 평균 계산
    static func averageColor(colors: [UIColor]) -> UIColor {
        var totalR: CGFloat = 0, totalG: CGFloat = 0, totalB: CGFloat = 0
        let count = CGFloat(colors.count)
        guard count > 0 else { return UIColor.gray } // 빈 배열 처리

        for color in colors {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            // getRed는 RGB 색 공간에서만 작동하므로, HSB나 Grayscale 변환 고려 필요 시 추가 로직 필요
            if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
                totalR += r
                totalG += g
                totalB += b
            } else {
                 // RGB 변환 실패 시 (예: Grayscale) 처리
                 var white: CGFloat = 0
                 if color.getWhite(&white, alpha: &a) {
                     totalR += white
                     totalG += white
                     totalB += white
                 }
                 // 변환 실패 시 회색 등으로 간주하거나 무시할 수 있음
            }
        }
        return UIColor(red: totalR/count, green: totalG/count, blue: totalB/count, alpha: 1.0)
    }

    // --- Phase 2: 추천 알고리즘 고도화 ---

    // (3) 유사색 추천 (Analogous)
    static func analogousColorRecommendations(baseColor: UIColor, count: Int = 3) -> [UIColor] {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard baseColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            // HSB 변환 실패 (흑백 등) -> 밝기 조절 추천 또는 빈 배열 반환
            let darker = UIColor(white: max(0, brightness - 0.15), alpha: 1.0)
            let lighter = UIColor(white: min(1, brightness + 0.15), alpha: 1.0)
            return [darker, lighter].prefix(count).map { $0 } // 최대 count 개수만큼 반환
        }

        var recommendations: [UIColor] = []
        let angleStep: CGFloat = 0.083 // 약 30도 (1.0 / 12)

        for i in 1...count {
            let sign: CGFloat = (i % 2 == 1) ? 1 : -1
            let stepMultiplier = CGFloat((i + 1) / 2) // 1, 1, 2, 2...

            let analogousHue = (hue + sign * angleStep * stepMultiplier).truncatingRemainder(dividingBy: 1.0)
            let finalHue = analogousHue < 0 ? analogousHue + 1.0 : analogousHue

            // 채도/명도 미세 조정 (선택적)
            let adjustedSaturation = max(0, min(1, saturation * (1.0 - CGFloat(stepMultiplier) * 0.05))) // 약간 채도 감소
            let adjustedBrightness = max(0, min(1, brightness * (1.0 + CGFloat(stepMultiplier) * 0.03))) // 약간 명도 증가

            recommendations.append(UIColor(hue: finalHue, saturation: adjustedSaturation, brightness: adjustedBrightness, alpha: alpha))
        }
        return recommendations
    }

    // (4) 보색 추천 (Complementary)
    static func complementaryColorRecommendation(baseColor: UIColor) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard baseColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
             return baseColor // 변환 실패 시 원본 반환
        }

        let complementaryHue = (hue + 0.5).truncatingRemainder(dividingBy: 1.0)
        // 채도/명도 조정 (더 선명하게)
        let adjustedSaturation = max(0.5, saturation) // 최소 채도 보장
        let adjustedBrightness = brightness < 0.3 ? brightness + 0.3 : (brightness > 0.8 ? brightness - 0.15 : brightness) // 극단적 명도 조절

        return UIColor(hue: complementaryHue, saturation: adjustedSaturation, brightness: adjustedBrightness, alpha: alpha)
    }

    // (5) 분할 보색 추천 (Split Complementary)
    static func splitComplementaryRecommendations(baseColor: UIColor) -> [UIColor] {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
         guard baseColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
             return []
         }

        let complementaryHue = (hue + 0.5).truncatingRemainder(dividingBy: 1.0)
        let angleOffset: CGFloat = 0.083 // 약 30도

        var recommendations: [UIColor] = []
        for sign in [-1.0, 1.0] {
             let splitHue = (complementaryHue + sign * angleOffset).truncatingRemainder(dividingBy: 1.0)
             let finalHue = splitHue < 0 ? splitHue + 1.0 : splitHue
             // 채도/명도 조정
             let adjustedSaturation = max(0.4, saturation * 0.9)
             let adjustedBrightness = brightness < 0.4 ? brightness + 0.15 : (brightness > 0.8 ? brightness - 0.1 : brightness)

             recommendations.append(UIColor(hue: finalHue, saturation: adjustedSaturation, brightness: adjustedBrightness, alpha: alpha))
        }
        return recommendations
    }

    // 통합 추천 함수
    static func recommendColors(from colors: [UIColor]) -> [RecommendationType: [UIColor]] {
        guard !colors.isEmpty else { return [:] }

        let average = averageColor(colors: colors)
        var recommendations: [RecommendationType: [UIColor]] = [:]

        recommendations[.analogous] = analogousColorRecommendations(baseColor: average, count: 3)
        recommendations[.complementary] = [complementaryColorRecommendation(baseColor: average)]
        recommendations[.splitComplementary] = splitComplementaryRecommendations(baseColor: average)

        // 추후 다른 타입 추가 가능
        // recommendations[.triadic] = calculateTriadic(baseColor: average)

        // 추천 결과에서 중복되거나 너무 유사한 색상 제거 (선택적 고급 기능)
        // recommendations = filterSimilarColors(recommendations)

        return recommendations
    }
}//
//  Untitled.swift
//  TodaysColor
//
//  Created by junpark on 4/11/25.
//

