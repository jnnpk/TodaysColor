// ColorMatchApp/AddCell.swift
import UIKit

class AddCell: UICollectionViewCell {
    static let identifier = "AddCell"

    // '+' 버튼 모양 뷰
    let addButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(addButtonView)
        // addButtonView가 contentView를 꽉 채우도록 설정
        NSLayoutConstraint.activate([
            addButtonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            addButtonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        // 셀 자체에도 cornerRadius 적용 (선택 사항)
        // contentView.layer.cornerRadius = 12
        // contentView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 탭 시 시각적 피드백 (선택 사항)
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
                self.addButtonView.alpha = self.isHighlighted ? 0.6 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            })
        }
    }
}
