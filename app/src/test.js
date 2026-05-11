const http = require('http');

const options = {
  hostname: 'localhost',
  port: process.env.PORT || 3000,
  path: '/health',
  method: 'GET',
  timeout: 5000
};

console.log('Running health check test...');

const req = http.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => data += chunk);
  res.on('end', () => {
    if (res.statusCode === 200) {
      const body = JSON.parse(data);
      if (body.status === 'healthy') {
        console.log('✓ Health check passed:', body);
        process.exit(0);
      }
    }
    console.error('✗ Health check failed. Status:', res.statusCode);
    process.exit(1);
  });
});

req.on('error', (err) => {
  console.error('✗ Test failed - could not connect:', err.message);
  process.exit(1);
});

req.on('timeout', () => {
  console.error('✗ Test timed out');
  req.destroy();
  process.exit(1);
});

req.end();
