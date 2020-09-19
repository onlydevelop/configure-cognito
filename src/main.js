'use strict';

exports.handler = (event, context, callback) => {
  const currentTime = new Date();
  const data = { msg: 'hello world', date: currentTime };
  callback(null, data);
};
