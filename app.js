const express = require('express');
const app = express();

const getFile = require('./routes/getFile');
const checkTime = require('./routes/checkTime');
const errorRoute = require('./routes/errorRoute');

app.use('/', express.static('./public'));
//routes
app.use('/fileDB', getFile);
app.use('/checkTime', checkTime);
app.use('*', errorRoute);

const port = 3000;

app.listen(port, console.log(`server is listening on port ${port}...`));
