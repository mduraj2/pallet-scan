const errorRoute = (req, res) => {
  console.log('wrong url');
  res.send('<h4>Wrong url entered</h4>');
};

module.exports = errorRoute;
