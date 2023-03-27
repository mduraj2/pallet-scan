const path = require('path');

const filePath = { root: path.dirname(__dirname) };
// const newFilePath = stringURL.join()
console.log(filePath);
const getFile = (req, res) => {
  res.sendFile('./file.json', filePath, () => {
    console.log('Sent');
  });
};

module.exports = getFile;
