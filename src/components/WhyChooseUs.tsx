import { 
  CheckCircle, 
  Shield, 
  Settings, 
  Award 
} from 'lucide-react';

const WhyChooseUs = () => {
  const features = [
    {
      icon: CheckCircle,
      title: "USPS Approved",
      description: "We coordinate placement, clearance requirements, and final inspection with USPS for seamless project completion."
    },
    {
      icon: Shield,
      title: "Licensed/Bonded/Insured",
      description: "California CSLB #904106 with full bonding and comprehensive insurance coverage for your peace of mind."
    },
    {
      icon: Settings,
      title: "Turnkey Installations",
      description: "Complete service including pads, anchors, leveling, signage, and final USPS handoff—nothing left to chance."
    },
    {
      icon: Award,
      title: "Warranty & Support",
      description: "Hardware backed by manufacturer warranties plus our workmanship guarantee for long-term reliability."
    }
  ];

  return (
    <section id="why-us" className="py-20 bg-white">
      <div className="container mx-auto px-4 max-w-[1140px]">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-[hsl(var(--postal-navy))] mb-4 font-poppins">
            Why Choose Postal Systems
          </h2>
          <p className="text-lg text-[hsl(var(--postal-slate))] max-w-2xl mx-auto font-inter">
            Two decades of experience delivering professional mailbox solutions across San Diego County.
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
          {features.map((feature, index) => (
            <div key={index} className="card-feature">
              <div className="w-12 h-12 bg-gradient-to-br from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] rounded-lg flex items-center justify-center flex-shrink-0">
                <feature.icon className="w-6 h-6 text-white" />
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-[hsl(var(--postal-navy))] mb-2 font-poppins">
                  {feature.title}
                </h3>
                <p className="text-[hsl(var(--postal-slate))] leading-relaxed font-inter">
                  {feature.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default WhyChooseUs;