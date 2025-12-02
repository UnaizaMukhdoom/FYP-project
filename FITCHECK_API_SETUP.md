# FitCheck API Setup Guide

## Problem
You're getting a **404 error** when uploading a photo in FitCheck because the `/analyze-outfit` endpoint is not available on the deployed Railway server.

## Solution: Run API Locally

### Step 1: Start the Flask API Server

Open a terminal/PowerShell and run:

```bash
# Navigate to the API folder
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"

# Install dependencies (if not already done)
pip install -r requirements.txt

# Run the Flask server
python app.py
```

**Expected Output:**
```
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://127.0.0.1:5000
```

**Keep this terminal open!** The API must be running.

---

### Step 2: Update Flutter App to Use Local API

1. **Find your computer's IP address:**
   ```bash
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., `192.168.1.100`)

2. **Update the API URL in Flutter:**

   Open: `lib/services/fitcheck_analysis_service.dart`

   **For Android Emulator:**
   ```dart
   static const String baseUrl = 'http://10.0.2.2:5000';
   ```

   **For Physical Device (same WiFi):**
   ```dart
   static const String baseUrl = 'http://192.168.1.100:5000'; // Replace with YOUR IP
   ```

   **For iOS Simulator:**
   ```dart
   static const String baseUrl = 'http://localhost:5000';
   ```

3. **Save the file and hot reload the app**

---

### Step 3: Test FitCheck

1. Open the app
2. Go to FitCheck
3. Upload a photo
4. The analysis should now work!

---

## Alternative: Deploy Updated API to Railway

If you want to use the production API instead of local:

1. **Push the updated `api/app.py` to your repository**
2. **Redeploy on Railway** (it should auto-deploy if connected to GitHub)
3. **Wait for deployment to complete** (5-10 minutes)
4. **The production URL will work automatically**

---

## Troubleshooting

### "Cannot connect to API"
- Make sure Flask server is running (`python app.py`)
- Check the IP address is correct
- Ensure phone and computer are on the same WiFi network
- For emulator, use `10.0.2.2:5000`

### "404 Not Found"
- The endpoint `/analyze-outfit` doesn't exist on the server
- Run API locally OR deploy updated code to Railway

### "Connection refused"
- Flask server might not be running
- Check if port 5000 is available: `netstat -ano | findstr :5000`

---

## Quick Test

Test if the API is working:

```bash
# In a new terminal
curl http://localhost:5000/health
```

Should return: `{"status":"healthy","service":"running"}`

