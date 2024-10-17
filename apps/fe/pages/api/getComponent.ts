// fe/pages/api/getComponent.ts
export default function handler(req:any, res:any) {

    res.setHeader('Access-Control-Allow-Origin', '*'); // Allow all origins for CORS
    res.setHeader('Access-Control-Allow-Methods', 'GET'); // Allow GET requests
    // Here you can send the code or component details as needed
    res.json({ componentName: 'page' }); // Just an example
  }
  