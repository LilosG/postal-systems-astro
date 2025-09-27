/* @ts-nocheck */
/* eslint-disable @next/next/no-img-element */
import heroImage from '../assets/hero-mailbox.jpg'

export default function Hero() {
  return (
    <section className="py-16">
      <div className="grid gap-8 lg:grid-cols-2 items-center">
        <div>
          <h1 className="text-4xl font-semibold mb-4">Commercial Mailbox Solutions</h1>
          <p className="opacity-80 mb-6">Installations, repairs, and upgrades—done right.</p>
          <a href="/contact" className="inline-flex items-center rounded-lg px-4 py-2 text-sm font-medium bg-gray-900 text-white hover:opacity-90">Get Quote</a>
        </div>
        <div className="relative">
          <img src={(typeof heroImage === "string" ? heroImage : (heroImage as any).src)} alt="Commercial mailbox" className="rounded-xl w-full h-auto" />
        </div>
      </div>
    </section>
  )
}
