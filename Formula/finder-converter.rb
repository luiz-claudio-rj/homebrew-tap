class FinderConverter < Formula
  desc "Converte vídeo, áudio e imagem com o botão direito no Finder"
  homepage "https://luiz-claudio-rj.github.io/finder-converter/"
  url "https://github.com/luiz-claudio-rj/finder-converter/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "2534abc632a21401036427d1bf358f8c4419d244d1ae98b25f6128e4072cb987"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "ffmpeg"
  depends_on :macos
  depends_on "webp"

  def install
    libexec.install "converter.sh", "install.sh", "uninstall.sh", "VERSION", "workflow"
    bin.install "bin/finder-converter"
  end

  def caveats
    <<~EOS
      Para colocar "Converter…" no menu do Finder, rode uma vez:
        finder-converter setup

      Depois, clique com o botão direito em um vídeo, áudio ou imagem e escolha
      Ações Rápidas → Converter…
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/finder-converter --version")

    # converte de verdade, sem abrir janelas: um tom de 1 s em WAV vira MP3
    system formula_opt_bin("ffmpeg")/"ffmpeg", "-loglevel", "error", "-f", "lavfi",
           "-i", "sine=frequency=440:duration=1", testpath/"tom.wav"
    with_env(SEM_JANELA: "1", SEM_AVISO: "1", FORMATO: "MP3") do
      system "zsh", libexec/"converter.sh", testpath/"tom.wav"
    end
    assert_path_exists testpath/"tom.mp3"
    assert_match "mp3", shell_output("#{formula_opt_bin("ffmpeg")}/ffprobe -v error " \
                                     "-show_entries format=format_name -of csv=p=0 #{testpath}/tom.mp3")
  end
end
