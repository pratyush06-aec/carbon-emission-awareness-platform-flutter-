export default function Home() {
  return (
    <div style={{ padding: '40px', fontFamily: 'system-ui', textAlign: 'center' }}>
      <h1>🌱 CarbonTwin API Server</h1>
      <p>This is the backend API for the CarbonTwin Flutter app.</p>
      <p style={{ color: '#888', marginTop: '16px' }}>
        Available endpoints: /api/auth/login, /api/auth/register, /api/dashboard, 
        /api/profile, /api/achievements, /api/carbontwin, /api/ocr, 
        /api/challenges/reward, /api/redeem, /api/wallet
      </p>
    </div>
  );
}
