import { useState } from 'react'
import { createFine } from '../services/trafficFineApi'

const fineCategories = [
  { value: 'SPEEDING', label: 'Speeding' },
  { value: 'RED_LIGHT', label: 'Running Red Light' },
  { value: 'NO_SEAT_BELT', label: 'Not Wearing Seat Belt' },
  { value: 'PARKING', label: 'Illegal Parking' },
  { value: 'DOCUMENTARY', label: 'Documentary Offense' },
  { value: 'OTHER', label: 'Other' },
]

export default function OfficerFineForm({ authUser }) {
  const [formData, setFormData] = useState({
    category: '',
    amount: '',
    district: '',
    driverName: '',
    driverLicense: '',
    vehicleNumber: '',
    offenseDate: '',
    offenseLocation: '',
    notes: '',
  })
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState({ type: '', text: '' })
  const [createdFine, setCreatedFine] = useState(null)

  const handleChange = event => {
    const { name, value } = event.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const validateForm = () => {
    if (!authUser || authUser.role !== 'OFFICER') {
      setMessage({ type: 'error', text: 'Officer access is required to create fines.' })
      return false
    }
    if (!formData.category) {
      setMessage({ type: 'error', text: 'Please select a fine category.' })
      return false
    }
    if (!formData.amount || Number(formData.amount) <= 0) {
      setMessage({ type: 'error', text: 'Enter a valid fine amount.' })
      return false
    }
    if (!formData.driverName.trim()) {
      setMessage({ type: 'error', text: 'Enter the driver name.' })
      return false
    }
    if (!formData.driverLicense.trim()) {
      setMessage({ type: 'error', text: 'Enter the driver license number.' })
      return false
    }
    if (!formData.vehicleNumber.trim()) {
      setMessage({ type: 'error', text: 'Enter the vehicle number.' })
      return false
    }
    if (!formData.offenseDate.trim()) {
      setMessage({ type: 'error', text: 'Select the offense date.' })
      return false
    }
    if (!formData.offenseLocation.trim()) {
      setMessage({ type: 'error', text: 'Enter the offense location.' })
      return false
    }
    return true
  }

  const handleSubmit = async event => {
    event.preventDefault()
    if (!validateForm()) {
      return
    }

    setLoading(true)
    setMessage({ type: '', text: '' })

    try {
      const response = await createFine({
        category: formData.category,
        amount: Number(formData.amount),
        district: formData.district.trim() || undefined,
        driverName: formData.driverName.trim(),
        driverLicense: formData.driverLicense.trim(),
        vehicleNumber: formData.vehicleNumber.trim(),
        offenseDate: formData.offenseDate,
        offenseLocation: formData.offenseLocation.trim(),
        notes: formData.notes.trim() || undefined,
      })

      setCreatedFine(response.fine)
      setMessage({ type: 'success', text: 'Fine created successfully.' })
      setFormData({
        category: '',
        amount: '',
        district: '',
        driverName: '',
        driverLicense: '',
        vehicleNumber: '',
        offenseDate: '',
        offenseLocation: '',
        notes: '',
      })
    } catch (error) {
      setMessage({
        type: 'error',
        text: error.response?.data?.message || 'Unable to create the fine. Please try again.',
      })
    } finally {
      setLoading(false)
    }
  }

  const handleClear = () => {
    setFormData({
      category: '',
      amount: '',
      district: '',
      driverName: '',
      driverLicense: '',
      vehicleNumber: '',
      offenseDate: '',
      offenseLocation: '',
      notes: '',
    })
    setMessage({ type: '', text: '' })
    setCreatedFine(null)
  }

  return (
    <div className="w-full card">
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-secondary-dark mb-2">
          Officer fine entry
        </h1>
        <p className="text-gray-600">
          Create a new fine record using your officer credentials.
        </p>
      </div>

      {message.text && (
        <div className={`mb-6 p-4 rounded-lg ${message.type === 'success'
          ? 'bg-green-100 text-green-800 border border-green-300'
          : 'bg-red-100 text-red-800 border border-red-300'}`}>
          {message.text}
        </div>
      )}

      {createdFine ? (
        <div className="mb-6 rounded-2xl border border-slate-200 bg-slate-50 p-4">
          <p className="text-sm font-semibold text-slate-700">Created fine reference</p>
          <p className="mt-2 text-lg font-bold text-slate-900">{createdFine.referenceNumber}</p>
          <p className="mt-1 text-sm text-slate-600">Status: {createdFine.status}</p>
          <div className="mt-4 grid gap-3 text-sm text-slate-700 md:grid-cols-2">
            <div><span className="font-semibold text-slate-500">Driver:</span> {createdFine.driverName || 'N/A'}</div>
            <div><span className="font-semibold text-slate-500">License:</span> {createdFine.driverLicense || 'N/A'}</div>
            <div><span className="font-semibold text-slate-500">Vehicle:</span> {createdFine.vehicleNumber || 'N/A'}</div>
            <div><span className="font-semibold text-slate-500">Offense date:</span> {createdFine.offenseDate || 'N/A'}</div>
            <div><span className="font-semibold text-slate-500">Location:</span> {createdFine.offenseLocation || 'N/A'}</div>
            <div><span className="font-semibold text-slate-500">Notes:</span> {createdFine.notes || 'N/A'}</div>
          </div>
        </div>
      ) : null}

      <form onSubmit={handleSubmit} className="space-y-6">
        <fieldset className="border-b-2 border-neutral-bg pb-6">
          <h2 className="text-xl font-semibold text-secondary-dark mb-4">
            Fine details
          </h2>

          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Fine category *
              </label>
              <select
                name="category"
                value={formData.category}
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

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Amount (LKR) *
              </label>
              <input
                type="number"
                name="amount"
                value={formData.amount}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter amount"
                min="0"
                step="0.01"
                required
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                District
              </label>
              <input
                type="text"
                name="district"
                value={formData.district}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter district or location"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Driver name *
              </label>
              <input
                type="text"
                name="driverName"
                value={formData.driverName}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter driver name"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Driver license number *
              </label>
              <input
                type="text"
                name="driverLicense"
                value={formData.driverLicense}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter license number"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Vehicle number *
              </label>
              <input
                type="text"
                name="vehicleNumber"
                value={formData.vehicleNumber}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter vehicle number"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Offense date *
              </label>
              <input
                type="date"
                name="offenseDate"
                value={formData.offenseDate}
                onChange={handleChange}
                className="input-field"
                required
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Offense location *
              </label>
              <input
                type="text"
                name="offenseLocation"
                value={formData.offenseLocation}
                onChange={handleChange}
                className="input-field"
                placeholder="Enter location of the offense"
                required
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Additional notes
              </label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                className="input-field min-h-[110px]"
                placeholder="Optional remarks from the officer"
              />
            </div>
          </div>
        </fieldset>

        <div className="flex gap-4">
          <button
            type="submit"
            disabled={loading}
            className="btn-primary flex-1"
          >
            {loading ? 'Submitting...' : 'Submit fine'}
          </button>
          <button
            type="button"
            className="px-6 py-3 border-2 border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50 transition-all duration-200"
            onClick={handleClear}
          >
            Clear
          </button>
        </div>
      </form>
    </div>
  )
}
