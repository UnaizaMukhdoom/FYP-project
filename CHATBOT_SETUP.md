# 🤖 Chatbot Integration - Setup Complete!

All chatbot files from [Chatbot_VogueAI repository](https://github.com/UnaizaMukhdoom/Chatbot_VogueAI) have been created and integrated into your project.

## ✅ What's Been Created

### Backend Files (Flask API)
- ✅ `api/chatbot_helper.py` - Main chatbot integration helper
- ✅ `api/Chatbot/train_intent_classifier.py` - Training script
- ✅ `api/Chatbot/exact_accuracy_calculator.py` - Accuracy calculation
- ✅ `api/Chatbot/llama_enhanced_rag.py` - Enhanced RAG implementation
- ✅ `api/Chatbot/advanced_training_strategy.py` - Advanced training (ensemble, tuning)
- ✅ `api/Chatbot/app.py` - Standalone chatbot for testing
- ✅ `api/Chatbot/README.md` - Documentation
- ✅ `api/app.py` - Updated with chatbot endpoints

### Frontend Files (Flutter)
- ✅ `lib/services/chatbot_service.dart` - Flutter service for API calls
- ✅ `lib/screens/ai_stylist_screen.dart` - AI Stylist chat interface (restored)
- ✅ `lib/screens/admin/chatbot_review_screen.dart` - Admin review screen

## 📋 Next Steps

### 1. Add Your Dataset

Place your fashion dataset CSV file in `api/Chatbot/` directory:

**Required columns:**
- `Query` or `query` - User queries
- `Intent` or `intent` - Intent labels  
- `Response` or `response` - Bot responses

**Filename:** `fashion_dataset_balanced.csv` (or update paths in scripts)

### 2. Add Model Files (if you already have trained models)

If you have trained models from your chatbot repository, place them in `api/Chatbot/`:

- `intent_classifier.pkl` - Trained model
- `vectorizer.pkl` - TF-IDF vectorizer
- `fashion_embeddings_balanced.pkl` - Optional: embeddings for RAG

### 3. Train the Model (if you don't have model files)

```bash
cd api/Chatbot
python train_intent_classifier.py
```

This will generate:
- `intent_classifier.pkl`
- `vectorizer.pkl`

### 4. Test Locally

**Test the chatbot standalone:**
```bash
cd api/Chatbot
python app.py
```

**Test the Flask API:**
```bash
cd api
python app.py
```

Then test the endpoint:
```bash
curl -X POST http://localhost:5000/chatbot/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What colors suit me?", "context": "fashion_styling"}'
```

### 5. Deploy to Railway

1. **Add model files to git** (if not too large):
   ```bash
   git add api/Chatbot/*.pkl
   git commit -m "Add chatbot model files"
   git push
   ```

2. **Or use Railway storage** for model files if they're large

3. **Ensure all dependencies are in requirements.txt** (already done ✅)

4. **Deploy:**
   - Railway will auto-deploy on push
   - Check logs to ensure model loads correctly

### 6. Update Flutter App

The Flutter app is already configured! Just update the Railway URL in `chatbot_service.dart` if needed:

```dart
static const String baseUrl = 'https://your-railway-url.railway.app';
```

## 📁 File Structure

```
api/
├── chatbot_helper.py              # Main integration helper
├── app.py                         # Flask API (with chatbot endpoints)
├── Chatbot/
│   ├── train_intent_classifier.py      # Training script
│   ├── exact_accuracy_calculator.py    # Accuracy metrics
│   ├── llama_enhanced_rag.py           # RAG implementation
│   ├── advanced_training_strategy.py   # Advanced training
│   ├── app.py                          # Standalone chatbot
│   ├── README.md                       # Documentation
│   ├── fashion_dataset_balanced.csv    # YOUR DATASET (add this)
│   ├── intent_classifier.pkl           # Trained model (generated)
│   └── vectorizer.pkl                  # Vectorizer (generated)

lib/
├── services/
│   └── chatbot_service.dart       # Flutter service
└── screens/
    ├── ai_stylist_screen.dart     # Chat interface
    └── admin/
        └── chatbot_review_screen.dart  # Admin review
```

## 🔌 API Endpoints

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
  "response": "Colors that complement your skin tone...",
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

## 🎯 User Flow

1. User opens app → Home Screen
2. Taps **"AI Stylist"** card
3. Opens `AIStylistScreen` (chatbot interface)
4. Sends message → `ChatbotService` → Flask API → `chatbot_helper.py`
5. Gets response → Displays in chat

## 📊 Training Options

### Basic Training
```bash
python train_intent_classifier.py
```

### Advanced: Ensemble Model
```bash
python advanced_training_strategy.py
# Choose option 1
```

### Advanced: Hyperparameter Tuning
```bash
python advanced_training_strategy.py
# Choose option 2
```

## ⚠️ Important Notes

1. **Fallback Mode**: The chatbot works even without trained models (uses keyword-based responses)

2. **Model Files**: 
   - Add `.pkl` files to `.gitignore` if they're large
   - Use Railway storage for large files
   - Or commit them if < 50MB

3. **Railway Deployment**:
   - Ensure model files are accessible
   - Check logs: `railway logs`
   - Verify model loads: Test `/chatbot/health` endpoint

4. **Dependencies**: Already in `requirements.txt` ✅

## 🐛 Troubleshooting

### Model Not Loading
- Check file paths in `chatbot_helper.py`
- Ensure `.pkl` files are in `api/Chatbot/` directory
- Check Railway logs for errors

### API Errors
- Verify Railway URL in `chatbot_service.dart`
- Test `/chatbot/health` endpoint
- Check CORS settings in Flask

### Training Errors
- Ensure dataset CSV has correct columns
- Check file paths in training scripts
- Verify dependencies: `pip install -r requirements.txt`

## ✅ Checklist

- [x] Chatbot files created
- [x] Flask API integrated
- [x] Flutter service created
- [x] UI screens restored
- [x] Routes configured
- [ ] Add your dataset CSV
- [ ] Train model (or add existing model files)
- [ ] Test locally
- [ ] Deploy to Railway
- [ ] Test in Flutter app

## 🎉 You're Ready!

Everything is set up! Just add your dataset and model files, then deploy to Railway. The chatbot will be available in your Flutter app through the "AI Stylist" feature.

For questions, check `api/Chatbot/README.md` for detailed documentation.

