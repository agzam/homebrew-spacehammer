class Spacehammer < Formula
  desc "Spacemacs|Doom-inspired modal toolkit for Hammerspoon"
  homepage "https://github.com/agzam/spacehammer"
  url "https://github.com/agzam/spacehammer/archive/refs/tags/1.6.0.tar.gz"
  version "1.6.0"
  sha256 "ccc6d70e296b50a8c8ff461a636eba49d0a1085a58ff4c53c26a8186a548fe27"
  head "https://github.com/agzam/spacehammer.git", branch: "master"

  depends_on "fennel"

  def install
    hammerspoon_dir = "#{Dir.home}/.hammerspoon"
    spacehammer_dir = "#{Dir.home}/.spacehammer"
    timestamp = Time.now.to_i

    # 1. Backup ~/.hammerspoon if exists
    if File.exist?(hammerspoon_dir) && !File.symlink?(hammerspoon_dir)
      backup = "#{hammerspoon_dir}.backup.#{timestamp}"
      ohai "Backing up ~/.hammerspoon to #{backup}"
      FileUtils.mv(hammerspoon_dir, backup)
    elsif File.symlink?(hammerspoon_dir)
      ohai "Removing existing symlink at ~/.hammerspoon"
      File.delete(hammerspoon_dir)
    end

    # 2. Backup ~/.spacehammer if exists AND we're cloning a new config
    if ENV["SPACEHAMMER_CONFIG_REPO"] && File.exist?(spacehammer_dir)
      backup = "#{spacehammer_dir}.backup.#{timestamp}"
      ohai "Backing up ~/.spacehammer to #{backup}"
      FileUtils.mv(spacehammer_dir, backup)
    end

    # 3. Install Hammerspoon cask if not present
    unless File.exist?("/Applications/Hammerspoon.app")
      ohai "Installing Hammerspoon..."
      system "brew", "install", "--cask", "hammerspoon"
    end

    # 4. Create ~/.hammerspoon and copy spacehammer files directly
    ohai "Installing Spacehammer to ~/.hammerspoon"
    FileUtils.mkdir_p(hammerspoon_dir)
    
    # Copy all files from buildpath to ~/.hammerspoon
    Dir.glob("#{buildpath}/*").each { |f| FileUtils.cp_r(f, hammerspoon_dir) }
    Dir.glob("#{buildpath}/.*").reject { |f| f.end_with?(".", "..") }.each { |f| FileUtils.cp_r(f, hammerspoon_dir) }

    # 5. Clone custom config if SPACEHAMMER_CONFIG_REPO is set
    if ENV["SPACEHAMMER_CONFIG_REPO"]
      ohai "Cloning custom config from #{ENV["SPACEHAMMER_CONFIG_REPO"]}..."
      system "git", "clone", ENV["SPACEHAMMER_CONFIG_REPO"], spacehammer_dir
    end

    # Also install to prefix for Homebrew tracking
    prefix.install Dir["*"]
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
    assert_path_exists "#{Dir.home}/.hammerspoon"
  end
end
