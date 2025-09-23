import Header from '../components/Header';
import Hero from '../components/Hero';
import Services from '../components/Services';
import Industries from '../components/Industries';
import WhyChooseUs from '../components/WhyChooseUs';
import FeaturedProjects from '../components/FeaturedProjects';
import Process from '../components/Process';
import FAQ from '../components/FAQ';
import CTABand from '../components/CTABand';
import Contact from '../components/Contact';
import ManufacturerLogos from '../components/ManufacturerLogos';
import Footer from '../components/Footer';
import MobileCTABar from '../components/MobileCTABar';

const Index = () => {
  return (
    <div className="min-h-screen">
      <Header />
      <main>
        <Hero />
        <Services />
        <Industries />
        <WhyChooseUs />
        <FeaturedProjects />
        <Process />
        <FAQ />
        <CTABand />
        <Contact />
        <ManufacturerLogos />
      </main>
      <Footer />
      <MobileCTABar />
    </div>
  );
};

export default Index;
