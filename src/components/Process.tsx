import { 
  MapPin, 
  FileText, 
  Calendar, 
  Hammer, 
  CheckCircle 
} from 'lucide-react';

const Process = () => {
  const steps = [
    {
      icon: MapPin,
      title: "Site Visit",
      description: "Assess your property and discuss mailbox requirements."
    },
    {
      icon: FileText,
      title: "Quote", 
      description: "Detailed proposal with materials, scope, timeline, and pricing."
    },
    {
      icon: Calendar,
      title: "Schedule",
      description: "Coordinate installation date, permits, and material delivery."
    },
    {
      icon: Hammer,
      title: "Install",
      description: "Professional installation with pads, anchors, and leveling."
    },
    {
      icon: CheckCircle,
      title: "USPS Handover",
      description: "Final inspection and official handover of your mailbox system."
    }
  ];

  return (
    <section id="process" className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-[hsl(var(--postal-navy))] mb-4">
            Our Installation Process
          </h2>
          <p className="text-lg text-[hsl(var(--postal-slate))] max-w-2xl mx-auto">
            A streamlined 5-step process that ensures your mailbox installation is done right the first time.
          </p>
        </div>

        <div className="max-w-6xl mx-auto">
          {/* Desktop Layout */}
          <div className="hidden lg:flex items-center justify-between relative">
            {/* Progress Line */}
            <div className="absolute top-6 left-0 right-0 h-0.5 bg-[hsl(var(--border))] z-0"></div>
            <div className="absolute top-6 left-0 w-4/5 h-0.5 bg-gradient-to-r from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] z-10"></div>
            
            {steps.map((step, index) => (
              <div key={index} className="relative z-20 text-center max-w-xs">
                <div className="w-12 h-12 bg-gradient-to-br from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
                  <step.icon className="w-6 h-6 text-white" />
                </div>
                
                <h3 className="text-lg font-semibold text-[hsl(var(--postal-navy))] mb-2">
                  {step.title}
                </h3>
                
                <p className="text-sm text-[hsl(var(--postal-slate))] leading-relaxed">
                  {step.description}
                </p>
              </div>
            ))}
          </div>

          {/* Mobile Layout */}
          <div className="lg:hidden space-y-6">
            {steps.map((step, index) => (
              <div key={index} className="flex items-start space-x-4">
                <div className="w-12 h-12 bg-gradient-to-br from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] rounded-full flex items-center justify-center flex-shrink-0">
                  <step.icon className="w-6 h-6 text-white" />
                </div>
                
                <div>
                  <h3 className="text-lg font-semibold text-[hsl(var(--postal-navy))] mb-1">
                    {step.title}
                  </h3>
                  <p className="text-[hsl(var(--postal-slate))] leading-relaxed">
                    {step.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default Process;