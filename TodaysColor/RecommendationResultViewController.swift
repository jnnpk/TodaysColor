// ColorMatchApp/RecommendationResultViewController.swift
import UIKit
// import Kingfisher // 이미지 로딩 라이브러리 사용 시 주석 해제

class RecommendationResultViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    var anchorItem: ClothingItem! // 전달받을 기준 아이템 (nil 아님을 확신)
    var recommendedItems: [ClothingItem] = [] // 추천된 아이템 목록

    // MARK: - UI Elements

    // --- 상단 영역 ---
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "코디 추천 결과"
        label.font = .systemFont(ofSize: 17, weight: .semibold) // 타이틀 폰트
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system) // 시스템 타입으로 변경하여 유연성 확보
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold) // 아이콘 크기/굵기 조정
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .secondaryLabel // 틴트 색상 조정
        button.backgroundColor = .quaternarySystemFill // 배경색 변경 (더 연하게)
        button.layer.cornerRadius = 15 // 원형 유지 (크기 30 기준)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    // --- 기준 아이템 영역 ---
    private lazy var anchorContainerView: UIView = createContainerView() // 카드 UI
    private lazy var anchorImageView: UIImageView = createItemImageView()
    private lazy var anchorCategoryLabel: UILabel = createInfoLabel(size: 15, weight: .medium, alignment: .center) // 카테고리
    private lazy var anchorColorSwatch: UIView = createColorSwatchView()
    private lazy var anchorHexLabel: UILabel = createInfoLabel(size: 13, weight: .regular, color: .secondaryLabel, alignment: .center) // Hex 코드
    // 정보 표시용 스택뷰 (수직 정렬)
    private lazy var anchorInfoStackView: UIStackView = {
        let colorStack = UIStackView(arrangedSubviews: [anchorColorSwatch, anchorHexLabel])
        colorStack.axis = .horizontal
        colorStack.spacing = 6
        colorStack.alignment = .center
        anchorColorSwatch.widthAnchor.constraint(equalToConstant: 14).isActive = true // 스와치 크기 조정
        anchorColorSwatch.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let stack = UIStackView(arrangedSubviews: [anchorCategoryLabel, colorStack]) // 카테고리 + 색상정보
        stack.axis = .vertical
        stack.spacing = 4 // 세로 간격
        stack.alignment = .center // 가운데 정렬
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // --- 추천 아이템 영역 ---
    private lazy var recommendationLabel: UILabel = {
        let label = UILabel()
        label.text = "이 옷과 어울리는 아이템"
        label.font = .systemFont(ofSize: 18, weight: .semibold) // 폰트 조정
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var recommendationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(ClosetItemCell.self, forCellWithReuseIdentifier: ClosetItemCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        // 컬렉션 뷰 자체 패딩
        cv.contentInset = UIEdgeInsets(top: 0, left: sectionInsets.left, bottom: sectionInsets.bottom, right: sectionInsets.right)
        return cv
    }()

    // 그리드 레이아웃 설정값
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 20.0, bottom: 30.0, right: 20.0) // 여백 조정
    private let itemSpacing: CGFloat = 15.0

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupViews()
        setupConstraints()
        configureAnchorItemView()
    }

    // MARK: - Setup Methods (Helper Functions)

    // 아이템 이미지 뷰 생성 (개선)
    private func createItemImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Fit으로 유지
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemBackground // 배경색 약간 더 어둡게
        imageView.layer.cornerRadius = 12 // 둥글기 증가
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // 이미지 없을 때 표시할 기본 아이콘 (선택적)
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .systemGray4
        return imageView
    }

    // 정보 레이블 생성 (파라미터 추가)
    private func createInfoLabel(size: CGFloat = 14, weight: UIFont.Weight = .medium, color: UIColor = .label, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // 색상 스와치 뷰 생성 (개선)
    private func createColorSwatchView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 7 // 크기(14)의 절반
        view.layer.borderWidth = 0.5 // 테두리 얇게
        view.layer.borderColor = UIColor.systemGray3.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    // 컨테이너 뷰 생성 (카드 스타일)
    private func createContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 18 // 둥글기 증가
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06 // 그림자 연하게
        view.layer.shadowOffset = CGSize(width: 0, height: 3) // 그림자 위치
        view.layer.shadowRadius = 5 // 그림자 반경
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    // UI 요소들을 view에 추가
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(anchorContainerView)
        anchorContainerView.addSubview(anchorImageView)
        anchorContainerView.addSubview(anchorInfoStackView) // 스택뷰만 추가
        view.addSubview(recommendationLabel)
        view.addSubview(recommendationCollectionView)
    }

    // 오토레이아웃 설정 (미니멀/개선)
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let padding = sectionInsets.left
        let spacing: CGFloat = 12 // 기본 간격 조정

        NSLayoutConstraint.activate([
            // 닫기 버튼
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            // 화면 제목
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: safeArea.leadingAnchor, constant: padding + 40),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor, constant: -(padding + 40)),

            // 기준 아이템 컨테이너
            anchorContainerView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 15),
            anchorContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            anchorContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),

            // 기준 아이템 이미지 (컨테이너 내부)
            anchorImageView.topAnchor.constraint(equalTo: anchorContainerView.topAnchor, constant: padding),
            anchorImageView.leadingAnchor.constraint(equalTo: anchorContainerView.leadingAnchor, constant: padding * 2), // 좌우 여백 더 주기
            anchorImageView.trailingAnchor.constraint(equalTo: anchorContainerView.trailingAnchor, constant: -padding * 2), // 좌우 여백 더 주기
            anchorImageView.heightAnchor.constraint(equalTo: anchorImageView.widthAnchor, multiplier: 1.1), // 높이 비율 유지

            // 기준 아이템 정보 스택뷰 (컨테이너 내부)
            anchorInfoStackView.topAnchor.constraint(equalTo: anchorImageView.bottomAnchor, constant: spacing),
            anchorInfoStackView.leadingAnchor.constraint(greaterThanOrEqualTo: anchorContainerView.leadingAnchor, constant: padding),
            anchorInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: anchorContainerView.trailingAnchor, constant: -padding),
            anchorInfoStackView.centerXAnchor.constraint(equalTo: anchorContainerView.centerXAnchor), // 가운데 정렬
            anchorInfoStackView.bottomAnchor.constraint(equalTo: anchorContainerView.bottomAnchor, constant: -padding),

            // 추천 목록 제목 레이블
            recommendationLabel.topAnchor.constraint(equalTo: anchorContainerView.bottomAnchor, constant: 25), // 간격 늘리기
            recommendationLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            recommendationLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),

            // 추천 목록 CollectionView
            recommendationCollectionView.topAnchor.constraint(equalTo: recommendationLabel.bottomAnchor, constant: spacing),
            recommendationCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            recommendationCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            recommendationCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // 기준 아이템 뷰 내용 설정
    private func configureAnchorItemView() {
        guard let item = anchorItem else {
            // Fallback UI
            anchorImageView.image = UIImage(systemName: "questionmark.diamond.fill") // 아이콘 변경
            anchorCategoryLabel.text = "아이템 정보 없음"
            anchorHexLabel.text = ""
            anchorColorSwatch.backgroundColor = .clear
            return
        }

        // 비동기 이미지 로딩 (실제 구현 시 라이브러리 사용 권장)
        anchorImageView.image = item.image ?? UIImage(systemName: "photo")

        anchorCategoryLabel.text = item.category.rawValue
        anchorColorSwatch.backgroundColor = item.color
        anchorHexLabel.text = item.color.hexString
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClosetItemCell.identifier, for: indexPath) as? ClosetItemCell else {
            fatalError("Unable to dequeue ClosetItemCell")
        }
        let item = recommendedItems[indexPath.item]
        // 추천 목록 셀 설정 시, 삭제 버튼은 확실히 숨김 처리
        cell.configure(with: item)
        cell.deleteButton.isHidden = true
        return cell
    }

    // MARK: - UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Recommended item selected: \(recommendedItems[indexPath.item].id)")
        // TODO: 추천 아이템 탭 시 상세 정보 보기 또는 다른 액션 구현
    }

    // MARK: - UICollectionViewDelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalPadding = sectionInsets.left + sectionInsets.right + itemSpacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - totalPadding // 컬렉션 뷰 contentInset 고려
        let widthPerItem = availableWidth / itemsPerRow
        // 셀 디자인 변경에 맞춰 높이 비율 조정 가능 (예: 1.4)
        return CGSize(width: widthPerItem, height: widthPerItem * 1.4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // 컬렉션 뷰 contentInset을 사용하므로 여기는 0
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
}

// UIColor 및 UIViewController 확장은 별도 파일에 있다고 가정 (UIColor+Extensions.swift 등)
