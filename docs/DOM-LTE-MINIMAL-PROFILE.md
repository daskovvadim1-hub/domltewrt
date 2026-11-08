# DOM-LTE-MINIMAL profile — NanoPi Zero2

Status: preparation only. This file does not change the active build workflow or kernel configuration.

## Goals

Reduce build time and firmware footprint while retaining the NanoPi Zero2 RK3528A FriendlyELEC boot chain/BSP and the router's required LTE, WAN failover, firewall and LuCI features.

## Must keep

- FriendlyELEC RK3528 BSP, board DTB, bootloader and eMMC image tooling.
- Board Ethernet and USB host/controller support.
- USB CDC-NCM, CDC-MBIM (if present in the selected modem path), USB ACM and USB serial/option/wwan support for Fibocom L850-GL/L860-GL.
- RNDIS for phone USB tethering.
- TUN, nftables/tproxy/socket, routing, conntrack, NAT and netfilter dependencies required by PassWall 2.
- LuCI, Russian translations, Argon, XMM protocol/modem packages, modem panels, Xray and sing-box.
- Generic USB input/recovery support needed for console and maintenance.

## Candidate areas for removal — audit before changing Kconfig

These are investigation targets, not approved blanket disables:
- DVB/TV tuners and unrelated media capture devices.
- NFC.
- CAN and IEEE 802.15.4.
- Bluetooth, only if the board configuration and user requirements do not need it.
- RAID/MD and unrelated storage stacks.
- ATM, Phonet, DCCP, SCTP, RxRPC and other uncommon protocol families, after checking selected package dependencies.
- Unrelated USB Wi-Fi and external Wi-Fi vendor drivers.

## Do not disable blindly

- Rockchip BSP drivers, board-specific Ethernet, storage, USB PHY/controller, regulators, clocks, pinctrl or thermal support.
- Rockchip NPU or integrated Wi-Fi components until the board config and runtime requirements are confirmed.
- mac80211/cfg80211 or shared wireless infrastructure while any selected onboard Wi-Fi driver depends on them.
- CDC-NCM/MBIM, USB serial, TUN, nftables, conntrack, netfilter, IPv6 kernel support or PPP dependencies without checking package closure.
- Kernel source directories manually. Prune through the actual Kconfig/profile and vendor build configuration.

## Validation required before enabling this profile

1. Preserve the successful baseline build and record its manifest, kernel release, target config and image contents.
2. Capture the effective kernel .config and package config after FriendlyWrt defconfig/merge steps.
3. Map each proposed Kconfig disable to selected packages, board hardware and reverse dependencies.
4. Apply changes in small groups, one commit per group.
5. Build and compare build duration, kernel/module size, rootfs size and eMMC image size.
6. Verify Ethernet, USB host, Fibocom NCM/serial, phone RNDIS tethering, LuCI, PassWall 2 and boot from eMMC on hardware.
7. Never publish or flash an image until the eMMC image and recovery path are verified.

## Current baseline

The active `nanopi-zero2` build run #11 is intentionally left untouched. This branch is not wired to the board-specific `build-nanopi-zero2.yml` trigger. The generic `.github/workflows/build.yml` previously did run on pushes to this branch and started an unrelated x86/Legacy BIOS ImageBuilder run (#50). Its push trigger now explicitly ignores `dom-lte-minimal`; the already-running #50 job is unaffected by that change. No kernel or package-pruning changes have been applied in this profile yet.
