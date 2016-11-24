import _ from 'underscore';

const EventKeys = {
  ALL_EVENTS: 'all',
  extend: (object) => {
    _.extend(EventKeys, object);
    return EventKeys;
  }
}

export default EventKeys;
