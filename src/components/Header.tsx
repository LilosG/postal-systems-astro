import { useState, useEffect } from 'react'
import { Menu, X, Phone, Mail } from 'lucide-react'

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [isScrolled, setIsScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10)
    }
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  const navItems = [
    { href: '/services', label: 'Services' },
    { href: '/industries', label: 'Industries' },
    { href: '/why-us', label: 'Why Us' },
    { href: '/projects', label: 'Projects' },
    { href: '/process', label: 'Process' },
    { href: '/faq', label: 'FAQ' },
    { href: '/contact', label: 'Contact' },
  ]

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled ? 'bg-white/95 backdrop-blur-md shadow-lg' : 'bg-white'
      }`}
    >
      <div className="container mx-auto px-4 py-4 max-w-[1140px]">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <div className="flex items-center space-x-2">
            <div className="w-10 h-10 bg-gradient-to-br from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] rounded-lg flex items-center justify-center">
              <Mail className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-[hsl(var(--postal-navy))] font-poppins">
                San Diego Commercial Mailbox
              </h1>
              <p className="text-xs text-[hsl(var(--postal-slate))] -mt-1">
                USPS-Approved Installation
              </p>
            </div>
          </div>

          {/* Desktop Navigation */}
          <nav className="hidden lg:flex items-center space-x-8">
            {navItems.map((item) => (
              <a
                key={item.href}
                href={item.href}
                className="text-[hsl(var(--postal-slate))] hover:text-[hsl(var(--postal-navy))] font-medium transition-colors font-inter"
              >
                {item.label}
              </a>
            ))}
          </nav>

          {/* Contact Info & Mobile Menu */}
          <div className="flex items-center space-x-4">
            <a href="tel:6194614787" className="btn-phone hidden md:flex">
              <Phone className="w-4 h-4" />
              <span>(619) 461-4787</span>
            </a>

            <button
              className="lg:hidden text-[hsl(var(--postal-navy))]"
              aria-label="Toggle mobile menu"
            >
              {isMenuOpen ? (
                <X className="w-6 h-6" />
              ) : (
                <Menu className="w-6 h-6" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {isMenuOpen && (
          <nav className="lg:hidden mt-4 pb-4 border-t border-[hsl(var(--border))]">
            <div className="flex flex-col space-y-3 pt-4">
              {navItems.map((item) => (
                <a
                  key={item.href}
                  href={item.href}
                  className="text-[hsl(var(--postal-slate))] hover:text-[hsl(var(--postal-navy))] font-medium py-2 font-inter"
                >
                  {item.label}
                </a>
              ))}
              <a href="tel:6194614787" className="btn-phone py-2">
                <Phone className="w-4 h-4" />
                <span>(619) 461-4787</span>
              </a>
            </div>
          </nav>
        )}
      </div>
    </header>
  )
}

export default Header
