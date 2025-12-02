# 🚀 Deployment Guide - Skin Tone Analysis API

## Quick Deploy to Render (FREE - Recommended)

### Step 1: Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up with GitHub (easiest)

### Step 2: Push Code to GitHub
```bash
# In your project root
git init
git add api/
git commit -m "Add skin analysis API"
git remote add origin YOUR_GITHUB_REPO_URL
git push -u origin main
```

### Step 3: Deploy on Render
1. Go to Render Dashboard
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repo
4. Configure:
   - **Name:** `fyp-skin-analysis`
   - **Root Directory:** `api`
   - **Environment:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `gunicorn app:app`
   - **Instance Type:** `Free`
5. Click **"Create Web Service"**

### Step 4: Get Your API URL
After deployment (5-10 minutes), you'll get a URL like:
```
https://fyp-skin-analysis.onrender.com
```

### Step 5: Update Flutter App
In `lib/services/skin_analysis_service.dart`, change:
```dart
static const String baseUrl = 'https://fyp-skin-analysis.onrender.com';
```

---

## Alternative: Local Testing First

### Step 1: Install Python Dependencies
```bash
cd api
pip install -r requirements.txt
```

### Step 2: Run API Locally
```bash
python app.py
```

API runs at `http://localhost:5000`

### Step 3: Connect Flutter to Local API

**Important:** Use your computer's IP address (not localhost)!

1. Find your IP:
   ```cmd
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., `192.168.1.100`)

2. Update `lib/services/skin_analysis_service.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:5000';
   ```

3. Make sure your phone and computer are on the **same WiFi network**

### Step 4: Test
```bash
# Run Flutter app
flutter run -d R58R30C7MXB

# Keep Python API running in another terminal
cd api
python app.py
```

---

## Alternative: Deploy to Google Cloud Run

### Prerequisites
- Google Cloud account
- gcloud CLI installed

### Steps
```bash
cd api

# Build and deploy
gcloud run deploy fyp-skin-analysis \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

You'll get a URL like: `https://fyp-skin-analysis-xxxxx.run.app`

---

## Testing the API

### Using curl
```bash
curl -X POST -F "image=@test_photo.jpg" http://localhost:5000/analyze
```

### Using Python
```python
import requests

url = "http://localhost:5000/analyze"
files = {'image': open('test_photo.jpg', 'rb')}
response = requests.post(url, files=files)
print(response.json())
```

---

## Troubleshooting

### "ModuleNotFoundError: No module named 'cv2'"
```bash
pip install opencv-python-headless
```

### "Port 5000 already in use"
Change port in `app.py`:
```python
app.run(host='0.0.0.0', port=8080, debug=True)
```

### API returns "No face detected"
- Use clear, well-lit selfie
- Make sure face is fully visible
- Try different image

---

## Next Steps After Deployment

1. ✅ Get your deployed API URL
2. ✅ Update `skin_analysis_service.dart` with the URL
3. ✅ Rebuild Flutter app: `flutter run`
4. ✅ Test the full flow: Selfie → Analysis → Results


