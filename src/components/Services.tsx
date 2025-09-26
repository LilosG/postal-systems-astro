import {
  Package,
  Building2,
  Lock,
  Wrench,
  Shield,
  Accessibility,
} from 'lucide-react'
import cbuImage from '../assets/4c-mailroom.jpg'
import parcelImage from '../assets/parcel-lockers-apartment.jpg'
import pedestalImage from '../assets/pedestal-mailbox.jpg'
import fourCThumb from '../assets/4c-mailroom-thumb.jpg'
import parcelThumb from '../assets/parcel-lockers-thumb.jpg'
import pedestalThumb from '../assets/pedestal-mailbox-thumb.jpg'
import lockThumb from '../assets/lock-change-thumb.jpg'

const Services = () => {
  const services = [
    {
      icon: Building2,
      title: 'Cluster Box Units (CBU)',
      description:
        'USPS-approved community mailbox installations for residential developments.',
      image: cbuImage,
      thumb: cbuImage,
      alt: '4C horizontal mailboxes in modern apartment mailroom setting',
    },
    {
      icon: Package,
      title: '4C Horizontal Mailboxes',
      description:
        'Modern mailroom solutions for apartments and office buildings.',
      image: fourCThumb,
      thumb: fourCThumb,
      alt: 'Professional 4C horizontal mailbox installation in apartment building',
    },
    {
      icon: Lock,
      title: 'Parcel Lockers',
      description:
        'Secure package delivery systems for modern e-commerce needs.',
      image: parcelThumb,
      thumb: parcelThumb,
      alt: 'Parcel lockers in apartment building for secure package delivery',
    },
    {
      icon: Shield,
      title: 'Pedestal & Wall-Mounted Boxes',
      description: 'Individual mailbox solutions for various property types.',
      image: pedestalThumb,
      thumb: pedestalThumb,
      alt: 'Pedestal mailbox installation, residential mailbox on post',
    },
    {
      icon: Wrench,
      title: 'Repairs & Lock Changes',
      description:
        'Maintenance services and hardware upgrades for existing systems.',
      image: lockThumb,
      thumb: lockThumb,
      alt: 'Professional mailbox repair and maintenance services',
    },
    {
      icon: Accessibility,
      title: 'ADA-Compliant Installs',
      description: 'Accessible installations meeting all ADA requirements.',
      image: cbuImage,
      thumb: cbuImage,
      alt: 'ADA-compliant mailbox installation meeting accessibility standards',
    },
  ]

  return (
    <section id="services" className="py-20 bg-white">
      <div className="container mx-auto px-4 max-w-[1140px]">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-[hsl(var(--postal-navy))] mb-4 font-poppins">
            Our Services
          </h2>
          <p className="text-lg text-[hsl(var(--postal-slate))] max-w-2xl mx-auto font-inter">
            Complete mailbox solutions from installation to maintenance, all
            USPS-approved and professionally executed.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {services.map((service, index) => (
            <a
              key={index}
              href="/contact"
              className="card-service group cursor-pointer h-full flex flex-col"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="w-12 h-12 bg-gradient-to-br from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] rounded-lg flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform duration-300">
                  <service.icon className="w-6 h-6 text-white" />
                </div>

                <div className="w-20 h-20 rounded-lg overflow-hidden flex-shrink-0 shadow-sm">
                  <img width="800" height="533" loading="lazy" decoding="async" fetchpriority="auto"
                    src={service.thumb}
                    alt={service.alt}
                    className="w-full h-full object-cover"
                    loading="lazy"
                  />
                </div>
              </div>

              <div className="flex-1">
                <h3 className="text-xl font-semibold text-[hsl(var(--postal-navy))] mb-3 font-poppins group-hover:text-[hsl(var(--postal-red))] transition-colors">
                  {service.title}
                </h3>

                <p className="text-[hsl(var(--postal-slate))] leading-relaxed mb-4 font-inter">
                  {service.description}
                </p>

                <span className="text-[hsl(var(--postal-red))] font-medium group-hover:underline transition-all font-inter">
                  Request Quote →
                </span>
              </div>
            </a>
          ))}
        </div>
      </div>
    </section>
  )
}

export default Services
