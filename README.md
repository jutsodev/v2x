# V2X — Твой неубиваемый туннель в свободный интернет

Premium iOS VPN клиент нового поколения с Liquid Glass UI дизайном для iPhone 16 Pro Max.

## Особенности

### Liquid Glass Premium UI
- Глубокий чёрный фон с неоновыми акцентами (Cyan, Purple, Green)
- Liquid Glass эффекты на всех элементах: рефракция, хроматическая аберрация, caustics
- Physics-based анимации с spring и micro-interactions
- Canvas-based particle системы для максимальной производительности

### Поддерживаемые протоколы
- **VLESS** — включая VLESS+Reality
- **Trojan** — TLS-based протокол
- **VMess** — V2Ray протокол
- **Hysteria2** — QUIC-based протокол
- **TUIC** — UDP over QUIC
- **Shadowsocks** — AEAD шифрование
- **WireGuard** — современный VPN протокол

### Уникальные фичи
- **AI Smart Connect** — автоматический выбор лучшего сервера и протокола
- **Quantum Stealth Mode** — тройная обфускация + quantum-resistant шифрование
- **V2X Pulse** — живые пульсирующие частицы вокруг кнопки подключения
- **Live Threat Shield** — блокировка трекеров, рекламы, malware в реальном времени
- **Mood Liquid Themes** — 5 тем: Ice, Neon, Cyberpunk, Obsidian, Blood
- **Shake to Disconnect** — мгновенное отключение встряхиванием
- **One-Tap Import** — поддержка любых ссылок: vless://, trojan://, vmess://, и др.
- **Universal Config Acceptor** — парсинг любых конфигураций и base64
- **Speed Test** — встроенный тест скорости
- **Network Diagnostics** — диагностика сети в реальном времени
- **Share Proxy** — поделиться VPN с другими устройствами через HTTP/SOCKS5

### URL Schemes (v2x://)
```
v2x://connect          — Запустить туннель
v2x://disconnect       — Остановить соединение
v2x://toggle           — Переключить состояние
v2x://add/{url}        — Добавить конфигурацию
v2x://import/vless     — Импорт VLESS конфига
v2x://import/trojan    — Импорт Trojan конфига
v2x://routing/add/{b64} — Добавить правило роутинга
```

### Экраны приложения
1. **Главный экран** — подключение/отключение с V2X Pulse анимацией
2. **Настройки** — полный набор параметров
3. **Туннель** — настройки VPN туннеля
4. **Профили** — управление VPN профилями
5. **Редактор профилей** — создание конфигураций вручную
6. **DNS** — настройка DNS серверов (DoH, DoT)
7. **Роутинг** — правила маршрутизации + GeoFiles
8. **Статистика** — графики трафика в реальном времени
9. **Подписки** — управление подписками
10. **AI Smart Connect** — ИИ-анализ сети
11. **Quantum Stealth** — продвинутая обфускация
12. **Threat Shield** — защита от угроз
13. **Серверы** — список серверов с пингом
14. **Speed Test** — тест скорости соединения
15. **Диагностика сети** — полная диагностика
16. **Импорт конфигов** — URL, Clipboard, QR, Telegram
17. **Экспорт** — URL, Base64, JSON, QR
18. **Темы** — выбор Mood Liquid Theme
19. **Логи** — просмотр журнала событий
20. **URL Schemes** — справочник URL-схем
21. **О приложении** — информация и ссылки
22. **Сообщество** — Telegram и каналы

## Технические характеристики

- **Платформа:** iOS 17.0+
- **Фреймворк:** SwiftUI
- **Архитектура:** MVVM с @StateObject / @EnvironmentObject
- **UI:** Liquid Glass Morphism
- **Анимации:** Canvas, Spring Physics, Particle Systems
- **Объём кода:** 15,000+ строк Swift
- **Файлов:** 59 Swift файлов
- **Bundle ID:** com.v2x.app

## Сборка

### Требования
- Xcode 15.0+
- iOS 17.0 SDK
- macOS Sonoma+

### Инструкции
```bash
git clone https://github.com/jutsodev/v2x.git
cd v2x
open V2X/V2X.xcodeproj
# Выберите iPhone 16 Pro Max симулятор и нажмите Build (⌘B)
```

## Контакты

- **Telegram:** [t.me/kreadwrite](https://t.me/kreadwrite)
- **Канал:** [@kreadwriteQ](https://t.me/kreadwriteQ)

## Лицензия

© 2025 V2X Team. All rights reserved.
