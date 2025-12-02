# Skin Tone Analysis API

Flask API for analyzing skin tone, hair color, eye color, and providing fashion color recommendations.

## Features

- 🎨 Skin tone classification (6 categories from Very Fair to Black)
- 👁️ Eye color detection
- 💇 Hair color detection
- 🌡️ Undertone analysis (Warm/Cool/Neutral)
- 👔 Personalized fashion color recommendations

## Installation

### Local Development

```bash
cd api
pip install -r requirements.txt
python app.py
```

The API will run on `http://localhost:5000`

### Test the API

```bash
curl -X POST -F "image=@test_image.jpg" http://localhost:5000/analyze
```

## API Endpoints

### GET /
Service information

### GET /health
Health check endpoint

### POST /analyze
Upload an image for analysis

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: `image` file (JPEG/PNG)

**Response:**
```json
{
  "success": true,
  "skin_tone": {
    "category": "Medium",
    "fitzpatrick_type": "Type IV",
    "rgb": {"r": 200, "g": 151, "b": 123},
    "hex": "#C8977B",
    "brightness": 162.46,
    "undertone": "Warm"
  },
  "hair_color": "Dark Brown",
  "eye_color": "Brown",
  "color_recommendations": {
    "best_colors": ["Jewel Tones", "Teal", "Purple", ...],
    "avoid_colors": ["Pale Pastels", ...],
    "neutrals": ["Charcoal", "Camel", ...],
    "description": "Rich, vibrant colors enhance your warm undertones."
  }
}
```

## Deployment

See deployment guides in `/api/deployment/` folder.

