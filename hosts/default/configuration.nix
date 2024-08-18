{ config, pkgs, inputs, ... }:

{
  imports = 
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # * ============ *
  # * Nix Settings *
  # * ============ *

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
  };


  # * ========== *
  # * Bootloader *
  # * ========== *

  boot = {

    kernelPackages = pkgs.linuxPackages_latest;
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot.enable = false;

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      grub = {
        enable = true;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
        theme = "${
          pkgs.fetchFromGitHub {
          owner = "Blaysht";
          repo = "grub_bios_theme";
          rev = "035554c30df6a10158a5a71acfbc4975045fc7ac";
          hash = "sha256-kYcEMCV9ipwPGgfAwOtFgYO4eHZxkUS97tOr0ft4rUE=";
        }}/OldBIOS";

      };
    };
  };


  # * ======== *
  # * Graphics *
  # * ======== *

  # Enable Graphics
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management.
    # Enable this if you have graphical corruption issues or application crashes after waking up from sleep. 
    # This fixes it by saving the entire VRAM memory to /tmp/ instead of just the bare essentials.
    # ! Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # ! Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


  # * ========== *
  # * Networking *
  # * ========== *

  # Set up networking
  networking.hostName = "brick"; # Define your hostname.

  # Enable networking
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Enable Tailscale
  services.tailscale.enable = true;


  # * ====== *
  # * Locale *
  # * ====== *
  
  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };



  # * ============== *
  # * Window Manager *
  # * ============== *

  # # Enable the X11 windowing system.
  # services.xserver = {
  #   enable = true;
  #   # Enable touchpad support (enabled default in most desktopManager).
  #   # libinput.enable = true;

  #   # Configure keymap in X11
  #   xkb = {
  #     layout = "us";
  #     variant = "";
  #   };
  # };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };


  # * ===== *
  # * Audio *
  # * ===== *

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # * ================== *
  # * User Configuration *
  # * ================== *

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bailey = {
    isNormalUser = true;
    description = "Bailey Allen";
    extraGroups = [ "networkmanager" "wheel"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "bailey" = import ./home.nix;
    };
  };

  # * =============== *
  # * System Packages *
  # * =============== *

  # Install firefox.
  programs.firefox.enable = false;

  # Install Steam
  programs.steam.enable = true;
  
  # enable zsh
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # stuff i'll need at a later date so might as well put up the top
    git
    kitty
    tailscale
    gh
    vscode
    texliveFull
    stow
    fzf
    zoxide
    nanorc

    # eh i'll probably need to program on this
    rustup
    jdk

    # "because blue is cool"
    firefox-devedition
    bitwarden
    
    # nerd notes
    obsidian
    zotero_7
    libreoffice-fresh

    # so i dont die inside
    spotify
    vlc

    # arty farty
    inkscape
    gimp
    upscayl
    
    # i have friends ok
    discord

    # why are icons always ugly
    papirus-icon-theme

    # it's at the bottom for a reason
    google-chrome
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # * ======== *
  # * Services *
  # * ======== *
  # List services that you want to enable:

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;



  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # ! DO NOT CHANGE THIS FROM `24.05`
  system.stateVersion = "24.05";
}
