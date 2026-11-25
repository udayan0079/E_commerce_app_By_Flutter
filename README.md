# CraftyBay E-Commerce Flutter App

A Flutter e-commerce mobile and web application built with clean modular architecture, live REST API integration, authentication (Sign Up, OTP verification, Sign In), product catalog, cart, wishlist, and customer reviews.

## Project Structure

```
lib/
├── app/            # App theme, colors, constants, env config, and API endpoints
├── data/           # Models and services (Auth, Cart, Wishlist, NetworkCaller)
└── presentation/   # Screens (Splash, Auth, Home, Categories, Product, Cart, Wishlist) and shared widgets
```

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/udayan0079/E_commerce_app_By_Flutter.git
   cd E_commerce_app_By_Flutter
   ```

2. **Install dependencies and run:**
   ```bash
   flutter pub get
   flutter run
   ```

*(Optional)* To pass custom `.env` overrides locally:
```bash
flutter run --dart-define-from-file=.env
```
