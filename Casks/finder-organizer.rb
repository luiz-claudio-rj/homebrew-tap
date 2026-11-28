cask "finder-organizer" do
  version "1.1.0"
  sha256 "b692eee38d5a8079d92bb7afd619f934b7fe092f550620a82995394a3b6d42e1"

  url "https://github.com/luiz-claudio-rj/finder-organizer/archive/refs/tags/v#{version}.tar.gz"
  name "Organizador"
  desc "Organiza arquivos em pastas por assunto com o botão direito no Finder"
  homepage "https://luiz-claudio-rj.github.io/finder-organizer/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "finder-organizer-#{version}/Organizador.app"
  service "finder-organizer-#{version}/workflow/Organizar.workflow"

  # Builds the app locally with osacompile, which ships with macOS
  preflight_steps do
    run "/bin/zsh", args: ["app/montar.sh", "Organizador.app"], chdir: "finder-organizer-{{version}}"
  end

  # Enables "Organizar…" in the Finder context menu and Quick Actions
  postflight_steps do
    run "/usr/bin/defaults",
        args:           ["write", "pbs", "NSServicesStatus", "-dict-add",
                         "\"(null) - Organizar… - runWorkflowAsService\"",
                         "<dict><key>presentation_modes</key><dict>" \
                         "<key>ContextMenu</key><true/><key>FinderPreview</key><true/>" \
                         "<key>ServicesMenu</key><true/><key>TouchBar</key><false/>" \
                         "</dict></dict>"],
        writable_paths: ["Library/Preferences"],
        writable_base:  :home
    run "/System/Library/CoreServices/pbs", args: ["-update"], must_succeed: false
    # Finder only reads the Quick Actions list at launch; it relaunches by itself
    terminate_process "Finder"
  end

  # removes "Organizar…" from the menu right away
  uninstall_postflight_steps do
    terminate_process "Finder"
  end

  uninstall quit: "io.github.luiz-claudio-rj.organizador"

  zap trash: [
    "~/Library/Application Support/Organizador",
    "~/Library/Logs/Organizador.log",
  ]

  caveats <<~EOS
    In Finder: select files, right-click → Quick Actions → Organizar…
    Or open the Organizador app and drop files on its window.
  EOS
end
