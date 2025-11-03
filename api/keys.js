// Generate completely random keys
const generateRandomKey = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  const segments = [];
  
  // Generate 4 segments of 4 random characters each
  for (let i = 0; i < 4; i++) {
    let segment = '';
    for (let j = 0; j < 4; j++) {
      segment += chars[Math.floor(Math.random() * chars.length)];
    }
    segments.push(segment);
  }
  
  return segments.join('-');
};

// Generate 15 completely random keys
const validKeys = Array.from({ length: 15 }, () => generateRandomKey());

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'GET') {
    res.status(200).json(validKeys);
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
