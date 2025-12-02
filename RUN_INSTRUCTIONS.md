# 🚀 How to Run Flutter App + Admin Panel Together

## 🎯 Quick Start (Easiest Method)

### Option 1: Use the Batch Script (Windows)
```bash
# Double-click or run:
RUN_BOTH.bat
```

### Option 2: Use PowerShell Script
```powershell
.\RUN_BOTH.ps1
```

---

## 📋 Manual Method (Step by Step)

### Terminal 1: Flutter App

```powershell
# Navigate to project directory
cd "C:\Users\AR\Downloads\New folder (2)\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"

# Get dependencies
flutter pub get

# Run Flutter app
flutter run
```

**Or run on specific device:**
```powershell
# Check available devices
flutter devices

# Run on specific device
flutter run -d chrome        # Web
flutter run -d windows        # Windows desktop
flutter run -d <device-id>    # Android/iOS device
```

---

### Terminal 2: Admin Panel

```powershell
# Navigate to admin panel directory
cd "C:\Users\AR\Downloads\New folder (2)\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\admin-panel"

# Install dependencies (first time only)
npm install

# Start admin panel
npm start
```

**Admin Panel will open at:** `http://localhost:3000`

---

## 🔧 Prerequisites

### For Flutter App:
- ✅ Flutter SDK installed
- ✅ Dart SDK installed
- ✅ Android Studio / Xcode (for mobile)
- ✅ Chrome (for web)
- ✅ VS Code / Android Studio (for development)

### For Admin Panel:
- ✅ Node.js installed (v14 or higher)
- ✅ npm installed

---

## 📱 What You'll See

### Flutter App:
- Mobile app running on device/emulator
- OR web app at `http://localhost:<port>`
- OR desktop app window

### Admin Panel:
- Web browser opens automatically
- URL: `http://localhost:3000`
- Login with admin credentials

---

## 🐛 Troubleshooting

### Flutter App Won't Start:
```bash
# Check Flutter installation
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Admin Panel Won't Start:
```bash
# Check Node.js
node --version

# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules
npm install
npm start
```

### Port Already in Use:
```bash
# Admin Panel (change port)
# Edit package.json or use:
PORT=3001 npm start

# Flutter (change port)
flutter run --web-port=8080
```

---

## ✅ Verification

### Check Flutter App:
- App should launch on device/emulator
- No errors in terminal

### Check Admin Panel:
- Browser opens at `http://localhost:3000`
- Dashboard loads (even if stats are 0)
- No errors in browser console (F12)

---

## 🎯 Next Steps After Running

1. **Test User Sync:**
   - Sign up/sign in a user in Flutter app
   - Check Admin Panel → Users page
   - User should appear

2. **Test Data Creation:**
   - Complete color analysis in Flutter app
   - Add item to closet
   - Check Admin Panel → Dashboard
   - Stats should update

3. **Check Console Logs:**
   - Admin Panel: Browser console (F12)
   - Flutter App: Terminal output

---

## 📝 Notes

- **First Time:** `npm install` may take a few minutes
- **Hot Reload:** Flutter app supports hot reload (press `r` in terminal)
- **Auto-Refresh:** Admin panel auto-refreshes on code changes
- **Keep Running:** Both apps need to stay running to work

---

**Ready to run?** Use `RUN_BOTH.bat` for the easiest method! 🚀

