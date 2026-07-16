'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { Leaf } from 'lucide-react';
import toast from 'react-hot-toast';
import { useAuth } from '../../context/AuthContext';
import api from '../../lib/api';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const { login } = useAuth();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await api.post('/auth/login', { email, password });
      if (res.data.user.role !== 'admin') {
        toast.error('Access denied. Admin only.');
        setLoading(false);
        return;
      }
      login(res.data.accessToken, res.data.user);
      toast.success('Login successful');
      router.push('/');
    } catch (error: any) {
      toast.error(error.response?.data?.error || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen relative flex items-center justify-center bg-[#0D1117]">
      {/* Background Banner */}
      <div className="absolute inset-0 z-0">
        <Image 
          src="http://www.gtec.ac.in/images/college/1.jpg"
          alt="Campus Banner"
          layout="fill"
          objectFit="cover"
          priority
        />
        <div className="absolute inset-0 bg-[#0D1117]/80 backdrop-blur-sm"></div>
      </div>

      {/* Login Card */}
      <div className="relative z-10 w-full max-w-md bg-card rounded-2xl shadow-2xl overflow-hidden border border-border">
        <div className="p-8 text-center bg-elevated border-b border-border">
          <div className="flex justify-center mb-4">
            <div className="w-16 h-16 relative bg-card rounded-full p-1 shadow-sm border border-primary flex items-center justify-center overflow-hidden">
              <Image 
                src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrTnuNmoXMfrv2kq0V8mxmPXDzx00wQFxedgi9ixZyRA&s=10"
                alt="GTEC Logo"
                layout="fill"
                objectFit="cover"
              />
            </div>
          </div>
          <h2 className="text-2xl font-bold text-white">Admin Login</h2>
          <p className="text-primary font-medium mt-1 flex items-center justify-center">
            <Leaf size={16} className="mr-1" /> Pure Veg Canteen
          </p>
        </div>

        <form onSubmit={handleLogin} className="p-8 space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">Email Address</label>
            <input 
              type="email" 
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 rounded-lg border border-border bg-background text-white focus:ring-2 focus:ring-primary focus:border-primary transition-colors placeholder-gray-600"
              placeholder="admin@gtec.ac.in"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">Password</label>
            <input 
              type="password" 
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 rounded-lg border border-border bg-background text-white focus:ring-2 focus:ring-primary focus:border-primary transition-colors placeholder-gray-600"
              placeholder="••••••••"
            />
          </div>
          <button 
            type="submit"
            disabled={loading}
            className="w-full bg-primary hover:bg-[#00C853] text-[#0D1117] font-bold py-3 px-4 rounded-lg transition-colors flex justify-center items-center"
            style={{ boxShadow: "0 0 20px rgba(0,230,118,0.3)" }}
          >
            {loading ? 'Authenticating...' : 'Sign In to Dashboard'}
          </button>
        </form>
      </div>
    </div>
  );
}
