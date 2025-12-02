"""
api/chatbot_helper.py
Chatbot integration helper for VogueAI.

This module uses the LLaMA-enhanced Fashion RAG system from llama_enhanced_rag.py
in the api folder.
"""

import os
import sys
import re
from dotenv import load_dotenv

# Load environment variables from .env file
# Get the directory where this file is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ENV_FILE = os.path.join(BASE_DIR, '.env')
CHATBOT_ENV_FILE = os.path.join(BASE_DIR, 'Chatbot', '.env')

# Try to load .env file from multiple possible locations
env_loaded = False

# First try: api/.env (preferred location)
if os.path.exists(ENV_FILE):
    print(f"📄 Found .env file at: {ENV_FILE}")
    load_dotenv(ENV_FILE)
    env_loaded = True
# Second try: api/Chatbot/.env (fallback)
elif os.path.exists(CHATBOT_ENV_FILE):
    print(f"📄 Found .env file at: {CHATBOT_ENV_FILE}")
    print(f"⚠️  Note: .env file should be in api/ folder, not api/Chatbot/ folder")
    load_dotenv(CHATBOT_ENV_FILE)
    env_loaded = True
else:
    print(f"⚠️  .env file not found at: {ENV_FILE}")
    print(f"   Also checked: {CHATBOT_ENV_FILE}")
    print(f"   Current directory: {os.getcwd()}")
    # Try loading from current directory as fallback
    load_dotenv()

# --------------------------------------------------------------------------
# Import LLaMA-enhanced RAG chatbot from api folder
# --------------------------------------------------------------------------

_rag_system = None

try:
    from llama_enhanced_rag import LlamaEnhancedFashionRAG
    
    print("🚀 Initializing LLaMA-Enhanced Fashion RAG System from api folder...")
    # Get LLaMA API key from environment variable
    llama_api_key = os.getenv('LLAMA_API_KEY') or os.getenv('GROQ_API_KEY')
    
    # Debug: Check all environment variables
    print(f"🔍 Debug - Checking environment variables:")
    print(f"   LLAMA_API_KEY exists: {os.getenv('LLAMA_API_KEY') is not None}")
    print(f"   GROQ_API_KEY exists: {os.getenv('GROQ_API_KEY') is not None}")
    
    if llama_api_key:
        print(f"✅ Found LLaMA API key: {llama_api_key[:10]}...")
        print(f"   Key length: {len(llama_api_key)} characters")
    else:
        print("⚠️  No LLaMA API key found. LLaMA will be disabled.")
        print("💡 To enable: Create .env file in api/ folder with: LLAMA_API_KEY=gsk_your_key_here")
        print(f"   Expected .env file location: {ENV_FILE}")
        if os.path.exists(CHATBOT_ENV_FILE):
            print(f"   ⚠️  Found .env file in Chatbot folder, but it's not being loaded properly.")
            print(f"   💡 Move it to: {ENV_FILE}")
    _rag_system = LlamaEnhancedFashionRAG(llama_api_key=llama_api_key)
    if not _rag_system.load_system():
        print("❌ Failed to load RAG system")
        _rag_system = None
    else:
        print("✅ Fashion RAG System loaded successfully (main API)")
except Exception as e:
    print(f"⚠ Warning: could not load LlamaEnhancedFashionRAG: {e}")
    _rag_system = None


# --------------------------------------------------------------------------
# Main entrypoint used by api/app.py
# --------------------------------------------------------------------------

def get_chatbot_response(user_message: str, context: str = "fashion_styling") -> str:
    """
    Called by /chatbot/chat and /api/chat in api/app.py.
    
    Uses the LLaMA-enhanced Fashion RAG system from llama_enhanced_rag.py.
    Falls back to rule-based responses if RAG system is not available.
    """
    try:
        # Try RAG chatbot
        if _rag_system is not None:
            import time
            
            start_time = time.time()
            result = _rag_system.chat(user_message)
            end_time = time.time()
            response_time = round(end_time - start_time, 2)
            
            predicted_intent = str(result.get("predicted_intent", "unknown"))
            confidence = float(result.get("confidence", 0.0))
            
            fashion_intents = [
                "product_recommendation",
                "outfit_recommendation",
                "occasion_match",
                "accessory_advice",
                "makeup_tip",
                "skin_tone_advice",
                "shopping_advice",
                "trend_info",
                "brand_info",
                "budget_advice",
                "color_advice",
                "style_tip",
            ]
            
            # Get the response from RAG system
            response_text = str(result.get("response", ""))
            
            # If response is empty, use fallback
            if not response_text or response_text.strip() == "":
                response_text = get_fallback_response(user_message, context)
                print(f"[RAG Chatbot] Empty response, using fallback")
            elif predicted_intent not in fashion_intents or confidence < 0.5:
                # If intent doesn't match or low confidence, still return the response
                # but log it for debugging - the RAG response might still be helpful
                print(f"[RAG Chatbot] Low confidence ({confidence:.2f}) or non-fashion intent ({predicted_intent}), but returning RAG response")
            
            print(
                f"[RAG Chatbot] intent={predicted_intent}, "
                f"conf={confidence:.2f}, time={response_time}s, "
                f"response_length={len(response_text)}"
            )
            return response_text
        
        # Fallback if RAG not available
        return get_fallback_response(user_message, context)
        
    except Exception as e:
        print(f"Error in RAG chatbot, using fallback: {e}")
        return get_fallback_response(user_message, context)


# --------------------------------------------------------------------------
# Simple rule‑based fallback (no sklearn / models needed)
# --------------------------------------------------------------------------

def get_fallback_response(user_message: str, context: str = "fashion_styling") -> str:
    """Fallback responses when RAG system is not available."""
    message_lower = user_message.lower()

    if any(word in message_lower for word in ["hello", "hi", "hey", "greetings"]):
        return "Hello! I'm your AI fashion stylist. How can I help you today?"

    if any(word in message_lower for word in ["color", "colour", "colours", "what color"]):
        return (
            "Great question about colors! The best colors for you depend on your skin tone. "
            "Have you completed your color analysis? I can help you find shades that "
            "complement your natural features."
        )

    if any(word in message_lower for word in ["outfit", "what to wear", "suggestion"]):
        return (
            "I'd love to help with outfit suggestions! Tell me about the occasion, "
            "your preferred style, and any colors you like or want to avoid."
        )

    if any(word in message_lower for word in ["style", "styling", "fashion tips"]):
        return (
            "Here are some style tips: focus on fit first, choose colors that complement "
            "your skin tone, and don't be afraid to express your personality. "
            "What specific style advice are you looking for?"
        )

    if any(word in message_lower for word in ["bye", "goodbye", "thanks", "thank you"]):
        return (
            "You're welcome! Feel free to come back anytime for more fashion advice. "
            "Have a stylish day!"
        )

    # Default fallback
    return (
        "I'm here to help with fashion and styling advice! You can ask me about colors, "
        "outfit suggestions, style tips, or anything fashion‑related. What would you like "
        "to know?"
    )


def is_chatbot_available() -> bool:
    """
    Used by /chatbot/health and /api/system-info.
    Returns True if the RAG system is loaded, False otherwise.
    """
    return _rag_system is not None and _rag_system.is_loaded


