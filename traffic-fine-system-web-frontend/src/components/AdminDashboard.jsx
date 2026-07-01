import { useEffect, useMemo, useState } from 'react'
import {
  checkAdminAccess,
  getAdminCategoryBreakdown,
  getAdminDistrictCollections,
  getAdminFines,
  getAdminPayments,
  getAdminTotalCollections,
  getAdminUsers,
  getFineByReference,
} from '../services/trafficFineApi'

const currencyFormatter = new Intl.NumberFormat('en-LK', {
  style: 'currency',
  currency: 'LKR',
  maximumFractionDigits: 2,
})

const integerFormatter = new Intl.NumberFormat('en-LK', {
  maximumFractionDigits: 0,
})

function formatAmount(value) {
  return currencyFormatter.format(Number(value) || 0)
}

function formatInteger(value) {
  return integerFormatter.format(Number(value) || 0)
}

function formatDate(value) {
  if (!value) {
    return 'N/A'
  }

  const date = new Date(value)

  if (Number.isNaN(date.getTime())) {
    return 'N/A'
  }

  return date.toLocaleString('en-LK', {
    dateStyle: 'medium',
    timeStyle: 'short',
  })
}

function normalizeError(error) {
  return error.response?.data?.message || error.message || 'Unable to load admin data.'
}

function capitalizeWords(value) {
  return String(value || 'Unknown')
    .replaceAll('_', ' ')
    .toLowerCase()
    .replace(/\b\w/g, (character) => character.toUpperCase())
}

function MetricCard({ label, value, hint }) {
  return (
    <div className="rounded-2xl border border-white/10 bg-slate-950/70 p-5 shadow-[0_18px_50px_rgba(2,6,23,0.35)] backdrop-blur">
      <p className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-400">{label}</p>
      <div className="mt-3 text-2xl font-semibold text-white">{value}</div>
      {hint ? <p className="mt-2 text-sm text-slate-400">{hint}</p> : null}
    </div>
  )
}

function SectionCard({ title, eyebrow, children, className = '' }) {
  return (
    <section
      className={`rounded-3xl border border-slate-200/80 bg-white/90 p-6 shadow-[0_24px_70px_rgba(15,23,42,0.08)] backdrop-blur ${className}`}
    >
      <div className="mb-5">
        {eyebrow ? (
          <p className="text-xs font-semibold uppercase tracking-[0.24em] text-primary-orange">
            {eyebrow}
          </p>
        ) : null}
        <h3 className="mt-2 text-xl font-semibold text-slate-900">{title}</h3>
      </div>
      {children}
    </section>
  )
}

