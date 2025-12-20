class Spacehammer < Formula
  desc "Spacemacs|Doom-inspired modal toolkit for Hammerspoon"
  homepage "https://github.com/agzam/spacehammer"
  url "https://github.com/agzam/spacehammer/archive/refs/tags/1.6.0.tar.gz"
  version "1.6.0"
  sha256 "ccc6d70e296b50a8c8ff461a636eba49d0a1085a58ff4c53c26a8186a548fe27"
  head "https://github.com/agzam/spacehammer.git", branch: "master"

  depends_on "fennel"

  def install
    # Just install to Cellar - user directory stuff happens in post_install (unsandboxed)
    prefix.install Dir["*"]
    prefix.install Dir[".*"].reject { |f| f.end_with?(".", "..") }
  end

  def post_install
    # post_install is NOT sandboxed - we can write to user directories here
    real_home = Etc.getpwuid.dir
    hammerspoon_dir = "#{real_home}/.hammerspoon"
    spacehammer_dir = "#{real_home}/.spacehammer"
    timestamp = Time.now.to_i

    # 1. Install Hammerspoon cask if not present
    unless File.exist?("/Applications/Hammerspoon.app")
      ohai "Installing Hammerspoon..."
      system "brew", "install", "--cask", "hammerspoon"
    end

    # 2. Backup ~/.hammerspoon if exists
    if File.exist?(hammerspoon_dir)
      backup = "#{hammerspoon_dir}.backup.#{timestamp}"
      ohai "Backing up ~/.hammerspoon to #{backup}"
      system "mv", hammerspoon_dir, backup
    elsif File.symlink?(hammerspoon_dir)
      ohai "Removing existing symlink at ~/.hammerspoon"
      system "rm", hammerspoon_dir
    end

    # 3. Backup ~/.spacehammer if exists AND we're cloning a new config
    if ENV["SPACEHAMMER_CONFIG_REPO"] && File.exist?(spacehammer_dir)
      backup = "#{spacehammer_dir}.backup.#{timestamp}"
      ohai "Backing up ~/.spacehammer to #{backup}"
      system "mv", spacehammer_dir, backup
    end

    # 4. Create ~/.hammerspoon and copy spacehammer files
    ohai "Installing Spacehammer to ~/.hammerspoon"
    system "mkdir", "-p", hammerspoon_dir
    system "cp", "-R", "#{prefix}/.", hammerspoon_dir

    # 5. Clone custom config if SPACEHAMMER_CONFIG_REPO is set
    if ENV["SPACEHAMMER_CONFIG_REPO"]
      ohai "Cloning custom config from #{ENV["SPACEHAMMER_CONFIG_REPO"]}..."
      system "git", "clone", ENV["SPACEHAMMER_CONFIG_REPO"], spacehammer_dir
    end
  end

  def caveats
    config_note = if ENV["SPACEHAMMER_CONFIG_REPO"]
      "Custom config has been cloned to ~/.spacehammer"
    else
      "On first launch, Spacehammer will create ~/.spacehammer/config.fnl"
    end

    <<~EOS
      Spacehammer has been installed to ~/.hammerspoon

      #{config_note}

      To start using Spacehammer:
        1. Launch Hammerspoon (if not already running)
        2. Press Option+Space (default LEAD key) to open the modal menu

      For more information, visit:
        https://github.com/agzam/spacehammer
    EOS
  end

  test do
    real_home = Etc.getpwuid.dir
    assert_path_exists "#{real_home}/.hammerspoon"
  end
end
