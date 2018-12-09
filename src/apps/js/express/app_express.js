// app.js
const express = require('express')

// Create Express app
const app = express()

// A sample route
app.get('/', (req, res) => res.send('Hello, World!'))
app.get('/healhz', (req, res) => res.send('OK'))

// Start the Express server
app.listen(8000, () => console.log('Server running on port 8000!'))  