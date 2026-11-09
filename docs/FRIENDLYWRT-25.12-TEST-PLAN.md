# NanoPi Zero2 — FriendlyWrt 25.12 test track

## Goal

Use the official FriendlyELEC FriendlyWrt 25.12 RK3528 image as the starting point for DOM LTE WRT. Preserve the vendor boot chain, kernel, device tree and board-specific configuration. Keep all requested modem and routing applications; Docker is the only intentional exclusion.

## Verified platform facts

- Board: NanoPi Zero2, Rockchip RK3528A, Cortex-A53, 2 GB RAM, eMMC.
- Official image family: `rk3528-sd-friendlywrt-25.12-YYYYMMDD.img.gz`.
- Official image kernel family: 6.1.y.
- FriendlyELEC documents the `sd` image for booting from microSD.
- Do not use an `eflasher` image for the first boot: its default behavior can automatically write eMMC.
- FriendlyELEC documents eMMC installation from a running SD-based FriendlyWrt via System → eMMC Tools, selecting an official `-sd-` or `-usb-` image.
- Official source build manifest is `friendlyarm/friendlywrt_manifests`, branch `master-v25.12`, manifest `rk3528.xml`.

Official references:
- https://wiki.friendlyelec.com/wiki/index.php/NanoPi_Zero2
- https://download.friendlyelec.com/NanoPiZero2
- https://github.com/friendlyarm/friendlywrt_manifests

## Mandatory inspection before package integration

1. Obtain the exact official non-Docker SD image and record its filename, date, size and published checksum (if available).
2. Inspect the image without writing it to any physical media.
3. Determine the actual APK architecture from the image (`/etc/apk/arch`, `apk --print-arch`), installed package database, kernel release and kernel package ABI.
4. Inspect the official image's repository configuration and signing keys.
5. Verify the 4IceG and PassWall repositories: APK architecture, signatures, package availability and dependency closure. Do not assume `aarch64_cortex-a53` or `aarch64_generic` until the image reports its architecture.
6. Build/install Fibocom XMM kernel modules and modem feed packages only against the exact FriendlyWrt 6.1.y kernel ABI and matching source revision.
7. Keep the full requested app set: luci-app-5gmodem, XMM modem support, 3ginfo-lite, ModemData, ModemBand, SMS Tool JS, PassWall 2, Xray, sing-box, geoip/geosite and required dependencies/translations.
8. Exclude Docker packages only: dockerd, luci-app-dockerman, containerd and docker-compose.
9. Verify package database consistency, all required apps, LuCI theme/configuration, boot files and output image structure.
10. Produce separate SD and eMMC installation artifacts only after all checks pass.

## Safety gates

- No writes to the user's microSD or eMMC during build preparation.
- No automatic eMMC flashing image for first boot.
- No eMMC erase, MASKROM erase, or RKDevTool write operation.
- Do not call an image ready until it has passed offline inspection and then a real SD boot test.
- The first hardware test must boot from microSD. Only after that is confirmed should eMMC installation be planned.
- After eMMC installation, remove microSD and verify independent eMMC boot.

## Current status

- Separate test branch created from `nanopi-zero2`.
- Previous workflow run #15 is cancelled.
- Official image architecture, repository metadata, package compatibility and kernel ABI are not yet verified.
- No firmware image has been written to physical media.
