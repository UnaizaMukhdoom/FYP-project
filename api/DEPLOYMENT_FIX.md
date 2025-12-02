# 🔧 Railway Deployment Fix

## Issue
Deployment failed with `metadata-generation-failed` error during `pip install -r requirements.txt`.

## Solution Applied

### 1. Updated `requirements.txt`
- Added explicit `scipy==1.11.4` (required by scikit-learn)
- Added build tools: `setuptools>=65.0.0` and `wheel>=0.38.0`
- Made chatbot imports resilient (will work even if packages fail to install)

### 2. Made Chatbot Dependencies Optional
- Updated `chatbot_helper.py` to gracefully handle missing scikit-learn
- Chatbot will use fallback mode if packages can't be installed
- App will still work without chatbot ML dependencies

### 3. Added `runtime.txt`
- Specified Python 3.11.9 for consistent builds

## Next Steps

1. **Commit the fixes:**
   ```bash
   git add api/requirements.txt api/chatbot_helper.py api/runtime.txt
   git commit -m "Fix Railway deployment - add build tools and make chatbot optional"
   git push
   ```

2. **Railway will auto-redeploy**

3. **If it still fails**, try this alternative approach:
   - Remove scikit-learn temporarily
   - Use only fallback mode
   - Add ML dependencies later via Railway's package installation

## Alternative: Minimal Requirements (if still failing)

If the build still fails, you can temporarily use this minimal `requirements.txt`:

```txt
Flask==3.0.3
flask-cors==4.0.1
opencv-python-headless==4.10.0.84
numpy==1.26.4
Pillow==10.4.0
gunicorn==21.2.0
beautifulsoup4==4.12.2
requests==2.31.0
```

The chatbot will work in fallback mode without scikit-learn.

