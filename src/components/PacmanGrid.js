'use client';

import { useState, useEffect } from 'react';
import styles from './PacmanGrid.module.css';

export default function PacmanGrid() {
  const [contributions, setContributions] = useState([]);
  const [pacmanIndex, setPacmanIndex] = useState(-1);
  const [eaten, setEaten] = useState(new Set());
  const [loading, setLoading] = useState(true);

  // Generate the last 90 days
  const days = [];
  const today = new Date();
  for (let i = 89; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    days.push(d.toISOString().split('T')[0]);
  }

  useEffect(() => {
    async function fetchContributions() {
      try {
        const res = await fetch('/api/contributions');
        if (res.ok) {
          const json = await res.json();
          // map server dates to local set
          const activeDates = new Set(json.data.map(d => d.date));
          setContributions(days.map(d => ({ date: d, active: activeDates.has(d) })));
        } else {
          setContributions(days.map(d => ({ date: d, active: false })));
        }
      } catch (err) {
        console.error(err);
        setContributions(days.map(d => ({ date: d, active: false })));
      } finally {
        setLoading(false);
      }
    }
    fetchContributions();
  }, []);

  // Pacman Animation Loop
  useEffect(() => {
    if (loading || contributions.length === 0) return;

    const interval = setInterval(() => {
      setPacmanIndex(prev => {
        const next = prev + 1;
        if (next >= contributions.length) {
          // Restart loop
          setEaten(new Set());
          return 0;
        }
        
        // If pacman is on an active dot, eat it
        if (contributions[next].active) {
          setEaten(currentEaten => new Set(currentEaten).add(next));
        }
        
        return next;
      });
    }, 150); // Speed of Pacman

    return () => clearInterval(interval);
  }, [loading, contributions]);

  if (loading) {
    return <div className={styles.loading}>Loading Contributions...</div>;
  }

  return (
    <div className={styles.wrapper}>
      <h3 className={styles.title}>Your Carbon Journey (Last 90 Days)</h3>
      <div className={styles.gridContainer}>
        <div className={styles.grid}>
          {contributions.map((day, idx) => {
            const isPacman = idx === pacmanIndex;
            const hasPellet = day.active && !eaten.has(idx);
            const isEaten = day.active && eaten.has(idx);

            // Calculate Pacman rotation based on movement direction
            // Since it goes left to right, wrapping around, we just face right mostly.
            
            return (
              <div 
                key={day.date} 
                className={`${styles.cell} ${hasPellet ? styles.pellet : ''} ${isEaten ? styles.eaten : ''}`}
                title={day.date}
              >
                {isPacman && (
                  <div className={styles.pacman}>
                    <div className={styles.pacmanTop}></div>
                    <div className={styles.pacmanBottom}></div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
