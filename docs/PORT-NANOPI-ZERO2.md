# Порт DOM LTE WRT на NanoPi Zero2

## Цель

Отдельная ARM64-сборка для FriendlyELEC NanoPi Zero2 (Rockchip RK3528A), 2 ГБ RAM, eMMC 64 ГБ. Ветка `nanopi-zero2` не меняет основной x86/Legacy BIOS проект.

## Платформа и сборка

- FriendlyWrt 25.12 для RK3528A, vendor kernel 6.1.y.
- Используется официальный manifest FriendlyELEC `rk3528.xml` и штатный `build.sh rk3528.mk` / `emmc-img`.
- eMMC image создаётся штатными инструментами FriendlyELEC; x86 ImageBuilder и ext4-combined образ не подходят.
- Источники: https://wiki.friendlyelec.com/wiki/index.php/NanoPi_Zero2 и https://wiki.friendlyelec.com/wiki/index.php/Template:RK3528-BuildFromSource

## Целевой набор DOM LTE WRT

- Fibocom L850-GL / L860-GL: штатный USB NCM + `proto xmm`; никаких команд переключения композиции.
- Драйверы USB ACM, CDC-NCM и serial собираются из FriendlyWrt для точного kernel ABI RK3528.
- LuCI на русском, тема Argon по умолчанию, Adblock.
- Панели 4IceG: 3ginfo-lite, ModemData, ModemBand, SMS Tool JS и русские переводы — устанавливаются в rootfs на этапе сборки из подписанного ARM64 APK-репозитория.
- PassWall 2, русский перевод, Xray, sing-box, geoip/geosite — устанавливаются на этапе сборки из подписанных репозиториев для `aarch64_cortex-a53`.
- nft tproxy / socket и TUN kernel modules собираются из текущего FriendlyWrt build, а не берутся из чужого kernel feed.
- IPv6 не вырезается: отключён по умолчанию через sysctl, стек и пакеты остаются доступными.

## Важные ограничения безопасности

- Не переключать USB composition модема.
- Не выполнять AT-команды с записью NVM.
- Не менять APN автоматически.
- Не использовать x86 APK, kernel modules или образы на NanoPi.
- Не публиковать eMMC image как готовый, пока workflow не проверил установленные пакеты, Argon, XMM-компоненты и упаковку eMMC.

## Порядок проверки

1. Зафиксировать FriendlyWrt manifest, kernel release и package architecture.
2. Собрать XMM feed и kernel modules для RK3528.
3. Установить подписанные 4IceG и PassWall APK в build rootfs под QEMU user-mode, до упаковки eMMC.
4. Проверить package DB, наличие Argon и настройки IPv6 по умолчанию.
5. Создать eMMC image через FriendlyELEC `emmc-img`.
6. После получения платы проверить загрузку, Ethernet/LuCI, USB NCM, `/dev/ttyACM*` и работу `proto xmm` с модемом — не меняя его композицию.

## Состояние

Портирование находится в процессе. До успешного завершения workflow и аппаратной проверки готовой прошивкой образ не считается.
