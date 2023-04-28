final: prev: {
   pop-control-center = let nixpkgs = prev.fetchgit (builtins.fromJSON ''{
      "url": "https://github.com/nurelin/nixpkgs",
      "rev": "d7bcff0bd40918a8d96cf68f2b766f987fad900a",
      "sha256": "1r2w6iq80ga8kspspnblk3zqbl1kfn96824cx4iiimzf88r35374"
    }'');
    pkgs = import nixpkgs { inherit (prev) system; };
  in 
  pkgs.callPackage (
    { lib
    , fetchFromGitHub
    , gnome
    , pop-desktop-widget
    , grilo
    , clutter
    , clutter-gtk
    , colord-gtk
    , libsoup
    , libhandy
    , firmware-manager
    }:

    gnome.gnome-control-center.overrideAttrs (old: rec {
    pname = "pop-control-center";
    src = fetchFromGitHub {
        owner = "pop-os";
        repo = "gnome-control-center";
        # from branch `master_jammy`
        rev = "64c84a25c51c7b6df23c0f5f420293f95df0fd1d";
        sha256 = "sha256-WIpVOUL9VFoSGejvxukZU9ljMEHDlj7DXgEPkWzTCmk=";
    };

    buildInputs = old.buildInputs ++ [
        grilo 
        pop-desktop-widget 
        gnome.cheese 
        clutter 
        clutter-gtk 
        gnome.gnome-bluetooth_1_0 
        colord-gtk 
        libsoup
        libhandy
        firmware-manager
    ];

    patches = let
        patchDir = "${src}/debian/patches";
    in old.patches ++ [
      "${patchDir}/git_owe_settings.patch"
    "${patchDir}/wacom-Print-errors-for-libwacom_new_from_-calls.patch"
    "${patchDir}/wacom-Split-off-notebook-switching-for-detected-stylus.patch"
    "${patchDir}/wacom-Add-a-fake-stylus-when-mocking-a-tablet.patch"
    "${patchDir}/wacom-Add-scenario-tester.patch"
    "${patchDir}/color-Remove-profile-upload-feature.patch"
    "${patchDir}/network-fix-critical-when-opening-VPN-details-page.patch"
    "${patchDir}/common-Fix-leak-of-GUdevDevice.patch"
    "${patchDir}/keyboard-manager-fix-leak-of-section-list-store.patch"
    "${patchDir}/keyboard-item-fix-leak-on-unused-CcKeyCombo.patch"
    "${patchDir}/keyboard-shortcut-editor-fix-leak-of-accel-string.patch"
    "${patchDir}/datetime-Remove-tzname_daylight.patch"
    "${patchDir}/ua-Use-the-new-high-contrast-key.patch"
    "${patchDir}/search-provider-Don-t-escape-result-description-as-markup.patch"
    "${patchDir}/build-Bump-required-gsettings-desktop-schemas-version.patch"
    "${patchDir}/network-Fix-saving-passwords-for-non-wifi-connections.patch"
    "${patchDir}/display-Always-show-refresh-rate.patch"
    "${patchDir}/applications-Properly-protect-against-NULL-app_id.patch"
    "${patchDir}/applications-Switch-to-g_spawn_check_wait_status.patch"
    "${patchDir}/wwan-Make-sure-secrets-are-set-when-querying-connection-A.patch"
    "${patchDir}/display-Only-display-configuration-options-if-apply-is-al.patch"
    "${patchDir}/info-Use-udev-to-get-the-hardware-RAM-size.patch"
    "${patchDir}/wacom-Allow-NULL-monitors-in-calibration.patch"
    "${patchDir}/wacom-Explicitly-discard-input-from-touchscreens.patch"
    "${patchDir}/keyboard-Allow-disabling-alternate-characters-key.patch"
    "${patchDir}/keyboard-For-xkb-options-have-Layout-default-toggle-and-N.patch"
    "${patchDir}/keyboard-Avoid-modifying-xkb-options-when-user-changes-n.patch"
    "${patchDir}/ubuntu/keyboard-Remove-01-screenshot.xml.patch"
    "${patchDir}/debian/Expose-touchpad-settings-if-synaptics-is-in-use.patch"
    "${patchDir}/debian/Debian-s-adduser-doesn-t-allow-uppercase-letters-by-defau.patch"
    "${patchDir}/debian/Revert-build-Bump-build-dependency-on-polkit.patch"
    # ubuntu/distro-logo.patch
    "${patchDir}/ubuntu/keyboard-Add-launch-terminal-shortcut.patch"
	    "${patchDir}/ubuntu/sound-Allow-volume-to-be-set-above-100.patch"
	    "${patchDir}/ubuntu/Allow-tweaking-some-settings-for-Ubuntu-Dock.patch"
	    "${patchDir}/ubuntu/multitasking-panel-Sync-workspace-and-monitor-isolation-d.patch"
	    "${patchDir}/ubuntu/Modify-Mulitasking-assets-for-accent-colors.patch"
	    "${patchDir}/ubuntu/lock-Add-Lock-Screen-on-Suspend-option.patch"
	    "${patchDir}/ubuntu/region-Add-Language-Selector-button.patch"
	    "${patchDir}/ubuntu/Adapts-the-region-capplet-and-the-language-chooser-in-the.patch"
	    "${patchDir}/ubuntu/printers-Temporarily-add-an-additional-advanced-printer-b.patch"
	    "${patchDir}/ubuntu/notifications-Handle-.desktop-files-that-got-renamed.patch"
# ubuntu/shell-Change-the-default-height-so-all-category-are-on-sc.patch
		    "${patchDir}/ubuntu/connectivity-add-network-connectivity-checking-toggle.patch"
# ubuntu/diagnostics-Add-Whoopsie-support.patch
		    "${patchDir}/ubuntu/online-accounts-Hide-window-after-adding-an-online-accoun.patch"
# ubuntu/applications-Add-hack-detect-snaps-before-X-SnapInstanceN.patch"
		    "${patchDir}/ubuntu/display-Support-UI-scaled-logical-monitor-mode.patch"
		    "${patchDir}/ubuntu/Disable-non-working-camera-microphones-panels.patch"
		    "${patchDir}/ubuntu/info-overview-Show-updates-in-software-propeties-instead-.patch"
		    "${patchDir}/ubuntu/sound-Add-a-button-to-select-the-default-theme.patch"
# ubuntu/applications-Launch-snap-store-if-it-is-installed.patch
# ubuntu/window-Stop-using-HdyLeaflet.patch
		    "${patchDir}/ubuntu/online-accounts-maybe-leak-a-reference-to-the-panel-to-pr.patch"
		    "${patchDir}/ubuntu/display-Allow-fractional-scaling-to-be-enabled.patch"
		    "${patchDir}/ubuntu/display-config-Parse-privacy-screen-property-and-expose-i.patch"
		    "${patchDir}/ubuntu/lock-panel-Add-Screen-Privacy-section-to-show-Privacy-scr.patch"
		    "${patchDir}/ubuntu/background-Support-changing-the-light-dark-theme-from-g-c.patch"

# RDP support backported to 41 - the patches match the upstream commits
		    "${patchDir}/ubuntu/sharing-rdp/0001-sharing-Port-Screen-Sharing-dialog-to-RDP.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0002-sharing-Add-TLS-certificate-generation-implementatio.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0003-sharing-tls-Change-expiration-timeout-to-2-years.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0004-sharing-Generate-RDP-TLS-certificates-when-missing.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0005-sharing-remote-login-Move-systemd-unit-management-in.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0006-sharing-systemd-service-Add-is_active-helper.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0007-sharing-remote-desktop-Use-systemd-directly-to-manag.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0008-sharing-remote-desktop-Add-copy-buttons.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0009-sharing-remote-desktop-Hook-up-to-explicit-enable-se.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0010-sharing-remote-desktop-Initialize-username-password-.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0011-sharing-remote-desktop-Only-try-to-enable-the-RDP-ba.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0012-sharing-systemd-service-Treat-static-state-as-enable.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0013-sharing-Remove-leftover-remote_desktop_password_inse.patch"
		    "${patchDir}/ubuntu/sharing-rdp/0014-sharing-panel-Make-possible-to-control-and-configure.patch"

# Pop patches
		    "${patchDir}/pop/distro-logo.patch"
		    "${patchDir}/pop/pop-allow-sound-above-100.patch"
		    "${patchDir}/pop/pop-mouse-accel.patch"
#"${patchDir}/pop/pop-shop.patch"
#"${patchDir}/pop/pop-upgrade.patch"
#"${patchDir}/pop/pop-hidpi.patch"
		    "${patchDir}/pop/system76-firmware.patch"
		    "${patchDir}/pop/pop-alert-sound.patch"
		    "${patchDir}/pop/remove-diagnostics.patch"
		    "${patchDir}/pop/0001-Do-not-enforce-password-strength-requirements.patch"
		    "${patchDir}/pop/0002-users-Recreate-RunHandler-on-failure.patch"
		    "${patchDir}/pop/cc-search-locations-dialog.patch"
		    "${patchDir}/pop/pop-no-search.patch"
		    "${patchDir}/pop/0001-keyboard-Pop-_OS-changes-with-support-for-multiple-b.patch"
#"${patchDir}/pop/pop-support.patch"
		    "${patchDir}/pop/camera-microphone-desktop.patch"
		    "${patchDir}/pop/no-adjust-for-tv.patch"
		    "${patchDir}/pop/pop-desktop-widget.patch"
		    "${patchDir}/pop/no-multitasking-panel.patch"
		    "${patchDir}/pop/touchpad-settings.patch"
#"${patchDir}/pop/pop-analytics.patch"
#"${patchDir}/pop/upgrade-scrolled.patch"
		    ];

    meta = with lib; {
	    description = "Modular IPC-based desktop launcher service for Pop!_OS";
	    maintainers = with maintainers; [ Enzime ];
	    license = licenses.gpl3;
	    homepage = "https://github.com/pop-os/gnome-control-center";
    };
    })
  ) {};
       }
