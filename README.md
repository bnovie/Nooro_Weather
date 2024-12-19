### **iOS Take-Home Test: Weather Tracker**

### **Objective**

Build a weather app that demonstrates your skills in **Swift**, **SwiftUI**, and **clean architecture**. The app should allow users to search for a city, display its weather on the home screen, and persist the selected city across launches. Follow the **Figma designs** closely and integrate data from **WeatherAPI.com**.

This work does not include test cases. 

This work borrow a bit from VIP architecture, except the the ViewModel acts as the presenter and has interactor logic. Both are done in protocols.

I included some work for dark mode and for dynamic type. I restricted the phone to portrait mode.

Searching gets a list of locations and uses that to make a 2nd call to get the current weather to display icon and temp.I also show eith country or region so user can distinguish between locations with same city name.  When location tapped it shows full weather for the location.

There is more work to be done like unit tests and dependacy injection. The weather service can be broken up into protocol and then use dependency injection.