function DataTable({ columns, rows, emptyMessage }) {
  if (!rows.length) {
    return (
      <div className="rounded-2xl border border-dashed border-slate-300 bg-slate-50 p-6 text-sm text-slate-600">
        {emptyMessage}
      </div>
    )
  }

  return (
    <div className="overflow-hidden rounded-2xl border border-slate-200">
      <table className="min-w-full divide-y divide-slate-200 text-left text-sm">
        <thead className="bg-slate-50 text-xs uppercase tracking-[0.2em] text-slate-500">
          <tr>
            {columns.map((column) => (
              <th key={column.key} className="px-4 py-3 font-semibold">
                {column.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-100 bg-white">
          {rows.map((row, rowIndex) => (
            <tr key={row.id ?? row.referenceNumber ?? row.createdAt ?? rowIndex} className="hover:bg-slate-50/70">
              {columns.map((column) => (
                <td key={column.key} className="px-4 py-4 text-slate-700">
                  {column.render ? column.render(row) : row[column.key] ?? 'N/A'}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default function AdminDashboard({ authUser }) {
  const isAdmin = authUser?.role === 'ADMIN'
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)
  const [error, setError] = useState('')
  const [dashboard, setDashboard] = useState({
    totalCollections: 0,
    districtCollections: [],
    categoryBreakdown: [],
    users: [],
    fines: [],
    payments: [],
    accessMessage: '',
  })
  const [referenceNumber, setReferenceNumber] = useState('')
  const [lookupLoading, setLookupLoading] = useState(false)
  const [lookupError, setLookupError] = useState('')
  const [lookupFine, setLookupFine] = useState(null)

  const totalDistrictCollections = useMemo(
    () => dashboard.districtCollections.reduce((sum, item) => sum + (Number(item.total) || 0), 0),
    [dashboard.districtCollections],
  )

  const totalPayments = dashboard.payments.length
  const paidFines = dashboard.fines.filter((fine) => fine.status === 'PAID').length

  const loadDashboard = async (showSpinner = false) => {
    if (!isAdmin) {
      setLoading(false)
      setRefreshing(false)
      setError('Admin access is required to view collections and breakdowns.')
      return
    }

    if (showSpinner) {
      setRefreshing(true)
    } else {
      setLoading(true)
    }

    setError('')

    const [
      totalResult,
      districtResult,
      categoryResult,
      usersResult,
      finesResult,
      paymentsResult,
      accessResult,
    ] = await Promise.allSettled([
      getAdminTotalCollections(),
      getAdminDistrictCollections(),
      getAdminCategoryBreakdown(),
      getAdminUsers(10),
      getAdminFines(10),
      getAdminPayments(10),
      checkAdminAccess(),
    ])

    const nextDashboard = {
      totalCollections:
        totalResult.status === 'fulfilled' ? Number(totalResult.value.total) || 0 : 0,
      districtCollections:
        districtResult.status === 'fulfilled' && Array.isArray(districtResult.value)
          ? districtResult.value
          : [],
      categoryBreakdown:
        categoryResult.status === 'fulfilled' && Array.isArray(categoryResult.value)
          ? categoryResult.value
          : [],
      users:
        usersResult.status === 'fulfilled' && Array.isArray(usersResult.value)
          ? usersResult.value
          : [],
      fines:
        finesResult.status === 'fulfilled' && Array.isArray(finesResult.value)
          ? finesResult.value
          : [],
      payments:
        paymentsResult.status === 'fulfilled' && Array.isArray(paymentsResult.value)
          ? paymentsResult.value
          : [],
      accessMessage:
        accessResult.status === 'fulfilled'
          ? accessResult.value.message || 'Admin route access confirmed.'
          : '',
    }

    const failures = [
      totalResult,
      districtResult,
      categoryResult,
      usersResult,
      finesResult,
      paymentsResult,
      accessResult,
    ]
      .filter((result) => result.status === 'rejected')
      .map((result) => normalizeError(result.reason))

    setDashboard(nextDashboard)
    setError(failures[0] || '')
    setLoading(false)
    setRefreshing(false)
  }

  useEffect(() => {
    loadDashboard()
  }, [isAdmin])

  const handleLookup = async (event) => {
    event.preventDefault()

    if (!referenceNumber.trim()) {
      setLookupError('Enter a fine reference number first.')
      setLookupFine(null)
      return
    }

    setLookupLoading(true)
    setLookupError('')

    try {
      const fine = await getFineByReference(referenceNumber.trim())
      setLookupFine(fine || null)
      if (!fine) {
        setLookupError('No fine found for that reference number.')
      }
    } catch (lookupException) {
      setLookupFine(null)
      setLookupError(normalizeError(lookupException))
    } finally {
      setLookupLoading(false)
    }
  }

  const highestCategoryCount = dashboard.categoryBreakdown.reduce(
    (max, item) => Math.max(max, Number(item.count) || 0),
    0,
  )

  const hasDistrictData = dashboard.districtCollections.length > 0
  const hasCategoryData = dashboard.categoryBreakdown.length > 0

  return (
    <div className="space-y-6">
      <section className="overflow-hidden rounded-[2rem] border border-slate-800 bg-[radial-gradient(circle_at_top_left,_rgba(255,122,0,0.35),_transparent_28%),linear-gradient(135deg,#0b1220_0%,#111827_50%,#1f2937_100%)] px-6 py-8 text-white shadow-[0_28px_80px_rgba(15,23,42,0.28)] md:px-8">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-3xl">
            <p className="text-xs font-semibold uppercase tracking-[0.3em] text-primary-light">
              Administrative Control Center
            </p>
            <h2 className="mt-3 text-3xl font-bold leading-tight md:text-4xl">
              Monitor collections, list users, inspect fines, and review payment activity.
            </h2>
            <p className="mt-4 max-w-2xl text-sm leading-6 text-slate-300 md:text-base">
              This portal is connected to the backend admin API for both summary metrics and the
              operational lists needed to monitor the system.
            </p>
          </div>

          <button type="button" onClick={() => loadDashboard(true)} className="btn-secondary self-start">
            {refreshing ? 'Refreshing...' : 'Refresh dashboard'}
          </button>
        </div>

        <div className="mt-8 grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
          <MetricCard
            label="Collections"
            value={formatAmount(dashboard.totalCollections)}
            hint="Successful payment total from the backend"
          />
          <MetricCard
            label="Districts tracked"
            value={formatInteger(dashboard.districtCollections.length)}
            hint={`${formatAmount(totalDistrictCollections)} across districts`}
          />
          <MetricCard
            label="Users listed"
            value={formatInteger(dashboard.users.length)}
            hint="Latest users from the admin list endpoint"
          />
          <MetricCard
            label="Payments listed"
            value={formatInteger(totalPayments)}
            hint={`${formatInteger(paidFines)} paid fines in the current slice`}
          />
        </div>
      </section>

      {loading ? (
        <div className="rounded-3xl border border-dashed border-slate-300 bg-white/70 p-8 text-slate-600 shadow-sm">
          Loading admin data...
        </div>
      ) : null}

      {!isAdmin ? (
        <section className="rounded-3xl border border-amber-200 bg-amber-50 px-6 py-5 text-amber-900 shadow-sm">
          <p className="font-semibold">Admin access is required.</p>
          <p className="mt-1 text-sm leading-6">
            The backend only allows this dashboard for users signed in with the ADMIN role. Use the
            small admin lock icon to open the dedicated admin access panel.
          </p>
        </section>
      ) : null}

      {error ? (
        <section className="rounded-3xl border border-rose-200 bg-rose-50 px-6 py-5 text-rose-900 shadow-sm">
          <p className="font-semibold">Partial data load</p>
          <p className="mt-1 text-sm leading-6">{error}</p>
        </section>
      ) : null}

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-[1.3fr_0.9fr]">
        <SectionCard eyebrow="District collections" title="Where the money is collected">
          {hasDistrictData ? (
            <div className="space-y-4">
              {dashboard.districtCollections.map((item) => {
                const total = Number(item.total) || 0
                const share = dashboard.totalCollections > 0 ? (total / dashboard.totalCollections) * 100 : 0

                return (
                  <div key={item.district} className="space-y-2 rounded-2xl bg-slate-50 p-4">
                    <div className="flex items-center justify-between gap-4">
                      <div>
                        <p className="font-semibold text-slate-900">{item.district}</p>
                        <p className="text-sm text-slate-500">{share.toFixed(1)}% of total collections</p>
                      </div>
                      <p className="text-lg font-semibold text-slate-900">{formatAmount(total)}</p>
                    </div>
                    <div className="h-2 overflow-hidden rounded-full bg-slate-200">
                      <div
                        className="h-full rounded-full bg-gradient-to-r from-primary-orange to-secondary-medium"
                        style={{ width: `${Math.max(share, 4)}%` }}
                      />
                    </div>
                  </div>
                )
              })}
            </div>
          ) : (
            <div className="rounded-2xl border border-dashed border-slate-300 bg-slate-50 p-6 text-sm text-slate-600">
              No district-level collection data is available yet.
            </div>
          )}
        </SectionCard>

        <SectionCard eyebrow="Fine lookup" title="Inspect a single fine reference">
          <form onSubmit={handleLookup} className="space-y-4">
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">
                Fine reference number
              </label>
              <input
                type="text"
                value={referenceNumber}
                onChange={(event) => setReferenceNumber(event.target.value)}
                className="input-field"
                placeholder="Enter reference number"
              />
            </div>
            <button type="submit" className="btn-primary w-full" disabled={lookupLoading}>
              {lookupLoading ? 'Searching...' : 'Search fine'}
            </button>
          </form>

          {lookupError ? (
            <div className="mt-4 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-800">
              {lookupError}
            </div>
          ) : null}

          {lookupFine ? (
            <div className="mt-4 space-y-3 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-700">
              <div className="flex items-center justify-between gap-4">
                <span className="font-semibold text-slate-900">{lookupFine.referenceNumber}</span>
                <span
                  className={`rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-[0.18em] ${
                    lookupFine.status === 'PAID'
                      ? 'bg-emerald-100 text-emerald-800'
                      : 'bg-amber-100 text-amber-800'
                  }`}
                >
                  {lookupFine.status}
                </span>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <p className="text-slate-500">Category</p>
                  <p className="font-medium text-slate-900">{capitalizeWords(lookupFine.category)}</p>
                </div>
                <div>
                  <p className="text-slate-500">Amount</p>
                  <p className="font-medium text-slate-900">{formatAmount(lookupFine.amount)}</p>
                </div>
                <div>
                  <p className="text-slate-500">District</p>
                  <p className="font-medium text-slate-900">{capitalizeWords(lookupFine.district)}</p>
                </div>
                <div>
                  <p className="text-slate-500">Officer</p>
                  <p className="font-medium text-slate-900">{lookupFine.officerId ?? 'N/A'}</p>
                </div>
                <div>
                  <p className="text-slate-500">Driver</p>
                  <p className="font-medium text-slate-900">{lookupFine.driverName || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-slate-500">License</p>
                  <p className="font-medium text-slate-900">{lookupFine.driverLicense || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-slate-500">Vehicle</p>
                  <p className="font-medium text-slate-900">{lookupFine.vehicleNumber || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-slate-500">Offense date</p>
                  <p className="font-medium text-slate-900">{lookupFine.offenseDate || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-slate-500">Location</p>
                  <p className="font-medium text-slate-900">{lookupFine.offenseLocation || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-slate-500">Notes</p>
                  <p className="font-medium text-slate-900">{lookupFine.notes || 'N/A'}</p>
                </div>
              </div>
            </div>
          ) : null}
        </SectionCard>
      </div>

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        <SectionCard eyebrow="Users" title="Latest users in the system">
          <DataTable
            rows={dashboard.users}
            emptyMessage="No users returned from the backend yet."
            columns={[
              {
                key: 'username',
                label: 'Username',
                render: (row) => (
                  <div>
                    <p className="font-semibold text-slate-900">{row.username}</p>
                    <p className="text-xs text-slate-500">{row.name}</p>
                  </div>
                ),
              },
              {
                key: 'email',
                label: 'Email',
              },
              {
                key: 'role',
                label: 'Role',
                render: (row) => capitalizeWords(row.role),
              },
            ]}
          />
        </SectionCard>

        <SectionCard eyebrow="Fines" title="Latest fines in the system">
          <DataTable
            rows={dashboard.fines}
            emptyMessage="No fines returned from the backend yet."
            columns={[
              {
                key: 'referenceNumber',
                label: 'Reference',
                render: (row) => (
                  <div>
                    <p className="font-semibold text-slate-900">{row.referenceNumber}</p>
                    <p className="text-xs text-slate-500">{capitalizeWords(row.category)}</p>
                  </div>
                ),
              },
              {
                key: 'amount',
                label: 'Amount',
                render: (row) => formatAmount(row.amount),
              },
              {
                key: 'status',
                label: 'Status',
                render: (row) => capitalizeWords(row.status),
              },
            ]}
          />
        </SectionCard>

        <SectionCard eyebrow="Payments" title="Latest payment activity">
          <DataTable
            rows={dashboard.payments}
            emptyMessage="No payment activity returned from the backend yet."
            columns={[
              {
                key: 'fine',
                label: 'Fine',
                render: (row) => (
                  <div>
                    <p className="font-semibold text-slate-900">{row.fine?.referenceNumber || `Fine #${row.fineId}`}</p>
                    <p className="text-xs text-slate-500">{capitalizeWords(row.fine?.category)}</p>
                  </div>
                ),
              },
              {
                key: 'amount',
                label: 'Amount',
                render: (row) => formatAmount(row.amount),
              },
              {
                key: 'createdAt',
                label: 'Created',
                render: (row) => formatDate(row.createdAt),
              },
            ]}
          />
        </SectionCard>
      </div>

      <SectionCard eyebrow="Category breakdown" title="How fines are distributed by category">
        {hasCategoryData ? (
          <div className="space-y-4">
            {dashboard.categoryBreakdown.map((item) => {
              const count = Number(item.count) || 0
              const share = highestCategoryCount > 0 ? (count / highestCategoryCount) * 100 : 0

              return (
                <div key={item.category} className="space-y-2 rounded-2xl bg-slate-50 p-4">
                  <div className="flex items-center justify-between gap-4">
                    <div>
                      <p className="font-semibold text-slate-900">{capitalizeWords(item.category)}</p>
                      <p className="text-sm text-slate-500">{count} fines tracked</p>
                    </div>
                    <p className="text-lg font-semibold text-slate-900">{count}</p>
                  </div>
                  <div className="h-2 overflow-hidden rounded-full bg-slate-200">
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-secondary-medium to-primary-orange"
                      style={{ width: `${Math.max(share, 4)}%` }}
                    />
                  </div>
                </div>
              )
            })}
          </div>
        ) : (
          <div className="rounded-2xl border border-dashed border-slate-300 bg-slate-50 p-6 text-sm text-slate-600">
            No category data is available yet.
          </div>
        )}
      </SectionCard>
    </div>
  )
}