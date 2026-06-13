'use client';

import { useState, useEffect } from 'react';
import styles from './page.module.css';
import PacmanGrid from '@/components/PacmanGrid';

export default function Home() {
  const [twinData, setTwinData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchTwinData() {
      try {
        const res = await fetch('/api/dashboard/digital-twin');
        if (res.ok) {
          const json = await res.json();
          setTwinData(json);
        }
      } catch (err) {
        console.error("Failed to load digital twin data");
      } finally {
        setLoading(false);
      }
    }
    fetchTwinData();
  }, []);

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <div>
          <h1 className={styles.title}>Digital Twin Dashboard</h1>
          <p className={styles.subtitle}>Welcome back! Here's your carbon impact based on your latest routine.</p>
        </div>
      </header>

      {loading ? (
        <div className={styles.loadingState}>Analyzing your routines...</div>
      ) : (
        <>
          <section className={styles.twinSection}>
            <div className={`${styles.twinCard} ${styles.currentTwin}`}>
              <div className={styles.twinHeader}>
                <h2>Current You</h2>
                <span className={styles.badge}>{twinData?.currentTwin?.tonsPerYear || "4.2"} Tons / yr</span>
              </div>
              <div className={styles.avatar}>🙎‍♂️</div>
              <p className={styles.twinDetail}>{twinData?.currentTwin?.summary || "Heavy AC Usage, Daily Cab Commute"}</p>
            </div>
            
            <div className={styles.vsDivider}>VS</div>

            <div className={`${styles.twinCard} ${styles.greenerTwin}`}>
              <div className={styles.twinHeader}>
                <h2>Greener You</h2>
                <span className={`${styles.badge} ${styles.greenBadge}`}>{twinData?.greenerTwin?.tonsPerYear || "2.8"} Tons / yr</span>
              </div>
              <div className={styles.avatar}>🦸‍♂️🍃</div>
              <p className={styles.twinDetail}>{twinData?.greenerTwin?.summary || "Optimized Cooling, Metro Commute"}</p>
            </div>
          </section>

          <section className={styles.simulations}>
            <h3>AI Simulations (What if?)</h3>
            {(twinData?.simulations || [
              { title: "Replace AC with Energy Efficient Model", description: "Current: 1.2 tons/year ➔ Alternative: 0.9 tons/year", badge: "25% Savings" },
              { title: "Work from home 2 days/week", description: "Emission reduction: 180 kg/year", badge: "High Impact" }
            ]).map((sim, idx) => (
              <div key={idx} className={styles.simCard}>
                <div className={styles.simInfo}>
                  <h4>{sim.title}</h4>
                  <p>{sim.description}</p>
                </div>
                <div className={styles.simAction}>
                  <span className={styles.savings}>{sim.badge}</span>
                  <button className={styles.simButton}>Simulate</button>
                </div>
              </div>
            ))}
          </section>
        </>
      )}

      <section>
        <PacmanGrid />
      </section>
    </div>
  );
}
