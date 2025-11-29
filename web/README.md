# Euromillions Web App

Modern web application built with Svelte 5 and TypeScript for interacting with the Euromillions API.

## Features

- **View Generated Grids**: Browse lottery grids with optimized numbers based on statistical frequency
- **Generate New Grids**: Create 4 new grids for the next draw
- **Fetch History**: Download the latest Euromillions draw results
- **Beautiful UI**: Modern gradient design with animations
- **Responsive**: Works on desktop, tablet, and mobile devices
- **Real-time Updates**: Instant feedback with loading states and notifications

## Tech Stack

- **Svelte 5**: Latest version with new runes API ($state, $props, $derived)
- **TypeScript**: Type-safe development
- **Vite**: Fast build tool and dev server
- **Native Fetch API**: No additional HTTP libraries needed

## Quick Start

### Prerequisites

- Node.js 18+ and npm

### Installation

1. Navigate to the web directory:
   ```bash
   cd web
   ```

2. Install dependencies (already done during project creation):
   ```bash
   npm install
   ```

3. Configure the API URL:
   - Open `src/api.ts`
   - Update the `BASE_URL` constant:
     ```typescript
     // For local development
     const BASE_URL = 'http://localhost:8080';
     
     // For production (replace with your API URL)
     const BASE_URL = 'https://your-api.render.com';
     ```

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Open your browser to [http://localhost:5173](http://localhost:5173)

## Project Structure

```
web/
├── src/
│   ├── App.svelte              # Main app component with navigation
│   ├── main.ts                 # App entry point
│   ├── types.ts                # TypeScript type definitions
│   ├── api.ts                  # API client
│   └── components/
│       ├── GridCard.svelte     # Grid list item component
│       └── GridModal.svelte    # Grid detail modal
├── index.html                   # HTML entry point
├── package.json                 # Dependencies
├── tsconfig.json               # TypeScript configuration
└── vite.config.ts              # Vite configuration
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run check` - Type-check the code

## Building for Production

Build the app for production:

```bash
npm run build
```

This creates optimized files in the `dist/` directory. You can preview the production build:

```bash
npm run preview
```

## Deployment

The built files in `dist/` can be deployed to any static hosting service:

- **Vercel**: `npm i -g vercel && vercel`
- **Netlify**: Drag and drop the `dist` folder
- **GitHub Pages**: Push `dist` contents to `gh-pages` branch
- **Render Static Site**: Point to the `web` directory

### Environment Variables

For production deployment, set the API base URL as an environment variable:

```bash
# .env.production
VITE_API_URL=https://your-api.render.com
```

Then update `src/api.ts` to use it:

```typescript
const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';
```

## Features Overview

### My Grids Tab
- Grid list with responsive card layout
- Each grid shows:
  - Draw date
  - 5 numbers in blue gradient balls
  - 2 stars in orange gradient balls
  - Generation timestamp
- Click any grid to see full details in a modal
- Generate button to create 4 new optimized grids
- Refresh button to reload data
- Empty state when no grids exist

### History Tab
- Simple interface to trigger history fetch
- Loading indicator during fetch
- Success/error messages
- Clean, centered layout

### Grid Detail Modal
- Large, beautiful number balls with gradients
- Large star balls with gradients
- Animated entrance
- Click outside or close button to dismiss

## API Integration

The app connects to three API endpoints:

- `GET /history` - Fetch latest draw results from the web
- `GET /generate` - Generate 4 optimized grids
- `GET /grids` - Get the 20 most recent generated grids

All API calls include:
- Error handling with user-friendly messages
- Loading states
- Success notifications

## Styling

The app features:
- Gradient purple background
- White content cards with shadows
- Smooth animations and transitions
- Blue gradient for number balls
- Orange gradient for star balls
- Responsive design with mobile-first approach
- Modern, clean typography

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Android)

## Troubleshooting

**"Failed to load grids"**
- Ensure the backend API is running
- Check the API URL in `src/api.ts`
- Open browser DevTools to see network errors
- Verify CORS is enabled on the backend

**Build errors**
- Delete `node_modules` and run `npm install` again
- Clear Vite cache: `rm -rf node_modules/.vite`

**TypeScript errors**
- Run `npm run check` to see all type errors
- Ensure all dependencies are installed

## Development Tips

- The app uses Svelte 5 runes (`$state`, `$props`, `$derived`)
- Hot module replacement (HMR) is enabled for instant updates
- TypeScript provides full type safety
- Components are scoped by default (styles don't leak)

## License

Part of the Euromillions Bot project.
