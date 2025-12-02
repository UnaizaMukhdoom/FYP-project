# 🚀 Railway Deployment Guide - Chatbot Integration

## ✅ Pre-Deployment Checklist

Before deploying, make sure you have:

- [x] ✅ Chatbot integration code added (`api/chatbot_helper.py`, updated `api/app.py`)
- [x] ✅ Dependencies updated (`api/requirements.txt`)
- [x] ✅ Flutter service created (`lib/services/chatbot_service.dart`)
- [ ] ⚠️ **Model files copied** (if you have trained models from chatbot repo)
- [ ] ⚠️ **All changes committed to Git**

## 📦 Step 1: Prepare Model Files (Optional but Recommended)

If you have trained model files from your chatbot repository:

```bash
# Copy model files to api/ directory
cp path/to/VogueAI_Chatbot/intent_classifier.pkl api/
cp path/to/VogueAI_Chatbot/vectorizer.pkl api/
```

**Note:** The chatbot will work in fallback mode even without model files, but trained models provide better responses.

## 🔧 Step 2: Verify Railway Configuration

Your `railway.toml` is already configured correctly:

```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "gunicorn app:app --bind 0.0.0.0:$PORT"
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

✅ This is correct - no changes needed!

## 📝 Step 3: Commit Your Changes

Make sure all new files are committed:

```bash
# Navigate to your project root
cd Vogue-AI-Next-_-Gen-Fashion-Stylist-main

# Check what files need to be committed
git status

# Add all new chatbot files
git add api/chatbot_helper.py
git add api/app.py
git add api/requirements.txt
git add lib/services/chatbot_service.dart
git add lib/screens/ai_stylist_screen.dart

# If you added model files (optional):
# git add api/*.pkl
# git add api/*.csv

# Commit the changes
git commit -m "Add chatbot integration for AI Stylist"

# Push to GitHub
git push origin main
```

## 🚂 Step 4: Deploy to Railway

### Option A: Auto-Deploy from GitHub (Recommended)

If your Railway project is connected to GitHub:

1. **Push to GitHub** (as shown above)
2. **Railway will automatically detect the push** and start deploying
3. **Monitor the deployment** in Railway dashboard
4. **Check logs** to ensure chatbot loads correctly

### Option B: Manual Deploy with Railway CLI

If not connected to GitHub:

```bash
# Install Railway CLI (if not installed)
npm i -g @railway/cli

# Login to Railway
railway login

# Link to your project (if not already linked)
railway link

# Deploy
railway up
```

## 🔍 Step 5: Verify Deployment

### 5.1 Check Railway Logs

In Railway dashboard:
1. Go to your project
2. Click on your service
3. Go to **"Deployments"** tab
4. Click on the latest deployment
5. Check **"Logs"** for:

✅ **Success indicators:**
```
✓ Scraper module loaded successfully
✓ Chatbot module loaded successfully
✓ Chatbot model loaded from [filename] (if model files present)
✓ Chatbot vectorizer loaded from [filename] (if model files present)
```

⚠️ **Warnings (OK if you don't have model files yet):**
```
⚠ Chatbot model files not found. Using fallback responses.
```

❌ **Errors to watch for:**
```
✗ ModuleNotFoundError: No module named 'sklearn'
✗ ImportError: cannot import name 'get_chatbot_response'
```

### 5.2 Test API Endpoints

Test the chatbot endpoints:

```bash
# Test chatbot health
curl https://amiable-encouragement-production.up.railway.app/chatbot/health

# Test chatbot chat
curl -X POST https://amiable-encouragement-production.up.railway.app/chatbot/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What colors suit me?"}'
```

**Expected responses:**

**Health check:**
```json
{
  "status": "healthy" or "fallback_mode",
  "service": "chatbot",
  "model_loaded": true or false,
  "message": "Chatbot is available"
}
```

**Chat:**
```json
{
  "success": true,
  "response": "Great question about colors! The best colors...",
  "context": "fashion_styling"
}
```

### 5.3 Test in Flutter App

1. **Run your Flutter app:**
   ```bash
   flutter run
   ```

2. **Navigate to AI Stylist:**
   - Open the app
   - Go to Home screen
   - Tap on "AI Stylist" card

3. **Test the chatbot:**
   - Type a message like "What colors suit me?"
   - Send the message
   - Wait for response

## 🐛 Troubleshooting

### Issue: "Chatbot module not available"

**Solution:**
- Check Railway logs for import errors
- Verify `chatbot_helper.py` is in `api/` directory
- Ensure all dependencies are in `requirements.txt`

### Issue: "Model files not found"

**Solution:**
- This is OK! The chatbot will use fallback responses
- To use trained models, copy `.pkl` files to `api/` directory
- Make sure model files are committed to Git (if < 100MB)

### Issue: "ModuleNotFoundError: No module named 'sklearn'"

**Solution:**
- Check `requirements.txt` has `scikit-learn==1.3.2`
- Railway should auto-install, but you can trigger a rebuild

### Issue: API returns 503 or 500 errors

**Solution:**
1. Check Railway logs for detailed error messages
2. Verify the API is running: `curl https://your-url.railway.app/health`
3. Check if chatbot endpoints are accessible
4. Review error messages in logs

### Issue: Flutter app can't connect

**Solution:**
1. Verify Railway URL in `lib/services/chatbot_service.dart`:
   ```dart
   static const String baseUrl = 'https://amiable-encouragement-production.up.railway.app';
   ```
2. Check if Railway service is running
3. Test API directly with curl (see Step 5.2)

## 📊 Monitoring

### Railway Dashboard

Monitor your deployment:
- **Metrics**: CPU, Memory usage
- **Logs**: Real-time application logs
- **Deployments**: Deployment history
- **Settings**: Environment variables, domains

### Health Checks

Set up monitoring:
```bash
# Add to your monitoring (optional)
# Check every 5 minutes
curl https://your-url.railway.app/chatbot/health
```

## 🔄 Updating the Deployment

To update after making changes:

1. **Make your changes**
2. **Commit and push:**
   ```bash
   git add .
   git commit -m "Update chatbot"
   git push
   ```
3. **Railway auto-deploys** (if connected to GitHub)
4. **Or manually deploy:**
   ```bash
   railway up
   ```

## ✅ Success Checklist

After deployment, verify:

- [ ] Railway deployment completed successfully
- [ ] `/chatbot/health` endpoint returns 200
- [ ] `/chatbot/chat` endpoint responds correctly
- [ ] Flutter app can connect to chatbot
- [ ] Chat interface works in the app
- [ ] Messages are sent and received properly

## 🎉 You're Done!

Your chatbot is now deployed and ready to use! Users can chat with the AI Stylist in your Flutter app.

**Next Steps:**
- Monitor Railway logs for any issues
- Test with real users
- Add model files later for improved responses (optional)
- Consider adding analytics to track chatbot usage

---

**Need Help?**
- Check Railway logs: Dashboard → Service → Deployments → Logs
- Test API endpoints directly with curl
- Review `api/CHATBOT_INTEGRATION.md` for integration details

