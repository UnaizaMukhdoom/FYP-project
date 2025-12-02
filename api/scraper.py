# api/scraper.py
# Web Scraper for Fashion Brands - Scrapes clothes based on skin tone and color preferences

import requests
from bs4 import BeautifulSoup
import time
import random
from urllib.parse import urljoin, urlparse
import re
import json
import html as html_lib

# ============================================================================
# CONFIGURATION
# ============================================================================

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
}

# Brand configurations with selectors
BRANDS = {
    "Sapphire": {
        "base": "https://pk.sapphireonline.pk",
        "start_url": "https://pk.sapphireonline.pk/collections/ready-to-wear",
        "selectors": {
            "card": "div.product-item, article.product-card, .product-grid-item",
            "title": "h2.product-title, .product-name a, h3 a",
            "price": ".price, .product-price, .price-current",
            "image": "img.product-image, .product-img img, img[data-src]",
            "link": "a.product-link, .product-name a, h3 a",
            "color": ".product-color, .color-name, [data-color]"
        }
    },
    "Limelight": {
        "base": "https://www.limelight.pk",
        "start_url": "https://www.limelight.pk/collections/women",
        "selectors": {
            "card": ".product-item, .grid-item, .product-card",
            "title": ".product-title, h3, .product-name",
            "price": ".price, .product-price",
            "image": "img.product-image, .product-img img",
            "link": "a.product-link, a",
            "color": ".color, .product-color"
        }
    },
    "AsimJofa": {
        "base": "https://asimjofa.com",
        "start_url": "https://asimjofa.com/collections/women",
        "selectors": {
            "card": ".product, .product-item, .grid-item",
            "title": ".product-title, h2, h3",
            "price": ".price, .product-price",
            "image": "img, .product-image img",
            "link": "a",
            "color": ".color-name, .product-color"
        }
    },
    "Generation": {
        "base": "https://www.generation.com.pk",
        "start_url": "https://www.generation.com.pk/women",
        "selectors": {
            "card": ".product-item, .product, .grid-item",
            "title": ".product-title, h3, .name",
            "price": ".price, .product-price",
            "image": "img, .product-image",
            "link": "a",
            "color": ".color, [data-color]"
        }
    },
    "Laam": {
        "base": "https://laam.pk",
        "start_url": "https://laam.pk/collections/women",
        "selectors": {
            "card": ".product-card, .product-item, .grid-item",
            "title": ".product-title, h3, .title",
            "price": ".price, .product-price",
            "image": "img.product-image, img",
            "link": "a",
            "color": ".color-name, .product-color"
        }
    }
}

