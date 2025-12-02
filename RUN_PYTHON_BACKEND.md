# Commands to Run Python Backend for Local Testing

## Quick Commands

### Option 1: Simple (From Project Root)
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
python app.py
```

### Option 2: Full Path (From Anywhere)
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
python app.py
```

### Option 3: One-Line Command
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api" && python app.py
```

## Step-by-Step Instructions

### Step 1: Open Command Prompt or PowerShell
Press `Win + R`, type `cmd` or `powershell`, and press Enter.

### Step 2: Navigate to API Folder
```cmd
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
```

### Step 3: Run the Flask Server
```cmd
python app.py
```

## Expected Output

You should see:
```
✓ Scraper module loaded successfully
✓ Chatbot module loaded successfully
✓ Chatbot responses loaded from...
⚠ Chatbot model files not found. Using fallback responses.
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.20.2.27:5000
Press CTRL+C to quit
```

## Test the Backend

Open a NEW terminal and test:

```powershell
# Test health endpoint
Invoke-WebRequest -Uri "http://localhost:5000/health" -Method GET -UseBasicParsing

# Test wardrobe endpoint
Invoke-WebRequest -Uri "http://localhost:5000/api/wardrobe" -Method GET -UseBasicParsing
```

## Stop the Server

Press `Ctrl + C` in the terminal where the server is running.

## Troubleshooting

### Python Not Found?
```cmd
python --version
# If not found, try:
py app.py
# or
python3 app.py
```

### Missing Dependencies?
```cmd
cd api
pip install -r requirements.txt
```

### Port Already in Use?
```cmd
# Find process using port 5000
netstat -ano | findstr :5000

# Kill the process (replace PID with actual number)
taskkill /PID <PID> /F
```

### Install Dependencies (First Time)
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
pip install -r requirements.txt
python app.py
```

