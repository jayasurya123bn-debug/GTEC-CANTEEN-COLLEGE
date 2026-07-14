import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Download, Smartphone } from "lucide-react";
import Link from "next/link";

export default function DownloadPage() {
  return (
    <div className="min-h-screen bg-green-50 flex flex-col items-center justify-center p-4">
      <Card className="w-full max-w-md shadow-xl border-green-100">
        <CardHeader className="text-center space-y-4">
          <div className="mx-auto bg-green-100 w-24 h-24 rounded-full flex items-center justify-center mb-4">
            <Smartphone className="w-12 h-12 text-green-600" />
          </div>
          <CardTitle className="text-3xl font-bold text-green-900">GTEC Canteen App</CardTitle>
          <CardDescription className="text-lg">
            Download the official student app to view the live menu, order food, and get real-time updates!
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="bg-white p-4 rounded-lg border border-gray-100 text-sm text-gray-600 text-center">
            <strong>Note for Android Users:</strong><br />
            When installing the APK, your phone might ask for permission to "Install from Unknown Sources". Please allow this to install the GTEC app.
          </div>
          
          <Link href="/gtec-canteen.apk" download className="w-full block">
            <Button className="w-full h-16 text-lg rounded-xl bg-green-600 hover:bg-green-700 shadow-lg transition-transform hover:scale-105">
              <Download className="mr-2 h-6 w-6" />
              Download APK Now
            </Button>
          </Link>
        </CardContent>
      </Card>
      
      <p className="mt-8 text-gray-500 text-sm text-center">
        Powered by Ganadipathy Tulsi Engineering College
      </p>
    </div>
  );
}
