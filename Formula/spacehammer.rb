class Spacehammer < Formula
  desc "Spacemacs|Doom-inspired modal toolkit for Hammerspoon"
  homepage "https://github.com/agzam/spacehammer"
  url "https://github.com/agzam/spacehammer/archive/refs/tags/1.6.0.tar.gz"
  version "1.6.0"
  sha256 "ccc6d70e296b50a8c8ff461a636eba49d0a1085a58ff4c53c26a8186a548fe27"
  head "https://github.com/agzam/spacehammer.git", branch: "master"

  depends_on cask: "hammerspoon"
  depends_on "fennel"

  def install
    # Install to Cellar (standard formula behavior)
    prefix.install Dir["*"]
    prefix.install Dir[".*"].reject { |f| f.end_with?(".", "..") }
  end

  def post_install
    hammerspoon_dir = "#{Dir.home}/.hammerspoon"

    # Warn if ~/.hammerspoon is a git repository
    if File.exist?("#{hammerspoon_dir}/.git")
      opoo "WARNING: ~/.hammerspoon appears to be a git repository"
      opoo "It will be backed up, but you may want to commit/push changes first"
      opoo "Press Ctrl+C now to cancel, or wait 5 seconds to continue..."
      sleep 5
    end

    # Backup existing ~/.hammerspoon
    if File.exist?(hammerspoon_dir) || File.symlink?(hammerspoon_dir)
      backup_dir = "#{hammerspoon_dir}.backup.#{Time.now.to_i}"
      if File.symlink?(hammerspoon_dir)
        File.delete(hammerspoon_dir)
        ohai "Removed existing symlink at ~/.hammerspoon"
      else
        system "mv", hammerspoon_dir, backup_dir
        ohai "Backed up ~/.hammerspoon to #{backup_dir}"
      end
    end

    # Copy from Cellar to ~/.hammerspoon
    system "mkdir", "-p", hammerspoon_dir
    system "cp", "-R", "#{prefix}/.", hammerspoon_dir

    # Clone custom config if SPACEHAMMER_CONFIG_REPO environment variable is set
    config_repo = ENV["SPACEHAMMER_CONFIG_REPO"]
    if config_repo
      config_dir = "#{Dir.home}/.spacehammer"

      if File.exist?(config_dir)
        opoo "~/.spacehammer already exists, skipping config clone"
      else
        ohai "Cloning custom config from #{config_repo}..."
        system "git", "clone", config_repo, config_dir
      end
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
    assert_path_exists "#{Dir.home}/.hammerspoon"
  end
end
