const validKeys = [
  "KEY-7A3B9C2D4E5F6G8H",
  "KEY-9J8K7L6M5N4P3Q2R",
  "KEY-2S3T4U5V6W7X8Y9Z",
  "KEY-5A6B7C8D9E0F1G2H",
  "KEY-3I4J5K6L7M8N9O0P"
];

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'GET') {
    res.status(200).json(validKeys);
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
