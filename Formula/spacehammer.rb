class Spacehammer < Formula
  desc "Spacemacs|Doom-inspired modal toolkit for Hammerspoon"
  homepage "https://github.com/agzam/spacehammer"
  url "https://github.com/agzam/spacehammer/archive/refs/tags/1.6.0.tar.gz"
  version "1.6.0"
  sha256 "ccc6d70e296b50a8c8ff461a636eba49d0a1085a58ff4c53c26a8186a548fe27"
  head "https://github.com/agzam/spacehammer.git", branch: "master"

  depends_on "fennel"

  # Check for existing directories before installation
  real_home = Etc.getpwuid.dir
  if File.exist?("#{real_home}/.hammerspoon") || File.exist?("#{real_home}/.spacehammer")
    odie <<~EOS
      Cannot install: ~/.hammerspoon or ~/.spacehammer already exists.
      
      Please backup and remove these directories first:
        mv ~/.hammerspoon ~/.hammerspoon.backup
        mv ~/.spacehammer ~/.spacehammer.backup
      
      Then run: brew install spacehammer
    EOS
  end

  def install
    # Install to Cellar only - user directory stuff in post_install
    prefix.install Dir["*"]
    prefix.install Dir[".*"].reject { |f| f.end_with?(".", "..") }
  end

  def post_install
    real_home = Etc.getpwuid.dir
    hammerspoon_dir = "#{real_home}/.hammerspoon"

    # Install Hammerspoon cask if not present
    unless File.exist?("/Applications/Hammerspoon.app")
      system "brew", "install", "--cask", "hammerspoon"
    end

    # Copy spacehammer to ~/.hammerspoon
    system "mkdir", "-p", hammerspoon_dir
    system "cp", "-R", "#{prefix}/.", hammerspoon_dir
  end

  def caveats
    <<~EOS
      Spacehammer has been installed to ~/.hammerspoon

      On first launch, Spacehammer will create ~/.spacehammer/config.fnl

      To start using Spacehammer:
        1. Launch Hammerspoon (if not already running)
        2. Press Option+Space (default LEAD key) to open the modal menu

      On uninstall, you'll need to manually remove:
        rm -rf ~/.hammerspoon ~/.spacehammer

      For more information, visit:
        https://github.com/agzam/spacehammer
    EOS
  end

  test do
    assert_predicate prefix, :exist?
  end
end