# Skin tone to filter mapping (if websites support filtering)
SKIN_TONE_TO_FILTER = {
    "Very Fair": "1",
    "Fair": "1",
    "Medium": "2",
    "Tan/Olive": "2",
    "Deep/Dark": "3",
    "Black": "3"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

def fetch(url, max_retries=3, delay=1):
    """Fetch HTML content from URL with retries"""
    for attempt in range(max_retries):
        try:
            response = requests.get(url, headers=HEADERS, timeout=10)
            response.raise_for_status()
            return response.text
        except requests.exceptions.RequestException as e:
            if attempt < max_retries - 1:
                time.sleep(delay * (attempt + 1))
                continue
            print(f"Error fetching {url}: {e}")
            return None
    return None

def extract_text(element, default=""):
    """Extract text from BeautifulSoup element"""
    if element:
        text = element.get_text(strip=True)
        return html_lib.unescape(text) if text else default
    return default

def extract_image_from_element(element):
    """Extract image URL from element"""
    if not element:
        return None
    
    # Try data-src, data-lazy-src, src attributes
    for attr in ['data-src', 'data-lazy-src', 'data-original', 'src']:
        img_url = element.get(attr)
        if img_url:
            return normalize_image_url(img_url)
    
    # Try nested img tag
    img_tag = element.find('img')
    if img_tag:
        for attr in ['data-src', 'data-lazy-src', 'data-original', 'src']:
            img_url = img_tag.get(attr)
            if img_url:
                return normalize_image_url(img_url)
    
    return None

def normalize_image_url(url, base_url=None):
    """Normalize image URL (handle relative URLs, remove query params if needed)"""
    if not url:
        return None
    
    # Remove query parameters that might be for sizing
    url = url.split('?')[0]
    
    # Handle relative URLs
    if url.startswith('//'):
        url = 'https:' + url
    elif url.startswith('/'):
        if base_url:
            url = urljoin(base_url, url)
        else:
            url = 'https://' + url.lstrip('/')
    elif not url.startswith('http'):
        if base_url:
            url = urljoin(base_url, url)
        else:
            return None
    
    return url

def extract_price(price_text):
    """Extract numeric price from text"""
    if not price_text:
        return ""
    
    # Remove currency symbols and extract numbers
    price_clean = re.sub(r'[^\d.,]', '', price_text)
    price_clean = price_clean.replace(',', '')
    
    try:
        return float(price_clean)
    except:
        return price_text  # Return original if parsing fails

def extract_color_from_text(text, preferred_colors):
    """Extract color information from product text"""
    if not text:
        return None
    
    text_lower = text.lower()
    preferred_lower = [c.lower() for c in preferred_colors]
    
    # Check if any preferred color is mentioned
    for color in preferred_lower:
        if color in text_lower:
            return color.capitalize()
    
    # Common color keywords
    color_keywords = ['red', 'blue', 'green', 'yellow', 'pink', 'purple', 'orange', 
                     'black', 'white', 'gray', 'grey', 'brown', 'beige', 'navy',
                     'coral', 'teal', 'burgundy', 'emerald', 'gold', 'silver']
    
    for keyword in color_keywords:
        if keyword in text_lower:
            return keyword.capitalize()
    
    return None

# ============================================================================
# BRAND-SPECIFIC PARSERS
# ============================================================================

def parse_sapphire_card(card, base_url, selectors):
    """Parse a product card from Sapphire"""
    try:
        title_elem = card.select_one(selectors.get("title", "h2, h3, .title"))
        title = extract_text(title_elem, "Untitled Product")
        
        price_elem = card.select_one(selectors.get("price", ".price"))
        price = extract_text(price_elem, "Price not available")
        
        link_elem = card.select_one(selectors.get("link", "a"))
        link = urljoin(base_url, link_elem.get('href', '')) if link_elem else None
        
        image_elem = card.select_one(selectors.get("image", "img"))
        image_url = extract_image_from_element(image_elem)
        if image_url and not image_url.startswith('http'):
            image_url = urljoin(base_url, image_url)
        
        color_elem = card.select_one(selectors.get("color", ".color"))
        color = extract_text(color_elem)
        
        return {
            "brand": "Sapphire",
            "title": title,
            "price": price,
            "url": link,
            "image": image_url,
            "color": color
        }
    except Exception as e:
        print(f"Error parsing Sapphire card: {e}")
        return None

def parse_limelight_card(card, base_url, selectors):
    """Parse a product card from Limelight"""
    try:
        title_elem = card.select_one(selectors.get("title", "h3, h2, .title"))
        title = extract_text(title_elem, "Untitled Product")
        
        price_elem = card.select_one(selectors.get("price", ".price"))
        price = extract_text(price_elem, "Price not available")
        
        link_elem = card.select_one(selectors.get("link", "a"))
        link = urljoin(base_url, link_elem.get('href', '')) if link_elem else None
        
        image_elem = card.select_one(selectors.get("image", "img"))
        image_url = extract_image_from_element(image_elem)
        if image_url and not image_url.startswith('http'):
            image_url = urljoin(base_url, image_url)
        
        color_elem = card.select_one(selectors.get("color", ".color"))
        color = extract_text(color_elem)
        
        return {
            "brand": "Limelight",
            "title": title,
            "price": price,
            "url": link,
            "image": image_url,
            "color": color
        }
    except Exception as e:
        print(f"Error parsing Limelight card: {e}")
        return None

def parse_generic_card(card, base_url, brand_name, selectors):
    """Generic parser for brands without specific parsers"""
    try:
        title_elem = card.select_one(selectors.get("title", "h2, h3, .title, .name"))
        title = extract_text(title_elem, "Untitled Product")
        
        price_elem = card.select_one(selectors.get("price", ".price, .product-price"))
        price = extract_text(price_elem, "Price not available")
        
        link_elem = card.select_one(selectors.get("link", "a"))
        link = urljoin(base_url, link_elem.get('href', '')) if link_elem else None
        
        image_elem = card.select_one(selectors.get("image", "img"))
        image_url = extract_image_from_element(image_elem)
        if image_url and not image_url.startswith('http'):
            image_url = urljoin(base_url, image_url)
        
        color_elem = card.select_one(selectors.get("color", ".color, .product-color"))
        color = extract_text(color_elem)
        
        return {
            "brand": brand_name,
            "title": title,
            "price": price,
            "url": link,
            "image": image_url,
            "color": color
        }
    except Exception as e:
        print(f"Error parsing {brand_name} card: {e}")
        return None

# ============================================================================
# MAIN SCRAPING FUNCTIONS
# ============================================================================

def scrape_brand_clothes(brand_name, preferred_colors=None, max_items=20):
    """Scrape clothes from a specific brand"""
    if brand_name not in BRANDS:
        print(f"Brand {brand_name} not configured")
        return []
    
    try:
        brand_info = BRANDS[brand_name]
        print(f"Fetching {brand_info['start_url']}...")
        html = fetch(brand_info["start_url"], max_retries=2, delay=0.5)  # Faster retries
        
        if not html:
            print(f"Failed to fetch {brand_name}")
            return []
        
        soup = BeautifulSoup(html, "html.parser")  # Using html.parser instead of lxml
        cards = soup.select(brand_info["selectors"]["card"])
        
        if not cards:
            print(f"No product cards found for {brand_name}. Website structure might have changed.")
            return []
        
        print(f"Found {len(cards)} product cards for {brand_name}")
        
        items = []
        preferred_lower = [c.lower() for c in (preferred_colors or [])]
        
        # Reduce delay for faster scraping
        for card in cards[:max_items * 3]:  # Check more cards
            try:
                # Parse based on brand
                if brand_name == "Sapphire":
                    item = parse_sapphire_card(card, brand_info["base"], brand_info["selectors"])
                elif brand_name == "Limelight":
                    item = parse_limelight_card(card, brand_info["base"], brand_info["selectors"])
                else:
                    item = parse_generic_card(card, brand_info["base"], brand_name, brand_info["selectors"])
                
                if not item or not item.get("title") or item.get("title") == "Untitled Product":
                    continue
                
                # Less strict color filtering - show items even if color doesn't match exactly
                if preferred_lower:
                    item_color = (item.get("color") or "").lower()
                    item_title = (item.get("title") or "").lower()
                    
                    # Check if any preferred color matches
                    color_match = any(color in item_color or color in item_title for color in preferred_lower)
                    
                    if not color_match:
                        # Try to extract color from title
                        extracted_color = extract_color_from_text(item.get("title", ""), preferred_colors)
                        if not extracted_color:
                            # Still include some items even without color match (30% chance)
                            if random.random() > 0.3:
                                continue
            
                items.append(item)
                
                if len(items) >= max_items:
                    break
                
                # Reduced delay for faster scraping
                if len(items) % 5 == 0:  # Only delay every 5 items
                    time.sleep(0.1)
            except Exception as e:
                print(f"Error parsing card for {brand_name}: {e}")
                continue
        
        print(f"Successfully scraped {len(items)} items from {brand_name}")
        return items
        
    except Exception as e:
        print(f"Error scraping {brand_name}: {e}")
        return []

def scrape_all_brands_by_skin_tone(skin_tone_category, preferred_colors, max_per_brand=10):
    """Scrape all brands and filter by skin tone preferences"""
    all_items = []
    
    print(f"Scraping for skin tone: {skin_tone_category}")
    print(f"Preferred colors: {preferred_colors}")
    
    for brand_name in BRANDS.keys():
        try:
            print(f"Scraping {brand_name}...")
            items = scrape_brand_clothes(brand_name, preferred_colors, max_per_brand)
            all_items.extend(items)
            print(f"Found {len(items)} items from {brand_name}")
        except Exception as e:
            print(f"Error scraping {brand_name}: {e}")
            continue
    
    print(f"Total items scraped: {len(all_items)}")
    return all_items

# ============================================================================
# TESTING
# ============================================================================

if __name__ == "__main__":
    # Test scraping
    test_colors = ["Coral", "Turquoise", "Teal", "Purple"]
    items = scrape_all_brands_by_skin_tone("Fair", test_colors, max_per_brand=5)
    
    print(f"\nScraped {len(items)} items:")
    for item in items[:5]:
        print(f"- {item.get('brand')}: {item.get('title')} ({item.get('color')})")

