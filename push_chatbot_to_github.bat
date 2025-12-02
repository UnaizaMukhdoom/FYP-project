@echo off
echo ============================================
echo Pushing Chatbot Integration to GitHub
echo ============================================
echo.

echo Step 1: Adding all chatbot files...
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
git add GIT_COMMIT_CHATBOT.md
git add .gitignore

echo.
echo Step 2: Checking status...
git status

echo.
echo Step 3: Committing changes...
git commit -m "Add complete chatbot integration with trained model

- Add chatbot_helper.py for Flask API integration
- Add trained model (78.98%% accuracy) with intent_classifier.pkl and vectorizer.pkl
- Add Chatbot directory with training scripts and utilities
- Add chatbot endpoints (/chatbot/chat, /chatbot/health) to Flask API
- Add Flutter ChatbotService for API communication
- Add AI Stylist screen with chat interface
- Add admin chatbot review screen
- Add comprehensive documentation and setup guides
- Include fashion_dataset_balanced.csv (2163 samples, 52 intents)"

echo.
echo Step 4: Pushing to GitHub...
git push

echo.
echo ============================================
echo Done! Check GitHub to verify upload.
echo ============================================
pause

