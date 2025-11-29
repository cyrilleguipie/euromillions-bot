<script lang="ts">
  import { onMount } from 'svelte';
  import { api } from './api';
  import type { Grid } from './types';
  import GridCard from './components/GridCard.svelte';
  import GridModal from './components/GridModal.svelte';
  
  let grids = $state<Grid[]>([]);
  let selectedGrid = $state<Grid | null>(null);
  let isLoading = $state(false);
  let isGenerating = $state(false);
  let isFetchingHistory = $state(false);
  let errorMessage = $state<string | null>(null);
  let successMessage = $state<string | null>(null);
  let showHistory = $state(false);
  
  onMount(() => {
    loadGrids();
  });
  
  async function loadGrids() {
    isLoading = true;
    errorMessage = null;
    
    try {
      grids = await api.fetchGrids();
    } catch (error) {
      errorMessage = error instanceof Error ? error.message : 'Failed to load grids';
    } finally {
      isLoading = false;
    }
  }
  
  async function generateGrids() {
    isGenerating = true;
    errorMessage = null;
    successMessage = null;
    
    try {
      await api.generateGrids();
      successMessage = '4 new grids generated successfully!';
      await loadGrids();
      
      // Clear success message after 3 seconds
      setTimeout(() => {
        successMessage = null;
      }, 3000);
    } catch (error) {
      errorMessage = error instanceof Error ? error.message : 'Failed to generate grids';
    } finally {
      isGenerating = false;
    }
  }
  
  async function fetchHistory() {
    isFetchingHistory = true;
    errorMessage = null;
    successMessage = null;
    
    try {
      const result = await api.fetchHistory();
      successMessage = result;
      
      // Clear success message after 5 seconds
      setTimeout(() => {
        successMessage = null;
      }, 5000);
    } catch (error) {
      errorMessage = error instanceof Error ? error.message : 'Failed to fetch history';
    } finally {
      isFetchingHistory = false;
    }
  }
  
  function openGridDetail(grid: Grid) {
    selectedGrid = grid;
  }
  
  function closeGridDetail() {
    selectedGrid = null;
  }
  
  function clearError() {
    errorMessage = null;
  }
</script>

