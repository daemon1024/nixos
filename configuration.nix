# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Workstation"; # Define your hostname.
  networking.networkmanager.enable = true; # Wifi via network manager

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    acpi
    acpid

    neovim
    tmux
    git
    htop

    dwm
    dmenu
    st
    slstatus
    slock
    xautolock
    feh
    xfce.thunar
    xfce.thunar-volman

    discord
    tdesktop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };
  programs.light.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 5"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 5"; }
      { keys = [ 122 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/amixer set 'Master' 5%-"; } { keys = [ 123 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/amixer set 'Master' 5%+"; }
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Swap control and caps lock
  services.xserver.xkbOptions = "ctrl:swapcaps";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Set up dwm
  services.xserver.windowManager.dwm.enable = true;

  nixpkgs.overlays = [
    (self: super: {
      # dwm from personal github fork
      dwm = super.dwm.overrideAttrs (oa: {
        src = super.fetchFromGitHub {
                owner = "BK1603";
                repo = "dwm";
                rev = "2cfc08d2bcaf8a272496715922d3ebf12fa6d790";
                sha256 = "11hlfipixz50rxqksgy88qznhl6cbj4pdg3ds6lnzjnnqxqfbdi3";
              };
	
	patches = oa.patches ++ [
	  (builtins.fetchurl https://dwm.suckless.org/patches/fibonacci/dwm-fibonacci-6.2.diff)
	  (builtins.fetchurl https://dwm.suckless.org/patches/actualfullscreen/dwm-actualfullscreen-20191112-cb3f58a.diff)
	];
      });

      #st patches
      st = super.st.overrideAttrs (oa: {
        src = super.fetchFromGitHub {
	  owner = "BK1603";
	  repo = "st";
	  rev = "05499c8ab9920a90a1ebe3b41bc3dd6ac55c9ab6";
	  sha256 = "0gwrc8mdypfw295lxkick214jwfqyrfrlvwx0zdx3lgx9bidxxwf";
	};
	
        patches = oa.patches ++ [
          (builtins.fetchurl https://st.suckless.org/patches/dracula/st-dracula-0.8.2.diff)
        ];
      });
    })
  ];

  # Setup lightdm
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.defaultSession = "none+dwm";
  services.xserver.displayManager.sessionCommands = ''
    feh --bg-fill /home/bk1603/Downloads/wallpaper.jpg;
    /home/bk1603/.xsetroot &
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bk1603 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}

