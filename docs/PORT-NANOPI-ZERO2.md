# Порт DOM LTE WRT на NanoPi Zero2

## Цель

Отдельная ARM64-сборка для FriendlyELEC NanoPi Zero2 (Rockchip RK3528A), 2 ГБ RAM, eMMC 64 ГБ. Ветка `nanopi-zero2` не меняет основной x86/Legacy BIOS проект.

## Подтверждённая платформа

- SoC: Rockchip RK3528A, Cortex-A53, ARM64.
- Плата имеет один USB 2.0 Host Type-A и USB-C Device для прошивки eMMC.
- Официальная платформа FriendlyWrt 25.12; vendor kernel 6.1.y.
- Для eMMC требуется образ, собранный инструментами FriendlyELEC RK3528 (SD/eMMC packaging, GPT); x86 ImageBuilder и ext4-combined образ не подходят.

Первичный источник: https://wiki.friendlyelec.com/wiki/index.php/NanoPi_Zero2

## Сохраняемые функции проекта

- Fibocom L850-GL / L860-GL: только штатный USB NCM + `proto xmm`.
- LuCI, русский язык, Argon.
- PassWall 2, Xray, sing-box.
- Adblock.
- IPv6 отключён по умолчанию, но стек не вырезается.
- Не переключать USB composition модема; не выполнять AT-команды записи в NVM; не менять APN автоматически.

## Критическая совместимость

Нельзя переносить x86 APK и kernel modules на RK3528. FriendlyWrt для этой платы использует vendor kernel 6.1.y, поэтому все kernel modules (USB serial, CDC-NCM, nft tproxy, tun и возможные XMM kernel dependencies) должны быть собраны для точного kernel ABI и конфигурации FriendlyWrt. Обычные пакеты LuCI/userspace также нужно брать из ARM64 feed совместимой версии.

Перед созданием прошиваемого образа необходимо:
1. Зафиксировать manifest/commit FriendlyWrt 25.12 RK3528 и kernel release.
2. Проверить доступность ARM64 пакетов ModemData/ModemBand/SMS/XMM и PassWall.
3. Собрать или включить kernel modules именно из исходников/конфигурации FriendlyELEC.
4. Проверить наличие USB VID/PID и tty/net интерфейсов L850-GL/L860-GL без изменения композиции.
5. Сформировать SD recovery image и eMMC image через штатный RK3528 sd-fuse/eMMC packaging.
6. Проверить манифест, загрузку с SD и eMMC, Ethernet, LuCI, USB NCM и только затем публиковать release artifact.

## Состояние порта

Подготовка порта начата. На этом этапе создана отдельная ветка и спецификация; готового образа и подтверждённой сборки ещё нет. Не прошивать x86-образ на NanoPi Zero2.
