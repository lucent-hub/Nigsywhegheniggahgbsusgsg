export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'GET') {
    res.status(200).json({ status: 'online', timestamp: new Date(), keyCount: 5 });
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
