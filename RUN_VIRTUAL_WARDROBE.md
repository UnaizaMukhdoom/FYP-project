# Commands to Run Virtual Wardrobe Feature

## Step 1: Run Python Backend (Terminal 1)

### Open first terminal and run:
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
python app.py
```

**Keep this terminal open!** The backend must keep running.

**Expected output:**
```
✓ Scraper module loaded successfully
✓ Chatbot module loaded successfully
 * Running on http://127.0.0.1:5000
 * Running on http://172.20.2.27:5000
Press CTRL+C to quit
```

---

## Step 2: Run Flutter App (Terminal 2)

### Open a NEW terminal and run:
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter run
```

**Or run on specific device:**
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter devices
flutter run -d <device-id>
```

**For Android Phone:**
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter run -d R58R30C7MXB
```

---

## Step 3: Test Virtual Wardrobe

1. **Open the Flutter app** on your device
2. **Navigate to "Plan Your Outfit"** feature
3. **Add items to wardrobe:**
   - Click "Add Item" button
   - Upload an image
   - Fill in details (Category, Color, etc.)
   - Click "Add to Wardrobe"
4. **Generate outfits:**
   - Click "Generate Outfit Ideas"
   - Or click "Get Quick Outfit"

---

## Quick Commands Summary

### Terminal 1 (Backend):
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
python app.py
```

### Terminal 2 (Flutter App):
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter run
```

---

## Important Notes

✅ **Both terminals must be running simultaneously**

✅ **Make sure:**
- Python backend is running on `http://172.20.2.27:5000`
- Your phone and computer are on the SAME WiFi network
- Flutter app is configured to use `http://172.20.2.27:5000` (already fixed)

✅ **To stop:**
- Press `Ctrl + C` in each terminal

---

## Troubleshooting

### Connection Error?
- Check both devices are on same WiFi
- Verify backend is running (test: `Invoke-WebRequest -Uri "http://172.20.2.27:5000/health"`)
- Make sure firewall isn't blocking port 5000

### Flutter Build Error?
```cmd
flutter clean
flutter pub get
flutter run
```

