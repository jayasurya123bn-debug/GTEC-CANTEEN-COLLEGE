import { Download, Smartphone } from "lucide-react";
import Link from "next/link";

export default function DownloadPage() {
  return (
    <div className="min-h-screen bg-green-50 flex flex-col items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-green-100 p-8">
        <div className="text-center space-y-4">
          <div className="mx-auto bg-green-100 w-24 h-24 rounded-full flex items-center justify-center mb-4">
            <Smartphone className="w-12 h-12 text-green-600" />
          </div>
          <h1 className="text-3xl font-bold text-green-900">GTEC Canteen App</h1>
          <p className="text-lg text-gray-600">
            Download the official student app to view the live menu, order food, and get real-time updates!
          </p>
        </div>
        
        <div className="space-y-6 mt-8">
          <div className="bg-blue-50 p-4 rounded-lg border border-blue-100 text-sm text-blue-800 text-center">
            <strong>Note for Android Users:</strong><br />
            When installing the APK, your phone might ask for permission to "Install from Unknown Sources". Please allow this to install the GTEC app.
          </div>
          
          <a href="https://raw.githubusercontent.com/jayasurya123bn-debug/GTEC-CANTEEN-COLLEGE/main/admin/public/gtec-canteen.apk" download="gtec-canteen.apk" className="w-full block">
            <button className="w-full flex items-center justify-center h-16 text-lg font-bold text-white rounded-xl bg-green-600 hover:bg-green-700 shadow-lg transition-transform hover:scale-105 cursor-pointer">
              <Download className="mr-2 h-6 w-6" />
              Download APK Now
            </button>
          </a>
        </div>
      </div>
      
      <p className="mt-8 text-gray-500 text-sm text-center">
        Powered by Ganadipathy Tulsi Engineering College
      </p>
    </div>
  );
}
