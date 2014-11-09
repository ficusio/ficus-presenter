function isAmong(value, array) {
  for ( var i = 0; i < array.length; ++i ) {
    if (array[i] === value) { return true; }
  }
  return false;
}

module.exports.ru = function(n) {
  var mod10  = n % 10;
  var mod100 = n % 100;

  if ( mod10 === 1 && n % 100 !== 11 ) { return 'one'; }

  if ( isAmong(mod10, [ 2, 3, 4 ]) &&
    !isAmong(mod100, [ 12, 13, 14 ]) ) { return 'few'; }

  if ( isAmong(mod10, [ 0, 5, 6, 7, 8, 9 ]) ||
    isAmong(mod100, [ 11, 12, 13, 14 ]) ) { return 'many'; }

  return 'other';
};