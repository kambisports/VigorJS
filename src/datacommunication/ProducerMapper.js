// Array of currently registered producers
const producers = [];

// Table look-up of subscription key to mapped producer
let producersByKey = {};

// Error thrown when no producers at all have been registered and component starts a subscription
const NO_PRODUCERS_ERROR = "There are no producers registered - register producers through the ProducerManager";

// Error thrown when a component tries to register a subscription and no producer has been registered for that subscription
const NO_PRODUCER_FOUND_ERROR = key => `No producer found for subscription ${key}!`;

// Error thrown when a component tries to register a subscription to a producer has already been registered for that subscription
const KEY_ALREADY_REGISTERED = key => `A producer for the key ${key} is already registered`;

// ##ProducerMapper
// Mapper class to keep track of the available producers and their corresponding subscriptions
const ProducerMapper = {

  producers,
  // **producerClassForKey:** </br>
  // @param [subscriptionKey]: String <br/>
  // @returns [producerClass]: Class </br>
  // @throws [NO_PRODUCERS_ERROR], [NO_PRODUCER_FOUND_ERROR] </br>
  //
  // Returns the corresponding producer class for the given [subscriptionKey]
  producerClassForKey(subscriptionKey) {
    const { key } = subscriptionKey;
    if (producers.length === 0) {
      throw NO_PRODUCERS_ERROR;
    }

    const producerClass = producersByKey[key];

    if (!producerClass) {
      throw NO_PRODUCER_FOUND_ERROR(key);
    }

    return producerClass;
  },

  // **producerForKey:** </br>
  // @param [subscriptionKey]: String <br/>
  // @returns [producerClass]: Producer </br>
  //
  // Returns the instance of the producer mapper to the [subscriptionKey]
  producerForKey(subscriptionKey) {
    const producerClass = this.producerClassForKey(subscriptionKey);
    return producerClass.prototype.getInstance();
  },

  // **register:** </br>
  // @param [producerClass]: Class <br/>
  // @throws [KEY_ALREADY_REGISTERED] </br>
  //
  // Registers a new producer type [producerClass] in the mapper
  register(producerClass) {
    if (producers.indexOf(producerClass) === -1) {
      producers.push(producerClass);
      const subscriptionKey = producerClass.prototype.PRODUCTION_KEY;
      const { key } = subscriptionKey;

      if (producersByKey[key]) {
        throw KEY_ALREADY_REGISTERED(key);
      }

      return producersByKey[key] = producerClass;
    }
  },

  // **reset:** </br>
  //
  // Used in unit tests to reset the mapper
  reset() {
    producers.length = 0;
    return producersByKey = {};
  }
};

export default ProducerMapper;
