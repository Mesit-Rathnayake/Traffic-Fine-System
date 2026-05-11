export default function Footer() {
  const currentYear = new Date().getFullYear()
  
  return (
    <footer className="bg-secondary-dark text-white mt-12">
      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
          <div>
            <h3 className="text-lg font-semibold mb-4 text-primary-light">Quick Links</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="#" className="hover:text-primary-light transition">About Us</a></li>
              <li><a href="#" className="hover:text-primary-light transition">Help & Support</a></li>
              <li><a href="#" className="hover:text-primary-light transition">FAQs</a></li>
              <li><a href="#" className="hover:text-primary-light transition">Track Payment</a></li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-semibold mb-4 text-primary-light">Information</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="#" className="hover:text-primary-light transition">Terms & Conditions</a></li>
              <li><a href="#" className="hover:text-primary-light transition">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-primary-light transition">Security</a></li>
              <li><a href="#" className="hover:text-primary-light transition">Contact Us</a></li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-semibold mb-4 text-primary-light">Contact</h3>
            <p className="text-sm mb-2">📧 support@trafficfines.lk</p>
            <p className="text-sm mb-2">📞 +94 11 2431 111</p>
            <p className="text-sm">⏰ Mon - Fri: 8:00 AM - 5:00 PM</p>
          </div>
        </div>

        <div className="border-t border-secondary-medium border-opacity-30 pt-8">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <p className="text-sm text-gray-300 mb-4 md:mb-0">
              {/* © {currentYear} Sri Lanka Police Department. All rights reserved. */}
            </p>
            <div className="flex gap-6">
              <a href="#" className="text-sm hover:text-primary-light transition">Facebook</a>
              <a href="#" className="text-sm hover:text-primary-light transition">Twitter</a>
              <a href="#" className="text-sm hover:text-primary-light transition">LinkedIn</a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}
