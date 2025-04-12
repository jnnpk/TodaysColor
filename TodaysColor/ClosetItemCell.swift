// ColorMatchApp/ClosetItemCell.swift
import UIKit

class ClosetItemCell: UICollectionViewCell {
    static let identifier = "ClosetItemCell"

    // UI 요소 정의
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let colorSwatch: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // 삭제 버튼
    let deleteButton: UIButton = {
         let button = UIButton(type: .custom)
         let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
         let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
         button.setImage(image, for: .normal)
         button.tintColor = .white
         button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
         button.layer.cornerRadius = 12
         button.translatesAutoresizingMaskIntoConstraints = false
         // isHidden은 configure에서 관리
         return button
     }()

     // 삭제 버튼 클릭 시 실행될 클로저 << --- 1. 프로퍼티 선언 추가됨 ---
     var deleteButtonAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

        // 삭제 버튼 액션 연결 << --- 3. addTarget 확인/추가됨 ---
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // UI 요소들을 셀의 contentView에 추가
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(colorSwatch)
        contentView.addSubview(deleteButton) // 삭제 버튼 추가 확인

        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }

    // 오토레이아웃 설정
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75),

            colorSwatch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            colorSwatch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            colorSwatch.widthAnchor.constraint(equalToConstant: 20),
            colorSwatch.heightAnchor.constraint(equalToConstant: 20),
            colorSwatch.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor, constant: 8),

            categoryLabel.leadingAnchor.constraint(equalTo: colorSwatch.trailingAnchor, constant: 8),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            categoryLabel.centerYAnchor.constraint(equalTo: colorSwatch.centerYAnchor),
            categoryLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor, constant: 8),

            // 삭제 버튼 위치 및 크기
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    // 삭제 버튼 탭 시 콜백 실행 << --- 2. 액션 함수 추가됨 ---
    @objc private func didTapDeleteButton() {
        deleteButtonAction?()
    }

    // 셀 내용 설정 함수
    func configure(with item: ClothingItem) {
        imageView.image = item.image
        categoryLabel.text = item.category.rawValue
        colorSwatch.backgroundColor = item.color
        deleteButton.isHidden = false // 이미지 설정 시 삭제 버튼 표시
    }

    // 재사용 준비
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        categoryLabel.text = nil
        colorSwatch.backgroundColor = .clear
        deleteButton.isHidden = true // 재사용 시 숨김
        deleteButtonAction = nil // << --- 4. 콜백 초기화 추가됨 ---
    }
}
