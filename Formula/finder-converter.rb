class FinderConverter < Formula
  desc "Converte vídeo, áudio e imagem com o botão direito no Finder"
  homepage "https://luiz-claudio-rj.github.io/finder-converter/"
  url "https://github.com/luiz-claudio-rj/finder-converter/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "83ca7dfe8863cbfca1b675450de9ae5dc41bdf118b77e5b1a04689a8388bb5fe"
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
