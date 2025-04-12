// ColorMatchApp/OutfitPagerViewController.swift
import UIKit

class OutfitPagerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    // MARK: - Properties
    var outfitPairs: [(top: ClothingItem, bottom: ClothingItem)] = []
    private var pageViewController: UIPageViewController!
    private var pageControl: UIPageControl!
    private var currentIndex: Int = 0

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPageViewController()
        setupPageControl()
        setupCloseButton()
    }

    // MARK: - Setup Methods
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        if let firstViewController = viewController(at: 0) {
            pageViewController.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil) // 애니메이션 없이 시작
        }

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40) // PageControl 공간
        ])
    }

    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = outfitPairs.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.pageIndicatorTintColor = .systemGray4 // 색상 변경
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        pageControl.hidesForSinglePage = true // 페이지 하나면 숨김
    }

     private func setupCloseButton() {
         let closeButton = UIButton(type: .close)
         closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
         closeButton.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(closeButton)
         NSLayoutConstraint.activate([
             closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
             closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
         ])
     }

    // MARK: - Helper Methods
    private func viewController(at index: Int) -> OutfitViewController? {
        guard index >= 0, index < outfitPairs.count else { return nil }
        let outfitVC = OutfitViewController()
        let pair = outfitPairs[index]
        outfitVC.topItem = pair.top
        outfitVC.bottomItem = pair.bottom
        outfitVC.indexLabel.text = "\(index + 1) / \(outfitPairs.count)" // 인덱스 레이블 설정
        // OutfitVC에 인덱스 정보 전달 (DataSource에서 사용하기 위함)
        // outfitVC.pageIndex = index (필요하다면 OutfitVC에 pageIndex 프로퍼티 추가)
        return outfitVC
    }

    // MARK: - UIPageViewControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OutfitViewController,
              // 현재 VC의 데이터를 기반으로 인덱스 찾기 (더 안정적인 방법)
              let currentIndex = outfitPairs.firstIndex(where: { $0.top.id == currentVC.topItem?.id && $0.bottom.id == currentVC.bottomItem?.id }) else {
            return nil
        }
        let previousIndex = currentIndex - 1
        return self.viewController(at: previousIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OutfitViewController,
              let currentIndex = outfitPairs.firstIndex(where: { $0.top.id == currentVC.topItem?.id && $0.bottom.id == currentVC.bottomItem?.id }) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        return self.viewController(at: nextIndex)
    }

    // MARK: - UIPageViewControllerDelegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? OutfitViewController,
              let newIndex = outfitPairs.firstIndex(where: { $0.top.id == currentVC.topItem?.id && $0.bottom.id == currentVC.bottomItem?.id }) else {
            return
        }
        self.currentIndex = newIndex
        self.pageControl.currentPage = newIndex
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
