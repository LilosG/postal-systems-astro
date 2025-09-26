import { Phone, Quote } from 'lucide-react'

const MobileCTABar = () => {
  return (
    <div className="mobile-cta-bar">
      <a
        href="/contact"
        className="btn-hero-primary flex-1 justify-center min-h-[44px]"
      >
        <Quote className="w-5 h-5" />
        Get a Quote
      </a>

      <a
        href="tel:6194614787"
        className="w-12 h-12 bg-[hsl(var(--postal-red))] text-white rounded-full flex items-center justify-center hover:bg-[hsl(var(--postal-navy))] transition-colors flex-shrink-0"
        aria-label="Call now"
      >
        <Phone className="w-5 h-5" />
      </a>
    </div>
  )
}

export default MobileCTABar
