# VOGUE AI Admin Panel

React-based admin panel for managing the VOGUE AI Fashion Stylist application.

## Features

- 🔐 Firebase Authentication
- 👥 User Management
- 📊 Analytics Dashboard
- 👔 Clothing Management
- 💎 Jewelry Management
- 📝 Questionnaire Management
- 🤖 Chatbot Review
- 🎨 Color Recommendations
- 📤 Data Export
- ⚙️ Scraper Configuration

## Setup

### 1. Install Dependencies

```bash
cd admin-panel
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the `admin-panel` directory:

```env
REACT_APP_API_URL=http://localhost:5000
```

For production, update this to your deployed API URL.

### 3. Update Admin Emails

Edit `src/contexts/AuthContext.js` and add your admin email addresses to the `ADMIN_EMAILS` array:

```javascript
const ADMIN_EMAILS = [
  'admin@vogueai.com',
  'your-email@example.com',
];
```

### 4. Run the Application

```bash
npm start
```

The admin panel will open at `http://localhost:3000`

## Firebase Configuration

The admin panel uses the same Firebase project as the Flutter app. The configuration is already set in `src/config/firebase.js`.

## Project Structure

```
admin-panel/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── Layout.js
│   │   └── Layout.css
│   ├── contexts/
│   │   └── AuthContext.js
│   ├── config/
│   │   ├── firebase.js
│   │   └── api.js
│   ├── pages/
│   │   ├── Login.js
│   │   ├── Dashboard.js
│   │   ├── Users.js
│   │   ├── Analytics.js
│   │   ├── ClothingManagement.js
│   │   ├── JewelryManagement.js
│   │   ├── QuestionnaireManagement.js
│   │   ├── ChatbotReview.js
│   │   ├── ColorRecommendations.js
│   │   ├── Export.js
│   │   └── ScraperConfig.js
│   ├── App.js
│   ├── App.css
│   ├── index.js
│   └── index.css
├── package.json
└── README.md
```

## Building for Production

```bash
npm run build
```

This creates an optimized production build in the `build` folder.

## Deployment

You can deploy the admin panel to:
- **Vercel**: `vercel deploy`
- **Netlify**: `netlify deploy`
- **Firebase Hosting**: `firebase deploy`
- Any static hosting service

## Notes

- The admin panel requires Firebase Authentication
- Only emails in the `ADMIN_EMAILS` array can access the panel
- Make sure your Flask API is running and accessible
- Update the API URL in `src/config/api.js` for production

