# Uerani

Uerani in "purepecha" means "going out of town". With uerani you will be able to create list of venue locations from the Foursquare API and optionally grab a fare from the Uber API from your location to the venue location, this will help you to save a list of locations where you like to go and easily get there with the help of Uber.

One of the challenges that this application present is the Foursquare API limitations, the API only allow you to do a limited amount of calls each end point, to get around this the application request the Foursquare Data and creates a cache Database using realm.io, by doing a more extensive use of NSOperaions make application feel faster. This cache is cleaned each 7 days.

As displaying all the Foursquare locations could end up in a bad performance due to the number of locations to display the application solves this by using the library FBAnnotationClustering to cluster the annotations on a given area.

To use the application your Foursquare credentials are required, the app is doing OAuth2 authentication either natively with the help of the Foursquare Application or going by using Safari to go to the Foursquare site.

![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/ConnectToFoursquare.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/MapView.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/CustomCallout.png)
![alt tag](https://raw.github.com/nmorenor/uerani/master/uerani/CategoryFilter.png)

## TODO

- User view to display user information, adding the ability to connect the Uber API and provide a way to logout from the application.
- Remember user venue selection.
- Display venue information.
- Display venue list to the user.

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