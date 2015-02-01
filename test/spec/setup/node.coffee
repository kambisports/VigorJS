requireHelper = require './requireHelper'

global.$ = global.jQuery = require 'jquery'
global._ = require 'underscore'
global.Backbone = require 'backbone'
global.Backbone.$ = global.$
global.Vigor = {}

  # COMMON
requireHelper 'common/EventBus'
requireHelper 'common/ComponentView'
requireHelper 'common/PackageBase'
requireHelper 'common/ViewModel'

  # DATACOMMUNICATION/PRODUCERS
requireHelper 'datacommunication/producers/Producer'
requireHelper 'datacommunication/producers/ProducerMapper'
requireHelper 'datacommunication/producers/ProducerManager'

  # DATACOMMUNICATION/APISERVICES
requireHelper 'datacommunication/apiservices/ApiService'

  # DATACOMMUNICATION
requireHelper 'datacommunication/SubscriptionKeys'
requireHelper 'datacommunication/EventKeys'
requireHelper 'datacommunication/ComponentIdentifier'
requireHelper 'datacommunication/DataCommunicationManager'

  # REPOSITORIES
requireHelper 'datacommunication/repositories/Repository'
requireHelper 'datacommunication/repositories/ServiceRepository'