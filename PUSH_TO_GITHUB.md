# Push Chatbot to GitHub - Quick Commands

Run these commands from the project root:

## Option 1: Use the Script (Easiest)

```bash
push_chatbot_to_github.bat
```

## Option 2: Manual Commands

```bash
# Navigate to project root
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"

# Add all chatbot files
git add api/chatbot_helper.py
git add api/app.py
git add api/Chatbot/
git add lib/services/chatbot_service.dart
git add lib/screens/ai_stylist_screen.dart
git add lib/screens/admin/chatbot_review_screen.dart
git add lib/screens/admin/admin_dashboard_screen.dart
git add lib/main.dart
git add CHATBOT_SETUP.md
git add QUICK_START_CHATBOT.md
git add .gitignore

# Commit
git commit -m "Add complete chatbot integration with trained model (78.98% accuracy)"

# Push
git push
```

## Option 3: Add Everything

```bash
git add .
git commit -m "Add complete chatbot integration with trained model"
git push
```

## What Will Be Pushed:

✅ `api/chatbot_helper.py` - Flask integration  
✅ `api/app.py` - Updated with chatbot endpoints  
✅ `api/Chatbot/` - All training scripts and model files  
   - `intent_classifier.pkl` - Trained model  
   - `vectorizer.pkl` - TF-IDF vectorizer  
   - `fashion_dataset_balanced.csv` - Dataset  
   - All Python training scripts  
✅ `lib/services/chatbot_service.dart` - Flutter service  
✅ `lib/screens/ai_stylist_screen.dart` - Chat UI  
✅ All documentation files  

## After Pushing:

1. ✅ Check GitHub to verify files uploaded
2. ✅ Railway will auto-deploy if connected
3. ✅ Test the chatbot in your Flutter app!

