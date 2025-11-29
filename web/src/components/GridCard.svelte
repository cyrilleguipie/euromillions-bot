<script lang="ts">
  import type { Grid } from '../types';
  
  interface Props {
    grid: Grid;
  }
  
  let { grid }: Props = $props();
  
  function formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      month: 'long', 
      day: 'numeric', 
      year: 'numeric' 
    });
  }
  
  function formatDateTime(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric', 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  }
</script>

<div class="grid-card">
  <div class="grid-header">
    <h3>{formatDate(grid.draw_date)}</h3>
  </div>
  
  <div class="numbers-section">
    <span class="label">Numbers:</span>
    <div class="balls">
      {#each grid.numbers as number}
        <span class="ball ball-number">{number}</span>
      {/each}
    </div>
  </div>
  
  <div class="stars-section">
    <span class="label">Stars:</span>
    <div class="balls">
      {#each grid.stars as star}
        <span class="ball ball-star">⭐ {star}</span>
      {/each}
    </div>
  </div>
  
  {#if grid.created_at}
    <div class="grid-footer">
      <span class="timestamp">Generated: {formatDateTime(grid.created_at)}</span>
    </div>
  {/if}
</div>

<style>
  .grid-card {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    transition: transform 0.2s, box-shadow 0.2s;
    cursor: pointer;
  }
  
  .grid-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  }
  
  .grid-header h3 {
    margin: 0 0 1rem 0;
    color: #1976d2;
    font-size: 1.25rem;
    font-weight: 600;
  }
  
  .numbers-section,
  .stars-section {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
  }
  
  .label {
    font-size: 0.875rem;
    color: #666;
    font-weight: 500;
    min-width: 70px;
  }
  
  .balls {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
  }
  
  .ball {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 32px;
    height: 32px;
    padding: 0 0.5rem;
    border-radius: 50%;
    color: white;
    font-weight: 600;
    font-size: 0.875rem;
  }
  
  .ball-number {
    background: linear-gradient(135deg, #1976d2, #1565c0);
    box-shadow: 0 2px 4px rgba(25, 118, 210, 0.3);
  }
  
  .ball-star {
    background: linear-gradient(135deg, #ff9800, #f57c00);
    box-shadow: 0 2px 4px rgba(255, 152, 0, 0.3);
  }
  
  .grid-footer {
    margin-top: 1rem;
    padding-top: 0.75rem;
    border-top: 1px solid #e0e0e0;
  }
  
  .timestamp {
    font-size: 0.75rem;
    color: #999;
  }
  
  @media (max-width: 640px) {
    .grid-card {
      padding: 1rem;
    }
    
    .numbers-section,
    .stars-section {
      flex-direction: column;
      align-items: flex-start;
    }
  }
</style>
