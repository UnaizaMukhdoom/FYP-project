# Commands to Run Python Backend

## Quick Start

### Option 1: Simple Command
```powershell
cd api
python app.py
```

### Option 2: One Line (from project root)
```powershell
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"; python app.py
```

### Option 3: With Full Path
```powershell
cd "C:\Users\AR\Downloads\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
python app.py
```

## Verify Backend is Running

### Test Health Endpoint
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/health" -Method GET -UseBasicParsing
```

### Test Wardrobe Endpoint
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/wardrobe" -Method GET -UseBasicParsing
```

### View All Available Endpoints
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/" -Method GET -UseBasicParsing | Select-Object -ExpandProperty Content
```

## Backend URLs

- **Base URL:** `http://localhost:5000`
- **Health Check:** `http://localhost:5000/health`
- **Wardrobe API:** `http://localhost:5000/api/wardrobe`
- **Wardrobe Stats:** `http://localhost:5000/api/wardrobe-stats`

## Stop the Server

Press `Ctrl + C` in the terminal where the server is running.

## Troubleshooting

### If port 5000 is already in use:
1. Find the process using port 5000:
   ```powershell
   netstat -ano | findstr :5000
   ```
2. Kill the process (replace PID with the actual process ID):
   ```powershell
   taskkill /PID <PID> /F
   ```

### Install Dependencies (if needed):
```powershell
cd api
pip install -r requirements.txt
```

