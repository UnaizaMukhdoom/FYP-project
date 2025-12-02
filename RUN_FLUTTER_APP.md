# Commands to Run Flutter App

## Quick Commands

### Option 1: Run on Available Device (Auto-select)
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter pub get
flutter run
```

### Option 2: Run on Android Phone
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter run -d R58R30C7MXB
```

### Option 3: Run on Chrome (for testing)
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter run -d chrome
```

### Option 4: Check Available Devices First
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter devices
flutter run -d <device-id>
```

## Full Path Commands (From Anywhere)

### From C:\Users\AR>
```cmd
cd "Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter pub get
flutter run
```

## One-Line Command (From Current Location)

```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main" && flutter pub get && flutter run
```

## Important Notes

1. **Keep Python Backend Running** - The Flask server must be running in a separate terminal
2. **Backend URL** - The Flutter app is configured to use: `http://localhost:5000` (or your Railway URL)
3. **First Run** - May take a few minutes to build
4. **Hot Reload** - Press `r` in terminal for hot reload, `R` for hot restart

