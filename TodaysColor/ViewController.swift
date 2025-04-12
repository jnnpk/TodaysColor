// ColorMatchApp/ViewController.swift
import UIKit

// 프로토콜 채택 확인
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - UI Elements

    // --- Image Selection Area (CollectionView) ---
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15 // 셀 좌우 간격
        // layout.minimumInteritemSpacing = 15 // 가로 스크롤에서는 의미 없음
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // Cell 등록
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.register(AddCell.self, forCellWithReuseIdentifier: AddCell.identifier)
        // 컬렉션 뷰 가장자리 여백 설정 (좌우 패딩 역할)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: cardPadding, bottom: 0, right: cardPadding)
        collectionView.clipsToBounds = false // 컨테이너 그림자 보이도록
        return collectionView
    }()

    // 이미지 선택 영역 컨테이너
    private lazy var imageSelectionContainer: UIView = createContainerView()

    // --- Results Area ---
    private lazy var averageColorSwatchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray3.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "평균 색상"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var averageColorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [averageColorSwatchView, resultLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        averageColorSwatchView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        averageColorSwatchView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return stackView // <<< return 추가
    }()
    private lazy var analogousLabel: UILabel = createSectionLabel(text: "어울리는 무난한 컬러 (유사색)")
    private lazy var analogousColorsStackView: UIStackView = createColorStackView()
    private lazy var accentLabel: UILabel = createSectionLabel(text: "포인트 컬러 (보색, 분할 보색)")
    private lazy var accentColorsStackView: UIStackView = createColorStackView()
    private lazy var resultsContainer: UIView = createContainerView()

    // --- Main Layout ---
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            imageSelectionContainer,
            resultsContainer
        ])
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView // <<< return 추가
    }()

    // MARK: - Properties
    // 데이터 구조: 이미지와 분석된 색상을 담는 튜플 배열
    private var selectedImageData: [(image: UIImage, color: UIColor)] = []
    // 카드 내부 여백 (제약 조건에서 사용)
    private let cardPadding: CGFloat = 15

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupNavigationBar()
        setupUIHierarchy()
        setupConstraints()
        hideResultSections()
    }

    // MARK: - UI Setup Helpers
    private func setupNavigationBar() {
        navigationItem.title = "Color Match"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetButtonTapped))
    }

    private func setupUIHierarchy() {
        imageSelectionContainer.addSubview(imageCollectionView)
        resultsContainer.addSubview(averageColorStackView)
        resultsContainer.addSubview(analogousLabel)
        resultsContainer.addSubview(analogousColorsStackView)
        resultsContainer.addSubview(accentLabel)
        resultsContainer.addSubview(accentColorsStackView)
        view.addSubview(mainStackView)
    }

    private func createContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view // <<< return 추가
    }

    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label // <<< return 추가
    }

    private func createColorStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView // <<< return 추가
    }

    private func hideResultSections() {
        resultsContainer.isHidden = true
        resultsContainer.alpha = 0
    }

    private func showResultSections() {
        guard resultsContainer.isHidden else { return }
        resultsContainer.alpha = 0
        resultsContainer.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
            self.resultsContainer.alpha = 1
        }
    }

    // MARK: - Auto Layout Constraints
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let collectionViewHeight: CGFloat = 120 // 컬렉션 뷰 높이

        NSLayoutConstraint.activate([
            // Main Stack View
            mainStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            // Image Selection Container & Collection View
            // 컨테이너가 컬렉션 뷰 높이를 가지도록 설정
            imageSelectionContainer.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            imageCollectionView.topAnchor.constraint(equalTo: imageSelectionContainer.topAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: imageSelectionContainer.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: imageSelectionContainer.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: imageSelectionContainer.bottomAnchor),

            // Results Container
            averageColorStackView.topAnchor.constraint(equalTo: resultsContainer.topAnchor, constant: cardPadding),
            averageColorStackView.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: cardPadding),
            averageColorStackView.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -cardPadding),

            analogousLabel.topAnchor.constraint(equalTo: averageColorStackView.bottomAnchor, constant: 20),
            analogousLabel.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: cardPadding),
            analogousLabel.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -cardPadding),

            analogousColorsStackView.topAnchor.constraint(equalTo: analogousLabel.bottomAnchor, constant: 8),
            analogousColorsStackView.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: cardPadding),
            analogousColorsStackView.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -cardPadding),
            analogousColorsStackView.heightAnchor.constraint(equalToConstant: 60),

            accentLabel.topAnchor.constraint(equalTo: analogousColorsStackView.bottomAnchor, constant: 20),
            accentLabel.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: cardPadding),
            accentLabel.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -cardPadding),

            accentColorsStackView.topAnchor.constraint(equalTo: accentLabel.bottomAnchor, constant: 8),
            accentColorsStackView.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: cardPadding),
            accentColorsStackView.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -cardPadding),
            accentColorsStackView.heightAnchor.constraint(equalToConstant: 60),
            accentColorsStackView.bottomAnchor.constraint(equalTo: resultsContainer.bottomAnchor, constant: -cardPadding)
        ])
    }

    // MARK: - Actions
    @objc private func resetButtonTapped() {
        resetSelection()
    }

    // MARK: - Image Picker Logic
    private func presentImagePicker() {
        let alert = UIAlertController(title: "이미지 소스 선택", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { [weak self] _ in self?.openCamera() })
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "사진 앨범", style: .default) { [weak self] _ in self?.openAlbum() })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        if let popoverController = alert.popoverPresentationController {
             let lastItemIndex = selectedImageData.count
             if let cell = imageCollectionView.cellForItem(at: IndexPath(item: lastItemIndex, section: 0)) {
                  popoverController.sourceView = cell
                  popoverController.sourceRect = cell.bounds
             } else {
                 popoverController.sourceView = self.view
                 popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                 popoverController.permittedArrowDirections = []
             }
        }
        present(alert, animated: true, completion: nil)
    }

    private func removeImage(at index: Int) {
        guard index >= 0 && index < selectedImageData.count else { return }
        selectedImageData.remove(at: index)
        imageCollectionView.performBatchUpdates({
             imageCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }) { [weak self] _ in
             self?.recommendColorsAndDisplay() // 추천 업데이트
        }
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { showPermissionAlert(type: "카메라"); return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    private func openAlbum() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { showPermissionAlert(type: "사진 앨범"); return }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
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

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else {
            dismiss(animated: true); return
        }

        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            // 로딩 인디케이터 표시 등
            DispatchQueue.global(qos: .userInitiated).async {
                if let dominantColor = ColorAnalyzer.analyzeDominantColorByFrequency(in: pickedImage) {
                    DispatchQueue.main.async {
                        let newData = (image: pickedImage, color: dominantColor)
                        let newIndex = self.selectedImageData.count
                        self.selectedImageData.append(newData)

                        let newIndexPath = IndexPath(item: newIndex, section: 0)
                        self.imageCollectionView.performBatchUpdates({
                            self.imageCollectionView.insertItems(at: [newIndexPath])
                        }) { _ in
                            let addButtonIndexPath = IndexPath(item: self.selectedImageData.count, section: 0)
                            self.imageCollectionView.scrollToItem(at: addButtonIndexPath, at: .right, animated: true)
                        }
                        self.recommendColorsAndDisplay()
                        self.showResultSections()
                    }
                } else {
                    DispatchQueue.main.async {
                        print("색상 분석 실패")
                        self.showAnalysisErrorAlert()
                    }
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    private func showAnalysisErrorAlert() {
        let alert = UIAlertController(title: "분석 실패", message: "이미지의 색상을 분석하는 데 실패했습니다. 다른 이미지를 시도해보세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Color Recommendation and Display Logic
    private func recommendColorsAndDisplay() {
        let validColors = selectedImageData.map { $0.color } // 데이터 소스 변경
        guard !validColors.isEmpty else {
            updateResultLabel(with: nil)
            clearStackViews()
            hideResultSections()
            return
        }
        let averageColor = ColorAnalyzer.averageColor(colors: validColors)
        updateResultLabel(with: averageColor)
        let recommendations = ColorAnalyzer.recommendColors(from: validColors)
        updateStackView(analogousColorsStackView, with: recommendations[.analogous] ?? [])
        let accentColors = (recommendations[.complementary] ?? []) + (recommendations[.splitComplementary] ?? [])
        updateStackView(accentColorsStackView, with: accentColors)
        showResultSections() // 결과 있으면 섹션 보이기
    }

    private func updateResultLabel(with color: UIColor?) {
        if let color = color {
            averageColorSwatchView.backgroundColor = color
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: nil)
            resultLabel.text = String(format: "평균 RGB: (%.0f, %.0f, %.0f)", r*255, g*255, b*255)
            resultLabel.textColor = .label
        } else {
            averageColorSwatchView.backgroundColor = .clear
            resultLabel.text = "평균 색상"
            resultLabel.textColor = .secondaryLabel
        }
    }

    // 추천 색상 스택뷰 업데이트 (스와치 탭 기능 포함)
    private func updateStackView(_ stackView: UIStackView?, with colors: [UIColor]) {
        guard let stackView = stackView else { return }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if colors.isEmpty {
            let placeholder = UILabel()
            placeholder.text = "추천 없음"
            placeholder.font = UIFont.systemFont(ofSize: 12)
            placeholder.textColor = .systemGray
            placeholder.textAlignment = .center
            stackView.addArrangedSubview(placeholder)
        } else {
            colors.forEach { color in
                let colorView = UIView()
                colorView.backgroundColor = color
                colorView.layer.cornerRadius = 10
                colorView.layer.masksToBounds = true
                colorView.layer.borderWidth = 1
                colorView.layer.borderColor = UIColor(white: 0.8, alpha: 0.5).cgColor

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorSwatchTapped(_:)))
                colorView.addGestureRecognizer(tapGesture)
                colorView.isUserInteractionEnabled = true
                stackView.addArrangedSubview(colorView)
            }
        }
    }

    // 색상 스와치 탭 처리 (Hex 코드 복사)
    @objc private func colorSwatchTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view, let color = tappedView.backgroundColor else { return }
        let hexString = color.hexString
        UIPasteboard.general.string = hexString
        showToast(message: "\(hexString) 복사됨")
        print("Copied hex: \(hexString)")
    }

     // 간단한 토스트 메시지 표시 함수
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

         // 최상단 뷰 컨트롤러 찾기 시도
         guard let keyWindow = UIApplication.shared.connectedScenes
             .filter({$0.activationState == .foregroundActive})
             .compactMap({$0 as? UIWindowScene})
             .first?.windows
             .filter({$0.isKeyWindow}).first,
               let topController = keyWindow.rootViewController?.topMostViewController() else {
             // Fallback: 현재 뷰에 추가
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

         // 최상단 뷰 컨트롤러에 토스트 추가
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

    // 선택 초기화
    private func resetSelection() {
        selectedImageData.removeAll()
        imageCollectionView.reloadData()
        clearStackViews()
        updateResultLabel(with: nil)
        hideResultSections()
        print("선택이 초기화되었습니다.")
    }

    // 스택뷰 내용 지우기
    private func clearStackViews() {
        [analogousColorsStackView, accentColorsStackView].forEach { stackView in
            stackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
    }

    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImageData.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == selectedImageData.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCell.identifier, for: indexPath) as! AddCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
            let data = selectedImageData[indexPath.item]
            cell.configure(with: data.image)
            cell.deleteButtonAction = { [weak self] in
                 self?.removeImage(at: indexPath.item)
            }
            return cell
        }
    }

    // MARK: - UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedImageData.count {
            presentImagePicker() // 추가 버튼 탭
        } else {
            print("Image cell tapped at index: \(indexPath.item)")
            // 이미지 셀 탭 시 동작 (예: 삭제 확인 ActionSheet)
             showDeleteConfirmation(for: indexPath.item)
        }
    }
     // 이미지 셀 탭 시 삭제 확인 ActionSheet (선택적 UI 개선)
     private func showDeleteConfirmation(for index: Int) {
         let alert = UIAlertController(title: "이미지 삭제", message: "이 이미지를 삭제하시겠습니까?", preferredStyle: .actionSheet)
         alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
             self?.removeImage(at: index)
         })
         alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

          // iPad Popover 설정 (탭된 이미지 셀 기준)
         if let popoverController = alert.popoverPresentationController {
              if let cell = imageCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                   popoverController.sourceView = cell
                   popoverController.sourceRect = cell.bounds
              }
             popoverController.permittedArrowDirections = .any
         }
         present(alert, animated: true)
     }


    // MARK: - UICollectionViewDelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height // 컬렉션 뷰 높이를 셀 높이로
        return CGSize(width: height, height: height) // 정사각형 셀
    }
}

 
    // MARK: - UIViewController Extension (Toast)
    extension UIViewController {
        func topMostViewController() -> UIViewController {
            if let navigationController = self as? UINavigationController {
                // 네비게이션 스택의 가장 위 컨트롤러를 재귀적으로 찾음
                return navigationController.visibleViewController?.topMostViewController() ?? navigationController
            }
            if let tabBarController = self as? UITabBarController {
                // 선택된 탭의 컨트롤러에서 재귀적으로 찾음
                return tabBarController.selectedViewController?.topMostViewController() ?? tabBarController
            }
            if let presentedViewController = presentedViewController {
                // 현재 Present 되어 있는 컨트롤러에서 재귀적으로 찾음
                return presentedViewController.topMostViewController()
            }
            // 더 이상 상위 컨트롤러가 없으면 현재 컨트롤러 반환
            return self
        }
    }
