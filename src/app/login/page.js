'use client';

import { useEffect, useRef } from 'react';
import { signIn } from 'next-auth/react';
import styles from './page.module.css';

export default function Login() {
  const containerRef = useRef(null);

  // Track mouse movement to create the Stitch AI interactive radial glow
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    let rafId;

    const handleMouseMove = (e) => {
      // Throttle via requestAnimationFrame for 60fps smoothness
      if (rafId) {
        cancelAnimationFrame(rafId);
      }

      rafId = requestAnimationFrame(() => {
        // Calculate coordinates relative to the container
        const rect = container.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        // Apply CSS variables for the radial gradient center
        container.style.setProperty('--mouse-x', `${x}px`);
        container.style.setProperty('--mouse-y', `${y}px`);
      });
    };

    container.addEventListener('mousemove', handleMouseMove);

    return () => {
      container.removeEventListener('mousemove', handleMouseMove);
      if (rafId) cancelAnimationFrame(rafId);
    };
  }, []);

  return (
    <div className={styles.container} ref={containerRef}>
      {/* Background layer for the Antigravity deep mesh floating animation */}
      <div className={styles.ambientBackground}></div>

      {/* Main Glassmorphism Login Card */}
      <div className={styles.loginCard}>
        <div className={styles.logoContainer}>
          <div className={styles.appIcon}></div>
          <h1 className={styles.title}>CarbonSense</h1>
        </div>

        <p className={styles.subtitle}>
          Sign in to access your Digital Twin and start reducing your carbon footprint.
        </p>

        <button 
          className={styles.googleButton}
          onClick={() => signIn('google', { callbackUrl: '/' })}
        >
          <img 
            src="https://authjs.dev/img/providers/google.svg" 
            alt="Google Logo" 
            className={styles.providerIcon} 
          />
          Sign in with Google
        </button>
      </div>
    </div>
  );
}
