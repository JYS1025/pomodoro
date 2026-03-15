cask "pomodoro" do
  version "1.0.0"
  sha256 "55df13269d439a0f18f393c2071b1c9179715eee7fce86cc7324c46db9bcf091"

  # Replace with your actual GitHub release URL after publishing
  url "https://github.com/YOUR_USERNAME/pomodoro/releases/download/v#{version}/Pomodoro.app.zip"

  name "Pomodoro"
  desc "Minimal macOS menu bar Pomodoro timer"
  homepage "https://github.com/YOUR_USERNAME/pomodoro"

  app "Pomodoro.app"

  zap trash: [
    "~/Library/Preferences/com.pomodoro.app.plist",
  ]
end
