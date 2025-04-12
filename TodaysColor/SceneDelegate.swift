// ColorMatchApp/SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // ColorMatchApp/SceneDelegate.swift
    // scene(_:willConnectTo:options:) 메서드 수정

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // 1. 탭 바 컨트롤러 생성
        let tabBarController = UITabBarController()

        // 2. 기존 ViewController (Color Match) 설정
        let colorMatchVC = ViewController() // 기존 뷰 컨트롤러 인스턴스 생성
        colorMatchVC.navigationItem.title = "실시간 컬러 분석" // 네비게이션 타이틀 설정 (옵션)
        let colorMatchNav = UINavigationController(rootViewController: colorMatchVC) // 네비게이션 컨트롤러로 감싸기
        colorMatchNav.tabBarItem = UITabBarItem(title: "컬러 분석", image: UIImage(systemName: "sparkles"), tag: 0) // 탭 바 아이템 설정

        // 3. 새로운 MyClosetViewController 설정
        let myClosetVC = MyClosetViewController() // 새로 만들 뷰 컨트롤러 인스턴스 생성
        myClosetVC.navigationItem.title = "내 옷장" // 네비게이션 타이틀 설정
        let myClosetNav = UINavigationController(rootViewController: myClosetVC) // 네비게이션 컨트롤러로 감싸기
        myClosetNav.tabBarItem = UITabBarItem(title: "내 옷장", image: UIImage(systemName: "hanger"), tag: 1) // 탭 바 아이템 설정

        // 4. 탭 바 컨트롤러에 뷰 컨트롤러들 설정
        tabBarController.setViewControllers([colorMatchNav, myClosetNav], animated: false)
        tabBarController.tabBar.tintColor = .systemIndigo // 탭 바 아이콘/텍스트 색상 설정 (옵션)

        // 5. window의 rootViewController를 탭 바 컨트롤러로 설정
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}
