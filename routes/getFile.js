const express = require('express');
const router = express.Router();

const getFile = require('../controllers/getFile');

router.get('/', getFile);

module.exports = router;
