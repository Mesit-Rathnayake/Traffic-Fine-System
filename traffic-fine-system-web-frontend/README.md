# Traffic Fine System - Web Frontend

A modern single-page web application for online traffic fine payments built with **React**, **Vite**, and **Tailwind CSS**.

## Features

- 🎨 Modern and responsive UI with custom color palette
- 💳 Secure payment form with card validation
- 📱 Mobile-friendly design
- 🔒 SSL encrypted payment gateway
- 🎯 Easy-to-use fine payment interface
- 📧 Email confirmation for payments
- ⚡ Fast and optimized with Vite

## Tech Stack

- **React 18** - UI library
- **Vite 5** - Build tool and development server
- **Tailwind CSS 3** - Styling framework
- **Axios** - HTTP client for API calls
- **PostCSS & Autoprefixer** - CSS processing

## Color Palette

- **Primary Orange**: `#ff7a00`
- **Primary Light**: `#ffb36b`
- **Secondary Dark**: `#0b4f6c`
- **Secondary Medium**: `#1b85b8`
- **Neutral Background**: `#f6f2ea`

## Project Structure

```
traffic-fine-system-web-frontend/
├── src/
│   ├── components/
│   │   ├── Header.jsx
│   │   ├── Footer.jsx
│   │   ├── PaymentForm.jsx
│   │   └── PaymentForm.css
│   ├── App.jsx
│   ├── App.css
│   └── main.jsx
├── index.html
├── vite.config.js
├── tailwind.config.js
├── postcss.config.js
├── package.json
└── README.md
```

## Getting Started

### Prerequisites

- Node.js 16+ and npm/yarn installed

### Installation

1. Navigate to the project directory:

```bash
cd traffic-fine-system-web-frontend
```

2. Install dependencies:

```bash
npm install
```

### Development

Start the development server:

```bash
npm run dev
```

The application will open automatically at `http://localhost:3000`

### Building for Production

Build the application:

```bash
npm run build
```

Preview the production build:

```bash
npm run preview
```

## API Integration

The application is configured to proxy API requests to `http://localhost:3001`. Update the `vite.config.js` if your backend API is on a different URL or port.

### Payment Endpoint

The application sends payment data to:

```
POST /api/payment/process
```

Expected payload:

```json
{
  "fineReferenceNumber": "string",
  "fineCategory": "string",
  "fullName": "string",
  "email": "string",
  "phoneNumber": "string",
  "licenseNumber": "string",
  "amount": "number",
  "cardNumber": "string",
  "expiryDate": "string",
  "cvv": "string"
}
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## Features Included

### Header Component

- Displays organization information
- Shows security badge
- Professional branding

### Payment Form Component

- Fine reference number input
- Fine category selector
- Personal information section
- Secure payment information section
- Form validation
- Loading states
- Success/error messages

### Footer Component

- Quick links
- Information links
- Contact details
- Social media links
- Copyright information

## Styling

The application uses Tailwind CSS with custom component classes defined in `App.css`:

- `.btn-primary` - Orange primary button
- `.btn-secondary` - Blue secondary button
- `.input-field` - Styled input fields
- `.card` - Card container with shadow

## Security Features

- Client-side form validation
- Card information masking
- SSL encryption ready
- Secure password fields (CVV)
- CORS proxy configured

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

This project is part of the Sri Lanka Police Department's traffic fine digitalization initiative.

## Support

For issues or questions, contact: support@trafficfines.lk
