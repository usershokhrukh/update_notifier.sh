# 🚀 Arch Update Notifier (Pro Version)

Arch Linux foydalanuvchilari uchun interaktiv, xavfsiz va aqlli yangilanishlar monitoringi tizimi. Hyprland, GNOME va boshqa oyna boshqaruvchilari uchun maxsus moslashtirilgan.

---

## 🛠 Tizim imkoniyatlari (Roadmap)

- **Avtomatik Monitoring:** Har 3 soatda yangilanishlarni fonda tekshiradi.
- **Paketlar Preview:** Bildirishnomada qaysi paketlar yangilanishini ko'rsatadi.
- **Xavfsiz O'rnatish:** `screen` orqali terminal yopilsa ham jarayon fonda davom etadi.
- **Action Required:** Agar `pacman` tasdiqlash (`Y/n`) so'rasa, skript sizni darhol ogohlantiradi.
- **Manual Trigger:** `Win + U` orqali istalgan vaqtda majburiy tekshirish imkoniyati.
- **Resurs Tejovchi:** Internet yo'qligida kutish rejimiga o'tadi va protsessorni yuklamaydi.

---

## 📦 O'rnatish va Sozlash

### 1. Kerakli paketlarni o'rnatish

Avval tizimingizda quyidagi vositalar borligiga ishonch hosil qiling:

```bash
sudo pacman -S --needed pacman-contrib libnotify screen kitty wget
```

---

## Skriptga ruxsat berish

```bash
chmod +x ~/update_notifier.sh
```

---

## ⚙️ Avtostartga qo'shish 'hyprland.conf'

```bash

# Tizim yoqilganda ishga tushirish
exec-once = bash ~/update_notifier.sh

# Win + U tugmasi orqali majburiy tekshirish
bind = SUPER, U, exec, pkill -SIGUSR1 -f update_notifier.sh && notify-send -t 2000 "Manual Check" "Checking now..."
```

---

## GENOME

1. **GNOME Tweaks -> Startup Applications** bo'limiga kiring.
2. 'update_notifier.sh' skriptini qo'shing.

---

## ⌨️ Boshqaruv tugmalari

Tugma / Harakat | Vazifasi
Win + U | Yangilanishlarni darhol tekshirish
Start Update | Parolni so'rab, o'rnatishni boshlash
Open Terminal | Orqa fonda ketyotgan jarayonga ulanish
Dismiss | Bildirishnomani yopish (skript ishlashda davom etadi)

## Eslatma

Skript standart ravishda 'kitty' terminalidan foydalanadi. Agar siz boshqa terminal ishlatsangiz, skript ichidagi 'kitty' so'zini o'zingizniki bilan almashtiring.

'

### Repozitoriya uchun oxirgi maslahat:

GitHub-ga yuklayotganingda, `README.md` faylidagi barcha "FOYDALANUVCHI_NOMI" yoki fayl yo'llarini (`~/update_notifier.sh`) o'zingga moslab to'g'rilab qo'yishni unutma.

Endi senda Arch Linux olamidagi eng aqlli "Update Manager" mahsuloti bor! Reponi ochganingdan keyin linkini menga tashlasang, men ham bir ko'raman. 😉🚀

'
