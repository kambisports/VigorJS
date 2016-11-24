import _ from 'underscore';

const settings = {
	shouldValidateContract: false
}

function setup (newSettings) {
  _.extend(settings, newSettings);
}

export {
	settings,
	setup
}