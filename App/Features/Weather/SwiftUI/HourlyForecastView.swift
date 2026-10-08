import HarborNewsCore
import SwiftUI

struct HourlyForecastView: View {
    @ObservedObject var viewModel = HourlyForecastViewModel()

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(viewModel.forecast) { entry in
                    VStack {
                        Text("\(entry.hour):00")
                            .font(.caption)
                        Text("\(entry.temperatureF)\u{00B0}")
                            .font(.headline)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            Task { await viewModel.startPolling() }
        }
    }
}
