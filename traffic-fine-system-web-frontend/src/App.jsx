import { useState } from 'react'
import PaymentForm from './components/PaymentForm'
import Header from './components/Header'
import Footer from './components/Footer'

function App() {
  return (
    <div className="min-h-screen flex flex-col bg-neutral-bg">
      <Header />
      <main className="flex-grow flex items-center justify-center px-4 py-8">
        <PaymentForm />
      </main>
      <Footer />
    </div>
  )
}

export default App
