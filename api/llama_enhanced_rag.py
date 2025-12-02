#!/usr/bin/env python3
"""
🚀 LLaMA-Enhanced Fashion RAG System
====================================
Integrates LLaMA API with your existing 90.99% accuracy RAG system
for natural, conversational fashion advice.

Architecture:
Query → Intent Classification (90.99%) → Semantic Search → LLaMA + Context → Rich Response
"""

import pickle
import pandas as pd
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import re
import json
import os
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    ENV_FILE = os.path.join(BASE_DIR, '.env')
    CHATBOT_ENV_FILE = os.path.join(BASE_DIR, 'Chatbot', '.env')
    
    # Try multiple locations
    if os.path.exists(ENV_FILE):
        load_dotenv(ENV_FILE)
    elif os.path.exists(CHATBOT_ENV_FILE):
        load_dotenv(CHATBOT_ENV_FILE)
    else:
        load_dotenv()  # Try current directory
except ImportError:
    pass  # dotenv not available, continue without it

# Groq LLaMA API Integration
try:
    from groq import Groq
    LLAMA_AVAILABLE = True
except ImportError:
    LLAMA_AVAILABLE = False
    print("⚠️  Groq not installed. Install with: pip install groq")

class LlamaEnhancedFashionRAG:
    def embed_chunks(self, chunks):
        """Embed a list of text chunks into vectors using SentenceTransformer."""
        if not self.model:
            raise RuntimeError("Embedding model not loaded.")
        if not isinstance(chunks, list):
            raise ValueError("Input must be a list of text chunks.")
        return self.model.encode(chunks)

    def chunk_text(self, text, chunk_size=1000, chunk_overlap=150):
        """Split long text into overlapping chunks for RAG embedding."""
        if not isinstance(text, str):
            return []
        chunks = []
        start = 0
        text_length = len(text)
        while start < text_length:
            end = min(start + chunk_size, text_length)
            chunk = text[start:end]
            chunks.append(chunk)
            start += chunk_size - chunk_overlap
        return chunks

    def __init__(self, llama_api_key=None):
        """Initialize the LLaMA-enhanced RAG system"""
        self.model = None
        self.intent_classifier = None
        self.label_encoder = None
        self.embeddings = None
        self.dataset = None
        self.is_loaded = False
        
        # LLaMA setup - automatically load from environment
        self.llama_api_key = llama_api_key or os.getenv('LLAMA_API_KEY') or os.getenv('GROQ_API_KEY')
        self.llama = None
        self.conversation_history = []
        self.llama_enabled = False
        
        # Performance settings
        self.confidence_threshold = 0.6
        self.similarity_threshold = 0.7
        self.use_llama_for_high_confidence = True
        
    def setup_llama(self, api_key=None):
        """Setup LLaMA API connection"""
        if not LLAMA_AVAILABLE:
            print("❌ Groq package not available. Install with: pip install groq")
            return False
            
        if api_key:
            self.llama_api_key = api_key
            print(f"🔑 API key provided: {api_key[:10]}...")
        else:
            print(f"🔍 Checking for API key in environment...")
            if self.llama_api_key:
                print(f"✅ Found API key in environment: {self.llama_api_key[:10]}...")
            else:
                print("⚠️  No LLaMA API key found in environment variables (LLAMA_API_KEY or GROQ_API_KEY)")
            
        if not self.llama_api_key:
            print("⚠️  No LLaMA API key provided. Using fallback mode.")
            print("💡 To enable LLaMA: Create .env file in api/ folder with: LLAMA_API_KEY=gsk_your_key_here")
            return False
            
        try:
            print("🔌 Connecting to Groq LLaMA API...")
            self.llama = Groq(api_key=self.llama_api_key)
            self.llama_enabled = True
            print("✅ LLaMA API connected successfully!")
            return True
        except Exception as e:
            print(f"❌ LLaMA API setup failed: {e}")
            print(f"   Error details: {type(e).__name__}")
            self.llama_enabled = False
            return False
    
    def load_system(self):
        """Load all trained components"""
        print("🚀 Loading LLaMA-Enhanced Fashion RAG System...")
        
        try:
            # Load sentence transformer model
            print("📦 Loading sentence transformer...")
            self.model = SentenceTransformer('all-MiniLM-L6-v2')
            
            # Load MAXIMUM ACCURACY classifiers (advanced + fallback)
            print("🎯 Loading intent classifiers for maximum accuracy...")
    
            # Initialize variables
            self.advanced_classifier = None
            self.feature_selector = None
            self.scaler = None
            classifier_loaded = False
            
            # 1. Try main intent classifier model (standard name)
            print("🚀 Attempting to load intent classifier model...")
            classifier_paths = [
                'intent_classifier_model.pkl',  # Standard name
                'advanced_intent_classifier_model.pkl',  # Advanced version
                'advanced_intent_classifier_corrected.pkl',  # Corrected version
                'intent_classifier_balanced_model.pkl',  # Balanced version
                'production_intent_classifier.pkl',  # Production version
            ]
            
            for model_path in classifier_paths:
                try:
                    with open(model_path, 'rb') as f:
                        classifier_data = pickle.load(f)
                    
                    # Handle different data structures
                    if isinstance(classifier_data, dict):
                        # Check if it's advanced classifier with feature selection
                        if 'classifier' in classifier_data and 'feature_selector' in classifier_data:
                            self.advanced_classifier = classifier_data['classifier']
                            self.advanced_label_encoder = classifier_data.get('label_encoder')
                            self.feature_selector = classifier_data.get('feature_selector')
                            self.scaler = classifier_data.get('scaler')
                            print(f"✅ Advanced classifier loaded from {model_path}!")
                            print("   🎯 Expected accuracy: 91.45% (maximum)")
                            classifier_loaded = True
                            break
                        else:
                            # Standard classifier dict
                            self.intent_classifier = classifier_data.get('model', classifier_data.get('classifier'))
                            self.label_encoder = classifier_data.get('label_encoder')
                            print(f"✅ Classifier loaded from {model_path}!")
                            classifier_loaded = True
                            break
                    else:
                        # Direct classifier object
                        self.intent_classifier = classifier_data
                        print(f"✅ Classifier loaded from {model_path}!")
                        classifier_loaded = True
                        break
                        
                except (FileNotFoundError, KeyError, Exception) as e:
                    continue
            
            if not classifier_loaded:
                raise Exception("No intent classifier found! Tried: " + ", ".join(classifier_paths))
            
            if not classifier_loaded:
                raise Exception("No intent classifier found!")
            
            # Display accuracy strategy
            if self.advanced_classifier is not None:
                print("🏆 MAXIMUM ACCURACY MODE: Advanced (91.45%) + Balanced (87.99%) fallback")
            else:
                print("📊 STANDARD MODE: Balanced classifier (87.99%)")
            
            # Load embeddings
            print("🧠 Loading embeddings...")
            embedding_paths = [
                'fashion_embeddings.pkl',  # Standard name
                'fashion_embeddings_balanced.pkl',  # Balanced version
                'fashion_embeddings_language_fixed.pkl',  # Language fixed version
            ]
            
            embeddings_loaded = False
            for emb_path in embedding_paths:
                try:
                    with open(emb_path, 'rb') as f:
                        self.embeddings = pickle.load(f)
                    print(f"✅ Embeddings loaded from {emb_path}")
                    embeddings_loaded = True
                    break
                except FileNotFoundError:
                    continue
            
            if not embeddings_loaded:
                raise Exception("No embeddings file found! Tried: " + ", ".join(embedding_paths))
            
            # Load dataset
            print("📊 Loading dataset...")
            try:
                self.dataset = pd.read_csv('fashion_dataset_balanced.csv')
                print("✅ Balanced dataset loaded")
            except FileNotFoundError:
                self.dataset = pd.read_csv('fashion_dataset_final_cleaned.csv')
                print("✅ Standard dataset loaded (fallback)")
            
            print("✅ All components loaded successfully!")
            self.is_loaded = True
            
            # System info
            print(f"\n📋 System Information:")
            print(f"  🎯 Dataset Size: {len(self.dataset)} entries")
            print(f"  🧠 Embedding Dimension: {self.embeddings.shape[1]}")
            print(f"  🤖 LLaMA Status: {'🟢 Enabled' if self.llama_enabled else '🔴 Disabled (Fallback Mode)'}")
            print(f"  🌍 Languages: Roman Urdu + English")
            
            # Auto-setup LLaMA if API key is available
            if self.llama_api_key and not self.llama_enabled:
                print("\n🔑 Auto-configuring LLaMA API...")
                if self.setup_llama():
                    print("✅ LLaMA API auto-configured successfully!")
                    # Verify LLaMA is actually enabled
                    print(f"🔍 Verification - llama_enabled: {self.llama_enabled}, llama object: {self.llama is not None}")
                else:
                    print("⚠️ LLaMA API auto-configuration failed")
            elif self.llama_enabled:
                print(f"✅ LLaMA already enabled (llama_enabled: {self.llama_enabled})")
            else:
                print(f"⚠️ LLaMA not enabled - API key: {self.llama_api_key is not None}, Enabled: {self.llama_enabled}")
            
            return True
            
        except Exception as e:
            print(f"❌ Error loading system: {str(e)}")
            self.is_loaded = False
            return False
    
    def clean_query(self, query):
        """Clean and preprocess user query"""
        if not isinstance(query, str):
            return ""
        
        # Basic cleaning
        query = query.lower().strip()
        
        # Remove extra whitespace
        query = re.sub(r'\s+', ' ', query)
        
        # Remove special characters but keep Roman Urdu friendly
        query = re.sub(r'[^\w\s\u0600-\u06FF]', ' ', query)
        
        return query.strip()
    
    def predict_intent(self, query):
        """Predict intent with MAXIMUM ACCURACY - uses advanced model with feature selection"""
        if not self.is_loaded:
            return "unknown", 0.0, []
        
        try:
            # Create embedding for query
            query_embedding = self.model.encode([query])
            
            # Try advanced model first (highest accuracy: 91.45%)
            if hasattr(self, 'advanced_classifier') and self.advanced_classifier is not None:
                try:
                    # Apply same feature selection as training
                    query_features = self.feature_selector.transform(query_embedding)
                    query_scaled = self.scaler.transform(query_features)
                    
                    probabilities = self.advanced_classifier.predict_proba(query_scaled)[0]
                    predicted_class = self.advanced_classifier.predict(query_scaled)[0]
                    confidence = probabilities[predicted_class]
                    
                    # Get top 3 predictions
                    top_indices = np.argsort(probabilities)[-3:][::-1]
                    
                    # Use advanced model's label encoder
                    predicted_intent = self.advanced_label_encoder.classes_[predicted_class]
                    
                    top_predictions = []
                    for i in top_indices[:3]:
                        if i < len(self.advanced_label_encoder.classes_):
                            top_predictions.append((self.advanced_label_encoder.classes_[i], probabilities[i]))
                    
                    return predicted_intent, confidence, top_predictions
                    
                except Exception as e:
                    print(f"⚠️ Advanced model error: {e}, falling back to balanced model")
            
            # Fallback to balanced classifier
            probabilities = self.intent_classifier.predict_proba(query_embedding)[0]
            predicted_class = self.intent_classifier.predict(query_embedding)[0]
            confidence = probabilities[predicted_class]
            
            # Get top 3 predictions
            top_indices = np.argsort(probabilities)[-3:][::-1]
            
            # Handle label encoding if available
            if hasattr(self, 'label_encoder') and self.label_encoder:
                top_predictions = [
                    (self.label_encoder.classes_[i], probabilities[i]) 
                    for i in top_indices
                ]
                predicted_intent = self.label_encoder.classes_[predicted_class]
            else:
                # Map to intent classes
                intent_classes = sorted(self.dataset['Intent'].unique())
                predicted_intent = intent_classes[predicted_class] if predicted_class < len(intent_classes) else 'unknown'
                
                top_predictions = []
                for i in top_indices[:3]:
                    if i < len(intent_classes):
                        top_predictions.append((intent_classes[i], probabilities[i]))
            
            return predicted_intent, confidence, top_predictions
            
        except Exception as e:
            print(f"⚠️ Intent prediction error: {str(e)}")
            return self._simple_intent_fallback(query), 0.3, []
    
    def _simple_intent_fallback(self, query):
        """Simple keyword-based intent classification as fallback"""
        query_lower = query.lower()
        
        # Basic keyword mapping
        if any(word in query_lower for word in ['wedding', 'shaadi', 'marriage']):
            return 'outfit_recommendation'
        elif any(word in query_lower for word in ['office', 'work', 'professional', 'formal']):
            return 'outfit_recommendation'  
        elif any(word in query_lower for word in ['makeup', 'lipstick', 'foundation', 'blush']):
            return 'makeup_tip'
        elif any(word in query_lower for word in ['shop', 'buy', 'store', 'budget', 'price']):
            return 'shopping_recommendation'
        elif any(word in query_lower for word in ['color', 'rang', 'skin', 'tone']):
            return 'skin_tone_advice'
        elif any(word in query_lower for word in ['summer', 'winter', 'weather', 'mausam']):
            return 'weather_advice'
        elif any(word in query_lower for word in ['party', 'casual', 'outfit', 'dress', 'wear']):
            return 'outfit_recommendation'
        else:
            return 'outfit_recommendation'  # Default fallback
    
    def semantic_search(self, query, intent=None, top_k=5):
        """Perform semantic search using your trained embeddings"""
        if not self.is_loaded:
            return []
        
        try:
            # Create embedding for query
            query_embedding = self.model.encode([query])
            
            # Calculate similarities
            similarities = cosine_similarity(query_embedding, self.embeddings)[0]
            
            # Filter by intent if provided and available
            intent_col = 'Intent' if 'Intent' in self.dataset.columns else 'intent'
            if intent and intent != "unknown" and intent_col in self.dataset.columns:
                intent_mask = self.dataset[intent_col] == intent
                filtered_indices = np.where(intent_mask)[0]
                
                if len(filtered_indices) > 0:
                    filtered_similarities = similarities[filtered_indices]
                    top_filtered_indices = np.argsort(filtered_similarities)[-top_k:][::-1]
                    top_indices = filtered_indices[top_filtered_indices]
                else:
                    top_indices = np.argsort(similarities)[-top_k:][::-1]
            else:
                top_indices = np.argsort(similarities)[-top_k:][::-1]
            
            # Prepare results
            results = []
            for idx in top_indices:
                row = self.dataset.iloc[idx]
                results.append({
                    'index': int(idx),
                    'query': str(row.get('user_query', row.get('query', ''))),
                    'response': str(row.get('bot_response', row.get('response', ''))),
                    'intent': str(row.get('Intent', row.get('intent', 'unknown'))),
                    'similarity': float(similarities[idx])
                })
            
            return results
            
        except Exception as e:
            print(f"⚠️ Semantic search error: {str(e)}")
            return []
    
    def build_llama_context(self, search_results, predicted_intent, confidence):
        """Build context for LLaMA from search results"""
        if not search_results:
            return f"Intent: {predicted_intent}\nNo specific context available."
        
        # Build rich context from top search results
        context_parts = [
            f"Intent Category: {predicted_intent}",
            f"Confidence: {confidence:.3f}",
            "\nRelevant Fashion Knowledge:"
        ]
        
        for i, result in enumerate(search_results[:3], 1):
            context_parts.append(f"\nExample {i}:")
            context_parts.append(f"Q: {result['query']}")
            context_parts.append(f"A: {result['response']}")
            context_parts.append(f"Similarity: {result['similarity']:.3f}")
        
        return "\n".join(context_parts)
    
    def generate_llama_response(self, query, search_results, predicted_intent, confidence):
        """Generate response using LLaMA API with RAG context"""
        if not self.llama_enabled:
            return self.generate_fallback_response(query, search_results, predicted_intent, confidence)

        # Language detection helper
        try:
            from langdetect import detect
            def detect_language(text):
                try:
                    lang = detect(text)
                    if lang == 'en':
                        return 'english'
                    elif lang == 'ur':
                        return 'roman_urdu'
                    else:
                        return 'unknown'
                except:
                    return 'unknown'
        except ImportError:
            def detect_language(text):
                return 'unknown'

        query_language = detect_language(query)

        # Build context for LLaMA
        context = self.build_llama_context(search_results, predicted_intent, confidence)

        # Set system prompt based on detected language
        if query_language == 'english':
            system_prompt = f"""You are Vogue AI, a helpful fashion assistant and stylist. Always reply only in English. Do not use Hindi or other languages. Answer user queries about fashion, styling, shopping, and trends. Support English only.\n\nStyle Guidelines:\n1. Use ONLY information from the provided context\n2. Be professional - avoid overly casual terms like 'beta' or 'bhai'\n3. Be specific about colors, styles, occasions, and styling tips\n4. Keep responses concise but comprehensive\n5. Start responses directly with advice, not greetings\n\nContext: {context}"""
        elif query_language == 'roman_urdu':
            system_prompt = f"""You are Vogue AI, a helpful fashion assistant and stylist. Always reply only in Roman Urdu. Do not use Hindi or other languages. Answer user queries about fashion, styling, shopping, and trends. Support Roman Urdu only.\n\nStyle Guidelines:\n1. Use ONLY information from the provided context\n2. Be professional - avoid overly casual terms like 'beta' or 'bhai'\n3. Be specific about colors, styles, occasions, and styling tips\n4. Keep responses concise but comprehensive\n5. Start responses directly with advice, not greetings\n\nContext: {context}"""
        else:
            system_prompt = f"""You are Vogue AI, a helpful fashion assistant and stylist. Always reply in a natural mix of Roman Urdu and English (like modern Pakistani fashion experts speak). Do not use Hindi or other languages. Answer user queries about fashion, styling, shopping, and trends. Support Roman Urdu and English only.\n\nStyle Guidelines:\n1. Use ONLY information from the provided context\n2. Be professional - avoid overly casual terms like 'beta' or 'bhai'\n3. Mix Roman Urdu and English naturally but professionally\n4. Be specific about colors, styles, occasions, and styling tips\n5. Keep responses concise but comprehensive\n6. Start responses directly with advice, not greetings\n\nContext: {context}"""

        try:
            messages = [
                {
                    "role": "system",
                    "content": system_prompt
                },
                {
                    "role": "user",
                    "content": query
                }
            ]

            # Add conversation history if available
            if len(self.conversation_history) > 0 and self.llama_enabled:
                messages = messages[:1] + self.conversation_history[-4:] + messages[1:]

            # Call Groq LLaMA API
            print("🌐 Making API call to Groq LLaMA...")
            print(f"   Model: llama-3.1-8b-instant")
            print(f"   Messages: {len(messages)} messages")
            print(f"   Context length: {len(context)} characters")
            import time
            api_start = time.time()
            response = self.llama.chat.completions.create(
                model="llama-3.1-8b-instant",
                messages=messages,
                temperature=0.2,
                max_tokens=300
            )
            api_time = round(time.time() - api_start, 2)
            print(f"✅ Received response from Groq LLaMA API (took {api_time}s)")

            # Extract response text from Groq response
            if hasattr(response, 'choices') and len(response.choices) > 0:
                llama_response = response.choices[0].message.content
            else:
                raise Exception("Invalid response format from Groq API")

            # Validate response
            if not llama_response or llama_response.strip() == "":
                raise Exception("Empty response from Groq API")

            # Update conversation history
            self.conversation_history.extend([
                {"role": "user", "content": query},
                {"role": "assistant", "content": llama_response}
            ])

            # Keep only last 6 messages (3 turns) to manage context length
            if len(self.conversation_history) > 6:
                self.conversation_history = self.conversation_history[-6:]

            return llama_response

        except Exception as e:
            print(f"⚠️ LLaMA API error: {e}")
            self.llama_enabled = False
            print("🔄 LLaMA disabled for session - using high-accuracy fallback")
            return self.generate_fallback_response(query, search_results, predicted_intent, confidence)
    
    def generate_fallback_response(self, query, search_results, predicted_intent, confidence):
        """Fallback response generation (your original system)"""
        if not search_results:
            return self._get_fallback_by_intent(predicted_intent)
        
        # Get the best match
        best_match = search_results[0]
        
        # High confidence and similarity - use direct response
        if confidence > self.confidence_threshold and best_match['similarity'] > self.similarity_threshold:
            return best_match['response']
        
        # Medium confidence - add context
        elif confidence > 0.4 and best_match['similarity'] > 0.6:
            base_response = best_match['response']
            
            # Add additional context if available
            if len(search_results) > 1 and search_results[1]['similarity'] > 0.5:
                additional = search_results[1]['response']
                if len(additional) < 100:
                    base_response += f"\n\nAur option: {additional}"
            
            return base_response
        
        # Lower confidence - multiple options
        else:
            responses = [r['response'] for r in search_results[:2] if r['similarity'] > 0.4]
            if responses:
                return f"Yahan kuch suggestions hain:\n\n" + "\n\n".join(responses)
            else:
                return self._get_fallback_by_intent(predicted_intent)
    
    def _get_fallback_by_intent(self, intent):
        """Intent-specific fallback responses"""
        fallbacks = {
            'outfit_recommendation': "Main aapko outfit recommend kar sakta hun. Occasion aur preference bataiye?",
            'occasion_match': "Kis occasion ke liye dress chahiye? Detail mein bataiye.",
            'makeup_tip': "Makeup tips de sakta hun. Kya specific chahiye?",
            'shopping_recommendation': "Shopping advice chahiye? Budget aur area bataiye.",
            'skin_tone_advice': "Skin tone ke hisab se colors bata sakta hun. Aur detail diye?",
            'weather_advice': "Mausam ke hisab se dress suggest kar sakta hun. Season kya hai?",
            'cultural_event': "Cultural event ke liye traditional wear best. Function kya hai?",
            'budget_advice': "Budget-friendly options suggest kar sakta hun. Range bataiye?",
            'fabric_advice': "Fabric ki advice de sakta hun. Kya janna chahte hain?"
        }
        return fallbacks.get(intent, "Fashion styling mein help kar sakta hun. Aur detail bataiye?")
    
    def chat(self, query, use_llama=None):
        """Main chat function - enhanced RAG pipeline with LLaMA"""
        if not self.is_loaded:
            return "❌ System not loaded. Please run load_system() first."
        
        print(f"\n👤 User: {query}")
        print("🤖 Processing...")
        print(f"🔍 Debug - llama_enabled: {self.llama_enabled}, llama_api_key exists: {self.llama_api_key is not None}")
        
        # Step 1: Clean query
        clean_query = self.clean_query(query)
        
        # Step 2: Predict intent using your 90.99% accuracy model
        predicted_intent, confidence, top_predictions = self.predict_intent(clean_query)
        
        # Step 3: Semantic search using your embeddings
        search_results = self.semantic_search(clean_query, predicted_intent, top_k=5)
        
        # Step 4: Determine if LLaMA should be used (enhanced logic)
        if use_llama is None:
            # Check if we have good semantic matches
            has_good_match = False
            if search_results:
                best_match = search_results[0]
                # Use LLaMA if no good semantic match OR high confidence intent
                has_good_match = (confidence > self.confidence_threshold and 
                                 best_match['similarity'] > self.similarity_threshold)
                
                # Additional check: if similarity is high but response seems irrelevant
                # (e.g., party query matching travel response), prefer LLaMA
                if has_good_match:
                    query_words = set(clean_query.lower().split())
                    response_words = set(best_match['response'].lower().split())
                    
                    # Key semantic check: if query contains specific terms like 'party'
                    # but top response doesn't, it's likely a poor match
                    key_terms = {'party', 'wedding', 'formal', 'casual', 'office', 'travel', 'sports', 'gym'}
                    query_key_terms = query_words.intersection(key_terms)
                    response_key_terms = response_words.intersection(key_terms)
                    
                    if query_key_terms and not query_key_terms.intersection(response_key_terms):
                        has_good_match = False  # Semantic mismatch detected
            
            # Use LLaMA if: high confidence OR no good semantic match OR LLaMA mode enabled
            # FORCE LLaMA usage if enabled (bypass confidence threshold for better responses)
            print(f"🔍 Debug - Checking LLaMA status: llama_enabled={self.llama_enabled}, llama={self.llama is not None}")
            if self.llama_enabled:
                use_llama = True  # Always use LLaMA if available
                print("🚀 LLaMA is enabled - forcing LLaMA usage for better responses")
            else:
                print(f"⚠️ LLaMA not enabled. Reason: llama_enabled={self.llama_enabled}, llama object={self.llama is not None}")
                use_llama = (self.use_llama_for_high_confidence and confidence > self.confidence_threshold) or not has_good_match
        
        # Step 5: Generate response
        if use_llama and self.llama_enabled:
            print("🤖 Calling LLaMA API...")
            response = self.generate_llama_response(clean_query, search_results, predicted_intent, confidence)
            generation_method = "🤖 LLaMA Enhanced (Smart Fallback)" if not has_good_match else "🤖 LLaMA Enhanced"
        else:
            if self.llama_enabled:
                print(f"⚠️ LLaMA enabled but use_llama={use_llama}, using fallback")
            else:
                print(f"⚠️ LLaMA not enabled (no API key), using fallback")
            response = self.generate_fallback_response(clean_query, search_results, predicted_intent, confidence)
            generation_method = "📋 Template Based"
        
        # Display analysis
        print(f"🎯 Intent: {predicted_intent} (confidence: {confidence:.3f})")
        if search_results:
            print(f"🔍 Best Match: {search_results[0]['similarity']:.3f}")
        print(f"⚙️  Method: {generation_method}")
        print(f"🤖 Bot: {response}")
        
        return {
            'query': query,
            'cleaned_query': clean_query,
            'predicted_intent': predicted_intent,
            'confidence': confidence,
            'top_predictions': top_predictions,
            'search_results': search_results,
            'response': response,
            'generation_method': generation_method,
            'llama_used': use_llama and self.llama_enabled
        }
    
    def clear_conversation(self):
        """Clear conversation history"""
        self.conversation_history = []
        print("🧹 Conversation history cleared")
    
    def set_llama_mode(self, enabled=True, confidence_threshold=0.6):
        """Enable/disable LLaMA mode and set confidence threshold"""
        self.use_llama_for_high_confidence = enabled
        self.confidence_threshold = confidence_threshold
        
        status = "🟢 Enabled" if enabled else "🔴 Disabled" 
        print(f"🤖 LLaMA Mode: {status} (threshold: {confidence_threshold:.2f})")

