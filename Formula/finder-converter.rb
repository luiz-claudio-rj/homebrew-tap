class FinderConverter < Formula
  desc "Converte vídeo, áudio e imagem com o botão direito no Finder"
  homepage "https://luiz-claudio-rj.github.io/finder-converter/"
  url "https://github.com/luiz-claudio-rj/finder-converter/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "d79f344dd45e4410bce419205143b0cb74bd998788f076d8eda92a00a5faf76c"
  license "MIT"

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
    system "zsh", "-n", libexec/"converter.sh"
  end
end
