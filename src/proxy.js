import nextAuthMiddleware from "next-auth/middleware";

export default function proxy(req, evt) {
  return nextAuthMiddleware(req, evt);
}

// Protect all routes except the auth API and static assets
export const config = {
  matcher: ["/((?!api/auth|_next/static|_next/image|favicon.ico|login).*)"]
};
