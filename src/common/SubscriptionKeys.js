import _ from 'underscore';
const SubscriptionKeys = {
  extend: (object) => {
    _.extend(SubscriptionKeys, object);
    return SubscriptionKeys;
  }
}

export default SubscriptionKeys;
