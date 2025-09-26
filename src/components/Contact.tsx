import { useState } from 'react'
import { Mail, Phone, MapPin, Send } from 'lucide-react'

const Contact = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    propertyType: '',
    location: '',
    units: '',
    message: '',
  })

  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isSubmitted, setIsSubmitted] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSubmitting(true)

    // Simulate form submission
    await new Promise((resolve) => setTimeout(resolve, 1000))

    setIsSubmitting(false)
    setIsSubmitted(true)
    console.log('Form submitted:', formData)
  }

  const handleChange = (
    e: React.ChangeEvent<
      HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement
    >
  ) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    })
  }

  return (
    <section id="contact" className="py-20 bg-white">
      <div className="container mx-auto px-4 max-w-[1140px]">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-[hsl(var(--postal-navy))] mb-4 font-poppins">
            Get Your Free Quote
          </h2>
          <p className="text-lg text-[hsl(var(--postal-slate))] max-w-2xl mx-auto font-inter">
            Ready to upgrade your mailbox system? Contact us for a professional
            consultation and detailed quote.
          </p>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Contact Form */}
          <div className="lg:col-span-2">
            {isSubmitted ? (
              <div className="bg-[hsl(var(--secondary))] p-8 rounded-xl text-center">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg
                    className="w-8 h-8 text-green-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                </div>
                <h3 className="text-xl font-semibold text-[hsl(var(--postal-navy))] mb-2 font-poppins">
                  Thank You!
                </h3>
                <p className="text-[hsl(var(--postal-slate))] font-inter">
                  Thanks—expect a call within one business day.
                </p>
              </div>
            ) : (
              <form
                onSubmit={handleSubmit}
                className="bg-[hsl(var(--secondary))] p-8 rounded-xl"
              >
                <div className="grid md:grid-cols-2 gap-6 mb-6">
                  <div>
                    <label className="block text-sm font-medium text-[hsl(var(--postal-slate))] mb-2 font-inter">
                      Name *
                    </label>
                    <input
                      type="text"
                      name="name"
                      value={formData.name}
                      onChange={handleChange}
                      required
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[hsl(var(--postal-navy))] focus:border-transparent min-h-[44px] font-inter"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-[hsl(var(--postal-slate))] mb-2 font-inter">
                      Email *
                    </label>
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleChange}
                      required
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[hsl(var(--postal-navy))] focus:border-transparent min-h-[44px] font-inter"
                    />
                  </div>
                </div>

                <div className="grid md:grid-cols-2 gap-6 mb-6">
                  <div>
                    <label className="block text-sm font-medium text-[hsl(var(--postal-slate))] mb-2 font-inter">
                      Phone
                    </label>
                    <input
                      type="tel"
                      name="phone"
                      value={formData.phone}
                      onChange={handleChange}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[hsl(var(--postal-navy))] focus:border-transparent min-h-[44px] font-inter"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-[hsl(var(--postal-slate))] mb-2 font-inter">
                      Property Type
                    </label>
                    <select
                      name="propertyType"
                      value={formData.propertyType}
                      onChange={handleChange}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[hsl(var(--postal-navy))] focus:border-transparent min-h-[44px] font-inter"
                    >
                      <option value="">Select Property Type</option>
                      <option value="hoa">HOA / Community</option>
                      <option value="apartment">Apartment / Multifamily</option>
                      <option value="builder">Builder / Contractor</option>
                      <option value="commercial">Commercial / Office</option>
                      <option value="other">Other</option>
                    </select>
                  </div>
                </div>

                <div className="grid md:grid-cols-2 gap-6 mb-6">
                  <div>
                    <label className="block text-sm font-medium text-[hsl(var(--postal-slate))] mb-2 font-inter">
                      Project Location (City)
                    </label>
                    <input
                      type="text"
                      name="location"
                      value={formData.location}
                      onChange={handleChange}
                      placeholder="e.g., San Diego, Carlsbad"
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[hsl(var(--postal-navy))] focus:border-transparent min-h-[44px] font-inter"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-[hsl(var(--postal-slate))] mb-2 font-inter">
                      Units/Boxes Count
                    </label>
                    <input
                      type="text"
                      name="units"
                      value={formData.units}
                      onChange={handleChange}
                      placeholder="e.g., 50 units, 24 boxes"
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[hsl(var(--postal-navy))] focus:border-transparent min-h-[44px] font-inter"
                    />
                  </div>
                </div>

                <div className="mb-6">
                  <label className="block text-sm font-medium text-[hsl(var(--postal-slate))] mb-2 font-inter">
                    Project Details
                  </label>
                  <textarea
                    name="message"
                    value={formData.message}
                    onChange={handleChange}
                    rows={4}
                    placeholder="Tell us about your mailbox installation needs..."
                    className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[hsl(var(--postal-navy))] focus:border-transparent font-inter"
                  />
                </div>

                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="btn-hero-primary w-full md:w-auto disabled:opacity-50 disabled:cursor-not-allowed min-h-[44px]"
                >
                  {isSubmitting ? (
                    <>
                      <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                      Sending...
                    </>
                  ) : (
                    <>
                      <Send className="w-5 h-5" />
                      Send Message
                    </>
                  )}
                </button>

                <p className="text-sm text-[hsl(var(--muted-foreground))] mt-4 font-inter">
                  Typical lead time: 1–3 weeks
                </p>
              </form>
            )}
          </div>

          {/* Contact Info Sidebar */}
          <div className="space-y-6">
            <div className="bg-[hsl(var(--postal-navy))] text-white p-8 rounded-xl">
              <h3 className="text-xl font-bold mb-6 font-poppins">
                Contact Information
              </h3>

              <div className="space-y-4">
                <div className="flex items-start space-x-3">
                  <MapPin className="w-5 h-5 mt-1 text-[hsl(var(--postal-red))]" />
                  <div>
                    <p className="font-medium font-inter">San Diego Commercial Mailbox</p>
                    <p className="text-blue-100 font-inter">San Diego, CA</p>
                  </div>
                </div>

                <div className="flex items-center space-x-3">
                  <Mail className="w-5 h-5 text-[hsl(var(--postal-red))]" />
                  <a
                    href="mailto:email@sandiegocommercialmailbox.com"
                    className="hover:text-blue-200 font-inter"
                  >
                    email@sandiegocommercialmailbox.com
                  </a>
                </div>

                <div className="flex items-center space-x-3">
                  <Phone className="w-5 h-5 text-[hsl(var(--postal-red))]" />
                  <a
                    href="tel:6194614787"
                    className="hover:text-blue-200 font-inter"
                  >
                    (619) 461-4787
                  </a>
                </div>
              </div>

              <div className="mt-8 pt-6 border-t border-blue-400">
                <p className="text-sm text-blue-100 font-inter">
                  <span className="font-medium">Licensed Contractor</span>
                  <br />
                  CSLB #904106
                  <br />
                  <span className="text-xs opacity-75">
                    San Diego County, CA
                  </span>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Contact
