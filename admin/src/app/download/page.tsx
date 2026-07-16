'use client';
import { Smartphone, Star, Search, Heart, Info } from "lucide-react";

export default function DownloadPage() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4"
      style={{ background: "linear-gradient(135deg, #0D1117 0%, #161B22 100%)" }}>
      
      {/* Card */}
      <div className="w-full max-w-lg rounded-3xl p-8 border"
        style={{ background: "#161B22", borderColor: "#30363D" }}>

        {/* Header */}
        <div className="text-center mb-8">
          <div className="mx-auto w-24 h-24 rounded-full flex items-center justify-center mb-5"
            style={{ background: "rgba(0,230,118,0.10)", boxShadow: "0 0 30px rgba(0,230,118,0.25)", border: "2px solid #00E676" }}>
            <Smartphone className="w-12 h-12" style={{ color: "#00E676" }} />
          </div>
          <h1 className="text-3xl font-bold mb-2" style={{ color: "#FFFFFF" }}>
            GTEC Canteen App
          </h1>
          <p className="text-base" style={{ color: "#8B949E" }}>
            The official Pure Veg canteen app for students of<br />
            <span style={{ color: "#00E676", fontWeight: 600 }}>Ganadipathy Tulsi Engineering College</span>
          </p>
        </div>

        {/* Feature Pills */}
        <div className="grid grid-cols-2 gap-3 mb-8">
          {[
            { icon: <Search className="w-4 h-4" />, label: "Live Menu & Search" },
            { icon: <Heart className="w-4 h-4" />, label: "Save Favourites" },
            { icon: <Star className="w-4 h-4" />, label: "User Reviews" },
            { icon: <Smartphone className="w-4 h-4" />, label: "Real-time Updates" },
          ].map((f) => (
            <div key={f.label} className="flex items-center gap-2 rounded-xl px-3 py-2"
              style={{ background: "#21262D", border: "1px solid #30363D" }}>
              <span style={{ color: "#00E676" }}>{f.icon}</span>
              <span className="text-sm font-medium" style={{ color: "#FFFFFF" }}>{f.label}</span>
            </div>
          ))}
        </div>

        {/* Info Note */}
        <div className="rounded-xl p-4 mb-6 flex gap-3"
          style={{ background: "rgba(0,230,118,0.08)", border: "1px solid rgba(0,230,118,0.25)" }}>
          <Info className="w-5 h-5 mt-0.5 flex-shrink-0" style={{ color: "#00E676" }} />
          <div className="text-sm" style={{ color: "#8B949E" }}>
            <span style={{ color: "#00E676", fontWeight: 700 }}>Available everywhere.</span> Android uses native APK. iOS, Windows, and Mac use our instant Web App.
          </div>
        </div>

        {/* Download Buttons */}
        <div className="flex flex-col gap-4">
          <a
            href="https://raw.githubusercontent.com/jayasurya123bn-debug/GTEC-CANTEEN-COLLEGE/main/releases/GTEC_Canteen_App.apk"
            download="GTEC_Canteen_App.apk"
            className="block w-full"
          >
            <button
              className="w-full flex items-center justify-center gap-3 h-14 text-base font-bold rounded-xl transition-all duration-200 cursor-pointer"
              style={{
                background: "#00E676",
                color: "#0D1117",
                boxShadow: "0 0 20px rgba(0,230,118,0.30)",
              }}
              onMouseOver={(e) => {
                (e.currentTarget as HTMLButtonElement).style.transform = "scale(1.02)";
              }}
              onMouseOut={(e) => {
                (e.currentTarget as HTMLButtonElement).style.transform = "scale(1)";
              }}
            >
              <Smartphone className="w-5 h-5" />
              Download APK (Android)
            </button>
          </a>

          <a href="/app" className="block w-full">
            <button
              className="w-full flex items-center justify-center gap-3 h-14 text-base font-bold rounded-xl transition-all duration-200 cursor-pointer"
              style={{
                background: "#21262D",
                color: "#FFFFFF",
                border: "1px solid #30363D",
              }}
              onMouseOver={(e) => {
                (e.currentTarget as HTMLButtonElement).style.transform = "scale(1.02)";
              }}
              onMouseOut={(e) => {
                (e.currentTarget as HTMLButtonElement).style.transform = "scale(1)";
              }}
            >
              <Smartphone className="w-5 h-5" />
              Download for iOS (Web App)
            </button>
          </a>

          <div className="grid grid-cols-2 gap-4">
            <a href="/app" className="block w-full">
              <button
                className="w-full flex items-center justify-center gap-2 h-12 text-sm font-bold rounded-xl transition-all duration-200 cursor-pointer"
                style={{
                  background: "#21262D",
                  color: "#FFFFFF",
                  border: "1px solid #30363D",
                }}
                onMouseOver={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = "#30363D";
                }}
                onMouseOut={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = "#21262D";
                }}
              >
                Download for Windows
              </button>
            </a>
            
            <a href="/app" className="block w-full">
              <button
                className="w-full flex items-center justify-center gap-2 h-12 text-sm font-bold rounded-xl transition-all duration-200 cursor-pointer"
                style={{
                  background: "#21262D",
                  color: "#FFFFFF",
                  border: "1px solid #30363D",
                }}
                onMouseOver={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = "#30363D";
                }}
                onMouseOut={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = "#21262D";
                }}
              >
                Download for Mac
              </button>
            </a>
          </div>
        </div>

        <p className="text-center text-xs mt-4" style={{ color: "#484F58" }}>
          Latest version · Pure Veg · No ordering required
        </p>
      </div>

      <p className="mt-6 text-sm text-center" style={{ color: "#484F58" }}>
        © Ganadipathy Tulsi Engineering College · GTEC Pure Veg Canteen
      </p>
    </div>
  );
}
