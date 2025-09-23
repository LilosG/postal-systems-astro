import { Mail, Facebook, Twitter, Linkedin } from 'lucide-react';

const Footer = () => {
  const quickLinks = [
    { href: '#services', label: 'Services' },
    { href: '#industries', label: 'Industries' },
    { href: '#why-us', label: 'Why Us' },
    { href: '#projects', label: 'Projects' },
    { href: '#process', label: 'Process' },
    { href: '#faq', label: 'FAQ' },
  ];

  return (
    <footer className="bg-[hsl(var(--postal-slate))] text-white py-8">
      <div className="container mx-auto px-4">
        <div className="flex flex-col lg:flex-row justify-between items-center gap-6">
          {/* Left: Logo & USPS */}
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-gradient-to-br from-[hsl(var(--postal-navy))] to-[hsl(var(--postal-red))] rounded-lg flex items-center justify-center">
              <Mail className="w-5 h-5 text-white" />
            </div>
            <div>
              <h3 className="text-lg font-bold">Postal Systems</h3>
              <p className="text-xs text-gray-300 -mt-1">USPS-Approved Installation</p>
            </div>
          </div>

          {/* Center: Compact Nav */}
          <div className="flex flex-wrap justify-center gap-x-6 gap-y-2">
            {quickLinks.map((link, index) => (
              <a 
                key={index}
                href={link.href}
                className="text-gray-300 hover:text-white transition-colors text-sm"
              >
                {link.label}
              </a>
            ))}
          </div>

          {/* Right: License & Service Area */}
          <div className="text-center lg:text-right">
            <p className="text-sm text-gray-300">CSLB #904106</p>
            <p className="text-xs text-gray-400">San Diego County</p>
          </div>
        </div>
        
        {/* Copyright Line */}
        <div className="border-t border-gray-600 mt-6 pt-4 text-center">
          <p className="text-xs text-gray-400">© 2024 Postal Systems. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;