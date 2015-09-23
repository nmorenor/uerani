# Uerani

Uerani in "purepecha" means "going out of town". With uerani you will be able to create list of venue locations from the Foursquare API and optionally grab a fare from the Uber API from your location to the venue location, this will help you to save a list of locations where you like to go and easily get there with the help of Uber.

Once you logged in to Uerani with your Foursquare credentials the application will ask your permission to get your location while the app is running, once it has the location it will zoom to an appropiate scale to show you the venues near your location. When the user touches the Venue annotation on the map it will show a callout annotation that will display the basic information of the venue and an info accessory that can be used to navigate to the venue location details. Inside the map View there is a search bar that can be used to filter the venues displayed on the map by category.

Inside the Venue Details View the app will run an operation on the background to get the complete details of the venue, it will show and image and the map location of the venue with all its details, if the user has Connected the application to Uber an Uber button will be shown in the view that can be used to get the fare to go from your location to the venue. There will be a + action on the navigation bar that allow you to add the current venue to a list.

The List View Show the number of lists you have created, and by touching in a list row will get the user to a list where you can see all the venues that have been added to the list and alternatively view the details of each venue, in "Your Lists" view there will be a + button where the user can create a new list of venues.

Finally the User View display the Foursquare image of the user a switch to enable or disable Uber usage for the application and a logout button.

One of the challenges that this application present is the Foursquare API limitations, the API only allow you to do a limited amount of calls each end point, to get around this the application request the Foursquare Data and creates a cache Database using realm.io, by doing a more extensive use of NSOperaions make application feel faster. This cache is cleaned each 7 days.

As displaying all the Foursquare locations could end up in a bad performance due to the number of locations to display the application solves this by using the library FBAnnotationClustering to cluster the annotations on a given area.

To use the application your Foursquare credentials are required, the app is doing OAuth2 authentication either natively with the help of the Foursquare Application or going by using Safari to go to the Foursquare site.

![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/ConnectToFoursquare.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/MapView.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/CustomCallout.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/CategoryFilter.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/VenueDetailsView.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/ListsView.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/VenuesOfListView.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/UserView.png)

## TODO

- Use Reactive Cocoa
- More Unit Tests
- Better App Icon

## License

The MIT License (MIT)

Copyright (c) 2015 Ignacio Moreno

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.