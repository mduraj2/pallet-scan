const express = require('express');
const router = express.Router();

const checkTime = require('../controllers/checkTime');

router.get('/', checkTime);

module.exports = router;
