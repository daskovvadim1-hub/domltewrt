# DOM LTE WRT — OpenWrt Edition (NanoPi Zero2)

## Decision

Build DOM LTE WRT as an OpenWrt-based system while retaining the board-specific boot chain and hardware support supplied by FriendlyElec for the RK3528A NanoPi Zero2.

**Important:** FriendlyWrt 25.12 is already based on OpenWrt 25.12. The NanoPi Zero2 vendor image combines that OpenWrt userspace with FriendlyElec's RK3528 board support (Linux 6.1.y kernel, device tree, U-Boot and image packaging). Therefore, switching to an unrelated generic upstream OpenWrt target would not be a safe shortcut: the board target, bootloader and eMMC layout must be proven compatible first.

## Hardware facts to preserve

- Board: FriendlyElec NanoPi Zero2
- SoC: Rockchip RK3528A
- Storage: eMMC (exact capacity to be verified on the user's board)
- USB-C: USB 2.0 device port used for eMMC upgrade
- Vendor platform documented by FriendlyElec: RK3528, Linux 6.1.y, U-Boot 2017.09
- Vendor OpenWrt-derived baseline: FriendlyWrt 25.12

Reference: https://wiki.friendlyelec.com/wiki/index.php/NanoPi_Zero2

## Planned DOM LTE features

- Fibocom L850-GL / L860-GL: USB ACM/serial and CDC-NCM support
- XMM modem integration and LuCI protocol support
- LuCI in Russian and Argon theme
- PassWall 2 with Xray and sing-box, subject to repository/package compatibility checks
- Keep the image focused on required drivers and packages
- eMMC image packaging using the vendor RK3528 tooling

## Build and validation strategy

1. Keep the existing `nanopi-zero2` branch and its current workflow unchanged while its build is being evaluated.
2. Use this `openwrt-edition` branch for OpenWrt Edition work.
3. Start from the documented FriendlyElec RK3528 BSP/manifest and OpenWrt 25.12-based FriendlyWrt source, not from a generic target lacking verified NanoPi Zero2 support.
4. Confirm package feeds, package architecture, kernel ABI and signing compatibility before adding modem panels or PassWall packages.
5. Build a test image and inspect its partition table, boot files, DTB, kernel modules and root filesystem.
6. Do not flash the user's board until the exact board revision, image type, loader/upgrade method and recovery path have been verified.

## Current status

This branch is a safe working branch and design baseline only. No new firmware has been built from this branch yet. The existing run #10 belongs to the original `nanopi-zero2` branch and is not changed by this document.
