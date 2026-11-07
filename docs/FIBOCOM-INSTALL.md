# Установка Fibocom L850-GL

Этот этап выполняется **после загрузки OpenWrt с USB**. Текущая система уже видит модем как USB CDC-NCM и порты `/dev/ttyACM*`, поэтому менять USB-композицию не нужно.

## Важно перед запуском

- Нужен интернет на роутере через Ethernet/WAN или другой уже работающий канал.
- Установщик рассчитан на OpenWrt 25.x с пакетным менеджером `apk`.
- APN по умолчанию задан как `TT` (как указано для этого проекта).
- Русские переводы панелей включены.
- Автоматическая перезагрузка выключена.
- `DO_MODE_SWITCH=0`: установщик **не выполняет** `AT+GTUSBMODE=0` и не записывает NVM модема.
- Установщик добавляет XMM-интерфейс в WAN firewall zone. Перед применением проверь, что у тебя штатная конфигурация firewall; при нестандартной конфигурации проверь привязку зоны после установки.

## Запуск

Скопировать скрипт на роутер (например, через SCP/WinSCP), затем в SSH-консоли:

```sh
chmod 700 /root/install-fibocom-l850.sh
APN=TT INSTALL_RU=yes AUTO_REBOOT=0 DO_MODE_SWITCH=0 sh /root/install-fibocom-l850.sh
```

Если скрипт скачивается прямо на роутере:

```sh
wget -O /root/install-fibocom-l850.sh https://raw.githubusercontent.com/daskovvadim1-hub/domltewrt/main/scripts/install-fibocom-l850.sh
APN=TT INSTALL_RU=yes AUTO_REBOOT=0 DO_MODE_SWITCH=0 sh /root/install-fibocom-l850.sh
```

## После установки

Проверь:

```sh
ifstatus LTE_Fibocom_L850
logread | grep -i xmm
ls -l /dev/ttyACM*
```

Затем открой LuCI → Network → Interfaces. Интерфейс должен называться `LTE_Fibocom_L850`. Панели ModemData, SMS Tool и ModemBand появятся в LuCI, если feeds и подписи пакетов доступны и установка завершилась успешно.

Не публикуй IMEI, IMSI, ICCID, номер SIM или пароли.

## Ограничения

Панель может не показывать все параметры, а CA и блокировка диапазонов зависят от прошивки модема и оператора. Для L850-GL приём входящих SMS может быть ограничен особенностями XMM/IMS; не обещаем эту функцию до проверки на SIM. Скрипт не включает PassWall 2, Xray, sing-box, TTL или IPv6 Hop Limit — это отдельный этап после подтверждения LTE-соединения.
