define(function () {

	'use strict';


	var responseFlattener = {

	},

	indexNamesArray, uniqueId, stashedArray, ModelClass, flattenMethod,
	customIdValue;




	responseFlattener.flatten = function (origArray, flattenSpecs) {

		var
			isBreadthFirst,
			startLevel = flattenSpecs.startLevel || 0,
			rootParentId = flattenSpecs.rootParentId || 1;

		customIdValue = 0;
		indexNamesArray = getindexNamesArray(flattenSpecs.indexName);
		uniqueId = flattenSpecs.uniqueIdentifier || responseFlattener.DEFAULT_INDEX_STRING;
		ModelClass = flattenSpecs.ModelClass || undefined;
		flattenMethod = flattenSpecs.flattenMethod;
		isBreadthFirst = (flattenMethod === responseFlattener.METHOD_BREADTH_FIRST);
		stashedArray = [];

		if (isBreadthFirst) {
			return flattenBreadthFirst(origArray, startLevel, rootParentId);
		} else {
			return flattenDepthFirst(origArray, startLevel, rootParentId);
		}
	};


	Object.defineProperty(responseFlattener, 'METHOD_DEPTH_FIRST', {
			value: 'depth-first',
			writeable: false,
			configurable: false,
			enumerable:	true
		});

	Object.defineProperty(responseFlattener, 'METHOD_BREADTH_FIRST', {
			value: 'breadth-first',
			writeable: false,
			configurable: false,
			enumerable: true
		});

	Object.defineProperty(responseFlattener, 'CUSTOM_ID_PREFIX', {
			value: 'rf-custId-',
			writeable: false,
			configurable: false,
			enumerable: true
		});

	Object.defineProperty(responseFlattener, 'DEFAULT_INDEX_STRING', {
			value: 'groups',
			writeable: false,
			configurable: false,
			enumerable: true
		});

	Object.defineProperty(responseFlattener, 'DEFAULT_ID_STRING', {
			value: 'id',
			writeable: false,
			configurable: false,
			enumerable: true
		});





	function getindexNamesArray(indexStrArg) {

		var indexStr = indexStrArg || responseFlattener.DEFAULT_INDEX_STRING,
			indexArray = indexStr.split(',');
		return indexArray;
	}





	function flattenDepthFirst(array, level, parentId) {


		var i = 0,
			currentLevel = level || 0,
			flattenedArray = [],
			currentId, childrenArray, node,
			flattenedNode, flattenedChildren,
			hasChildren = false;


		for (; i < array.length; i++) {

			node = array[i];
			currentId = getUniqueIdFor(node);
			hasChildren = childrenExistIn(node);

			if (hasChildren) {
				childrenArray = getChildrenFrom(node);
				deleteChildrenFrom(node);
			}

			flattenedNode = flattenNode(node, currentLevel, parentId);
			flattenedArray.push(flattenedNode);

			if (hasChildren) {
				flattenedChildren = flattenDepthFirst(childrenArray, currentLevel + 1, currentId);
				flattenedArray = flattenedArray.concat(flattenedChildren);
			}

		}

		return flattenedArray;
	}





	function getUniqueIdFor(node) {

		var uniqueIdValue = node[uniqueId];

		if (uniqueIdValue === undefined || uniqueIdValue === null) {
			uniqueIdValue = responseFlattener.CUSTOM_ID_PREFIX + customIdValue;
			node[uniqueId] = uniqueIdValue;
			customIdValue++;
		}

		return uniqueIdValue;
	}





	function flattenBreadthFirst(array, level, parentId) {

		var currentLevel = level || 0,
			index = 0,
			node,
			flattenedNode,
			childrenArray,
			flattenedArray = [],
			currentId,
			flattenedChildren;

		for (; index < array.length; index++) {

			node = array[index];
			currentId = getUniqueIdFor(node);

			if (childrenExistIn(node)) {

				childrenArray = getChildrenFrom(node);
				stash(childrenArray, currentId, currentLevel + 1);
				deleteChildrenFrom(node);

			}

			flattenedNode = flattenNode(node, currentLevel, parentId);
			flattenedArray.push(flattenedNode);
		}

		if (currentLevel === 0) {
			flattenedChildren = getStashedAllFlattened();
			flattenedArray = flattenedArray.concat(flattenedChildren);
		}

		return flattenedArray;
	}





	function stash(array, parentId, level) {

		var stashedArrayObj = {
			array: array,
			parentId: parentId,
			level: level
		};

		stashedArray.push(stashedArrayObj);
	}





	function getStashedAllFlattened() {

		var stashed,
			flattenedStashedArray,
			all = [];

		while (stashedArray.length > 0) {
			stashed = stashedArray.shift();
			flattenedStashedArray = flattenBreadthFirst(stashed.array, stashed.level, stashed.parentId);
			all = all.concat(flattenedStashedArray);
		}

		return all;
	}





	function flattenNode(node, currentLevel, parentId) {

		var flattenedNode = node;

		flattenedNode.level = currentLevel;

		if (parentId) {
			flattenedNode.parentId = parentId;
		}
		// else {
		// 	console.log('node: ', node)
		// 	flattenedNode.parentId = 1;
		// }

		if (ModelClass) {
			node = new ModelClass(node);
		}

		return node;

	}




	function deleteChildrenFrom(node) {

		var i = 0, indexName,
			indexNodeExists = false;

		for (; i < indexNamesArray.length; i++) {

			indexName = indexNamesArray[i];
			indexNodeExists = (node[indexName] || false);

			if (indexNodeExists) {
				delete node[indexName];
			}
		}
	}





	function childrenExistIn(node) {
		var i = 0, indexName,
			childrenExist = false;

		for (; i < indexNamesArray.length; i++) {
			indexName = indexNamesArray[i];
			childrenExist = (node[indexName] && node[indexName].length > 0) || false;
			if (childrenExist) {
				break;
			}
		}

		return childrenExist;
	}





	function getChildrenFrom(node) {
		var i = 0, indexName,
			children = [],
			childrenExistAtIndex = false;

		for (; i < indexNamesArray.length; i++) {
			indexName = indexNamesArray[i];
			childrenExistAtIndex = node[indexName] && node[indexName].length > 0;

			if (childrenExistAtIndex) {
				children = children.concat(node[indexName]);
			}
		}

		return children;
	}



	return responseFlattener;


});
