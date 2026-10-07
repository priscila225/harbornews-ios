import HarborNewsCore
import SwiftUI

struct WeatherStripView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        Text(label)
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .task { await viewModel.refresh() }
    }

    private var label: String {
        switch viewModel.state {
        case .idle, .loading: return "Loading weather..."
        case .success(let conditions): return "\(conditions.temperatureF)\u{00B0}F \(conditions.summary)"
        case .error: return "Weather unavailable"
        }
    }
}
