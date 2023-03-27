const fs = require('fs');
const path = require('path');

const absolute = path.resolve('file.json');
console.log(absolute);

let lastModifiedDate = fs.stat(absolute, function (err, stats) {
  const mtime =
    new Date(stats.mtimeMs).toLocaleDateString() +
    ' ' +
    new Date(stats.mtimeMs).toLocaleTimeString();
  lastModifiedDate = mtime;

  return lastModifiedDate;
});

const checkTime = (req, res) => {
  // console.log(lastModifiedDate);
  res.status(200).json({ success: true, msg: lastModifiedDate });
  // next();
};
module.exports = checkTime;
