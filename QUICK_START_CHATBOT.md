# 🚀 Quick Start: Chatbot Setup & Deployment

## Current Status ✅

All chatbot files have been created and integrated! Here's what's ready:

- ✅ Chatbot Python files created
- ✅ Flask API endpoints integrated
- ✅ Flutter UI screens ready
- ✅ Routes configured
- ✅ Dependencies in requirements.txt

## What You Need to Do Next

### 1️⃣ Get Your Dataset (Required for Training)

**Download from your repository:**
```
https://github.com/UnaizaMukhdoom/Chatbot_VogueAI
```

**Steps:**
1. Go to the repository above
2. Navigate to `Chatbot` folder
3. Download `fashion_dataset_balanced.csv`
4. Place it in: `Vogue-AI-Next-_-Gen-Fashion-Stylist-main/api/Chatbot/`

**OR clone and copy:**
```bash
cd ..
git clone https://github.com/UnaizaMukhdoom/Chatbot_VogueAI.git
cp Chatbot_VogueAI/Chatbot/fashion_dataset_balanced.csv api/Chatbot/
```

### 2️⃣ Get Model Files (If You Have Them)

If you already have trained models, download these files:
- `intent_classifier.pkl`
- `vectorizer.pkl`
- `fashion_embeddings_balanced.pkl` (optional)

Place them in: `api/Chatbot/`

### 3️⃣ Train Model (If You Don't Have Model Files)

```bash
cd api/Chatbot
python train_intent_classifier.py
```

This will create the `.pkl` model files.

### 4️⃣ Test Locally

**Test chatbot:**
```bash
cd api/Chatbot
python app.py
```

**Test Flask API:**
```bash
cd api
python app.py
```

**Test endpoint:**
```bash
curl -X POST http://localhost:5000/chatbot/chat -H "Content-Type: application/json" -d "{\"message\": \"Hello\"}"
```

### 5️⃣ Deploy to Railway

```bash
# Add and commit files
git add api/Chatbot/
git add api/chatbot_helper.py
git commit -m "Add chatbot integration"
git push
```

Railway will auto-deploy! Check logs to verify model loads.

### 6️⃣ Test in Flutter App

1. Open your Flutter app
2. Go to Home Screen
3. Tap **"AI Stylist"** card
4. Start chatting! 💬

## File Checklist

Make sure these files exist:

### Required Files:
- [x] `api/chatbot_helper.py`
- [x] `api/app.py` (with chatbot endpoints)
- [x] `api/Chatbot/train_intent_classifier.py`
- [x] `lib/services/chatbot_service.dart`
- [x] `lib/screens/ai_stylist_screen.dart`

### Files You Need to Add:
- [ ] `api/Chatbot/fashion_dataset_balanced.csv` (download from repo)
- [ ] `api/Chatbot/intent_classifier.pkl` (train or download)
- [ ] `api/Chatbot/vectorizer.pkl` (train or download)

## Important Notes

1. **Fallback Mode**: Chatbot works even without models (uses keyword responses)
2. **Model Files**: If > 50MB, use Railway storage instead of git
3. **Railway URL**: Update in `chatbot_service.dart` if your URL changed

## Troubleshooting

**No dataset?**
- Download from your GitHub repo
- Or use `DATASET_TEMPLATE.csv` as starting point

**Model not loading?**
- Check files are in `api/Chatbot/` directory
- Verify file names match exactly
- Check Railway logs

**API errors?**
- Test locally first
- Check Railway URL is correct
- Verify all dependencies installed

## Helpful Files Created

- `api/Chatbot/SETUP_INSTRUCTIONS.md` - Detailed setup guide
- `api/Chatbot/DEPLOYMENT_CHECKLIST.md` - Deployment checklist
- `api/Chatbot/setup_chatbot.py` - Setup verification script
- `CHATBOT_SETUP.md` - Full integration documentation

## Next Steps Summary

1. ✅ **Download dataset** from your repo → `api/Chatbot/`
2. ✅ **Get/train model files** → `api/Chatbot/`
3. ✅ **Test locally** → Verify everything works
4. ✅ **Deploy to Railway** → `git push`
5. ✅ **Test in app** → Home → AI Stylist → Chat!

---

**Ready to deploy?** Follow `api/Chatbot/DEPLOYMENT_CHECKLIST.md` for step-by-step instructions!

