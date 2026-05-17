import { useState } from 'react'
import axios from 'axios'
import './PaymentForm.css'

export default function PaymentForm() {
  const [formData, setFormData] = useState({
    fineReferenceNumber: '',
    fineCategory: '',
    fullName: '',
    email: '',
    phoneNumber: '',
    licenseNumber: '',
    amount: '',
    cardNumber: '',
    expiryDate: '',
    cvv: ''
  })

  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState({ type: '', text: '' })

  const fineCategories = [
    { value: 'SPEEDING', label: 'Speeding' },
    { value: 'RED_LIGHT', label: 'Running Red Light' },
    { value: 'NO_SEAT_BELT', label: 'Not Wearing Seat Belt' },
    { value: 'PARKING', label: 'Illegal Parking' },
    { value: 'DOCUMENTARY', label: 'Documentary Offense' },
    { value: 'OTHER', label: 'Other' }
  ]

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
  }

  const validateForm = () => {
    if (!formData.fineReferenceNumber.trim()) {
      setMessage({ type: 'error', text: 'Fine reference number is required' })
      return false
    }
    if (!formData.fineCategory) {
      setMessage({ type: 'error', text: 'Please select a fine category' })
      return false
    }
    if (!formData.fullName.trim()) {
      setMessage({ type: 'error', text: 'Full name is required' })
      return false
    }
    if (!formData.email.trim()) {
      setMessage({ type: 'error', text: 'Email is required' })
      return false
    }
    if (!formData.phoneNumber.trim()) {
      setMessage({ type: 'error', text: 'Phone number is required' })
      return false
    }
    if (!formData.cardNumber.trim()) {
      setMessage({ type: 'error', text: 'Card number is required' })
      return false
    }
    return true
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    
    if (!validateForm()) {
      return
    }

    setLoading(true)
    setMessage({ type: '', text: '' })

    try {
      const response = await axios.post('/api/payment/process', formData)
      setMessage({ type: 'success', text: 'Payment processed successfully! Check your email for receipt.' })
      
      // Reset form
      setFormData({
        fineReferenceNumber: '',
        fineCategory: '',
        fullName: '',
        email: '',
        phoneNumber: '',
        licenseNumber: '',
        amount: '',
        cardNumber: '',
        expiryDate: '',
        cvv: ''
      })
    } catch (error) {
      setMessage({ 
        type: 'error', 
        text: error.response?.data?.message || 'Payment failed. Please try again.' 
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="w-full max-w-2xl card">
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-secondary-dark mb-2">
          Traffic Fine Payment
        </h1>
        <p className="text-gray-600">
          Enter your fine details and payment information to complete the transaction
        </p>
      </div>

      {message.text && (
        <div className={`mb-6 p-4 rounded-lg ${message.type === 'success' 
          ? 'bg-green-100 text-green-800 border border-green-300' 
          : 'bg-red-100 text-red-800 border border-red-300'}`}>
          {message.text}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        
        {/* Fine Details Section */}
        <div className="border-b-2 border-neutral-bg pb-6">
          <h2 className="text-xl font-semibold text-secondary-dark mb-4">
            Fine Details
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Fine Reference Number *
              </label>
              <input
                type="text"
                name="fineReferenceNumber"
                value={formData.fineReferenceNumber}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter reference number"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Fine Category *
              </label>
              <select
                name="fineCategory"
                value={formData.fineCategory}
                onChange={handleChange}
                className="input-field"
                required
              >
                <option value="">Select a category</option>
                {fineCategories.map(cat => (
                  <option key={cat.value} value={cat.value}>
                    {cat.label}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        {/* Personal Information Section */}
        <div className="border-b-2 border-neutral-bg pb-6">
          <h2 className="text-xl font-semibold text-secondary-dark mb-4">
            Personal Information
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Full Name *
              </label>
              <input
                type="text"
                name="fullName"
                value={formData.fullName}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter your full name"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Email *
              </label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter your email"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Phone Number *
              </label>
              <input
                type="tel"
                name="phoneNumber"
                value={formData.phoneNumber}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter your phone number"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                License Number
              </label>
              <input
                type="text"
                name="licenseNumber"
                value={formData.licenseNumber}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter your license number"
              />
            </div>
          </div>
        </div>

        {/* Payment Information Section */}
        <div className="border-b-2 border-neutral-bg pb-6">
          <h2 className="text-xl font-semibold text-secondary-dark mb-4">
            Payment Information
          </h2>
          
          <div className="grid grid-cols-1 gap-4 mb-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Fine Amount (LKR) *
              </label>
              <input
                type="number"
                name="amount"
                value={formData.amount}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter amount to pay"
                min="0"
                step="0.01"
                required
              />
            </div>
          </div>

          <div className="bg-secondary-dark bg-opacity-5 p-4 rounded-lg mb-4">
            <p className="text-sm text-gray-600 mb-4">
              🔒 Your payment information is secure and encrypted
            </p>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Card Number *
                </label>
                <input
                  type="text"
                  name="cardNumber"
                  value={formData.cardNumber}
                  onChange={(e) => {
                    const value = e.target.value.replace(/\s/g, '')
                    if (value.length <= 16) {
                      const formatted = value.replace(/(\d{4})/g, '$1 ').trim()
                      handleChange({target: {name: 'cardNumber', value: formatted}})
                    }
                  }}
                  className="input-field"
                  placeholder="1234 5678 9012 3456"
                  maxLength="19"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Expiry Date *
                  </label>
                  <input
                    type="text"
                    name="expiryDate"
                    value={formData.expiryDate}
                    onChange={(e) => {
                      let value = e.target.value.replace(/\D/g, '')
                      if (value.length >= 2) {
                        value = value.slice(0, 2) + '/' + value.slice(2, 4)
                      }
                      handleChange({target: {name: 'expiryDate', value}})
                    }}
                    className="input-field"
                    placeholder="MM/YY"
                    maxLength="5"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    CVV *
                  </label>
                  <input
                    type="password"
                    name="cvv"
                    value={formData.cvv}
                    onChange={(e) => {
                      if (e.target.value.length <= 4) {
                        handleChange(e)
                      }
                    }}
                    className="input-field"
                    placeholder="123"
                    maxLength="4"
                    required
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Submit Button */}
        <div className="flex gap-4">
          <button
            type="submit"
            disabled={loading}
            className="btn-primary flex-1"
          >
            {loading ? 'Processing...' : 'Pay Now'}
          </button>
          <button
            type="reset"
            className="px-6 py-3 border-2 border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50 transition-all duration-200"
            onClick={() => setMessage({ type: '', text: '' })}
          >
            Clear
          </button>
        </div>

        <p className="text-xs text-gray-500 text-center">
          By clicking Pay Now, you agree to our terms and conditions. Your data is secured.
        </p>
      </form>
    </div>
  )
}
