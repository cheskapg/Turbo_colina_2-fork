// Exporting the default Page component
export { default as Page } from "./page"; 

// Importing required modules
const http = require('http');
const fs = require('fs'); // If you want to serve static files

const server = http.createServer((req:any, res:any) => {
    res.setHeader('Access-Control-Allow-Origin', 'http://localhost:3001'); // Allow requests from the web app
    res.setHeader('Access-Control-Allow-Methods', 'GET,HEAD,PUT,PATCH,POST,DELETE');
    res.setHeader('Access-Control-Allow-Credentials', true);
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type'); // Allow specific headers if needed

    // Serve your static files or content here
    if (req.method === 'GET') {
        // Example: Serve an HTML file
        fs.readFile('./path/to/your/index.html', 'utf8', (err:any, data:any) => {
            if (err) {
                res.writeHead(500, {'Content-Type': 'text/plain'});
                res.end('Internal Server Error');
                return;
            }
            res.writeHead(200, {'Content-Type': 'text/html'});
            res.end(data); // Send the HTML content
        });
    } else {
        res.writeHead(405, {'Content-Type': 'text/plain'});
        res.end('Method Not Allowed'); // Respond with a 405 for other methods
    }
});

server.listen(3000, () => {
    console.log('Server running on http://localhost:3000/');
});
