# Harbor News iOS

Local-news iPhone app: headline list and a weather strip, scoped to one station. UIKit screens with SwiftUI where it is newer.

## Architecture

- `Packages/HarborNewsCore` is a platform-agnostic Swift package (Foundation and Combine only): models, networking, repositories, services, storage and view models. It never imports UIKit or SwiftUI.
- `App/` holds the screens: UIKit view controllers (with `+DataSource` and `+Actions` extensions per screen) and SwiftUI views hosted through child view controllers.
- View-state MVVM: each view model exposes one `@Published private(set) var state: ViewState<Model>` (`idle`, `loading`, `success`, `error`). Views render from that single value.
- View models report navigation intent through a weak actions protocol; the view controller implements it and pushes or presents directly. There is no coordinator.
- Dependencies are protocols injected through `init`, with defaults taken from `AppDependencies.shared`.

## Tech stack

Swift 5 language mode, iOS 16+, XcodeGen (`project.yml`), Swift Package Manager, URLSession with Codable, Combine plus async/await.
Tests: Swift Testing for new tests, XCTest for older ones, hand-written protocol stubs.

## Conventions

- **Views talk only to view models.** View controllers and SwiftUI views never create or call a `Repository` or `Service`; only view models consume them. Why: view-state MVVM keeps screens dumb and testable.
- **One state value.** A view model exposes a single `state` property. Do not add separate `isLoading` or `error` flags. Why: one source of truth for rendering.
- **Persistence goes through `KeyValueStore`.** Never call `UserDefaults.standard` directly outside `UserDefaultsStore`. Why: tests swap the store and keys stay namespaced.
- **Delegates are class-bound and weak.** Declare delegate protocols as `: AnyObject` and hold them as `weak var`. Why: retain cycles between cells, view controllers and view models.
- **Threading.** UIKit controllers hop to the main queue when binding (`receive(on: DispatchQueue.main)`); view models and repositories stay thread-agnostic. ObservableObjects that drive SwiftUI are `@MainActor`. Why: view models stay testable, and every UI update lands on the main thread.
- Closures that capture `self` and are stored (Combine sinks, completion handlers) use `[weak self]`.
- No force unwraps (`!`, `try!`, `as!`) in production code; handle the failure path. No magic numbers.

## Anti-patterns

- Importing UIKit or SwiftUI into `HarborNewsCore`.
- Creating a view model inline in a SwiftUI view with `@ObservedObject`; use `@StateObject`.
- Starting a `Task` that nothing cancels when the screen goes away.
- Adding a view controller's view as a subview without `addChild` and `didMove(toParent:)`.

## Commands

```bash
swift test --package-path Packages/HarborNewsCore   # unit tests
xcodegen generate                                   # create HarborNews.xcodeproj
xcodebuild build -project HarborNews.xcodeproj -scheme HarborNews \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```
