# frozen_string_literal: true

cask "spacehammer" do
  version "1.6.0"
  sha256 "ccc6d70e296b50a8c8ff461a636eba49d0a1085a58ff4c53c26a8186a548fe27"

  url "https://github.com/agzam/spacehammer/archive/refs/tags/#{version}.tar.gz"
  name "Spacehammer"
  desc "Spacemacs|Doom-inspired modal toolkit for Hammerspoon"
  homepage "https://github.com/agzam/spacehammer"

  # Capture env var at load time (must be HOMEBREW_ prefixed)
  @@config_repo = ENV["HOMEBREW_SPACEHAMMER_CONFIG"]

  depends_on cask: "hammerspoon"
  depends_on formula: "fennel"

  preflight do
    # Check BEFORE anything installs
    hammerspoon_dir = "#{Dir.home}/.hammerspoon"
    spacehammer_dir = "#{Dir.home}/.spacehammer"
    if File.exist?(hammerspoon_dir) || File.exist?(spacehammer_dir)
      odie <<~EOS
        ~/.hammerspoon or ~/.spacehammer already exists.
        Please backup and remove first:
          mv ~/.hammerspoon ~/.hammerspoon.backup
          mv ~/.spacehammer ~/.spacehammer.backup
      EOS
    end

    # Validate config repo if provided
    if @@config_repo && !@@config_repo.empty?
      result = system("git ls-remote #{@@config_repo} > /dev/null 2>&1")
      unless result
        odie "Cannot access config repo: #{@@config_repo}"
      end
    end
  end

  postflight do
    source = "#{staged_path}/spacehammer-#{version}"
    target = "#{Dir.home}/.hammerspoon"
    ohai "Installing Spacehammer to #{target}"
    system_command "cp", args: ["-R", source, target]

    if @@config_repo && !@@config_repo.empty?
      ohai "Cloning config from #{@@config_repo}..."
      system_command "git", args: ["clone", @@config_repo, "#{Dir.home}/.spacehammer"]
    end
  end

  uninstall_postflight do
    if File.exist?("#{Dir.home}/.hammerspoon") || File.exist?("#{Dir.home}/.spacehammer")
      puts "To complete uninstall, manually remove:"
      puts "  rm -rf ~/.hammerspoon ~/.spacehammer"
    end
  end

  caveats <<~EOS
    Spacehammer installed to ~/.hammerspoon

    On uninstall, manually remove:
      rm -rf ~/.hammerspoon ~/.spacehammer
  EOS
end
