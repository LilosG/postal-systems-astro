import { Mail } from 'lucide-react'

export default function Footer() {
  return (
    <footer className="border-t">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8 text-sm opacity-70 flex items-center justify-between">
        <span>© {new Date().getFullYear()} San Diego Commercial Mailbox. All rights reserved.</span>
        <a href="mailto:info@example.com" className="inline-flex items-center gap-2">
          <Mail className="h-4 w-4" />
          info@example.com
        </a>
      </div>
    </footer>
  )
}
