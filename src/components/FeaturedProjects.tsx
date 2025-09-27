/* @ts-nocheck */
import hoaImage from '../assets/project-hoa-san-marcos.jpg'
import mailroomImage from '../assets/project-carlsbad-retrofit.jpg'
import officeImage from '../assets/project-office-park.jpg'

const FeaturedProjects = () => {
  const projects = [
    {
      image: hoaImage,
      title: 'HOA CBU Upgrade',
      location: 'San Marcos',
      description:
        'Complete cluster box unit replacement for 200-unit residential community with ADA compliance upgrades.',
      alt: 'HOA CBU upgrade project in San Marcos residential community',
    },
    {
      image: mailroomImage,
      title: '4C Mailroom Retrofit',
      location: 'Carlsbad',
      description:
        'Modern 4C horizontal mailbox installation for luxury apartment complex with integrated parcel system.',
      alt: '4C mailroom retrofit project in Carlsbad apartment building',
    },
    {
      image: officeImage,
      title: 'Parcel Lockers',
      location: 'Office Park',
      description:
        'Large-scale parcel locker installation serving multiple office buildings with secure package delivery.',
      alt: 'Office park parcel lockers installation for commercial buildings',
    },
  ]

  return (
    <section id="projects" className="py-20 bg-[hsl(var(--secondary))]">
      <div className="container mx-auto px-4 max-w-[1140px]">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-[hsl(var(--postal-navy))] mb-4 font-poppins">
            Featured Projects
          </h2>
          <p className="text-lg text-[hsl(var(--postal-slate))] max-w-2xl mx-auto font-inter">
            See our recent installations across San Diego County communities and
            commercial properties.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {projects.map((project, index) => (
            <div
              key={index}
              className="bg-white rounded-xl overflow-hidden shadow-[var(--shadow-card)] hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group cursor-pointer"
            >
              <div className="aspect-video overflow-hidden relative">
                <img width="800" height="533" loading="lazy" decoding="async" fetchPriority="auto"
                  src={project.image}
                  alt={project.alt}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  loading="lazy"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-[hsl(var(--postal-navy)_/_0.7)] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                <div className="absolute bottom-4 left-4 right-4 text-white opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <h3 className="font-semibold text-lg font-poppins">
                    {project.title}
                  </h3>
                  <p className="text-sm opacity-90 font-inter">
                    {project.location}
                  </p>
                </div>
              </div>

              <div className="p-6">
                <h3 className="text-lg font-semibold text-[hsl(var(--postal-navy))] mb-2 font-poppins">
                  {project.title} — {project.location}
                </h3>
                <p className="text-[hsl(var(--postal-slate))] text-sm leading-relaxed font-inter">
                  {project.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default FeaturedProjects
