<script lang="ts">
  import type { Grid } from '../types';
  
  interface Props {
    grid: Grid;
    onClose: () => void;
  }
  
  let { grid, onClose }: Props = $props();
  
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
      year: 'numeric',
      hour: '2-digit', 
      minute: '2-digit' 
    });
  }
</script>

<div class="modal-overlay" onclick={onClose} role="button" tabindex="0">
  <div class="modal-content" onclick={(e) => e.stopPropagation()} role="dialog">
    <button class="close-btn" onclick={onClose} aria-label="Close">×</button>
    
    <div class="modal-header">
      <h3>Grid for</h3>
      <h2>{formatDate(grid.draw_date)}</h2>
    </div>
    
    <div class="detail-section">
      <h4>Numbers</h4>
      <div class="large-balls">
        {#each grid.numbers as number}
          <div class="large-ball large-ball-number">
            {number}
          </div>
        {/each}
      </div>
    </div>
    
    <div class="divider"></div>
    
    <div class="detail-section">
      <h4>Lucky Stars</h4>
      <div class="large-balls">
        {#each grid.stars as star}
          <div class="large-ball large-ball-star">
            ⭐<br />{star}
          </div>
        {/each}
      </div>
    </div>
    
    {#if grid.created_at}
      <div class="modal-footer">
        <div class="divider"></div>
        <p class="generated-info">Generated on</p>
        <p class="generated-date">{formatDateTime(grid.created_at)}</p>
      </div>
    {/if}
  </div>
</div>

<style>
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 1rem;
    animation: fadeIn 0.2s ease-out;
  }
  
  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }
  
  .modal-content {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    max-width: 600px;
    width: 100%;
    max-height: 90vh;
    overflow-y: auto;
    position: relative;
    animation: slideUp 0.3s ease-out;
  }
  
  @keyframes slideUp {
    from {
      transform: translateY(20px);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
  
  .close-btn {
    position: absolute;
    top: 1rem;
    right: 1rem;
    background: none;
    border: none;
    font-size: 2rem;
    color: #666;
    cursor: pointer;
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    transition: background-color 0.2s, color 0.2s;
  }
  
  .close-btn:hover {
    background-color: #f0f0f0;
    color: #333;
  }
  
  .modal-header {
    text-align: center;
    margin-bottom: 2rem;
  }
  
  .modal-header h3 {
    margin: 0;
    color: #666;
    font-size: 1.125rem;
    font-weight: 500;
  }
  
  .modal-header h2 {
    margin: 0.5rem 0 0 0;
    color: #1976d2;
    font-size: 1.875rem;
    font-weight: 700;
  }
  
  .detail-section {
    margin-bottom: 2rem;
  }
  
  .detail-section h4 {
    text-align: center;
    color: #666;
    font-size: 1rem;
    font-weight: 600;
    margin: 0 0 1rem 0;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  
  .large-balls {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
  }
  
  .large-ball {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.5rem;
    font-weight: 700;
    text-align: center;
    line-height: 1.2;
  }
  
  .large-ball-number {
    background: linear-gradient(135deg, #1976d2, #1565c0);
    box-shadow: 0 4px 12px rgba(25, 118, 210, 0.4);
  }
  
  .large-ball-star {
    background: linear-gradient(135deg, #ff9800, #f57c00);
    box-shadow: 0 4px 12px rgba(255, 152, 0, 0.4);
    font-size: 1rem;
  }
  
  .divider {
    height: 1px;
    background: linear-gradient(to right, transparent, #e0e0e0, transparent);
    margin: 2rem 0;
  }
  
  .modal-footer {
    margin-top: 2rem;
    text-align: center;
  }
  
  .generated-info {
    margin: 1rem 0 0.25rem 0;
    color: #999;
    font-size: 0.875rem;
  }
  
  .generated-date {
    margin: 0;
    color: #666;
    font-size: 0.9375rem;
  }
  
  @media (max-width: 640px) {
    .modal-content {
      padding: 1.5rem;
    }
    
    .large-ball {
      width: 50px;
      height: 50px;
      font-size: 1.25rem;
    }
    
    .modal-header h2 {
      font-size: 1.5rem;
    }
  }
</style>
