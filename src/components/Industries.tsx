const Industries = () => {
  const industries = [
    { name: 'HOAs & Property Managers', param: 'hoa' },
    { name: 'Apartments & Multifamily', param: 'apartment' },
    { name: 'Builders & General Contractors', param: 'builder' },
    { name: 'Commercial & Industrial Parks', param: 'commercial' },
    { name: 'Campuses & Municipal', param: 'municipal' },
  ]

  return (
    <section id="industries" className="py-20 bg-[hsl(var(--secondary))]">
      <div className="container mx-auto px-4 max-w-[1140px]">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-[hsl(var(--postal-navy))] mb-4 font-poppins">
            Industries We Serve
          </h2>
          <p className="text-lg text-[hsl(var(--postal-slate))] max-w-2xl mx-auto font-inter">
            Specialized mailbox solutions for diverse property types across San
            Diego County.
          </p>
        </div>

        <div className="flex flex-wrap justify-center gap-4 max-w-4xl mx-auto">
          {industries.map((industry, index) => (
            <a
              key={index}
              href={`#contact?type=${industry.param}`}
              className="inline-flex items-center justify-center px-6 py-3 bg-white rounded-full font-medium text-[hsl(var(--postal-slate))] hover:bg-[hsl(var(--postal-navy))] hover:text-white transition-all duration-300 shadow-[var(--shadow-soft)] hover:shadow-[var(--shadow-card)] hover:-translate-y-1 min-h-[44px] font-inter border border-[hsl(var(--border))]"
            >
              {industry.name}
            </a>
          ))}
        </div>
      </div>
    </section>
  )
}

export default Industries
