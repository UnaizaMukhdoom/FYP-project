# 🚀 Commands to Run the Project

## Quick Start

### Step 1: Get Dependencies (if not already done)
```bash
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter pub get
```

### Step 2: Check Connected Devices
```bash
flutter devices
```

### Step 3: Run on Your Android Phone
```bash
flutter run -d R58R30C7MXB
```

### Step 4: Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Step 5: Run on Windows Desktop
```bash
flutter run -d windows
```

---

## Full Command Sequence

### For Android Phone:
```bash
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter clean
flutter pub get
flutter run -d R58R30C7MXB
```

### For Chrome (Testing):
```bash
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter clean
flutter pub get
flutter run -d chrome
```

---

## Important Notes

✅ **Railway API is already configured** - No need to run local Flask server
✅ **Web files are embedded** - The outfit planner web interface is now part of the app
✅ **All dependencies included** - webview_flutter has been added

---

## Troubleshooting

### If build fails:
```bash
flutter clean
flutter pub get
flutter run -d R58R30C7MXB
```

### Check Flutter setup:
```bash
flutter doctor
```

### List all devices:
```bash
flutter devices
```

---

## What's New

- ✅ **Plan Your Outfit** feature now embedded in app using WebView
- ✅ Web interface loads HTML/CSS/JS from assets
- ✅ Connects to Railway API automatically
- ✅ No external browser needed - everything in-app!

---

## Quick Run (One Command)

```bash
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main" && flutter run -d R58R30C7MXB
```

