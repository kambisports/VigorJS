import EventBus from 'common/EventBus';
import EventKeys from 'common/EventKeys';
import SubscriptionKeys from 'common/SubscriptionKeys';
import ComponentBase from 'component/ComponentBase';
import ComponentView from 'component/ComponentView';
import ComponentViewModel from 'component/ComponentViewModel';
import ProducerManager from 'datacommunication/ProducerManager';
import ProducerMapper from 'datacommunication/ProducerMapper';
import Subscription from 'datacommunication/Subscription';
import validateContract from 'utils/validateContract';
import {settings, setup} from './settings';
import APIService from 'datacommunication/apiservices/APIService';
import IdProducer from 'datacommunication/producers/IdProducer';
import Producer from 'datacommunication/producers/Producer';
import Repository from 'datacommunication/repositories/Repository';
import ServiceRepository from 'datacommunication/repositories/ServiceRepository';

const Vigor = {
	EventBus,
	EventKeys,
	SubscriptionKeys,
	ComponentBase,
	ComponentView,
	ComponentViewModel,
	ProducerManager,
	ProducerMapper,
	Subscription,
	settings,
	setup,
	validateContract,
	APIService,
	IdProducer,
	Producer,
	Repository,
	ServiceRepository
};

export default Vigor;

// In the long run this should be the only export needed, default
// default above is
export {
	EventBus,
	EventKeys,
	SubscriptionKeys,
	ComponentBase,
	ComponentView,
	ComponentViewModel,
	ProducerManager,
	ProducerMapper,
	Subscription,
	settings,
	setup,
	validateContract,
	APIService,
	IdProducer,
	Producer,
	Repository,
	ServiceRepository
}