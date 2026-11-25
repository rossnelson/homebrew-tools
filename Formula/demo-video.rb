class DemoVideo < Formula
  desc "Narrated, music-timed product videos recorded from a browser"
  homepage "https://rossnelson.github.io/demo-video-tool/"
  # scripts/release.sh in demo-video-tool writes the url and sha256 of each release.
  url "https://github.com/rossnelson/demo-video-tool/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  head "https://github.com/rossnelson/demo-video-tool.git", branch: "main"

  depends_on "ffmpeg"
  depends_on "node"
  depends_on "python@3.12"

  def install
    libexec.install "bin", "lib", "requirements.txt", "VERSION"
    (libexec/"projects").install "projects/example"
    # Homebrew's Python 3.12 first on the PATH: demo-video setup makes the
    # beat tracker's venv with it, and librosa supports it.
    (bin/"demo-video").write_env_script libexec/"bin/demo",
      PATH: "#{formula_opt_libexec("python@3.12")}/bin:$PATH"
  end

  def caveats
    <<~EOS
      Finish the install with:
        demo-video setup    # the beat tracker and Playwright with Chromium
        demo-video doctor   # what is found, what is missing

      Put your ElevenLabs key in ELEVENLABS_API_KEY or in
        ~/.config/demo-video/el-key
      `demo-video narrate <project> --dry` needs no key.
    EOS
  end

  test do
    expected = version.head? ? /^demo-video \d+\.\d+\.\d+$/ : /^demo-video #{Regexp.escape(version.to_s)}$/
    assert_match expected, shell_output("#{bin}/demo-video --version").strip
    system bin/"demo-video", "new", "my-video"
    assert_path_exists testpath/"my-video/project.mjs"
    assert_match "notes-demo", shell_output("#{bin}/demo-video show my-video")
    assert_match "slant", shell_output("#{bin}/demo-video themes")
  end
end