def main():
    """Demo the LLaMA-enhanced system"""
    print("🌟 LLaMA-Enhanced Fashion RAG System")
    print("=" * 60)
    
    # Initialize system
    rag = LlamaEnhancedFashionRAG()
    
    # Load components
    if not rag.load_system():
        print("❌ Failed to load system")
        return
    
    # Setup LLaMA (you'll need to provide API key)
    print(f"\n🔑 LLaMA API Setup:")
    # api_key = input("Enter your LLaMA API key (or press Enter to skip): ").strip()
    api_key = "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"
    

    
    if api_key:
        rag.setup_llama(api_key)
    else:
        print("⚠️  Continuing without LLaMA API (fallback mode)")
    
    # Test with sample queries
    test_queries = [
        "wedding ke liye red lehenga suggest karo",
        "office mein kya pehnu professional look ke liye?",
        "summer mein light colors kaunse best hain?",
        "budget mein party dress kahan milega?",
        "makeup tips for oily skin",
    ]
    
    print(f"\n🧪 Testing Enhanced System:")
    print("=" * 40)
    
    for i, query in enumerate(test_queries, 1):
        print(f"\n📝 Test {i}/{len(test_queries)}:")
        rag.chat(query)
        print("-" * 40)
    
    # Interactive mode
    print(f"\n🎉 System ready! Starting interactive mode...")
    
    while True:
        print(f"\n" + "="*50)
        user_input = input("👤 Enter your fashion query (or 'quit'/'help'): ").strip()
        
        if user_input.lower() in ['quit', 'exit', 'q']:
            print("👋 Thanks for using LLaMA-Enhanced Fashion RAG!")
            break
        elif user_input.lower() == 'help':
            print("\n🔧 Commands:")
            print("  • 'clear' - Clear conversation history")
            print("  • 'llama on/off' - Toggle LLaMA mode")
            print("  • 'status' - Show system status")
            print("  • 'quit' - Exit")
            continue
        elif user_input.lower() == 'clear':
            rag.clear_conversation()
            continue
        elif user_input.lower().startswith('llama'):
            if 'on' in user_input.lower():
                rag.set_llama_mode(True)
            elif 'off' in user_input.lower():
                rag.set_llama_mode(False)
            continue
        elif user_input.lower() == 'status':
            print(f"🎯 Intent Classifier: ✅ Loaded")
            print(f"🧠 Embeddings: ✅ Loaded ({rag.embeddings.shape})")
            print(f"📊 Dataset: ✅ Loaded ({len(rag.dataset)} entries)")
            print(f"🤖 LLaMA: {'🟢 Enabled' if rag.llama_enabled else '🔴 Disabled'}")
            continue
        
        if user_input:
            rag.chat(user_input)

if __name__ == "__main__":
    main()