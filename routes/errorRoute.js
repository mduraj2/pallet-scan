const express = require('express');
const router = express.Router();

const errorRoute = require('../controllers/errorRoute');

router.get('/', errorRoute);

module.exports = router;
