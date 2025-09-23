const ManufacturerLogos = () => {
  const manufacturers = [
    { name: "Salsbury Industries", alt: "Salsbury Industries - Mailbox Manufacturer" },
    { name: "Auth Florence", alt: "Auth Florence - Commercial Mailbox Solutions" },
    { name: "Letter Locker", alt: "Letter Locker - Parcel Delivery Systems" }
  ];

  return (
    <section className="py-12 bg-white border-t border-[hsl(var(--border))]">
      <div className="container mx-auto px-4 max-w-[1140px]">
        <div className="text-center mb-8">
          <h3 className="text-lg font-semibold text-[hsl(var(--postal-slate))] mb-2 font-poppins">
            Authorized Dealer
          </h3>
          <p className="text-sm text-[hsl(var(--muted-foreground))] font-inter">
            We work with leading mailbox manufacturers
          </p>
        </div>
        
        <div className="flex flex-wrap justify-center items-center gap-8 opacity-60">
          {manufacturers.map((manufacturer, index) => (
            <div 
              key={index}
              className="manufacturer-logo flex items-center justify-center h-12 px-6"
              aria-label={manufacturer.alt}
            >
              <div className="text-[hsl(var(--postal-slate))] font-semibold text-sm font-inter">
                {manufacturer.name}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default ManufacturerLogos;