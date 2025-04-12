// ColorMatchApp/ImageCell.swift
import UIKit

class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12 // 셀 디자인 일관성
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 삭제 버튼
    let deleteButton: UIButton = {
         let button = UIButton(type: .custom)
         let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold) // 아이콘 크기/굵기
         let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
         button.setImage(image, for: .normal)
         button.tintColor = .white
         button.backgroundColor = UIColor.black.withAlphaComponent(0.6) // 반투명 검정 배경
         button.layer.cornerRadius = 12 // 버튼 크기의 절반 (아래 제약조건과 맞춤)
         button.translatesAutoresizingMaskIntoConstraints = false
         // button.isHidden = true // configure에서 관리
         return button
     }()

     // 삭제 버튼 클릭 시 실행될 클로저
     var deleteButtonAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)

        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)

        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // 삭제 버튼 위치 및 크기 (우측 상단)
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5), // 여백 조정
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5), // 여백 조정
            deleteButton.widthAnchor.constraint(equalToConstant: 24), // 버튼 크기
            deleteButton.heightAnchor.constraint(equalToConstant: 24)  // 버튼 크기
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

     // 삭제 버튼 탭 시 콜백 실행
     @objc private func didTapDeleteButton() {
         deleteButtonAction?()
     }

     // 셀 내용 설정
     func configure(with image: UIImage) {
         imageView.image = image
         deleteButton.isHidden = false // 이미지 있을 때 삭제 버튼 표시
     }

     // 셀 재사용 준비
     override func prepareForReuse() {
         super.prepareForReuse()
         imageView.image = nil
         deleteButton.isHidden = true // 재사용 시 기본 숨김
         deleteButtonAction = nil // 콜백 초기화
     }
}
