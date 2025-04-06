# 🌤 LUCID WEATHER

A clean, intuitive iOS weather application that delivers current forecasts for selected cities and current location. Built with Swift using the OpenWeather API.

<p align="center">
  <img src="https://github.com/user-attachments/assets/8662b060-0ad1-4940-8f05-0793d4ea72e0" width="200" height="400" alt="Forecast Screen">
  <img src="https://github.com/user-attachments/assets/96890839-27db-4ece-806a-62ec34e70067" width="200" height="400" alt="History Screen"> 
  <img src="https://github.com/user-attachments/assets/fdd38a01-cfd0-4228-a161-a08f2398f05d" width="200" height="400" alt="Location Screen">
</p>

## ✨ Features

### 🌍 Current Weather
- Real-time weather data for 4 predefined cities (Rijeka, Zagreb, Split, New York)
- Automatic location detection for current position
- Detailed weather metrics:
  - Temperature (ºC/ºF)
  - Humidity
  - Wind speed
  - Feels like

### 📚 History Tracking
- Persistent storage of past forecasts using CoreData
- View saved weather reports
- Swipe-to-delete functionality
- Timestamped entries

### 🎛 User Interface
- Clean, minimalist design
- Tab-based navigation (Forecast/History)
- Segmented control for temperature unit selection

## 🛠 Technical Implementation

### Architecture
- **MVC** design pattern

### Technologies
| Component       | Technology |
|-----------------|------------|
| Language        | Swift      |
| Persistence     | CoreData   |
| Networking      | URLSession |
| API             | OpenWeather Current Weather Data |
| UI Framework    | UIKit      |

### Key Components
- `UITabBarController` for main navigation
- `UINavigationController` for hierarchical views  
- `UITableView` with custom cells for weather display
- `UISegmentedControl` for temperature unit selection

## 📲 Installation

### Requirements
- iOS 15.0+
- Xcode 13+
- OpenWeather API key

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/ivanlozic/weather-app-ios.git
