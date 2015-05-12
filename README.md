# Vigorjs

## Introduction
As applications grows they become harder and harder to maintain, Vigorjs is a small library built ontop of Backbone to address this issue. 

The main goal of Vigorjs is to keep the application modular and separate gui components, data handling, and api communication.


## Concept
By introducing the concepts of ***Components***, ***Producers***, ***Repositories***, ***Services*** and an ***EventBus*** we want to clarify and simplify the responsibilities and actions of each layer within a large scale Backbone application.

A simplified description of the responsibilities fore each concept is as follows: 


### Components
[ComponentBase.coffee](./docs/ComponentBase.html)
[ComponentView.coffee](./docs/ComponentView.html)
[ComponentViewModel.coffee](./docs/ComponentViewModel.html)

- A ***Component*** is the gui component presented to the end user in the form of a package containing one or multiple views, view-models, collections etc. 

- A ***Component***  should be as simple, and easy to reuse. Main focus should be on rendering, handle user interaction etc. 

- A ***Component*** should be served with data tailored for its needs.

- A ***Component*** subscribes to a ***Producer*** using a ***SubscriptionKey***

- A ***Component*** should be able to live by them selves and be created anywhere within the application (avoid dependencies to other components)



###Producers
[Producer.coffee](./docs/Producer.html)
[IdProducer.coffee](./docs/IdProducer.html)
[SubscriptionKeys.coffee](./docs/SubscriptionKeys.html)

- A ***Producer*** is the link between a ***Component*** and a ***Repository***

- A ***Producer*** is responsible for gathering data and tailor it for one or multiple ***Components*** from one or multiple ***Repositories***

- A ***Producer*** produces data on only one ***SubscriptionKey*** (each producer only does one thing)

- A ***Producers*** produce new data on its ***SubscriptionKey*** everytime any relevant data changes. 

- A ***Producer***  subscribes to one or more ***Repositories*** to be notified when data changes and then produces new data.

- A ***Producer*** subscribes to one or more ***Repositories*** to show interest in new data (start services)

- A ***Producer*** produces data that matches the format stated by the contract in the ***SubscriptionKey***

- A ***Producer*** produces data in JSON format



###Repositories
[Repository.coffee](./docs/Repository.html)
[ServiceRepository.coffee](./docs/ServiceRepository.html)

- A ***Repository*** is the link between a ***Producer*** and a ***Service***

- A ***Repository*** is responsible for storing data of a specific type

- A ***Repository*** is responsible for triggering events whenever the stored data changes

- A ***Repository*** is responsible providing data to one or multiple ***Producers***



###Services
[APIService.coffee](./docs/APIService.html)

- A ***Service*** is the link between one or multiple ***Repositories*** and an external API

- A ***Service*** requests data from an external API

- A ***Service*** is responsible for handling polling of data

- A ***Service*** should provide one or multiple ***Repositories*** with data by triggering events



###EventBus
[EventBus.coffee](./docs/EventBus.html)
[EventKeys.coffee](./docs/EventKeys.html)

- The ***EventBus*** is the communication link between components and other parts of a application

- By using ***EventKeys*** a component can send messages through the ***EventBus***

- By using ***EventKeys*** a component can subscribe to messages from the ***EventBus***


## Dependencies
[jQuery](http://jquery.com/)
[Backbone](http://backbonejs.org/)
[Underscore](http://underscorejs.org/)

- ***Vigorjs*** is dependent on ***jQuery***, ***Backbone*** and ***Underscore***

- ***Vigorjs*** source files are written in Coffeescript



## Code documentation



## Hello World

## Best practises 
(TODO: Create better examples showing how to use the library)