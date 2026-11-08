# FriendlyWrt prebuilt compatibility audit

Date: 2026-11-08
Branch: `prebuilt-friendlywrt`

## Executive decision

Do not install kernel modules from the stock OpenWrt package feeds or the bundled local package directory into either inspected FriendlyWrt image. Both images expose a running module tree at `/lib/modules/6.1.141`, while their available/bundled kernel-module packages target different kernel builds.

The practical path is to keep the FriendlyElec boot chain/BSP and build any missing modules against the exact FriendlyElec 6.1.141 kernel source, configuration, and symbol versions; alternatively, rebuild the full image from the matching FriendlyElec BSP. Do not replace the vendor boot chain with a generic upstream image.

## FriendlyWrt 24.10.4

Probe: [GitHub Actions run 42525596265](https://github.com/daskovvadim1-hub/domltewrt/actions/runs/42525596265)

- Image: FriendlyWrt 24.10.4, revision `r28959-29397011cc`.
- Target/architecture: `rockchip/armv8`, `aarch64_generic`.
- Root filesystem module directory: `/lib/modules/6.1.141`.
- Modules found in the image matching the modem/network/tproxy scan: `cdc_ncm.ko`, `cdc_mbim.ko`, `nft_socket.ko`, `nft_tproxy.ko`, `tun.ko`.
- The scan did not find `cdc_acm`, `cdc_ether`, `rndis_host`, `usbnet`, `usbserial`, `usb_wwan`, or `option` module files. Confirm whether any are built into the kernel before finalizing the driver plan.
- Configured public opkg feeds are architecture package feeds; the image's local package directory contains kmods/kernel packages built for `6.6.110`, and its installed package database also reports kernel dependencies at `6.6.110`. This does not match the image's `6.1.141` module tree.
- The probe did not establish a compatible 6.1.141 kmod feed. Do not treat the absence from the scanned architecture feeds as proof that no vendor feed exists.

## FriendlyWrt 25.12.5

Probe: [GitHub Actions run 42524489285](https://github.com/daskovvadim1-hub/domltewrt/actions/runs/42524489285)

- Image: FriendlyWrt 25.12.5, revision `r33051-f5dae5ece4`.
- Target/architecture: `rockchip/armv8`, `aarch64_generic`.
- Root filesystem module directory: `/lib/modules/6.1.141`.
- Bundled local kernel package: `6.12.94~452b8d54654094aee238e7bb15a5d315-r1`; local kmod packages use the `6.12.94` kernel release.
- The APK availability probe did not find the required kmod packages in the configured feeds. This is consistent with the kernel-package mismatch; it is not proof that no separate FriendlyElec package repository exists.

## Consequences for Fibocom L850-GL / L860-GL

- NCM and MBIM data-path modules are present in the inspected 24.10 root filesystem.
- The serial/AT-control path is not yet proven ready: the scan did not find the usual `cdc_acm`, `usbserial`, `usb_wwan`, and `option` modules.
- No modem has been runtime-tested on this image. Do not claim the modem works based on static image inspection alone.
- Before adding modules, inspect the exact FriendlyElec kernel source/config and obtain matching `Module.symvers`/build metadata for the 6.1.141 kernel. Build and validate only the missing drivers against that exact kernel.

## Next steps

1. Identify the exact NanoPi Zero2 board revision and preserve the current MASKROM recovery state; do not flash an unverified image.
2. Locate the matching FriendlyElec RK3528 Linux 6.1.141 source tree, kernel config, and symbol-version/build artifacts.
3. Check which of the required USB drivers are built-in versus modular in that kernel.
4. Build only missing modules against the exact kernel ABI, then validate module loading and USB enumeration before installing/configuring modem software.
5. Only after the board boots safely and the modem is tested, proceed to PassWall 2, Russian LuCI/Argon, and Multi-WAN.

## Safety rule

Never install generic OpenWrt kmods built for 6.6.110 or 6.12.94 into this 6.1.141 image. Never flash the device until exact board/image compatibility and a recovery path are confirmed.

## Confirmed vendor BSP source path

FriendlyELEC's NanoPi Zero2 wiki identifies the board as RK3528A and documents the matching Linux 6.1.y BSP path. It names:

- Kernel source: https://github.com/friendlyarm/kernel-rockchip, branch `nanopi6-v6.1.y`.
- RK3528 image/packaging scripts: https://github.com/friendlyarm/sd-fuse_rk3528, branch `kernel-6.1.y`.
- FriendlyWrt 24 and 25 are listed as supported OS profiles in the RK3528 packaging repository.

This gives us a concrete vendor-supported route for the next audit: retrieve the exact FriendlyWrt kernel configuration and build metadata from the matching FriendlyELEC tree, then compare its `kernelrelease` and `Module.symvers` with the shipped image before building any missing modem modules. The kernel source branch alone is not sufficient proof of ABI identity; the final config/build metadata must match the image.

References: [NanoPi Zero2 official wiki](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_Zero2), [FriendlyELEC RK3528 image builder](https://github.com/friendlyarm/sd-fuse_rk3528), [FriendlyELEC kernel BSP](https://github.com/friendlyarm/kernel-rockchip).
