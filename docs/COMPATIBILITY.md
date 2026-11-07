# Матрица совместимости — ДОМ LTE WRT

Проверка источников: 2026-11-07. Фактическая совместимость зависит от USB/PCIe-подключения, прошивки модема и feeds.

## Fibocom L850-GL и L860-GL: правильный путь NCM/XMM
- Пользователь сообщил, что модем определялся как XMM и интернет через него работал.
- Для этих модемов в OpenWrt есть отдельный протокол `xmm`: пакет LuCI `luci-proto-xmm` подтягивает сервис `xmm-modem` и необходимые зависимости из стороннего feed 132lan.
- В режиме USB NCM нужны как минимум `kmod-usb-net-cdc-ncm` и `kmod-usb-acm`; для AT-портов также используется `/dev/ttyACM*`. Для конкретной USB-композиции может понадобиться `kmod-usb-serial-option`.
- В конфигурации сети используется `proto 'xmm'`, а не QMI/MBIM. Пакеты QMI/MBIM оставлены только как диагностический запас и не являются основным способом подключения этих Fibocom.
- Источники с практическими инструкциями:
  - https://github.com/lastik9/openwrt-fibocom-l850
  - https://github.com/lastik9/openwrt-fibocom-l860gl
  - https://www.satriadykomunikasi.eu.org/2022/07/cara-setting-fibocom-l850-gl-l860-gl-mode-ncm-openwrt.html

## Важное различие моделей
- L850-GL — Intel XMM7360.
- L860-GL — Intel XMM7560.
- Не следует путать USB NCM + OpenWrt proto xmm с отдельным Linux PCIe-проектом `xmm7360-pci`. Это разные способы подключения/драйверные пути.

## Что включено в базовый образ
- OpenWrt 25.12.6 / target `x86/legacy`, ext4 combined — для старого ПК с Legacy BIOS.
- `kmod-usb-acm`, `kmod-usb-net-cdc-ncm`, `kmod-usb-serial-option`.
- Русский LuCI и базовые диагностические утилиты.
- Внешний feed 132lan и `luci-proto-xmm` пока не встраиваются в ImageBuilder: их установка должна выполняться на уже загруженной системе через APK. Это требует доступного интернета на роутере.

## LTE-панель
- Кандидат: `luci-app-3ginfo-lite`, `luci-app-sms-tool-js`, `luci-app-modemband` из APK feed 4IceG.
- Эти панели заявляют мониторинг модема, AT/SMS/USSD и выбор диапазонов; реальные функции зависят от доступных AT-команд и прошивки.
- Источники: https://github.com/4IceG/Modem-extras-apk и https://github.com/lastik9/openwrt-fibocom-l850

## VPN и сетевые правила
- PassWall 2, Xray и sing-box пока не включены: сначала требуется проверить feeds и зависимости для OpenWrt 25.12.6 x86/legacy.
- TTL и IPv6 Hop Limit добавим после проверки nftables/fw4 на целевой системе.

## Проверка модема после загрузки
В подключённой OpenWrt выполнить:
```sh
lsusb
lsusb -t
dmesg | grep -iE 'fibocom|xmm|cdc_acm|cdc_ncm'
ls -l /dev/ttyACM* 2>/dev/null
ip link
```
После установки `luci-proto-xmm` и настройки интерфейса проверить:
```sh
uci show network | grep -A8 -B2 xmm
logread | grep -i xmm
ifstatus LTE_Fibocom
```
Не отправлять IMEI, IMSI, ICCID, номер SIM и пароли.
