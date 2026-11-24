cask "finder-converter" do
  version "1.3.0"
  sha256 "a11b91dd824a7398eef42aca5fc0b94d9820bed5a5cf046fb3bd1c674fc3a01d"

  url "https://github.com/luiz-claudio-rj/finder-converter/archive/refs/tags/v#{version}.tar.gz"
  name "Converter"
  desc "Converte vídeo, áudio e imagem com o botão direito no Finder"
  homepage "https://luiz-claudio-rj.github.io/finder-converter/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: ["ffmpeg", "webp"]
  depends_on macos: :ventura

  binary "finder-converter-#{version}/bin/finder-converter"
  service "finder-converter-#{version}/workflow/Converter.workflow"

  # Põe o script dentro da Ação Rápida antes de ela ir para ~/Library/Services
  preflight_steps do
    mkdir_p "finder-converter-#{version}/workflow/Converter.workflow/Contents/Resources", base: :staged_path
    copy "finder-converter-#{version}/converter.sh",
         "finder-converter-#{version}/workflow/Converter.workflow/Contents/Resources/converter.sh",
         source_base: :staged_path, target_base: :staged_path
    set_permissions "finder-converter-#{version}/workflow/Converter.workflow/Contents/Resources/converter.sh",
                    "0755", base: :staged_path
  end

  # Liga "Converter…" no menu de contexto e nas Ações Rápidas do Finder
  postflight_steps do
    run "/usr/bin/defaults",
        args:           ["write", "pbs", "NSServicesStatus", "-dict-add",
                         "\"(null) - Converter… - runWorkflowAsService\"",
                         "<dict><key>presentation_modes</key><dict>" \
                         "<key>ContextMenu</key><true/><key>FinderPreview</key><true/>" \
                         "<key>ServicesMenu</key><true/><key>TouchBar</key><false/>" \
                         "</dict></dict>"],
        writable_paths: ["Library/Preferences"],
        writable_base:  :home
    run "/System/Library/CoreServices/pbs", args: ["-update"], must_succeed: false
    # o Finder só lê a lista de Ações Rápidas ao abrir; ele reabre sozinho
    terminate_process "Finder"
  end

  # tira "Converter…" do menu na hora
  uninstall_postflight_steps do
    terminate_process "Finder"
  end

  zap trash: [
    "~/Library/Application Support/Converter",
    "~/Library/Logs/Converter.log",
  ]

  caveats <<~EOS
    No Finder: botão direito em um vídeo, áudio ou imagem → Ações Rápidas → Converter…
  EOS
end
