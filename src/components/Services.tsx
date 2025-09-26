/* eslint-disable @next/next/no-img-element */
import type { FC } from 'react'

type Service = {
  title: string
  href: string
  thumb: { src: string }
}

const services: Service[] = [
  { title: 'Water Damage Restoration', href: '/services/water-damage-restoration', thumb: { src: '/placeholder.png' } },
  { title: 'Mailbox Installation', href: '/services/cluster-box-units', thumb: { src: '/placeholder.png' } },
  { title: 'Repairs & Lock Changes', href: '/services/repairs-lock-changes', thumb: { src: '/placeholder.png' } }
]

const Services: FC = () => {
  return (
    <section className="py-12">
      <h2 className="text-2xl font-medium mb-6">Services</h2>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {services.map((service) => (
          <a key={service.href} href={service.href} className="block rounded-xl border p-6 hover:shadow-md transition">
            <img src={service.thumb.src} alt={service.title} className="rounded-md mb-4" />
            <h3 className="text-lg font-medium mb-2">{service.title}</h3>
            <span className="inline-flex rounded-lg px-3 py-2 text-sm bg-gray-900 text-white">View</span>
          </a>
        ))}
      </div>
    </section>
  )
}

export default Services
