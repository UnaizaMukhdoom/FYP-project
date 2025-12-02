# Commands to Run the Code Locally

## Step 1: Run Flask API Server

### Open Terminal/PowerShell and run:

```bash
# Navigate to API directory
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"

# Install dependencies (if not already installed)
pip install -r requirements.txt

# Run the Flask server
python app.py
```

**Expected Output:**
```
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://192.168.1.4:5000
```

**Keep this terminal open!** The API server must be running for the Flutter app to work.

---

## Step 2: Test API Endpoints (Optional)

### Open a NEW terminal and test:

```bash
# Test health endpoint
curl http://localhost:5000/health

# Expected: {"status":"healthy","service":"running"}
```

---

## Step 3: Run Flutter App

### Open a NEW terminal/PowerShell and run:

```bash
# Navigate to Flutter project root
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"

# Get dependencies (if not already done)
flutter pub get

# Clean build (if needed)
flutter clean
flutter pub get

# Run on connected device/emulator
flutter run
```

**Or run on specific device:**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Chrome (for web testing)
flutter run -d chrome

# Run on Android emulator
flutter run -d android

# Run on iOS simulator (Mac only)
flutter run -d ios
```

---

## Step 4: Test the Discover Feature

1. **Open Flutter App** on your device/emulator
2. **Sign in** (or create account)
3. **Complete Skin Tone Analysis:**
   - Go to "Scan" button
   - Take/upload a selfie
   - Wait for analysis
   - View results
4. **Go to Discover Tab:**
   - Click "Discover" in bottom navigation
   - Wait for clothes to load (first time may take 30-60 seconds)
   - Browse scraped items
   - Filter by brand

---

## Troubleshooting

### API Server Not Starting?
```bash
# Check if port 5000 is in use
netstat -ano | findstr :5000

# If port is busy, kill the process or change port in app.py
```

### Flutter Build Errors?
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### API Connection Failed?
1. Check Flask server is running on `http://localhost:5000`
2. Update `lib/services/skin_analysis_service.dart`:
   - For Android Emulator: `http://10.0.2.2:5000`
   - For Physical Device: `http://YOUR_COMPUTER_IP:5000`
   - For iOS Simulator: `http://localhost:5000`
3. Check your computer's IP:
   ```bash
   ipconfig  # Windows
   # Look for IPv4 Address under your active network adapter
   ```

### Scraping Returns Empty Results?
- Some websites may block scrapers
- Check internet connection
- Try with different skin tone/colors
- Check API logs in Flask terminal for errors

---

## Quick Test Scraping Endpoint

### Using curl (PowerShell):
```bash
# Test scraping endpoint
curl -X POST http://localhost:5000/scrape-clothes -H "Content-Type: application/json" -d "{\"skin_tone\":\"Fair\",\"best_colors\":[\"Coral\",\"Turquoise\"],\"undertone\":\"Warm\",\"max_items\":5}"
```

### Using PowerShell (Invoke-WebRequest):
```powershell
$body = @{
    skin_tone = "Fair"
    best_colors = @("Coral", "Turquoise")
    undertone = "Warm"
    max_items = 5
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5000/scrape-clothes" -Method POST -Body $body -ContentType "application/json"
```

---

## Summary

**Terminal 1 (API Server):**
```bash
cd api
python app.py
```

**Terminal 2 (Flutter App):**
```bash
cd Vogue-AI-Next-_-Gen-Fashion-Stylist-main
flutter run
```

**Keep both running simultaneously!**

