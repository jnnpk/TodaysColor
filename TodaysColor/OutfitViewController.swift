// ColorMatchApp/OutfitViewController.swift
import UIKit

class OutfitViewController: UIViewController {

    var topItem: ClothingItem?
    var bottomItem: ClothingItem?

    private lazy var topImageView: UIImageView = createOutfitImageView()
    private lazy var bottomImageView: UIImageView = createOutfitImageView()
    private lazy var topLabel: UILabel = createInfoLabel()
    private lazy var bottomLabel: UILabel = createInfoLabel()
    // 페이지 인덱스 표시 레이블
    let indexLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 배경은 Pager VC 따르므로 clear
        view.backgroundColor = .clear
        setupViews()
        setupConstraints()
        configureViews()
    }

    private func createOutfitImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground // 배경 추가
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func createInfoLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func setupViews() {
        view.addSubview(topImageView)
        view.addSubview(topLabel)
        view.addSubview(bottomImageView)
        view.addSubview(bottomLabel)
        view.addSubview(indexLabel) // 인덱스 레이블 추가
    }

    private func setupConstraints() {
        let padding: CGFloat = 20
        let spacing: CGFloat = 8 // 레이블과 이미지 간격 조정

        NSLayoutConstraint.activate([
            // 인덱스 레이블 (상단)
            indexLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding / 2),
            indexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indexLabel.heightAnchor.constraint(equalToConstant: 15), // 높이 고정

            // 상의 이미지
            topImageView.topAnchor.constraint(equalTo: indexLabel.bottomAnchor, constant: spacing),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            // 높이 제약을 비율 대신 하위 요소와의 관계로 설정
            // topImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),

            // 상의 레이블
            topLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: spacing),
            topLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            topLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            topLabel.heightAnchor.constraint(equalToConstant: 20),

            // 하의 이미지
            bottomImageView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: padding),
            bottomImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            bottomImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bottomImageView.heightAnchor.constraint(equalTo: topImageView.heightAnchor), // 상의와 같은 높이

            // 하의 레이블
            bottomLabel.topAnchor.constraint(equalTo: bottomImageView.bottomAnchor, constant: spacing),
            bottomLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            bottomLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bottomLabel.heightAnchor.constraint(equalToConstant: 20),
            // 하단 제약 조건 추가하여 전체 높이 결정
            bottomLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }

    // 데이터로 뷰 설정
    func configureViews() {
        if let top = topItem {
            topImageView.image = top.image
            topLabel.text = "\(top.category.rawValue) (\(top.color.hexString))"
        } else {
            topImageView.image = nil
            topLabel.text = "상의 정보 없음"
        }
        if let bottom = bottomItem {
            bottomImageView.image = bottom.image
            bottomLabel.text = "\(bottom.category.rawValue) (\(bottom.color.hexString))"
        } else {
            bottomImageView.image = nil
            bottomLabel.text = "하의 정보 없음"
        }
    }
}
