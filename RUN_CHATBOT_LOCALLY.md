# 🤖 Run Chatbot Locally

The chatbot is integrated into the main Flask API. You can run it locally in two ways:

## Option 1: Run with Main Flask API (Recommended)

The chatbot endpoints are already part of `api/app.py`. Just run the main Flask server:

### Step 1: Navigate to API Directory
```powershell
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
```

### Step 2: Start Flask Server
```powershell
python app.py
```

**Expected Output:**
```
✓ Chatbot module loaded successfully
✓ Chatbot model loaded from ...
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.20.2.27:5000
```

The chatbot will be available at:
- **Chat Endpoint:** `http://localhost:5000/chatbot/chat`
- **Health Check:** `http://localhost:5000/chatbot/health`

---

## Option 2: Run Standalone Chatbot (For Testing)

For interactive CLI testing:

### Step 1: Navigate to Chatbot Directory
```powershell
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api\Chatbot"
```

### Step 2: Run Standalone Chatbot
```powershell
python app.py
```

This opens an interactive chat interface in the terminal.

---

## Update Flutter App for Local Testing

### Step 1: Find Your Computer's IP Address
```powershell
ipconfig
```

Look for **IPv4 Address** (e.g., `172.20.2.27`)

### Step 2: Update Chatbot Service

Edit `lib/services/chatbot_service.dart`:

```dart
// For phone testing - use your computer's IP
static const String baseUrl = 'http://172.20.2.27:5000';

// OR for web/emulator testing - use localhost
// static const String baseUrl = 'http://localhost:5000';
```

### Step 3: Hot Reload Flutter App
Press `r` in the Flutter terminal to hot reload.

---

## Test the Chatbot

### Test 1: Health Check (Browser or PowerShell)
```powershell
curl http://localhost:5000/chatbot/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "service": "chatbot",
  "model_loaded": true,
  "message": "Chatbot is available"
}
```

### Test 2: Send a Chat Message
```powershell
curl -X POST http://localhost:5000/chatbot/chat -H "Content-Type: application/json" -d '{\"message\": \"Hello! What colors suit me?\", \"context\": \"fashion_styling\"}'
```

**Expected Response:**
```json
{
  "success": true,
  "response": "Hello! I'm your AI fashion stylist...",
  "context": "fashion_styling"
}
```

### Test 3: In Flutter App
1. Open the app on your phone/emulator
2. Navigate to **AI Stylist** screen
3. Type a message like "What colors suit me?"
4. Send - you should get a response!

---

## Chatbot Endpoints

### POST `/chatbot/chat`
Send a message to the chatbot.

**Request:**
```json
{
  "message": "What colors suit me?",
  "context": "fashion_styling"
}
```

**Response:**
```json
{
  "success": true,
  "response": "Great question about colors!...",
  "context": "fashion_styling"
}
```

### GET `/chatbot/health`
Check chatbot availability.

**Response:**
```json
{
  "status": "healthy",
  "service": "chatbot",
  "model_loaded": true,
  "message": "Chatbot is available"
}
```

---

## Notes

1. **Model Files:** The chatbot works in **fallback mode** if model files are not found (uses keyword-based responses). To use the trained model:
   - Place `.pkl` files in `api/Chatbot/Chatbot/` directory
   - Or train the model: `cd api/Chatbot && python train_intent_classifier.py`

2. **Same Network:** For phone testing, ensure your phone and computer are on the **same WiFi network**.

3. **CORS:** Already configured in Flask to allow requests from Flutter app.

4. **Dependencies:** Required packages are in `api/requirements.txt`:
   - `scikit-learn` (for ML model)
   - `pandas` (for dataset loading)
   - `joblib` (for model loading)

---

## Troubleshooting

### Chatbot Not Responding
- Check if Flask server is running
- Verify the IP address in `chatbot_service.dart`
- Test health endpoint: `http://localhost:5000/chatbot/health`

### "Chatbot service is not available"
- Check Flask server logs for errors
- Verify `chatbot_helper.py` is loading correctly
- Check if dependencies are installed: `pip install -r requirements.txt`

### Model Not Loading
- Chatbot works in fallback mode even without model files
- To use trained model, ensure `.pkl` files are in correct location
- Check `api/Chatbot/Chatbot/` directory for model files

### Connection Refused
- Make sure Flask server is running
- Use correct IP address (not `localhost` for phone)
- Check firewall settings

---

## Quick Start Commands

```powershell
# Terminal 1: Start Flask API (includes chatbot)
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
python app.py

# Terminal 2: Run Flutter app (in another terminal)
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
flutter run
```

That's it! The chatbot is ready to use! 🎉