<main>
  <header>
    <div class="header-content">
      <h1>🎰 Euromillions</h1>
      <p class="subtitle">Optimized lottery grids based on statistical frequency</p>
    </div>
    
    <nav>
      <button 
        class="nav-btn"
        class:active={!showHistory}
        onclick={() => showHistory = false}
      >
        My Grids
      </button>
      <button 
        class="nav-btn"
        class:active={showHistory}
        onclick={() => showHistory = true}
      >
        History
      </button>
    </nav>
  </header>
  
  {#if !showHistory}
    <!-- Grids View -->
    <div class="container">
      <div class="actions">
        <button 
          class="btn btn-primary" 
          onclick={generateGrids}
          disabled={isGenerating}
        >
          {isGenerating ? '⏳ Generating...' : '✨ Generate 4 Grids'}
        </button>
        
        <button 
          class="btn btn-secondary" 
          onclick={loadGrids}
          disabled={isLoading}
        >
          {isLoading ? '⏳ Loading...' : '🔄 Refresh'}
        </button>
      </div>
      
      {#if errorMessage}
        <div class="alert alert-error">
          <span>{errorMessage}</span>
          <button class="alert-close" onclick={clearError}>×</button>
        </div>
      {/if}
      
      {#if successMessage}
        <div class="alert alert-success">
          {successMessage}
        </div>
      {/if}
      
      {#if isLoading}
        <div class="loading">
          <div class="spinner"></div>
          <p>Loading grids...</p>
        </div>
      {:else if grids.length === 0}
        <div class="empty-state">
          <span class="empty-icon">🎲</span>
          <h2>No grids yet</h2>
          <p>Generate your first optimized lottery grids based on historical data</p>
        </div>
      {:else}
        <div class="grids-grid">
          {#each grids as grid (grid.id)}
            <div onclick={() => openGridDetail(grid)}>
              <GridCard {grid} />
            </div>
          {/each}
        </div>
      {/if}
    </div>
  {:else}
    <!-- History View -->
    <div class="container">
      <div class="history-section">
        <div class="history-icon">🔄</div>
        <h2>Fetch History</h2>
        <p>Download the latest Euromillions draw results from the web</p>
        
        {#if errorMessage}
          <div class="alert alert-error">
            <span>{errorMessage}</span>
            <button class="alert-close" onclick={clearError}>×</button>
          </div>
        {/if}
        
        {#if successMessage}
          <div class="alert alert-success">
            {successMessage}
          </div>
        {/if}
        
        <button 
          class="btn btn-primary btn-large" 
          onclick={fetchHistory}
          disabled={isFetchingHistory}
        >
          {isFetchingHistory ? '⏳ Fetching...' : '📥 Fetch Now'}
        </button>
      </div>
    </div>
  {/if}
  
  {#if selectedGrid}
    <GridModal grid={selectedGrid} onClose={closeGridDetail} />
  {/if}
</main>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
  }
  
  main {
    min-height: 100vh;
    padding-bottom: 2rem;
  }
  
  header {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    box-shadow: 0 2px 16px rgba(0, 0, 0, 0.1);
    padding: 1.5rem 0;
    margin-bottom: 2rem;
    position: sticky;
    top: 0;
    z-index: 100;
  }
  
  .header-content {
    text-align: center;
    margin-bottom: 1rem;
  }
  
  h1 {
    margin: 0;
    font-size: 2.5rem;
    background: linear-gradient(135deg, #1976d2, #ff9800);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  
  .subtitle {
    margin: 0.5rem 0 0 0;
    color: #666;
    font-size: 1rem;
  }
  
  nav {
    display: flex;
    justify-content: center;
    gap: 1rem;
    padding: 0 1rem;
  }
  
  .nav-btn {
    background: none;
    border: none;
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    font-weight: 600;
    color: #666;
    cursor: pointer;
    border-radius: 8px;
    transition: all 0.2s;
  }
  
  .nav-btn:hover {
    background: rgba(25, 118, 210, 0.1);
    color: #1976d2;
  }
  
  .nav-btn.active {
    background: #1976d2;
    color: white;
  }
  
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
  }
  
  .actions {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
    flex-wrap: wrap;
  }
  
  .btn {
    padding: 0.875rem 1.75rem;
    border: none;
    border-radius: 8px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  }
  
  .btn:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  }
  
  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .btn-primary {
    background: linear-gradient(135deg, #1976d2, #1565c0);
    color: white;
  }
  
  .btn-secondary {
    background: white;
    color: #1976d2;
  }
  
  .btn-large {
    padding: 1.25rem 2.5rem;
    font-size: 1.125rem;
  }
  
  .alert {
    padding: 1rem 1.5rem;
    border-radius: 8px;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    animation: slideDown 0.3s ease-out;
  }
  
  @keyframes slideDown {
    from {
      transform: translateY(-10px);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
  
  .alert-error {
    background: #ffebee;
    color: #c62828;
    border-left: 4px solid #c62828;
  }
  
  .alert-success {
    background: #e8f5e9;
    color: #2e7d32;
    border-left: 4px solid #2e7d32;
  }
  
  .alert-close {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: inherit;
    opacity: 0.7;
    padding: 0;
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .alert-close:hover {
    opacity: 1;
  }
  
  .loading {
    text-align: center;
    padding: 4rem 0;
  }
  
  .spinner {
    width: 50px;
    height: 50px;
    border: 4px solid rgba(255, 255, 255, 0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 0 auto 1rem;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  
  .loading p {
    color: white;
    font-size: 1.125rem;
  }
  
  .empty-state {
    text-align: center;
    padding: 4rem 2rem;
    background: white;
    border-radius: 16px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  }
  
  .empty-icon {
    font-size: 4rem;
    display: block;
    margin-bottom: 1rem;
  }
  
  .empty-state h2 {
    margin: 0 0 0.5rem 0;
    color: #333;
    font-size: 1.75rem;
  }
  
  .empty-state p {
    margin: 0;
    color: #666;
    font-size: 1.125rem;
  }
  
  .grids-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.5rem;
  }
  
  .history-section {
    text-align: center;
    padding: 4rem 2rem;
    background: white;
    border-radius: 16px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    max-width: 600px;
    margin: 0 auto;
  }
  
  .history-icon {
    font-size: 5rem;
    margin-bottom: 1.5rem;
  }
  
  .history-section h2 {
    margin: 0 0 1rem 0;
    color: #333;
    font-size: 2rem;
  }
  
  .history-section p {
    margin: 0 0 2rem 0;
    color: #666;
    font-size: 1.125rem;
  }
  
  @media (max-width: 768px) {
    h1 {
      font-size: 2rem;
    }
    
    .grids-grid {
      grid-template-columns: 1fr;
    }
    
    .actions {
      flex-direction: column;
    }
    
    .btn {
      width: 100%;
    }
  }
</style>
