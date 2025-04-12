// ColorMatchApp/ClosetDataManager.swift
import Foundation

class ClosetDataManager {
    // 싱글톤 인스턴스: 앱 전체에서 이 인스턴스를 통해 데이터 관리
    static let shared = ClosetDataManager()

    // UserDefaults에서 사용할 키
    private let userDefaultsKey = "closetItems"

    // 초기화는 private으로 막아서 외부에서 추가 인스턴스 생성을 방지
    private init() {}

    // 저장된 옷 아이템 목록 불러오기
    func loadItems() -> [ClothingItem] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            // 저장된 데이터가 없으면 빈 배열 반환
            return []
        }

        do {
            // JSON 데이터를 [ClothingItem] 배열로 디코딩
            let items = try JSONDecoder().decode([ClothingItem].self, from: data)
            // 날짜 순으로 정렬 (최신순 또는 오래된 순 선택)
            return items.sorted { $0.addedDate > $1.addedDate } // 최신순 정렬 예시
        } catch {
            print("Error decoding clothing items: \(error)")
            // 디코딩 실패 시 빈 배열 반환
            return []
        }
    }

    // 옷 아이템 목록 저장하기
    private func saveItems(_ items: [ClothingItem]) {
           do {
               let data = try JSONEncoder().encode(items)
               UserDefaults.standard.set(data, forKey: userDefaultsKey)
               // --- START: 강제 동기화 코드 추가 ---
               UserDefaults.standard.synchronize() // 변경 사항 즉시 반영 시도
               print("UserDefaults saved successfully with \(items.count) items.") // 저장 확인 로그
               // --- END: 강제 동기화 코드 추가 ---
           } catch {
               print("Error encoding clothing items: \(error)")
           }
       }

    // 새 옷 아이템 추가하기
    func addItem(_ item: ClothingItem) {
        var currentItems = loadItems() // 현재 저장된 아이템 불러오기
        currentItems.insert(item, at: 0) // 새 아이템을 맨 앞에 추가 (최신순)
        // currentItems.append(item) // 맨 뒤에 추가하고 싶다면 append 사용
        saveItems(currentItems)      // 변경된 목록 저장
    }

    // 특정 옷 아이템 삭제하기 (ID 기준)
    func deleteItem(withId id: UUID) {
        var currentItems = loadItems()
        // 해당 ID를 가진 아이템의 인덱스를 찾아 삭제
        if let index = currentItems.firstIndex(where: { $0.id == id }) {
            currentItems.remove(at: index)
            saveItems(currentItems)
        } else {
            print("Error: Item with ID \(id) not found for deletion.")
        }
    }

    // (선택 사항) 특정 인덱스의 아이템 삭제하기
    func deleteItem(at index: Int) {
        var currentItems = loadItems()
        guard index >= 0 && index < currentItems.count else {
            print("Error: Index \(index) out of bounds for deletion.")
            return
        }
        currentItems.remove(at: index)
        saveItems(currentItems)
    }
}
