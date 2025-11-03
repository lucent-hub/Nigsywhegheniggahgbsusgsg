import validKeys from './keys.js'; // optional, or copy array

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'GET') {
    res.status(200).json({ count: 5 });
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
