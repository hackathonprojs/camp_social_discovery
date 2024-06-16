// Importing required modules
const express = require('express');
const fs = require('fs');

// Creating an Express application
const app = express();

// Define the route for '/fandata' using HTTP GET method
app.get('/fandata', (req, res) => {
    // Read the JSON file from the server
    fs.readFile('sample_fan_data.json', 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading JSON file:', err);
            res.status(500).send('Error reading JSON file');
            return;
        }

        // Parse the JSON data
        const jsonData = JSON.parse(data);

        // Send the JSON data as the response
        res.json(jsonData);
    });
});

app.use(express.static('web'));

// Start the server on port 3000
const port = 3000;
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
