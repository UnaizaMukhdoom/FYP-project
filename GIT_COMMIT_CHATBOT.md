# Git Commit Commands for Chatbot Integration

Run these commands to commit and push all chatbot files to GitHub:

## Step 1: Check Current Status
```bash
git status
```

## Step 2: Add All Chatbot Files
```bash
# Add chatbot helper
git add api/chatbot_helper.py

# Add all chatbot directory files
git add api/Chatbot/

# Add updated Flask app
git add api/app.py

# Add Flutter service and screens
git add lib/services/chatbot_service.dart
git add lib/screens/ai_stylist_screen.dart
git add lib/screens/admin/chatbot_review_screen.dart
git add lib/screens/admin/admin_dashboard_screen.dart

# Add main.dart (if it has chatbot route)
git add lib/main.dart

# Add documentation files
git add CHATBOT_SETUP.md
git add QUICK_START_CHATBOT.md

# Add updated .gitignore
git add .gitignore
```

## Step 3: Commit Changes
```bash
git commit -m "Add chatbot integration - complete setup with training scripts and Flask API endpoints

- Add chatbot_helper.py for Flask integration
- Add Chatbot directory with training scripts (train_intent_classifier.py, llama_enhanced_rag.py, advanced_training_strategy.py)
- Add chatbot endpoints to Flask API (/chatbot/chat, /chatbot/health)
- Add Flutter ChatbotService and AI Stylist screen
- Add admin chatbot review screen
- Add setup documentation and deployment guides
- Update routes and navigation
- Add dataset template and setup instructions"
```

## Step 4: Push to GitHub
```bash
git push
```

## Or Add Everything at Once
```bash
# Add all modified and new files
git add .

# Commit
git commit -m "Add complete chatbot integration for VogueAI Fashion Stylist"

# Push
git push
```

## Verify Upload
After pushing, verify on GitHub that:
- ✅ `api/chatbot_helper.py` exists
- ✅ `api/Chatbot/` directory with all Python files
- ✅ `api/app.py` has chatbot endpoints
- ✅ `lib/services/chatbot_service.dart` exists
- ✅ `lib/screens/ai_stylist_screen.dart` exists
- ✅ Documentation files are uploaded

## Important Notes

1. **Dataset CSV**: If your dataset file is large (>50MB), consider using Git LFS or Railway storage
2. **Model Files (.pkl)**: If model files are large, they might be gitignored. Check `.gitignore`
3. **Railway Auto-Deploy**: If Railway is connected to your GitHub repo, it will auto-deploy after push

## If You Get Errors

### Large File Error:
```bash
# If dataset or model files are too large, add to .gitignore
# Or use Git LFS:
git lfs track "*.pkl"
git lfs track "*.csv"
git add .gitattributes
```

### Authentication Error:
```bash
# Make sure you're logged in to GitHub
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

