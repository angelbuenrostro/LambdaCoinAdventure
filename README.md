# LambdaCoinAdventure
An iOS application to traverse a maze and mine a blockchain coin

Watch a short video demonstration where I speak about how I built this application here: https://youtu.be/c_ZMKQ8PInw?t=675

![](AnimaxFeatCleanShot 2019-10-09 at 16.45.06.gifureDemo.gif)

# Application Features

Directional Controls (Makes an API movement request when pressed)

Special Abilities (Makes appropriate API request based on button pressed: Pickup Treasure, Sell Treasure, etc)

Map Persistence (Saves room coordinates as an array of Coordinate objects that are transformed into NSData then decoded and loaded for subsequent application launches)

Location, Status Updates (JSON responses provide room information on movement and player status can be retrieved also through a press of the STATUS button)
