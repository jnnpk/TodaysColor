// ColorMatchApp/ClothingItem.swift
import Foundation
import UIKit // UIColor 변환을 위해 임포트

// 옷 카테고리 정의 (추후 확장 가능)
enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case top = "상의"
    case bottom = "하의"
    case outerwear = "아우터"
    case dress = "원피스"
    case accessories = "액세서리"
    case shoes = "신발"
    // 필요에 따라 카테고리 추가

    var id: String { self.rawValue } // Identifiable 준수
}

// 옷 아이템 데이터 구조체 정의
struct ClothingItem: Codable, Identifiable {
    let id: UUID          // 고유 식별자
    let imageData: Data     // 이미지 데이터 (JPEG 또는 PNG)
    let analyzedColorHex: String // 분석된 대표 색상 (Hex 문자열)
    var category: ClothingCategory // 옷 카테고리
    let addedDate: Date       // 추가된 날짜 (정렬 등에 활용 가능)

    // 초기화 메서드
    init(id: UUID = UUID(), image: UIImage, analyzedColor: UIColor, category: ClothingCategory, addedDate: Date = Date()) {
        self.id = id
        // 이미지를 JPEG 데이터로 압축하여 저장 (품질 조절 가능, PNG보다 용량 작음)
        self.imageData = image.jpegData(compressionQuality: 0.8) ?? Data() // 압축 실패 시 빈 데이터
        self.analyzedColorHex = analyzedColor.hexString // UIColor를 Hex 문자열로 변환 (UIColor Extension 필요)
        self.category = category
        self.addedDate = addedDate
    }

    // 저장된 Data로부터 UIImage를 가져오는 계산 프로퍼티 (사용 시점에 이미지 로드)
    var image: UIImage? {
        return UIImage(data: imageData)
    }

    // 저장된 Hex 문자열로부터 UIColor를 가져오는 계산 프로퍼티
    var color: UIColor {
        return UIColor(hex: analyzedColorHex) ?? .gray // Hex 변환 실패 시 회색 반환 (UIColor Extension 필요)
    }
}

