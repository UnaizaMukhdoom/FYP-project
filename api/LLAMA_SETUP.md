# 🤖 LLaMA API Setup Guide

## Why is LLaMA Disabled?

The LLaMA status shows **🔴 Disabled (Fallback Mode)** because the Groq API key is not configured. The chatbot will still work using the high-accuracy RAG system (90.99% accuracy), but without LLaMA enhancement for more natural, conversational responses.

## How to Enable LLaMA

### Step 1: Get a Free Groq API Key

1. Go to [https://console.groq.com/](https://console.groq.com/)
2. Sign up for a free account (no credit card required)
3. Navigate to **API Keys** section
4. Click **Create API Key**
5. Copy your API key (starts with `gsk_...`)

### Step 2: Create `.env` File

1. In the `api/` folder, create a file named `.env` (not `.env.example`)
2. Add your API key:

```env
LLAMA_API_KEY=gsk_your_actual_api_key_here
```

**OR** you can use:

```env
GROQ_API_KEY=gsk_your_actual_api_key_here
```

### Step 3: Restart Flask Server

After adding the `.env` file, restart your Flask server:

```powershell
cd "C:\Users\AR\Downloads\New folder (2)\Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
.\.venv\Scripts\Activate.ps1
python app.py
```

### Step 4: Verify LLaMA is Enabled

After restarting, you should see:

```
✅ LLaMA API connected successfully!
🤖 LLaMA Status: 🟢 Enabled
```

Instead of:

```
🤖 LLaMA Status: 🔴 Disabled (Fallback Mode)
```

## What Does LLaMA Do?

- **Without LLaMA**: Uses high-accuracy RAG system (90.99% accuracy) with rule-based responses
- **With LLaMA**: Enhanced natural language generation for more conversational, context-aware responses

## Troubleshooting

### Still Shows "Disabled" After Adding API Key?

1. **Check `.env` file location**: Must be in the `api/` folder
2. **Check file name**: Must be exactly `.env` (not `.env.txt` or `.env.example`)
3. **Check API key format**: Should start with `gsk_`
4. **Restart server**: Changes only take effect after restarting

### API Key Invalid?

- Make sure you copied the entire key (it's long)
- Check for extra spaces or newlines
- Verify the key is active in your Groq console

### Don't Want to Use LLaMA?

That's fine! The chatbot works perfectly without it using the high-accuracy RAG system. LLaMA is optional and only enhances the conversational quality.

