import '../node_modules/core-js/es6';
import '../node_modules/core-js/es7/reflect';
require('../node_modules/zone.js/dist/zone');

if (process.env.ENV === 'production') {
  // enableProdMode();
} else {
  // Development
  Error['stackTraceLimit'] = Infinity;
  require('zone.js/dist/long-stack-trace-zone');
}
