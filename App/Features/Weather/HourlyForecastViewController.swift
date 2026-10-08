import SwiftUI
import UIKit

final class HourlyForecastViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hourly forecast"
        view.backgroundColor = .systemBackground
        let hosting = UIHostingController(rootView: HourlyForecastView())
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.heightAnchor.constraint(equalToConstant: 96)
        ])
    }
}
