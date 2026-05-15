import type { Metadata } from "next";
import { Inter, Space_Grotesk, JetBrains_Mono } from "next/font/google";
import TopNav from "@/components/TopNav";
import "./globals.css";
import Script from "next/script";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  variable: "--font-space-grotesk",
  display: "swap",
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains-mono",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Crucible",
    template: "%s · Crucible",
  },
  description:
    "High-performance C++ benchmarking. Naive vs tuned, real hardware measurements, visualised system behaviour.",
  metadataBase: new URL("https://crucible.garethcooke.com"),
  openGraph: {
    siteName: "Crucible",
    locale: "en_GB",
    type: "website",
  },
};

// Prevents flash of wrong theme on load by setting the class before React hydrates.
const themeInitScript = `try{var t=localStorage.getItem('theme')||'dark';document.documentElement.classList.add(t);}catch(e){document.documentElement.classList.add('dark');}`;

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${spaceGrotesk.variable} ${jetbrainsMono.variable}`}
    >
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeInitScript }} />
      </head>
      <body>
        <TopNav />
        <main className="max-w-4xl mx-auto px-6 py-12">{children}</main>
        <footer className="site-footer">
          <div className="max-w-4xl mx-auto px-6 py-8 flex items-center justify-between text-sm">
            <span>Crucible · MIT</span>
            <a
              href="https://garethcooke.com"
              target="_blank"
              rel="noopener noreferrer"
            >
              garethcooke.com
            </a>
          </div>
        </footer>
        <Script
          defer
          src="https://cloud.umami.is/script.js"
          data-website-id="13c87896-c09b-4150-b659-600faf29b575"
          strategy="afterInteractive"
        />{" "}
      </body>{" "}
    </html>
  );
}
