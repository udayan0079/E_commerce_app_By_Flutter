# CraftyBay E-Commerce Flutter App

A Flutter e-commerce mobile and web application built with clean modular architecture, live REST API integration, authentication (Sign Up, OTP verification, Sign In), product catalog, cart, wishlist, and customer reviews.

## Project Structure

```
lib/
├── app/            # App theme, colors, constants, env loader, and API endpoints
├── data/           # Models and services (Auth, Cart, Wishlist, NetworkCaller)
└── presentation/   # Screens (Splash, Auth, Home, Categories, Product, Cart, Wishlist) and shared widgets
```

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/udayan0079/E_commerce_app_By_Flutter.git
   cd E_commerce_app_By_Flutter
   ```

2. **Configure environment variables:**
   Copy `.env.example` to `.env` in the project root and set your backend `API_BASE_URL`:
   ```bash
   cp .env.example .env
   ```

3. **Install dependencies and run:**
   ```bash
   flutter pub get
   flutter run
   ```
