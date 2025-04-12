// ColorMatchApp/MyClosetViewController.swift
import UIKit

// 필요한 프로토콜 채택 확인
class MyClosetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    private var closetItems: [ClothingItem] = [] // 화면에 표시될 (필터링된) 아이템 배열
    private var allClosetItems: [ClothingItem] = [] // 원본 전체 아이템 배열 (필터링 위해)
    private lazy var placeholderLabel: UILabel = createPlaceholderLabel() // 아이템 없을 때 안내 문구
    private var currentCategoryFilter: ClothingCategory? = nil // 현재 선택된 카테고리 필터 (nil = 전체)
    
    // MARK: - UI Elements
    // 카테고리 필터 Segmented Control
    private lazy var categorySegmentedControl: UISegmentedControl = {
        let allCategoryTitle = "전체"
        var segments = [allCategoryTitle]
        segments.append(contentsOf: ClothingCategory.allCases.map { $0.rawValue })
        
        let control = UISegmentedControl(items: segments)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(categoryFilterChanged(_:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // 옷장 아이템 표시 컬렉션 뷰
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(ClosetItemCell.self, forCellWithReuseIdentifier: ClosetItemCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // 그리드 레이아웃 설정값
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupNavigationBar() // 네비게이션 바 설정 (수정됨)
        setupUI()
        setupConstraints()
        loadAndDisplayItems()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = "내 옷장"
        // 오른쪽: 아이템 추가 버튼만 유지
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        // 왼쪽 '코디 추천' 버튼 제거됨
    }
    
    private func createPlaceholderLabel() -> UILabel {
        let label = UILabel()
        label.text = "오른쪽 위 (+) 버튼을 눌러\n옷장 아이템을 추가해보세요."
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }
    
    private func setupUI() {
        view.addSubview(categorySegmentedControl)
        view.addSubview(collectionView)
        view.addSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            categorySegmentedControl.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            categorySegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            collectionView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 15),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Data Handling & Display
    private func loadAndDisplayItems() {
        allClosetItems = ClosetDataManager.shared.loadItems()
        if let filter = currentCategoryFilter {
            closetItems = allClosetItems.filter { $0.category == filter }
        } else {
            closetItems = allClosetItems
        }
        updatePlaceholderVisibility()
        collectionView.reloadData()
        print("Closet display updated. Filter: \(currentCategoryFilter?.rawValue ?? "All"). Displaying count: \(closetItems.count)")
    }
    
    private func updatePlaceholderVisibility() {
        let shouldShowPlaceholder = closetItems.isEmpty
        placeholderLabel.isHidden = !shouldShowPlaceholder
        collectionView.isHidden = shouldShowPlaceholder
        if shouldShowPlaceholder {
            if currentCategoryFilter != nil {
                placeholderLabel.text = "선택된 카테고리에 해당하는\n아이템이 없습니다."
            } else {
                placeholderLabel.text = "오른쪽 위 (+) 버튼을 눌러\n옷장 아이템을 추가해보세요."
            }
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        presentImageSourceActionSheet()
    }
    
    // recommendButtonTapped 함수 삭제됨
    
    // Segmented Control 값 변경 액션 함수
    @objc private func categoryFilterChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        if selectedIndex == 0 { // "전체"
            currentCategoryFilter = nil
        } else {
            let categoryIndex = selectedIndex - 1
            if categoryIndex >= 0 && categoryIndex < ClothingCategory.allCases.count {
                currentCategoryFilter = ClothingCategory.allCases[categoryIndex]
            } else {
                currentCategoryFilter = nil
            }
        }
        loadAndDisplayItems()
    }
    
    // MARK: - Item-Based Recommendation Logic (Step 6 신규 추가)
    
    // 특정 아이템 기반으로 추천 생성 요청
    private func getRecommendations(basedOn anchorItem: ClothingItem) {
        print("Getting recommendations based on: \(anchorItem.category.rawValue) - \(anchorItem.analyzedColorHex)")
        let allOtherItems = ClosetDataManager.shared.loadItems().filter { $0.id != anchorItem.id }
        
        let targetCategory: ClothingCategory?
        switch anchorItem.category {
        case .top: targetCategory = .bottom
        case .bottom: targetCategory = .top
        default: targetCategory = nil
        }
        
        guard let categoryToFind = targetCategory else {
            print("Recommendation for \(anchorItem.category.rawValue) is not supported yet.")
            let alert = UIAlertController(title: "알림", message: "현재 \(anchorItem.category.rawValue) 아이템 기준 추천은 지원하지 않습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let potentialMatches = allOtherItems.filter { $0.category == categoryToFind }
        
        guard !potentialMatches.isEmpty else {
            showNoMatchesAlert(for: categoryToFind)
            return
        }
        
        let anchorColor = anchorItem.color
        let recommendedColorsDict = ColorAnalyzer.recommendColors(from: [anchorColor])
        let targetColors = (recommendedColorsDict[.analogous] ?? []) +
        (recommendedColorsDict[.complementary] ?? []) +
        (recommendedColorsDict[.splitComplementary] ?? [])
        
        var compatibleItems: [ClothingItem] = []
        let maxRecommendations = 4
        
        for item in potentialMatches.shuffled() {
            guard compatibleItems.count < maxRecommendations else { break }
            let itemColor = item.color
            for targetColor in targetColors {
                if areColorsSimilar(itemColor, targetColor) {
                    if !compatibleItems.contains(where: { $0.id == item.id }) {
                        compatibleItems.append(item)
                        break
                    }
                }
            }
        }
        
        if !compatibleItems.isEmpty {
            displaySpecificRecommendations(anchorItem: anchorItem, recommendations: compatibleItems)
        } else {
            showNoMatchesAlert(for: categoryToFind)
        }
    }
    
    // 색상 유사도 비교 함수 (재사용)
    private func areColorsSimilar(_ color1: UIColor, _ color2: UIColor, threshold: CGFloat = 0.25) -> Bool {
        var hue1: CGFloat = 0, saturation1: CGFloat = 0, brightness1: CGFloat = 0
        var hue2: CGFloat = 0, saturation2: CGFloat = 0, brightness2: CGFloat = 0
        
        guard color1.getHue(&hue1, saturation: &saturation1, brightness: &brightness1, alpha: nil),
              color2.getHue(&hue2, saturation: &saturation2, brightness: &brightness2, alpha: nil) else {
            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0
            var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0
            if color1.getRed(&r1, green: &g1, blue: &b1, alpha: nil) && color2.getRed(&r2, green: &g2, blue: &b2, alpha: nil) {
                let rgbThreshold: CGFloat = 0.1
                return abs(r1 - r2) < rgbThreshold && abs(g1 - g2) < rgbThreshold && abs(b1 - b2) < rgbThreshold
            }
            return false
        }
        let hueDistance = min(abs(hue1 - hue2), 1.0 - abs(hue1 - hue2))
        let saturationDistance = abs(saturation1 - saturation2)
        let brightnessDistance = abs(brightness1 - brightness2)
        let totalDistance = hueDistance * 1.0 + saturationDistance * 0.5 + brightnessDistance * 0.5
        return totalDistance < threshold
    }
    
    // 특정 아이템 기반 추천 결과 표시 (새로운 ViewController 사용)
    private func displaySpecificRecommendations(anchorItem: ClothingItem, recommendations: [ClothingItem]) {
        // !!! 중요: RecommendationResultViewController 파일이 프로젝트에 존재해야 합니다 !!!
        let resultVC = RecommendationResultViewController()
        resultVC.anchorItem = anchorItem
        resultVC.recommendedItems = recommendations
        resultVC.modalPresentationStyle = .pageSheet
        if let sheet = resultVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(resultVC, animated: true, completion: nil)
    }
    
    // 매칭 아이템 없음 알림
    private func showNoMatchesAlert(for category: ClothingCategory) {
        let alert = UIAlertController(title: "추천 아이템 없음", message: "선택한 옷과 어울리는 \(category.rawValue) 아이템을 옷장에서 찾지 못했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Image Picking Flow (구현 내용 채워넣음)
    private func presentImageSourceActionSheet() {
        let alert = UIAlertController(title: "옷 아이템 추가", message: "사진 가져올 방법을 선택하세요.", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라로 촬영", style: .default) { [weak self] _ in self?.presentImagePicker(sourceType: .camera) })
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "앨범에서 선택", style: .default) { [weak self] _ in self?.presentImagePicker(sourceType: .photoLibrary) })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showPermissionAlert(type: sourceType == .camera ? "카메라" : "사진 앨범")
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) else {
            picker.dismiss(animated: true); return
        }
        picker.dismiss(animated: true) { [weak self] in
            self?.promptForCategory(for: pickedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func promptForCategory(for image: UIImage) {
        let alert = UIAlertController(title: "카테고리 선택", message: "추가할 옷의 종류를 선택하세요.", preferredStyle: .actionSheet)
        for category in ClothingCategory.allCases {
            alert.addAction(UIAlertAction(title: category.rawValue, style: .default) { [weak self] _ in
                self?.analyzeAndSave(image: image, category: category)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
    
    // 색상 분석 및 데이터 저장
    
    
    private func analyzeAndSave(image: UIImage, category: ClothingCategory) {
        print("Starting analysis for category: \(category.rawValue)...")
        // 로딩 인디케이터 표시 (선택 사항)
        
        // 원본 이미지로 바로 색상 분석 함수 호출 (백그라운드에서)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // 약한 참조 확인
            guard let self = self else { return }
            
            // 이제 원본 이미지를 analyzeColor 함수로 바로 전달
            self.analyzeColor(from: image, originalImage: image, category: category)
        }
    }
    
    // 색상 분석 로직 함수 (내용은 이전과 동일하게 유지)

    
    // 색상 분석 로직 분리
    private func analyzeColor(from imageToAnalyze: UIImage, originalImage: UIImage, category: ClothingCategory) {
        if let dominantColor = ColorAnalyzer.analyzeDominantColorByFrequency(in: imageToAnalyze) {
            let newItem = ClothingItem(image: originalImage, analyzedColor: dominantColor, category: category)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                ClosetDataManager.shared.addItem(newItem)
                print("Item added successfully: \(newItem.id) - \(newItem.category.rawValue) - Color: \(dominantColor.hexString)")
                // self.hideLoadingIndicator()
                self.loadAndDisplayItems() // UI 업데이트
                self.showToast(message: "\(category.rawValue) 아이템 추가 완료")
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                print("Color analysis failed for the provided image.")
                // self?.hideLoadingIndicator()
                self?.showAnalysisErrorAlert() // 분석 실패 알림
            }
        }
    }
    // ID 기반 삭제 및 UI 새로고침 함수
    private func deleteItemUsingDataManager(withId id: UUID) {
        print("Attempting to delete item with ID: \(id)")
        ClosetDataManager.shared.deleteItem(withId: id)
        // 데이터가 변경되었으므로 전체 데이터를 다시 로드하고 화면 갱신
        loadAndDisplayItems()
        print("Item with ID \(id) deleted. Display reloaded.")
    }
    
    // MARK: - Alerts & Helpers (구현 내용 채워넣음)
    private func showPermissionAlert(type: String) {
        let alert = UIAlertController(title: "\(type) 접근 권한 필요", message: "\(type)에 접근할 수 있도록 '설정'에서 권한을 허용해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showAnalysisErrorAlert() {
        let alert = UIAlertController(title: "분석 실패", message: "이미지의 색상을 분석하는 데 실패했습니다. 다른 이미지를 시도해보세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showToast(message : String, duration: TimeInterval = 1.5) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 0.0 // 시작 시 투명
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first,
              let topController = keyWindow.rootViewController?.topMostViewController() else {
            self.view.addSubview(toastLabel)
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            toastLabel.sizeToFit()
            toastLabel.frame = CGRect(x: 0, y: 0, width: toastLabel.frame.width + 30, height: toastLabel.frame.height + 15)
            toastLabel.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.height - toastLabel.frame.height - 50)
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { toastLabel.alpha = 1.0 }) { _ in
                UIView.animate(withDuration: 0.4, delay: duration, options: .curveEaseIn, animations: { toastLabel.alpha = 0.0 }) { _ in
                    toastLabel.removeFromSuperview()
                }
            }
            return
        }
        
        topController.view.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.sizeToFit()
        let toastWidth = toastLabel.intrinsicContentSize.width + 30
        let toastHeight = toastLabel.intrinsicContentSize.height + 15
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: topController.view.safeAreaLayoutGuide.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: topController.view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toastLabel.widthAnchor.constraint(equalToConstant: toastWidth),
            toastLabel.heightAnchor.constraint(equalToConstant: toastHeight)
        ])
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { toastLabel.alpha = 1.0 }) { _ in
            UIView.animate(withDuration: 0.4, delay: duration, options: .curveEaseIn, animations: { toastLabel.alpha = 0.0 }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return closetItems.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClosetItemCell.identifier, for: indexPath) as? ClosetItemCell else {
            fatalError("Unable to dequeue ClosetItemCell")
        }
        let item = closetItems[indexPath.item]
        cell.configure(with: item)
        cell.deleteButtonAction = { [weak self] in
            self?.showDeleteConfirmation(forItemAt: indexPath)
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods (Step 6 수정됨)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at index: \(indexPath.item)")
        guard indexPath.item >= 0 && indexPath.item < closetItems.count else { return }
        let selectedItem = closetItems[indexPath.item]
        
        let alert = UIAlertController(title: "\(selectedItem.category.rawValue) 아이템",
                                      message: "색상: \(selectedItem.analyzedColorHex)\n원하는 작업을 선택하세요.",
                                      preferredStyle: .actionSheet)
        
        if selectedItem.category == .top || selectedItem.category == .bottom {
            alert.addAction(UIAlertAction(title: "이 옷 기준으로 코디 추천받기", style: .default, handler: { [weak self] _ in
                self?.getRecommendations(basedOn: selectedItem)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "삭제하기", style: .destructive, handler: { [weak self] _ in
            self?.showDeleteConfirmation(forItemAt: indexPath) // 삭제 확인 함수 호출
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            if let cell = collectionView.cellForItem(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
        }
        present(alert, animated: true)
    }
    
    // 삭제 확인 액션 시트 표시 함수
    private func showDeleteConfirmation(forItemAt indexPath: IndexPath) {
        guard indexPath.item >= 0 && indexPath.item < closetItems.count else { return }
        let selectedItem = closetItems[indexPath.item]
        
        let alert = UIAlertController(title: "삭제 확인", // 제목 변경
                                      message: "\(selectedItem.category.rawValue) 아이템을 옷장에서 삭제하시겠습니까?",
                                      preferredStyle: .alert) // 스타일 변경 (선택 사항)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            self?.deleteItemUsingDataManager(withId: selectedItem.id)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { return sectionInsets }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return sectionInsets.left }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return sectionInsets.left }
}

// UIViewController 확장 (Toast 메시지용 - 별도 파일 권장)
// extension UIViewController { ... topMostViewController() ... }
