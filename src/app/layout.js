export const metadata = {
  title: "CarbonTwin API",
  description: "Backend API server for CarbonTwin Flutter app",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
