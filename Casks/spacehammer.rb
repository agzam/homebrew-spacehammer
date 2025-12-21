# frozen_string_literal: true

cask "spacehammer" do
  version "1.6.0"
  sha256 "ccc6d70e296b50a8c8ff461a636eba49d0a1085a58ff4c53c26a8186a548fe27"

  url "https://github.com/agzam/spacehammer/archive/refs/tags/#{version}.tar.gz"
  name "Spacehammer"
  desc "Spacemacs|Doom-inspired modal toolkit for Hammerspoon"
  homepage "https://github.com/agzam/spacehammer"

  # Capture env var at load time (must be HOMEBREW_ prefixed)
  @@config_repo = ENV.fetch("HOMEBREW_SPACEHAMMER_CONFIG", nil)

  depends_on cask: "hammerspoon"
  depends_on formula: "fennel"

  preflight do
    # Validate config repo if provided
    if @@config_repo.present?
      result = system("git ls-remote #{@@config_repo} > /dev/null 2>&1")
      odie "Cannot access config repo: #{@@config_repo}" unless result
    end
  end

  postflight do
    hammerspoon_dir = "#{Dir.home}/.hammerspoon"
    spacehammer_dir = "#{Dir.home}/.spacehammer"

    # Protect existing user data - never overwrite
    if File.exist?(hammerspoon_dir)
      ohai "#{hammerspoon_dir} already exists, skipping to preserve your config"
      ohai "To update spacehammer: cd ~/.hammerspoon && git pull origin main"
    else
      source = "#{staged_path}/spacehammer-#{version}"
      ohai "Installing Spacehammer to #{hammerspoon_dir}"
      system_command "cp", args: ["-R", source, hammerspoon_dir]
    end

    # Clone config repo only if dir doesn't exist
    if @@config_repo.present?
      if File.exist?(spacehammer_dir)
        ohai "#{spacehammer_dir} already exists, skipping config clone"
      else
        ohai "Cloning config from #{@@config_repo}..."
        system_command "git", args: ["clone", @@config_repo, spacehammer_dir]
      end
    end
  end

  uninstall_postflight do
    if File.exist?("#{Dir.home}/.hammerspoon") || File.exist?("#{Dir.home}/.spacehammer")
      puts "To complete uninstall, manually remove:"
      puts "  rm -rf ~/.hammerspoon ~/.spacehammer"
    end
  end

  caveats <<~EOS
    Spacehammer will be installed to ~/.hammerspoon

    Existing ~/.hammerspoon and ~/.spacehammer directories are never
    overwritten to protect your config. To update spacehammer code:
      cd ~/.hammerspoon && git pull origin main

    To use a custom config, set before installing:
      export HOMEBREW_SPACEHAMMER_CONFIG=https://github.com/username/config-repo

    On uninstall, manually remove:
      rm -rf ~/.hammerspoon ~/.spacehammer
  EOS
end
