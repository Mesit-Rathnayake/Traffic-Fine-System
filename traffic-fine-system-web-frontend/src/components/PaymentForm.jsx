import { useEffect, useState } from 'react'
import './PaymentForm.css'
import { getFineByReference, payFine } from '../services/trafficFineApi'

const INITIAL_FORM_DATA = {
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
}

export default function PaymentForm({ isAuthenticated = false }) {
  const [formData, setFormData] = useState(INITIAL_FORM_DATA)

  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState({ type: '', text: '' })
  const [fineRecord, setFineRecord] = useState(null)
  const [lookupLoading, setLookupLoading] = useState(false)

  useEffect(() => {
    if (isAuthenticated) {
      return
    }

    setFormData(INITIAL_FORM_DATA)
    setMessage({ type: '', text: '' })
    setFineRecord(null)
    setLookupLoading(false)
  }, [isAuthenticated])

  const fineDetailRows = fineRecord
    ? [
        { label: 'Reference', value: fineRecord.referenceNumber },
        { label: 'Category', value: fineRecord.category },
        { label: 'Amount', value: `LKR ${Number(fineRecord.amount || 0).toFixed(2)}` },
        { label: 'Status', value: fineRecord.status },
        { label: 'Driver', value: fineRecord.driverName },
        { label: 'License', value: fineRecord.driverLicense },
        { label: 'Vehicle', value: fineRecord.vehicleNumber },
        { label: 'Offense date', value: fineRecord.offenseDate },
        { label: 'Location', value: fineRecord.offenseLocation },
        { label: 'District', value: fineRecord.district },
        { label: 'Notes', value: fineRecord.notes },
      ]
    : []

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
      ...(name === 'fineReferenceNumber'
        ? { fineCategory: '', amount: '' }
        : {}),
      [name]: value
    }))

    if (name === 'fineReferenceNumber') {
      setFineRecord(null)
    }
  }

  const handleLoadFine = async () => {
    if (!formData.fineReferenceNumber.trim()) {
      setMessage({ type: 'error', text: 'Enter a fine reference number first.' })
      return
    }

    setLookupLoading(true)
    setMessage({ type: '', text: '' })

    try {
      const fine = await getFineByReference(formData.fineReferenceNumber.trim())

      if (!fine) {
        setFineRecord(null)
        setMessage({ type: 'error', text: 'No fine found for that reference number.' })
        return
      }

      setFineRecord(fine)
      setFormData(prev => ({
        ...prev,
        fineCategory: fine.category || prev.fineCategory,
        amount: String(fine.amount ?? prev.amount),
      }))
      setMessage({
        type: fine.status === 'PAID' ? 'error' : 'success',
        text:
          fine.status === 'PAID'
            ? 'This fine is already marked as paid.'
            : 'Fine details loaded from the backend.',
      })
    } catch (error) {
      setFineRecord(null)
      setMessage({
        type: 'error',
        text: error.response?.data?.message || 'Unable to load the fine details.',
      })
    } finally {
      setLookupLoading(false)
    }
  }

  const validateForm = () => {
    if (!isAuthenticated) {
      setMessage({ type: 'error', text: 'Please sign in before filling the form.' })
      return false
    }
    if (!formData.fineReferenceNumber.trim()) {
      setMessage({ type: 'error', text: 'Fine reference number is required' })
      return false
    }
    if (!formData.fineCategory) {
      setMessage({ type: 'error', text: 'Please select a fine category' })
      return false
    }
    if (!fineRecord) {
      setMessage({ type: 'error', text: 'Load the fine details before paying.' })
      return false
    }
    if (fineRecord.status === 'PAID') {
      setMessage({ type: 'error', text: 'This fine has already been paid.' })
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
    if (!formData.amount.trim()) {
      setMessage({ type: 'error', text: 'Fine amount is required' })
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
      const amount = Number.parseFloat(formData.amount)

      if (Number.isNaN(amount) || amount <= 0) {
        setMessage({ type: 'error', text: 'Enter a valid fine amount.' })
        return
      }

      await payFine({
        referenceNumber: formData.fineReferenceNumber.trim(),
        fineId: fineRecord?.id,
        amount,
      })
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
      setFineRecord(null)
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
    <div className="w-full card">
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-secondary-dark mb-2">
          Traffic Fine Payment
        </h1>
        <p className="text-gray-600">
          Enter your fine details and payment information to complete the transaction
        </p>
      </div>

      {!isAuthenticated ? (
        <div className="mb-6 rounded-xl border border-amber-300 bg-amber-50 px-4 py-3 text-amber-900">
          Please sign in before filling the form.
        </div>
      ) : null}

      {message.text && (
        <div className={`mb-6 p-4 rounded-lg ${message.type === 'success' 
          ? 'bg-green-100 text-green-800 border border-green-300' 
          : 'bg-red-100 text-red-800 border border-red-300'}`}>
          {message.text}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        
        {/* Fine Details Section */}
        <fieldset
          disabled={!isAuthenticated}
          className={`border-b-2 border-neutral-bg pb-6 ${!isAuthenticated ? 'opacity-60' : ''}`}
        >
          <h2 className="text-xl font-semibold text-secondary-dark mb-4">
            Fine Details
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Fine Reference Number *
              </label>
              <div className="flex flex-col gap-3 sm:flex-row">
                <input
                  type="text"
                  name="fineReferenceNumber"
                  value={formData.fineReferenceNumber}
                  onChange={handleChange}
                  className="input-field flex-1"
                  placeholder="Enter reference number"
                  required
                />
                <button
                  type="button"
                  onClick={handleLoadFine}
                  disabled={lookupLoading}
                  className="px-5 py-3 rounded-lg border-2 border-secondary-dark text-secondary-dark font-semibold hover:bg-secondary-dark hover:text-white transition-all duration-200 disabled:opacity-60"
                >
                  {lookupLoading ? 'Loading...' : 'Load fine details'}
                </button>
              </div>
              {/* {fineRecord ? (
                <div className="mt-3 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-700">
                  <p className="font-semibold text-slate-900">Fine details loaded</p>
                  <div className="mt-3 grid gap-2 md:grid-cols-2">
                    {fineDetailRows.map((item) => (
                      <div key={item.label} className="rounded-xl bg-white px-3 py-2">
                        <p className="text-xs uppercase tracking-[0.16em] text-slate-500">{item.label}</p>
                        <p className="mt-1 font-medium text-slate-900">{item.value || 'N/A'}</p>
                      </div>
                    ))}
                  </div>
                </div>
              ) : null} */}
              {fineRecord ? (
                <div className="mt-4 rounded-3xl border border-slate-200 bg-white shadow-sm overflow-hidden">

                  {/* HEADER STRIP */}
                  <div className="flex items-center justify-between px-5 py-4 bg-gradient-to-r from-slate-50 to-slate-100 border-b">
                    <div>
                      <p className="text-xs uppercase tracking-[0.2em] text-slate-500">
                        Fine Details Loaded
                      </p>
                      <p className="text-sm font-semibold text-slate-900">
                        Reference: {fineRecord.referenceNumber}
                      </p>
                    </div>

                    {/* STATUS BADGE */}
                    <div
                      className={`px-3 py-1 rounded-full text-xs font-semibold tracking-wide ${
                        fineRecord.status === 'PAID'
                          ? 'bg-emerald-100 text-emerald-700'
                          : 'bg-amber-100 text-amber-700'
                      }`}
                    >
                      {fineRecord.status}
                    </div>
                  </div>

                  {/* BODY GRID */}
                  <div className="p-5 grid grid-cols-1 md:grid-cols-2 gap-4">
                    {fineDetailRows.map(item => (
                      <div
                        key={item.label}
                        className="flex flex-col gap-1 rounded-2xl border border-slate-100 bg-slate-50 px-4 py-3 hover:bg-slate-100 transition"
                      >
                        <p className="text-[11px] uppercase tracking-[0.18em] text-slate-500">
                          {item.label}
                        </p>
                        <p className="text-sm font-semibold text-slate-900 break-words">
                          {item.value || 'N/A'}
                        </p>
                      </div>
                    ))}
                  </div>

                  {/* FOOTER INFO STRIP */}
                  <div className="px-5 py-3 bg-slate-50 border-t text-xs text-slate-500 flex justify-between">
                    <span>System verified record</span>
                    <span>Traffic Fine Portal</span>
                  </div>

                </div>
              ) : null}
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
                disabled={Boolean(fineRecord)}
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
        </fieldset>

        {/* Personal Information Section */}
        <fieldset
          disabled={!isAuthenticated}
          className={`border-b-2 border-neutral-bg pb-6 ${!isAuthenticated ? 'opacity-60' : ''}`}
        >
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
        </fieldset>

        {/* Payment Information Section */}
        <fieldset
          disabled={!isAuthenticated}
          className={`border-b-2 border-neutral-bg pb-6 ${!isAuthenticated ? 'opacity-60' : ''}`}
        >
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
                readOnly={Boolean(fineRecord)}
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
        </fieldset>

        {/* Submit Button */}
        <div className="flex gap-4">
          <button
            type="submit"
            disabled={loading}
            className="btn-primary flex-1"
          >
            {loading ? 'Processing...' : isAuthenticated ? 'Pay Now' : 'Sign in to Pay'}
          </button>
          <button
            type="button"
            className="px-6 py-3 border-2 border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50 transition-all duration-200"
            onClick={() => {
              setFormData(INITIAL_FORM_DATA)
              setFineRecord(null)
              setMessage({ type: '', text: '' })
              setLookupLoading(false)
            }}
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
