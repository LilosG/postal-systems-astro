import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

const FAQ = () => {
  const [openItem, setOpenItem] = useState<number | null>(null);

  const faqItems = [
    {
      question: "Do you coordinate with USPS?",
      answer: "Yes—we handle location compliance, clearance requirements, and coordinate the final USPS inspection for seamless handover."
    },
    {
      question: "Do you pour pads and set anchors?",
      answer: "Yes—concrete pads, bases, and proper leveling are included in our installations when requested as part of the project scope."
    },
    {
      question: "Can you match existing units?",
      answer: "Usually—we work with major manufacturers and carry various finishes to match or complement your existing mailbox installations."
    },
    {
      question: "Are 4C mailboxes required?",
      answer: "For many new construction and major renovation projects, yes. We'll advise you on current postal regulations and code requirements for your specific situation."
    },
    {
      question: "How fast can we schedule?",
      answer: "Typical lead times are 1–3 weeks depending on project scope, permits required, and material availability. Emergency repairs can often be prioritized."
    }
  ];

  return (
    <section id="faq" className="py-20 bg-[hsl(var(--secondary))]">
      <div className="container mx-auto px-4 max-w-[1140px]">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-[hsl(var(--postal-navy))] mb-4 font-poppins">
            Frequently Asked Questions
          </h2>
          <p className="text-lg text-[hsl(var(--postal-slate))] max-w-2xl mx-auto font-inter">
            Get answers to common questions about our mailbox installation services
          </p>
        </div>

        <div className="max-w-3xl mx-auto space-y-4">
          {faqItems.map((item, index) => (
            <div key={index} className="bg-white rounded-xl shadow-[var(--shadow-soft)] overflow-hidden">
              <button
                className="w-full text-left p-6 flex items-center justify-between hover:bg-[hsl(var(--light-gray))] transition-colors min-h-[44px]"
                onClick={() => setOpenItem(openItem === index ? null : index)}
              >
                <h3 className="text-lg font-semibold text-[hsl(var(--postal-navy))] pr-4 font-poppins">
                  {item.question}
                </h3>
                {openItem === index ? (
                  <ChevronUp className="w-5 h-5 text-[hsl(var(--postal-slate))] flex-shrink-0" />
                ) : (
                  <ChevronDown className="w-5 h-5 text-[hsl(var(--postal-slate))] flex-shrink-0" />
                )}
              </button>
              
              {openItem === index && (
                <div className="px-6 pb-6">
                  <p className="text-[hsl(var(--postal-slate))] leading-relaxed font-inter">
                    {item.answer}
                  </p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default FAQ;