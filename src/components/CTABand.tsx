import { Phone, Quote } from 'lucide-react'

const CTABand = () => {
  return (
    <section className="py-20 bg-gradient-to-r from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] text-white">
      <div className="container mx-auto px-4 max-w-[1140px] text-center">
        <h2 className="text-3xl md:text-4xl font-bold mb-6 font-poppins">
          Ready to{' '}
          <span className="relative">
            upgrade
            <span className="absolute bottom-0 left-0 w-full h-1 bg-white rounded-full"></span>
          </span>{' '}
          your mailboxes?
        </h2>

        <p className="text-xl mb-8 text-white/90 max-w-2xl mx-auto font-inter">
          Get professional USPS-approved installation with 20+ years of
          experience. Contact us today for your free consultation and detailed
          quote.
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center mb-6">
          <a
            href="#contact"
            className="inline-flex items-center justify-center gap-2 bg-white text-[hsl(var(--postal-navy))] px-8 py-4 rounded-xl font-semibold hover:bg-white/90 transition-colors shadow-lg min-h-[44px]"
          >
            <Quote className="w-5 h-5" />
            Get a Quote
          </a>

          <a
            href="tel:6194614787"
            className="inline-flex items-center justify-center gap-2 bg-transparent text-white px-8 py-4 rounded-xl font-semibold border-2 border-white hover:bg-white hover:text-[hsl(var(--postal-navy))] transition-colors min-h-[44px]"
          >
            <Phone className="w-5 h-5" />
            Call Now
          </a>
        </div>

        <p className="text-sm text-white/75 font-inter">
          USPS-approved • Licensed/Bonded/Insured • 20+ years experience
        </p>
      </div>
    </section>
  )
}

export default CTABand
