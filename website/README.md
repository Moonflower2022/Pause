# Pause Website

This is the marketing website for Pause, a macOS meditation and mindfulness application.

## Tech Stack

- **Vue.js 3.5+**: Progressive JavaScript framework
- **TypeScript**: Type-safe development
- **Vite**: Next-generation frontend tooling
- **ESLint**: Code quality and consistency

## Development

### Prerequisites

- Node.js 20.19.0 or 22.12.0+
- npm or your preferred package manager

### Getting Started

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production (includes type checking)
- `npm run preview` - Preview production build locally
- `npm run type-check` - Run TypeScript compiler checks
- `npm run lint` - Run linters (oxlint + eslint)
- `npm run format` - Format code with Prettier

## Recommended IDE Setup

- [VS Code](https://code.visualstudio.com/) + [Vue (Official)](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (disable Vetur if installed)

## Recommended Browser Setup

**Chromium-based browsers** (Chrome, Edge, Brave, etc.):
- [Vue.js devtools](https://chromewebstore.google.com/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd)
- [Turn on Custom Object Formatter](http://bit.ly/object-formatters)

**Firefox**:
- [Vue.js devtools](https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/)
- [Turn on Custom Object Formatter](https://fxdx.dev/firefox-devtools-custom-object-formatters/)

## Project Structure

```
website/
├── src/
│   ├── App.vue          # Main application component
│   └── main.ts          # Application entry point
├── public/
│   └── favicon.ico      # Site favicon
├── index.html           # HTML entry point
├── vite.config.ts       # Vite configuration
├── tsconfig.json        # TypeScript configuration
└── package.json         # Dependencies and scripts
```

## Website Features

The website showcases:

- **Hero Section**: Animated breathing circle with gradient background
- **Feature Highlights**: 6 key features with icons
- **Automation Modes**: Explanation of repeated, random, and scheduled activation
- **How It Works**: 4-step process walkthrough
- **Testimonials**: User quotes and feedback
- **Download Section**: Installation instructions and GitHub releases link
- **Responsive Footer**: Navigation and community links

## Customization

### Colors

The site uses a purple gradient color scheme:
- Primary: `#667eea` (purple-blue)
- Secondary: `#764ba2` (deep purple)

To change colors, update the CSS gradients in `src/App.vue`:

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Content

Update content by modifying the data arrays in `src/App.vue`:

```typescript
const features: Feature[] = [ /* ... */ ]
const testimonials = [ /* ... */ ]
const activationModes = [ /* ... */ ]
```

### Links

Update GitHub repository links throughout the site:

1. Download button in hero section
2. Footer links
3. Download section release link

Replace `yourusername` with your actual GitHub username:

```typescript
href="https://github.com/yourusername/Pause"
```

## Deployment

The site can be deployed to any static hosting service:

### GitHub Pages

```bash
npm run build
# Deploy dist/ folder to gh-pages branch
```

### Netlify

1. Connect your GitHub repository
2. Set build command: `npm run build`
3. Set publish directory: `dist`

### Vercel

1. Import your project
2. Vercel auto-detects Vite configuration
3. Deploy with zero additional configuration

### Cloudflare Pages

1. Connect your repository
2. Set build command: `npm run build`
3. Set build output directory: `dist`

## Build Output

Production build generates optimized static files in `dist/`:

```bash
npm run build
# Output: dist/
```

Features:
- Minified JavaScript and CSS
- Tree-shaking for optimal bundle size
- Modern ES modules
- Optimized assets

## Responsive Design

The website is fully responsive with breakpoints:

- **Desktop**: 1200px+ (full-width container)
- **Tablet**: 768px - 1199px (adjusted grid layouts)
- **Mobile**: < 768px (single-column stacked layouts)

## Performance Optimizations

- Lazy-loaded components via Vite
- Optimized production build with tree-shaking
- Minified CSS and JavaScript
- SVG icons for crisp display at any size
- CSS animations (GPU-accelerated)

## Type Support for `.vue` Imports

TypeScript cannot handle type information for `.vue` imports by default. This project uses `vue-tsc` for type checking instead of standard `tsc`. Ensure Volar extension is installed in VS Code for proper `.vue` type support.

## License

Same as parent Pause project (see root LICENSE file).

## Contributing

Contributions to improve the website are welcome! Please follow the parent project's contributing guidelines in the main README.md.

---

Built with ❤️ using Vue.js 3 and Vite for the Pause macOS meditation app.
