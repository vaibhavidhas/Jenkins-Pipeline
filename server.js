const express = require('express');
const app = express();

// GET endpoint
app.get('/', (req, res) => {
  res.send('Hello World');
});

// Server listening on port 3000
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
