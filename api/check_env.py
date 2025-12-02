#!/usr/bin/env python3
"""
Quick script to check if .env file exists and API key is loaded correctly
"""

import os
from dotenv import load_dotenv

# Get the directory where this file is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ENV_FILE = os.path.join(BASE_DIR, '.env')

print("=" * 60)
print("🔍 Checking .env file and API key configuration")
print("=" * 60)

# Check if .env file exists
if os.path.exists(ENV_FILE):
    print(f"✅ .env file found at: {ENV_FILE}")
    
    # Try to load it
    load_dotenv(ENV_FILE)
    
    # Check for API keys
    llama_key = os.getenv('LLAMA_API_KEY')
    groq_key = os.getenv('GROQ_API_KEY')
    
    if llama_key:
        print(f"✅ LLAMA_API_KEY found: {llama_key[:10]}...{llama_key[-5:]}")
        print(f"   Length: {len(llama_key)} characters")
    elif groq_key:
        print(f"✅ GROQ_API_KEY found: {groq_key[:10]}...{groq_key[-5:]}")
        print(f"   Length: {len(groq_key)} characters")
    else:
        print("❌ No API key found in .env file")
        print("\n💡 Your .env file should contain:")
        print("   LLAMA_API_KEY=gsk_your_actual_api_key_here")
        print("\n   OR")
        print("   GROQ_API_KEY=gsk_your_actual_api_key_here")
        
        # Show first few lines of .env file (without revealing the key)
        try:
            with open(ENV_FILE, 'r') as f:
                lines = f.readlines()
                print(f"\n📄 First few lines of .env file:")
                for i, line in enumerate(lines[:5], 1):
                    if 'API_KEY' in line or 'KEY' in line:
                        # Mask the key
                        parts = line.split('=')
                        if len(parts) == 2:
                            print(f"   Line {i}: {parts[0]}=***hidden***")
                        else:
                            print(f"   Line {i}: {line.strip()}")
                    else:
                        print(f"   Line {i}: {line.strip()}")
        except Exception as e:
            print(f"   Could not read .env file: {e}")
else:
    print(f"❌ .env file NOT found at: {ENV_FILE}")
    print(f"\n📁 Current directory: {os.getcwd()}")
    print(f"📁 Script directory: {BASE_DIR}")
    print("\n💡 To create .env file:")
    print("   1. Create a file named '.env' (with the dot) in the api/ folder")
    print("   2. Add this line:")
    print("      LLAMA_API_KEY=gsk_your_actual_api_key_here")
    print("   3. Save the file")
    print("   4. Restart your Flask server")

print("\n" + "=" * 60)

