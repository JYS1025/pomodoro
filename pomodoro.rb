cask "pomodoro" do
  version "1.0.0"
  sha256 "75541c9711d45067831d4e6953104e5e27b327d036f2d036e242a7be4b966962"

  # Replace with your actual GitHub release URL after publishing
  url "https://github.com/JYS1025/pomodoro/releases/download/v#{version}/Pomodoro.zip"

  name "Pomodoro"
  desc "Minimal macOS menu bar Pomodoro timer"
  homepage "https://github.com/JYS1025/pomodoro"

  app "Pomodoro.app"

  zap trash: [
    "~/Library/Preferences/com.pomodoro.app.plist",
  ]
end
