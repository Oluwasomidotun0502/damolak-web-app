const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    app: 'Damolak Web App',
    version: process.env.APP_VERSION || '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Damolak Technologies</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Segoe UI',sans-serif;background:#0a0f1e;color:#fff;
min-height:100vh;display:flex;align-items:center;justify-content:center;}
.container{text-align:center;padding:2rem;max-width:700px;}
.badge{background:#1a2a4a;border:1px solid #2a4a8a;color:#4a9eff;
padding:.4rem 1rem;border-radius:20px;font-size:.85rem;
text-transform:uppercase;display:inline-block;margin-bottom:1.5rem;}
h1{font-size:3rem;font-weight:700;margin-bottom:1rem;color:#4a9eff;}
p{color:#8a9bb5;font-size:1.1rem;line-height:1.7;margin-bottom:2rem;}
.status{display:flex;align-items:center;justify-content:center;gap:.5rem;
background:#0d1f0d;border:1px solid #1a4a1a;padding:.6rem 1.4rem;
border-radius:8px;color:#4aff7a;margin-bottom:2rem;}
.dot{width:8px;height:8px;background:#4aff7a;border-radius:50%;}
.footer{margin-top:3rem;color:#3a4a5a;font-size:.8rem;}
a{color:#4a9eff;text-decoration:none;}
</style>
</head>
<body>
<div class="container">
  <div class="badge">Production Deployment</div>
  <h1>Damolak Technologies</h1>
  <p>Deployed on AWS using a fully automated DevOps pipeline -
  containerized with Docker, provisioned with Terraform,
  and delivered via Jenkins CI/CD.</p>
  <div class="status">
    <div class="dot"></div>
    All systems operational
  </div>
  <div class="footer">
    Version ${process.env.APP_VERSION || '1.0.0'} &nbsp;|&nbsp;
    <a href="/health">Health Check</a>
  </div>
</div>
</body>
</html>
  `);
});

app.listen(PORT, () => {
  console.log(`Damolak Web App running on port ${PORT}`);
});

module.exports = app;
